import ballerina/http;
import wso2/data_model;
import ballerinax/mysql;
import ballerina/sql;
import ballerinax/mysql.driver as _;
import ballerina/time;
import ballerina/uuid;

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

# A service representing a network-accessible API
# bound to port `9098`.
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://www.m3.com", "http://www.hello.com", "https://localhost:3000"],
        allowCredentials: false,
        allowHeaders: ["CORELATION_ID"],
        exposeHeaders: ["X-CUSTOM-HEADER", "Authorization"],
        maxAge: 84900
    }
}
service /contestService on new http:Listener(9098) {

    @http:ResourceConfig {
        cors: {
            allowOrigins: ["http://www.m3.com", "http://www.hello.com", "https://localhost:3000"],
            allowCredentials: true,
            allowHeaders: ["X-Content-Type-Options", "X-PINGOTHER", "Authorization", "Content-type"]
        }
    }
    resource function get contests/[string contestId]() returns data_model:Contest| http:InternalServerError|http:STATUS_NOT_FOUND {

        data_model:Contest|sql:Error contest = getContest(contestId);

        if contest is sql:Error {
            if contest is sql:NoRowsError {
                return http:STATUS_NOT_FOUND;
            }
            return http:INTERNAL_SERVER_ERROR;
        }

        return contest;
    }

    @http:ResourceConfig {
        cors: {
            allowOrigins: ["http://www.m3.com", "http://www.hello.com", "https://localhost:3000"],
            allowCredentials: true,
            allowHeaders: ["X-Content-Type-Options", "X-PINGOTHER", "Authorization"]
        }
    }
    resource function get contests/status/[string status]() returns data_model:Contest[]|http:InternalServerError|http:STATUS_NOT_FOUND {
        
        data_model:Contest[]|sql:Error|error? contestsWithStatus = getContestsWithStatus(status);
        if contestsWithStatus is data_model:Contest[] {
            return contestsWithStatus;

        } else if contestsWithStatus is sql:Error? {
            return http:INTERNAL_SERVER_ERROR;

        } else if contestsWithStatus is error {
            return http:STATUS_NOT_FOUND;
        }


    }

    @http:ResourceConfig {
        cors: {
            allowOrigins: ["http://www.m3.com", "http://www.hello.com", "https://localhost:3000"],
            allowCredentials: true,
            allowHeaders: ["X-Content-Type-Options", "X-PINGOTHER", "Authorization"]
        }
    }
    resource function get contests/[string contestId]/challenges () returns string[]|http:InternalServerError {
        string[]|sql:Error? contestChallenges = getContestChallenges(contestId);
        if contestChallenges is string[] {
            return contestChallenges;
        } else if contestChallenges is sql:Error {
            return http:INTERNAL_SERVER_ERROR;
        } else {
            // FIXME
            return http:INTERNAL_SERVER_ERROR;
        }


    }

    @http:ResourceConfig {
        cors: {
            allowOrigins: ["http://www.m3.com", "http://www.hello.com", "https://localhost:3000"],
            allowCredentials: true,
            allowHeaders: ["X-Content-Type-Options", "X-PINGOTHER", "Authorization", "Content-type"]
        }
    }
    resource function post contests (@http:Payload NewContest newContest) returns string|int?|http:InternalServerError{
        string generatedContestId = "contest_" + uuid:createType1AsString();
        data_model:Contest newContestToAdd = {
                                                 contestId : generatedContestId,
                                                 title: newContest.title,
                                                 description: newContest.description,
                                                 startTime: newContest.startTime,
                                                 endTime: newContest.endTime,
                                                 moderator: newContest.moderator
                                            };

        string|int|sql:Error? contest = addContest(newContestToAdd);

        if contest is sql:Error {
            return http:INTERNAL_SERVER_ERROR;
        }

        return contest;

    }

    @http:ResourceConfig {
        cors: {
            allowOrigins: ["http://www.m3.com", "http://www.hello.com", "https://localhost:3000"],
            allowCredentials: true,
            allowHeaders: ["X-Content-Type-Options", "X-PINGOTHER", "Authorization", "Content-type"]
        }
    }
    resource function post contests/[string contestId]/challenges/[string challengeId] () returns string|int?|http:InternalServerError {
        string|int|sql:Error? challengeToContest = addChallengeToContest(contestId, challengeId);
        
        if challengeToContest is sql:Error {
            return http:INTERNAL_SERVER_ERROR;
        }

        return challengeToContest;

    }

    @http:ResourceConfig {
        cors: {
            allowOrigins: ["http://www.m3.com", "http://www.hello.com", "https://localhost:3000"],
            allowCredentials: true,
            allowHeaders: ["X-Content-Type-Options", "X-PINGOTHER", "Authorization", "Content-type"]
        }
    }
    resource function put contests/[string contestId](@http:Payload UpdatedContest toBeUpdatedContest) returns UpdatedContest|http:InternalServerError|http:STATUS_NOT_FOUND {
        error? updatedContest = updateContest(contestId, toBeUpdatedContest);
        if updatedContest is error {
            if updatedContest is sql:Error {
                return http:INTERNAL_SERVER_ERROR;
            }
            return http:STATUS_NOT_FOUND;
        }
        toBeUpdatedContest["contestId"] = contestId;
        return toBeUpdatedContest;
    }

    @http:ResourceConfig {
        cors: {
            allowOrigins: ["http://www.m3.com", "http://www.hello.com", "https://localhost:3000"],
            allowCredentials: true,
            allowHeaders: ["X-Content-Type-Options", "X-PINGOTHER", "Authorization", "Content-type"]
        }
    }
    resource function delete contests/[string contestId]() returns http:InternalServerError|http:STATUS_NOT_FOUND| http:STATUS_OK {
        error? contest = deleteContest(contestId);
        if contest is error {
            if contest is sql:Error {
                return http:INTERNAL_SERVER_ERROR;
            }
            return http:STATUS_NOT_FOUND;
        }

        return http:STATUS_OK;

    }

    @http:ResourceConfig {
        cors: {
            allowOrigins: ["http://www.m3.com", "http://www.hello.com", "https://localhost:3000"],
            allowCredentials: true,
            allowHeaders: ["X-Content-Type-Options", "X-PINGOTHER", "Authorization", "Content-type"]
        }
    }
    resource function delete contests/[string contestId]/challenges/[string challengeId] () returns http:InternalServerError|http:STATUS_NOT_FOUND| http:STATUS_OK{
        string|int?|sql:Error challengeFromContest = deleteChallengeFromContest(contestId, challengeId);
        
        if challengeFromContest is sql:Error {
            return http:INTERNAL_SERVER_ERROR;
        }

        return http:STATUS_OK;

    }
}

function addChallengeToContest(string contestId, string challengeId) returns string|int|sql:Error? {
    final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);

    sql:ExecutionResult execRes = check dbClient->execute(`
        INSERT INTO contest_challenge (contest_id, challenge_id) VALUES (${contestId}, ${challengeId});
    `);
    check dbClient.close();
    return execRes.lastInsertId;
}

function deleteChallengeFromContest(string contestId, string challengeId) returns string|int?|sql:Error? {
    final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);
    sql:ExecutionResult execRes = check dbClient->execute(`
        DELETE FROM contest_challenge WHERE contest_id = ${contestId} AND challenge_id = ${challengeId};
    `);
    check dbClient.close();
    return execRes.lastInsertId;
}

function deleteContest(string contestId) returns error? {
    final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);
    sql:ExecutionResult execRes = check dbClient->execute(`
        DELETE FROM contest WHERE contest_id = ${contestId} AND CURRENT_TIMESTAMP() <= start_time;
    `);
    if execRes.affectedRowCount == 0 {
        return error("INVALID CONTEST_ID OR CONTEST IS ONGOING OR ENDED.");
    }
    check dbClient.close();
    return;
}

function getContestChallenges(string contestId) returns string[]|sql:Error? {
    final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);
    
    stream<ChallengeId,sql:Error?> result = dbClient->query(`SELECT challenge_id FROM contest_challenge WHERE contest_id = ${contestId};`);
    check dbClient.close();

    string[]|sql:Error? listOfChallengeIds = from ChallengeId challengeId in result select challengeId.challengeId;

    return listOfChallengeIds;
}

function updateContest(string contestId, UpdatedContest toBeUpdatedContest) returns error?{
    final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);
    sql:ExecutionResult execRes = check dbClient->execute(`
        UPDATE contest SET title = ${toBeUpdatedContest.title}, start_time = ${toBeUpdatedContest.startTime}, end_time = ${toBeUpdatedContest.endTime}, moderator = ${toBeUpdatedContest.moderator} WHERE contest_id = ${contestId};
    `);
    if execRes.affectedRowCount == 0 {
        return error("INVALID CONTEST_ID.");
    }
    check dbClient.close();
    return;
}

function getContestsWithStatus(string status) returns data_model:Contest[]|sql:Error|error? {
    final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);
    sql:ParameterizedQuery query = ``;
    if status.equalsIgnoreCaseAscii("future") {
        query = `SELECT * FROM contest WHERE CURRENT_TIMESTAMP() <= start_time;`;
    } else if status.equalsIgnoreCaseAscii("present"){
        query = `SELECT * FROM contest WHERE CURRENT_TIMESTAMP() BETWEEN start_time AND end_time;`;
    } else if status.equalsIgnoreCaseAscii("past") {
        query = `SELECT * FROM contest WHERE CURRENT_TIMESTAMP() >= end_time;`;
    } else {
        return error("INVALID STATUS!!");
    }
    stream<data_model:Contest,sql:Error?> result = dbClient->query(query);
    check dbClient.close();

    data_model:Contest[]|sql:Error? listOfContests = from data_model:Contest contest in result select contest;

    return listOfContests;
}

function addContest(data_model:Contest newContest) returns string|int|sql:Error? {
    final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);

    string generatedContestId = "contest-" + uuid:createType1AsString();

    sql:ExecutionResult execRes = check dbClient->execute(`
        INSERT INTO contest (contest_id, title, start_time, end_time, moderator) VALUES (${generatedContestId},${newContest.title}, ${newContest.startTime}, ${newContest.endTime}, ${newContest.moderator});
    `);
    check dbClient.close();
    return execRes.lastInsertId;
}

function getContest(string contestId) returns data_model:Contest|sql:Error {
    final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);
    data_model:Contest|sql:Error result = dbClient->queryRow(`SELECT * FROM contest WHERE contest_id = ${contestId}`);
    check dbClient.close();
    return result;
}