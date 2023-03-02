import ballerina/http;
import wso2/data_model;
import ballerinax/mysql;
import ballerina/sql;
import ballerinax/mysql.driver as _;
import ballerina/time;
import ballerina/uuid;
// import ballerina/io;
// import ballerina/io;
// import ballerina/mime;
// import ballerina/file;
// import ballerina/regex;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

type UpdatedContest record {
    string name;
    @sql:Column {name: "start_time"}
    time:Civil startTime;
    @sql:Column {name: "end_time"}
    time:Civil endTime;
    string moderator;
};

type ChallengeId record {
    @sql:Column {name: "challenge_id"}
    int challengeId;
};

# A service representing a network-accessible API
# bound to port `9090`.
service /contestService on new http:Listener(9090) {

    resource function get contest/[string contestId]() returns data_model:Contest|error? {
        
        data_model:Contest contest = check getContest(contestId);
        return contest;
    }

    resource function get contests/[string status]() returns data_model:Contest[]|error? {
        
        data_model:Contest[]|error? listOfContests = getContestsWithStatus(status);
        if listOfContests is error {
            if listOfContests.message().equalsIgnoreCaseAscii("INVALID STATUS!!") {
                return listOfContests;
            }
            return error("ERROR OCCURED");
        }
        return listOfContests;
    }

    resource function get contest/[string contestId]/challenges () returns error|int[]|sql:Error? {
        error|int[]|sql:Error? contestChallenges = getContestChallenges(contestId);
        if !(contestChallenges is int[]) {
            return error("DATABASE ERROR");
            // return contestChallenges;
        }

        return contestChallenges;
    }

    resource function post contest (@http:Payload data_model:Contest newContest) returns string|int|error?{
        string|int|error? contestId =  addContest(newContest);
        if contestId is error {
            return error("ERROR OCCURED, COULD NOT INSERT CONTEST");
        }
        return contestId;
    }

    resource function put contest/[string contestId](@http:Payload UpdatedContest toBeUpdatedContest) returns UpdatedContest|error {
        error? updatedContest = updateContest(contestId, toBeUpdatedContest);
        if updatedContest is error {
            if updatedContest.message().equalsIgnoreCaseAscii("INVALID CONTEST_ID.") {
                return updatedContest;
            }
            return error("DATABASE ERROR!");
        }
        toBeUpdatedContest["contestId"] = contestId;
        return toBeUpdatedContest;
    }

    resource function delete contest/[string contestId]() returns string|error {
        error? contest = deleteContest(contestId);
        if contest is error {
            if contest.message().equalsIgnoreCaseAscii("INVALID CONTEST_ID OR CONTEST IS ONGOING OR ENDED.") {
                return contest;
            }
            // return error("DATABASE ERROR");
            return contest;
        }

        return "DELETE SUCCESSFULL";
    }
}

function deleteContest(string contestId) returns error? {
    final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);
    sql:ExecutionResult execRes = check dbClient->execute(`
        DELETE FROM Contests WHERE contest_id = ${contestId} AND CURRENT_TIMESTAMP() <= start_time;
    `);
    if execRes.affectedRowCount == 0 {
        return error("INVALID CONTEST_ID OR CONTEST IS ONGOING OR ENDED.");
    }
    check dbClient.close();
    return;
}

function getContestChallenges(string contestId) returns error|int[]|sql:Error? {
    final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);
    
    stream<ChallengeId,sql:Error?> result = dbClient->query(`SELECT challenge_id FROM Contest_Challenge WHERE contest_id = ${contestId};`);
    check dbClient.close();

    int[]|sql:Error? listOfChallengeIds = from ChallengeId challengeId in result select challengeId.challengeId;

    return listOfChallengeIds;
}

function updateContest(string contestId, UpdatedContest toBeUpdatedContest) returns error?{
    final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);
    sql:ExecutionResult execRes = check dbClient->execute(`
        UPDATE Contests SET name = ${toBeUpdatedContest.name}, start_time = ${toBeUpdatedContest.startTime}, end_time = ${toBeUpdatedContest.endTime}, moderator = ${toBeUpdatedContest.moderator} WHERE contest_id = ${contestId};
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
        query = `SELECT * FROM Contests WHERE CURRENT_TIMESTAMP() <= start_time`;
    } else if status.equalsIgnoreCaseAscii("present"){
        query = `SELECT * FROM Contests WHERE CURRENT_TIMESTAMP() BETWEEN start_time AND end_time`;
    } else if status.equalsIgnoreCaseAscii("past") {
        query = `SELECT * FROM Contests WHERE CURRENT_TIMESTAMP() >= end_time`;
    } else {
        return error("INVALID STATUS!!");
    }
    stream<data_model:Contest,sql:Error?> result = dbClient->query(query);
    check dbClient.close();

    data_model:Contest[]|sql:Error? listOfContests = from data_model:Contest contest in result select contest;

    return listOfContests;
}

function addContest(data_model:Contest newContest) returns string|int?|error{
    final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);
    string generatedContestId = "contest-" + uuid:createType1AsString();

    sql:ExecutionResult execRes = check dbClient->execute(`
        INSERT INTO Contests (contest_id, name, start_time, end_time, moderator) VALUES (${generatedContestId},${newContest.name}, ${newContest.startTime}, ${newContest.endTime}, ${newContest.moderator});
    `);
    check dbClient.close();
    return execRes.lastInsertId;
}

function getContest(string contestId) returns data_model:Contest|sql:Error|error {
    final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);
    data_model:Contest|sql:Error result = dbClient->queryRow(`SELECT * FROM Contests WHERE contest_id = ${contestId}`);
    check dbClient.close();
    return result;
}