import ballerina/http;
import samjs/ballroom.data_model;
import ballerinax/mysql;
import ballerina/sql;
import ballerinax/mysql.driver as _;
import ballerina/io;
import ballerina/mime;
import ballerina/regex;
import ballerina/uuid;
import ballerina/log;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

type UpdatedChallenge record {
    string title;
    string description;
    string constraints;
    string difficulty;
};

final mysql:Client db = check new (host = HOST, user = USER, password = PASSWORD, port = PORT, database = DATABASE);

# A service representing a network-accessible API
# bound to port `9096`.
@display {
    label: "Challenge Service",
    id: "ChallengeService"
}
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://www.m3.com", "http://www.hello.com", "https://localhost:3000"],
        allowCredentials: true,
        allowHeaders: ["CORELATION_ID", "Authorization", "Content-Type"],
        exposeHeaders: ["X-CUSTOM-HEADER"],
        maxAge: 84900
    }
}
service /challengeService on new http:Listener(9096) {

    function init() {
        log:printInfo("Challenge service started...");
    }

    resource function get challenges/[string challengeId]() returns data_model:Challenge|error {
        data_model:Challenge challenge = check getChallenge(challengeId);
        return challenge;
    }

    resource function get challenges(string difficulty) returns data_model:Challenge[]|error {
        data_model:Challenge[] challengesWithDifficulty = check getChallengesWithDifficulty(difficulty);
        return challengesWithDifficulty;
    }

    // OpenAPI Tool Bug:https://github.com/ballerina-platform/openapi-tools/issues/1314  returns byte[]|error
    resource function get challenges/[string challengeId]/template() returns @http:Payload {mediaType: "application/octet-stream"} http:Response|error {

        byte[] testCaseFileBlob = check db->queryRow(
            `SELECT challenge_template FROM challenge WHERE challenge_id = ${challengeId}`
        );

        http:Response response = new;
        response.setBinaryPayload(testCaseFileBlob);
        return response;
    }

    
    resource function post challenges(http:Request request) returns string|int|error {
        io:println("RECVD REQ");
        mime:Entity[] bodyParts = check request.getBodyParts();
        io:println(request.getContentType());

        data_model:Challenge newChallenge = {title: "", challengeId: "", description: "", difficulty: "HARD", testCase: [], template: [], constraints: ""};

        string fileName = "testCaseFile";
        string templateFileName = "templateFile";
        foreach mime:Entity item in bodyParts {
            // check if the body part is a zipped file or normal text
            io:print("content ytpy eis ...");
            io:println(item.getContentType());
            if item.getContentType().length() == 0 {
                string contentDispositionString = item.getContentDisposition().toString();
                // get the relevant key for the value provided
                string[] keyArray = regex:split(contentDispositionString, "name=\"");
                string key = regex:replaceAll(keyArray[1], "\"", "");
                newChallenge[key] = check item.getText();
            }
            // body part is a zipped file
            else {
                string key = item.getContentDisposition().name;
                stream<byte[], io:Error?> streamer = check item.getByteStream();
                if key.equalsIgnoreCaseAscii("testCase") {
                    io:Error? fileWriteBlocksFromStream = io:fileWriteBlocksFromStream("/tmp/" + fileName + ".zip", streamer);
                } else {
                    io:Error? fileWriteBlocksFromStream = io:fileWriteBlocksFromStream("/tmp/" + templateFileName + ".zip", streamer);
                }

                check streamer.close();
                io:println("------");
            }

        }

        byte[] & readonly fileReadBytes = check io:fileReadBytes("/tmp/" + fileName + ".zip");
        byte[] & readonly templateFileReadBytes = check io:fileReadBytes("/tmp/" + templateFileName + ".zip");
        string|int challengeId = check addChallenge(newChallenge, fileReadBytes, templateFileReadBytes, fileName, ".zip");
        return challengeId;

    }

    // TODO: Why are we returning a string here?
    // TODO: Shouldn't they be errors?
    resource function put challenges/[string challengeId](UpdatedChallenge updatedChallenge) returns UpdatedChallenge|string|error {
        error? challenge = updateChallenge(challengeId, updatedChallenge);
        if challenge is error {
            if challenge.message().equalsIgnoreCaseAscii("INVALID CHALLENGE_ID.") {
                return "INVALID CHALLENGE_ID.";
            }
            return "DATABASE ERROR!";
        }
        updatedChallenge["challengeId"] = challengeId;
        return updatedChallenge;
    }

    resource function delete challenges/[string challengeId]() returns string {
        error? challenge = deleteChallenge(challengeId);
        if challenge is error {
            if challenge.message().equalsIgnoreCaseAscii("INVALID CHALLENGE_ID.") {
                return "INVALID CHALLENGE_ID.";
            }
            return "DATABASE ERROR!";
        }

        return "DELETE SUCCESSFULL";
    }
}

isolated function deleteChallenge(string challengeId) returns error? {
    sql:ExecutionResult execRes = check db->execute(`
        DELETE FROM challenge WHERE challenge_id = ${challengeId};
    `);
    if execRes.affectedRowCount == 0 {
        return error("INVALID CHALLENGE_ID.");
    }
    return;
}

isolated function updateChallenge(string challengeId, UpdatedChallenge updatedChallenge) returns error? {
    sql:ExecutionResult execRes = check db->execute(`
        UPDATE challenge SET title = ${updatedChallenge.title}, description = ${updatedChallenge.description}, constraints = ${updatedChallenge.constraints}, difficulty = ${updatedChallenge.difficulty} WHERE challenge_id = ${challengeId};
    `);
    if execRes.affectedRowCount == 0 {
        return error("INVALID CHALLENGE_ID.");
    }
    return;
}

isolated function addChallenge(data_model:Challenge newChallenge, byte[] testcaseFile, byte[] templateFile, string fileName, string fileExtension) returns string|int|error {
    string generatedChallengeId = "challenge-" + uuid:createType1AsString();

    sql:ExecutionResult execRes = check db->execute(`
        INSERT INTO challenge (challenge_id, title, description, constraints, difficulty, testcase, challenge_template) VALUES (${generatedChallengeId},${newChallenge.title}, ${newChallenge.description}, ${newChallenge.constraints}, ${newChallenge.difficulty}, ${testcaseFile}, ${templateFile})
    `);
    string|int? lastInsertId = execRes.lastInsertId;
    if lastInsertId is () {
        return error("DATABASE does not support last insert Id!");
    }
    return lastInsertId;
}

isolated function getChallenge(string challengeId) returns data_model:Challenge|sql:Error {
    data_model:Challenge|sql:Error result = db->queryRow(`SELECT * FROM challenge WHERE challenge_id = ${challengeId}`);
    return result;

}

isolated function getChallengesWithDifficulty(string difficulty) returns data_model:Challenge[]|sql:Error {
    stream<data_model:Challenge, sql:Error?> result = db->query(`SELECT * FROM challenge WHERE difficulty = ${difficulty}`);
    data_model:Challenge[]|sql:Error listOfChallenges = from data_model:Challenge challenge in result
        select challenge;

    return listOfChallenges;

}
