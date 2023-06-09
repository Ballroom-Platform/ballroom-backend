import ballerina/http;
import ballroom/data_model;
import ballerina/io;
import ballerina/mime;
import ballerina/uuid;
import ballerina/log;
import ballroom/entities;
import ballerina/persist;
import ballerina/time;

type UpdatedChallenge record {
    string title;
    string description;
    string constraints;
    string difficulty;
};

type SharedChallenge record {|
    string userId;
    record {|
        string id;
        string title;
        string description;
        string constraints;
        time:Civil createdTime;
        byte[] templateFile;
        string difficulty;
        byte[] testCasesFile;
        string authorId;
    |} challenge;
|};

type Payload record {
    string message;
    anydata data;
};

type ChallengeAccessAdmins record {|
    string challengeId;
    record {|
        string id;
        string username;
        string fullname;
    |} user;
|};

type ChallengeAccessAdminsOut record {|
    string userId;
    string userName;
    string fullName;
|};

# A service representing a network-accessible API
# bound to port `9096`.
@display {
    label: "Challenge Service",
    id: "ChallengeService"
}
@http:ServiceConfig {
    cors: {
        allowOrigins: ["https://localhost:3000"],
        allowCredentials: true,
        allowHeaders: ["CORELATION_ID", "Authorization", "Content-Type", "ngrok-skip-browser-warning"],
        exposeHeaders: ["X-CUSTOM-HEADER"],
        maxAge: 84900
    }
}
service /challengeService on new http:Listener(9096) {
    private final entities:Client db;

    function init() returns error? {
        self.db = check new ();
        log:printInfo("Challenge service started...");
    }

    resource function get challenges/[string challengeId]()
            returns data_model:Challenge|http:InternalServerError|http:NotFound {
        entities:Challenge|persist:Error entityChallenge = self.db->/challenges/[challengeId];
        if entityChallenge is persist:InvalidKeyError {
            return http:NOT_FOUND;
        } else if entityChallenge is persist:Error {
            log:printError("Error while retrieving challenge by id", challengeId = challengeId,
                'error = entityChallenge);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while retrieving challenge by ${challengeId}`
                }
            };
        } else {
            return toDataModelChallenge(entityChallenge);
        }
    }

    resource function get challenges(string difficulty)
            returns data_model:Challenge[]|http:InternalServerError|http:BadRequest {
        if !(difficulty is "EASY" || difficulty is "MEDIUM" || difficulty is "HARD") {
            return http:BAD_REQUEST;
        }

        stream<entities:Challenge, persist:Error?> challengeStream = self.db->/challenges;
        entities:Challenge[]|persist:Error challenges = from var challenge in challengeStream
            where challenge.difficulty == difficulty
            select challenge;

        if challenges is persist:Error {
            log:printError("Error while retrieving challenges", 'error = challenges);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while retrieving challenges`
                }
            };
        } else {
            data_model:Challenge[] dataModelChallenges = from var challenge in challenges
                select toDataModelChallenge(challenge);
            return dataModelChallenges;
        }
    }

    resource function get challenges/[string difficulty]/owned/[string userId]() returns data_model:Challenge[]|http:InternalServerError|http:BadRequest {
        if !(difficulty is "EASY" || difficulty is "MEDIUM" || difficulty is "HARD") {
            return http:BAD_REQUEST;
        }

        stream<entities:Challenge, persist:Error?> challengeStream = self.db->/challenges;
        entities:Challenge[]|persist:Error challenges = from var challenge in challengeStream
            where challenge.difficulty == difficulty && challenge.authorId == userId
            select challenge;

        if challenges is persist:Error {
            log:printError("Error while retrieving challenges", 'error = challenges);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while retrieving challenges`
                }
            };
        } else {
            data_model:Challenge[] dataModelChallenges = from var challenge in challenges
                select toDataModelChallenge(challenge);
            return dataModelChallenges;
        }
    }

    resource function get challenges/owned/[string userId]() returns string[]|http:InternalServerError|http:BadRequest {

        stream<entities:Challenge, persist:Error?> challengeStream = self.db->/challenges;

        entities:Challenge[]|persist:Error challenges = from var challenge in challengeStream
            where challenge.authorId == userId
            select challenge;

        if challenges is persist:Error {
            log:printError("Error while retrieving challenges", 'error = challenges);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while retrieving challenges`
                }
            };
        } else {
            string[] challengeIds = from var challenge in challenges
                select challenge.id;
            return challengeIds;
        }
    }

    resource function get challenges/shared/[string userId]() returns string[]|http:InternalServerError|http:BadRequest {

        stream<SharedChallenge, persist:Error?> sharedChallenges = self.db->/challengeaccesses;
        SharedChallenge[]|persist:Error challenges = from var sharedChallenge in sharedChallenges
                where  sharedChallenge.userId == userId
                select sharedChallenge;

        if challenges is persist:Error {
            log:printError("Error while retrieving challenges", 'error = challenges);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while retrieving challenges`
                }
            };
        } else {
            string[] challengeIds = from var challenge in challenges
                select challenge.challenge.id;
            return challengeIds;
        }
    }

    resource function get challenges/[string difficulty]/shared/[string userId]() returns data_model:Challenge[]|http:InternalServerError|http:BadRequest {
        if !(difficulty is "EASY" || difficulty is "MEDIUM" || difficulty is "HARD") {
            return http:BAD_REQUEST;
        }

        stream<SharedChallenge, persist:Error?> sharedChallenges = self.db->/challengeaccesses;
        SharedChallenge[]|persist:Error challenges = from var sharedChallenge in sharedChallenges
                where sharedChallenge.challenge.difficulty == difficulty && sharedChallenge.userId == userId
                select sharedChallenge;

        if challenges is persist:Error {
            log:printError("Error while retrieving challenges", 'error = challenges);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while retrieving challenges`
                }
            };
        } else {
            data_model:Challenge[] dataModelChallenges = from var challenge in challenges
                select toSharedChallenge(challenge);
            return dataModelChallenges;
        }
    }

    // OpenAPI Tool Bug:https://github.com/ballerina-platform/openapi-tools/issues/1314  returns byte[]|error
    resource function get challenges/[string challengeId]/template()
            returns @http:Payload {mediaType: "application/octet-stream"} http:Response|
        http:InternalServerError|http:NotFound {
        record {|byte[] templateFile;|}|persist:Error templateFileRecord = self.db->/challenges/[challengeId];
        if templateFileRecord is persist:InvalidKeyError {
            return http:NOT_FOUND;
        } else if templateFileRecord is persist:Error {
            log:printError("Error while retrieving challenge template by id", challengeId = challengeId,
                'error = templateFileRecord);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while retrieving template file by the challenge '${challengeId}'`
                }
            };
        } else {
            http:Response response = new;
            response.setBinaryPayload(templateFileRecord.templateFile);
            return response;
        }
    }

    resource function get challenges/[string challengeId]/access() returns Payload|http:InternalServerError {
       do {
            ChallengeAccessAdminsOut[]|persist:Error result = getChallengeAdmins(self.db, challengeId) ?: [];

            Payload responsePayload = {
                message: "Admin access table created",
                data: check result
            };
            return responsePayload;

        } on fail error e {
            log:printError("Error while creating admin access table", 'error = e);
            return http:INTERNAL_SERVER_ERROR;
        }
    }

    resource function get challenges/accessgranted/[string challengeId]() returns string[]|http:InternalServerError|http:NotFound {
        string[]|persist:Error users =  getAccessGrantedUsers(self.db, challengeId);
        if users is persist:Error {
            log:printError("Error while retrieving users", 'error = users);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while retrieving users`
                }
            };
        } else {
            return users;
        }
    }

    resource function post challenges(http:Request request)
            returns string|http:BadRequest|http:InternalServerError|error {
        mime:Entity[] bodyParts = check request.getBodyParts();
        // Check if the request has 7 body parts
        if bodyParts.length() != 7 {
            return <http:BadRequest>{
                body: {
                    message: string `Expects 7 bodyparts but found ${bodyParts.length()}`
                }
            };
        }

        // Creates a map with the body part name as the key and the body part as the value
        map<mime:Entity> bodyPartMap = {};
        foreach mime:Entity entity in bodyParts {
            bodyPartMap[entity.getContentDisposition().name] = entity;
        }

        // Check if all the required body parts are present
        if !bodyPartMap.hasKey("title") || !bodyPartMap.hasKey("description") ||
            !bodyPartMap.hasKey("constraints") || !bodyPartMap.hasKey("difficulty") ||
            !bodyPartMap.hasKey("testCase") || !bodyPartMap.hasKey("template") || !bodyPartMap.hasKey("authorId") {
            return <http:BadRequest>{
                body: {
                    message: string `Expects 7 bodyparts with names 'title', 'description', 'constraints', 'difficulty', 'testCase' , 'author' and 'template'`
                }
            };
        }

        entities:Challenge entityChallenge = {
            id: uuid:createType4AsString(),
            title: check bodyPartMap.get("title").getText(),
            description: check bodyPartMap.get("description").getText(),
            difficulty: check bodyPartMap.get("difficulty").getText(),
            constraints: check bodyPartMap.get("constraints").getText(),
            testCasesFile: check readEntityToByteArray("testCase", bodyPartMap),
            templateFile: check readEntityToByteArray("template", bodyPartMap),
            createdTime: time:utcToCivil(time:utcNow()),
            authorId:  check bodyPartMap.get("authorId").getText()};

        string[]|persist:Error insertedIds = self.db->/challenges.post([entityChallenge]);
        if insertedIds is persist:Error {
            log:printError("Error while adding contest", 'error = insertedIds);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while adding contest`
                }
            };
        } else {
            return insertedIds[0];
        }
    }

    resource function post challenges/[string challengeId]/access/[string userId]()
            returns string|http:BadRequest|http:InternalServerError {
        stream<entities:ChallengeAccess, persist:Error?> challengeAccesses = self.db->/challengeaccesses;

        entities:ChallengeAccess[]|persist:Error duplicates = from var challengeAccess in challengeAccesses
            where challengeAccess.challengeId == challengeId && challengeAccess.userId == userId
            select challengeAccess;

        if duplicates is persist:Error {
            log:printError("Error while reading challengeAccesss data", 'error = duplicates);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while adding admins to challenge`
                }
            };
        }

        if duplicates.length() > 0 {
            return <http:BadRequest>{
                body: {
                    message: string `Admin already added to challenge`
                }
            };
        }

        string[]|persist:Error insertedIds = self.db->/challengeaccesses.post([
            {
                id: uuid:createType4AsString(),
                challengeId: challengeId,
                userId: userId
            }
        ]);

        if insertedIds is persist:Error {
            log:printError("Error while adding admin to challenge", 'error = insertedIds);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while adding admin to challenge`
                }
            };
        } else {
            return insertedIds[0];
        }
    }

    // TODO: Why are we returning a string here?
    // TODO: Shouldn't they be errors?
    resource function put challenges/[string challengeId](UpdatedChallenge updatedChallenge) 
            returns UpdatedChallenge|http:InternalServerError|http:NotFound|error {
        entities:ChallengeUpdate challengeUpdate = {
            title: updatedChallenge.title,
            description: updatedChallenge.description,
            difficulty: updatedChallenge.difficulty,
            constraints: updatedChallenge.constraints
        };

        entities:Challenge|persist:Error challenge = self.db->/challenges/[challengeId].put(challengeUpdate);
        if challenge is persist:InvalidKeyError {
            return http:NOT_FOUND;
        } else if challenge is persist:Error {
            log:printError("Error while updating challenge by id", challengeId = challengeId, 'error = challenge);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while updating challenge by ${challengeId}`
                }
            };
        } else {
            updatedChallenge["challengeId"] = challengeId;
            return updatedChallenge;
        }
    }

    resource function delete challenges/[string challengeId]() 
            returns http:InternalServerError|http:NotFound|http:Ok {
        entities:Challenge|persist:Error deletedChallenge = self.db->/challenges/[challengeId].delete;
        if deletedChallenge is persist:InvalidKeyError {
            return http:NOT_FOUND;
        } else if deletedChallenge is persist:Error {
            log:printError("Error while deleting challenge by id", challengeId = challengeId, 'error = deletedChallenge);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while deleting challenge by ${challengeId}`
                }
            };
        } else {
            return http:OK;
        }
    }

    resource function delete challenges/[string challengeId]/access/[string userId]() returns http:InternalServerError|http:NotFound|http:Ok {
        stream<entities:ChallengeAccess, persist:Error?> challengeAccessStream = self.db->/challengeaccesses;
        
        entities:ChallengeAccess[]|persist:Error challengeAccesses = from var challengeAccess in challengeAccessStream
            select challengeAccess;

        if challengeAccesses is persist:Error {
            log:printError("Error while reading challenge access data", 'error = challengeAccesses);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while retrieving data`
                }
            };
        } else {
            entities:ChallengeAccess[] listResult = from var challengeAccess in challengeAccesses
                where challengeAccess.challengeId == challengeId && challengeAccess.userId == userId
                select challengeAccess;

            if (listResult.length() == 0) {
                return <http:NotFound>{
                    body: {
                        message: string `User ${userId} hasn't access to challenge ${challengeId}`
                    }
                };
            }

            entities:ChallengeAccess|persist:Error deleteChallengeAccess = self.db->/challengeaccesses/[listResult[0].id].delete;

            if deleteChallengeAccess is persist:InvalidKeyError {
                return http:NOT_FOUND;
            } else if deleteChallengeAccess is persist:Error {
                log:printError("Error while deleting ", 'error = deleteChallengeAccess);
                return <http:InternalServerError>{
                    body: {
                        message: string `Error while deleting challenge User ${userId} challenge ${challengeId} access`
                    }
                };
            } else {
                return http:OK;
            }
        }
    }
}

function readEntityToByteArray(string entityName, map<mime:Entity> entityMap) returns byte[]|error {
    stream<byte[], io:Error?> testCaseStream = check entityMap.get(entityName).getByteStream();
    byte[] testCaseFile = [];
    check from var bytes in testCaseStream
        do {
            testCaseFile.push(...bytes);
        };

    return testCaseFile;
}

isolated function toDataModelChallenge(entities:Challenge challenge) returns data_model:Challenge =>
{
    title: challenge.title,
    challengeId: challenge.id,
    description: challenge.description,
    difficulty: challenge.difficulty,
    testCase: challenge.testCasesFile,
    template: challenge.templateFile,
    constraints: challenge.constraints,
    authorId: challenge.authorId
};

isolated function toSharedChallenge(SharedChallenge challenge) returns data_model:Challenge =>
{
    title: challenge.challenge.title,
    challengeId: challenge.challenge.id,
    description: challenge.challenge.description,
    difficulty: challenge.challenge.difficulty,
    testCase: challenge.challenge.testCasesFile,
    template: challenge.challenge.templateFile,
    constraints: challenge.challenge.constraints,
    authorId: challenge.challenge.authorId
};

function getChallengeAdmins(entities:Client db, string challengeId) returns ChallengeAccessAdminsOut[]|persist:Error? {

    stream<ChallengeAccessAdmins, persist:Error?> challengeAccessStream = db->/challengeaccesses;

    ChallengeAccessAdmins[]|persist:Error challengeAccesses = from var challengeAccess in challengeAccessStream
        select challengeAccess;

    if challengeAccesses is persist:Error {
        log:printError("Error while reading contests data", 'error = challengeAccesses);
        return challengeAccesses;
    } else {
        return from var challengeAccess in challengeAccesses
            where challengeAccess.challengeId == challengeId
            select toChallengeAccessAdminsOut(challengeAccess);
    }
}

function toChallengeAccessAdminsOut( ChallengeAccessAdmins challengeAccess) returns ChallengeAccessAdminsOut => {
    userId: challengeAccess.user.id,
    userName: challengeAccess.user.username,
    fullName: challengeAccess.user.fullname
};

function getAccessGrantedUsers(entities:Client db, string challengeId) returns string[]|persist:Error {

    stream<entities:ChallengeAccess, persist:Error?> challengeAccessStream = db->/challengeaccesses;

    entities:ChallengeAccess[]|persist:Error challengeAccesses = from var challengeAccess in challengeAccessStream
        select challengeAccess;

    if challengeAccesses is persist:Error {
        log:printError("Error while reading contests data", 'error = challengeAccesses);
        return challengeAccesses;
    } else {
        return from var challengeAccess in challengeAccesses
            where challengeAccess.challengeId == challengeId
            select challengeAccess.userId;
    }
}