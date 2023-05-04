import ballerina/http;
import ballerinax/mysql;
import ballerina/sql;
import ballerinax/mysql.driver as _;
import ballerina/time;
import ballerina/uuid;
import ballerina/log;
import ballroom/data_model;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

type UpdatedContest record {
    string title;
    @sql:Column {name: "start_time"}
    time:Civil startTime;
    @sql:Column {name: "end_time"}
    time:Civil endTime;
    string moderator;
};

type ChallengeId record {
    @sql:Column {name: "challenge_id"}
    string challengeId;
};

type NewContest record {
    string title;
    string description;
    @sql:Column {name: "start_time"}
    time:Civil startTime;
    @sql:Column {name: "end_time"}
    time:Civil endTime;
    string moderator;
};

final mysql:Client db = check new (host = HOST, user = USER, password = PASSWORD, port = PORT, database = DATABASE);

# A service representing a network-accessible API
# bound to port `9098`.
# // TODO Remove this CORS config when the BFF is configured properly
@display {
    label: "Contest Service",
    id: "ContestService"
}
@http:ServiceConfig {
    cors: {
        allowOrigins: ["https://localhost:3000", "http://localhost:9099"],
        allowCredentials: true,
        allowHeaders: ["CORELATION_ID", "Authorization", "Content-Type", "ngrok-skip-browser-warning"],
        exposeHeaders: ["X-CUSTOM-HEADER"],
        maxAge: 84900
    }
}
service /contestService on new http:Listener(9098) {

    function init() {
        log:printInfo("Contest service started...");
    }

    resource function get contests/[string contestId]() returns data_model:Contest|http:InternalServerError|http:NotFound {
        data_model:Contest|sql:Error contest = getContest(contestId);
        if contest is sql:Error {
            if contest is sql:NoRowsError {
                return http:NOT_FOUND;
            }
            return http:INTERNAL_SERVER_ERROR;
        }

        return contest;
    }

    resource function get contests(string? status) returns data_model:Contest[]|http:InternalServerError|http:NotFound {
        log:printInfo("get contests by status invoked", status = status);
        data_model:Contest[]|sql:Error|error contestsWithStatus = getContestsWithStatus(status ?: "future");
        if contestsWithStatus is data_model:Contest[] {
            return contestsWithStatus;

        } else if contestsWithStatus is sql:Error? {
            return http:INTERNAL_SERVER_ERROR;

        } else if contestsWithStatus is error {
            return http:NOT_FOUND;
        }

    }

    resource function get contests/[string contestId]/challenges() returns string[]|http:InternalServerError {
        string[]|sql:Error contestChallenges = getContestChallenges(contestId);
        if contestChallenges is string[] {
            return contestChallenges;
        } else if contestChallenges is sql:Error {
            return http:INTERNAL_SERVER_ERROR;
        }
    }

    resource function post contests(@http:Payload NewContest newContest) returns string|int|http:InternalServerError|error {
        log:printInfo("POST contests invoked, REQ: " + newContest.toBalString());
        string generatedContestId = "contest_" + uuid:createType1AsString();
        data_model:Contest newContestToAdd = {
            contestId: generatedContestId,
            title: newContest.title,
            description: newContest.description,
            startTime: newContest.startTime,
            endTime: newContest.endTime,
            moderator: newContest.moderator
        };

        string|int|error contest = addContest(newContestToAdd);
        if contest is error {
            return http:INTERNAL_SERVER_ERROR;
        }

        return contest;
    }

    resource function post contests/[string contestId]/challenges/[string challengeId]() returns string|int|http:InternalServerError|error {
        string|int|sql:Error|error challengeToContest = addChallengeToContest(contestId, challengeId);

        if challengeToContest is sql:Error {
            if challengeToContest.message().includes("Duplicate entry", 0) {
                return error("Challenge already added to contest", message = "Duplicate entry");
            }
            return http:INTERNAL_SERVER_ERROR;
        }

        return challengeToContest;

    }

    resource function put contests/[string contestId](@http:Payload UpdatedContest toBeUpdatedContest) returns UpdatedContest|http:InternalServerError|http:NotFound {
        error? updatedContest = updateContest(contestId, toBeUpdatedContest);
        if updatedContest is error {
            if updatedContest is sql:Error {
                return http:INTERNAL_SERVER_ERROR;
            }
            return http:NOT_FOUND;
        }
        toBeUpdatedContest["contestId"] = contestId;
        return toBeUpdatedContest;
    }

    resource function delete contests/[string contestId]() returns http:InternalServerError|http:NotFound|http:Ok {
        error? contest = deleteContest(contestId);
        if contest is error {
            if contest is sql:Error {
                return http:INTERNAL_SERVER_ERROR;
            }
            return http:NOT_FOUND;
        }

        return http:OK;

    }

    resource function delete contests/[string contestId]/challenges/[string challengeId]() returns http:InternalServerError|http:NotFound|http:Ok {
        string|int|sql:Error|error challengeFromContest = deleteChallengeFromContest(contestId, challengeId);
        if challengeFromContest is sql:Error {
            return http:INTERNAL_SERVER_ERROR;
        }

        return http:OK;
    }
}

function addChallengeToContest(string contestId, string challengeId) returns string|int|error {
    sql:ExecutionResult execRes = check db->execute(`
        INSERT INTO contest_challenge (contest_id, challenge_id) VALUES (${contestId}, ${challengeId});
    `);
    string|int? lastInsertId = execRes.lastInsertId;
    if lastInsertId is () {
        return error("Datbase does not support lastInsertId.");
    } else {
        return lastInsertId;
    }
}

function deleteChallengeFromContest(string contestId, string challengeId) returns string|int|error {
    sql:ExecutionResult execRes = check db->execute(`
        DELETE FROM contest_challenge WHERE contest_id = ${contestId} AND challenge_id = ${challengeId};
    `);
    string|int? lastInsertId = execRes.lastInsertId;
    if lastInsertId is () {
        return error("Datbase does not support lastInsertId.");
    } else {
        return lastInsertId;
    }
}

function deleteContest(string contestId) returns error? {
    sql:ExecutionResult execRes = check db->execute(`
        DELETE FROM contest WHERE contest_id = ${contestId} AND CURRENT_TIMESTAMP() <= start_time;
    `);
    if execRes.affectedRowCount == 0 {
        return error("INVALID CONTEST_ID OR CONTEST IS ONGOING OR ENDED.");
    }
    return;
}

function getContestChallenges(string contestId) returns string[]|sql:Error {
    stream<ChallengeId, sql:Error?> result = db->query(`SELECT challenge_id FROM contest_challenge WHERE contest_id = ${contestId};`);
    string[]|sql:Error listOfChallengeIds = from ChallengeId challengeId in result
        select challengeId.challengeId;

    return listOfChallengeIds;
}

function updateContest(string contestId, UpdatedContest toBeUpdatedContest) returns error? {
    sql:ExecutionResult execRes = check db->execute(`
        UPDATE contest SET title = ${toBeUpdatedContest.title}, start_time = ${toBeUpdatedContest.startTime}, end_time = ${toBeUpdatedContest.endTime}, moderator = ${toBeUpdatedContest.moderator} WHERE contest_id = ${contestId};
    `);
    if execRes.affectedRowCount == 0 {
        return error("INVALID CONTEST_ID.");
    }
    return;
}

function getContestsWithStatus(string status) returns data_model:Contest[]|sql:Error|error {
    sql:ParameterizedQuery query = ``;
    if status.equalsIgnoreCaseAscii("future") {
        query = `SELECT * FROM contest WHERE CURRENT_TIMESTAMP() <= start_time;`;
    } else if status.equalsIgnoreCaseAscii("present") {
        query = `SELECT * FROM contest WHERE CURRENT_TIMESTAMP() BETWEEN start_time AND end_time;`;
    } else if status.equalsIgnoreCaseAscii("past") {
        query = `SELECT * FROM contest WHERE CURRENT_TIMESTAMP() >= end_time;`;
    } else {
        return error("INVALID STATUS!!");
    }
    stream<data_model:Contest, sql:Error?> result = db->query(query);

    data_model:Contest[]|sql:Error listOfContests = from data_model:Contest contest in result
        select contest;

    return listOfContests;
}

function addContest(data_model:Contest newContest) returns string|int|error {
    sql:ExecutionResult _ = check db->execute(`
        INSERT INTO contest (contest_id, title, description, start_time, end_time, moderator) VALUES (${newContest.contestId},${newContest.title}, ${newContest.description}, ${newContest.startTime}, ${newContest.endTime}, ${newContest.moderator});
    `);
    string lastInsertId = newContest.contestId;
    return lastInsertId;
}

function getContest(string contestId) returns data_model:Contest|sql:Error {
    data_model:Contest|sql:Error result = db->queryRow(`SELECT * FROM contest WHERE contest_id = ${contestId}`);
    return result;
}
