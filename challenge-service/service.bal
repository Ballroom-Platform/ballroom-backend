// Copyright (c) 2023 WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import tharinduu/data_model;
import ballerina/io;
import ballerina/mime;
import ballerina/uuid;
import ballerina/log;
import tharinduu/entities;
import ballerina/persist;
import ballerina/time;
import ballerinax/mysql;

configurable int port = ?;
configurable string host = ?;
configurable string user = ?;
configurable string database = ?;
configurable string password = ?;
configurable mysql:Options & readonly connectionOptions = {};

type UpdatedChallenge record {
    string title;
    string difficulty;
    byte[] readmeFile;
    byte[] templateFile;
    byte[] testCasesFile;
};

type UserAccess record {
    string userId;
};

type SharedChallenge record {|
    string userId;
    record {|
        string id;
        string title;
        byte[] readmeFile;
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
        allowOrigins: ["https://localhost:3000","https://ballroom.ballerina.io","https://2b34f7b5-5b06-4f55-ba18-16bffa3b1bba.e1-us-east-azure.choreoapps.dev"],
        allowCredentials: true,
        allowHeaders: ["CORELATION_ID", "Authorization", "Content-Type", "ngrok-skip-browser-warning"],
        exposeHeaders: ["X-CUSTOM-HEADER"],
        maxAge: 84900
    }
}

service /challengeService on new http:Listener(9096) {
    private final entities:Client db;

    function init() returns error? {
        self.db = check new (host, port, user, database, password, connectionOptions);
        log:printInfo("Challenge service started...");
    }

    resource function get challenges/[string challengeId]()
            returns data_model:Challenge|http:InternalServerError|http:NotFound {
        entities:Challenge|persist:Error entityChallenge = self.db->/challenges/[challengeId];
        if entityChallenge is persist:NotFoundError {
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

    resource function get challenges/owned/[string userId](string? difficulty) returns data_model:Challenge[]|http:InternalServerError|http:BadRequest {

        if difficulty != null {
            if !(difficulty is "EASY" || difficulty is "MEDIUM" || difficulty is "HARD") {
                return http:BAD_REQUEST;
            }
        }
        stream<entities:Challenge, persist:Error?> challengeStream = self.db->/challenges;

        entities:Challenge[]|persist:Error challenges = [];
        if difficulty != null {
            challenges = from entities:Challenge challenge in challengeStream
                where challenge.difficulty == difficulty && challenge.authorId == userId
                select challenge;
        } else {
            challenges = from entities:Challenge challenge in challengeStream
                where challenge.authorId == userId
                select challenge;
        }

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

    resource function get challenges/shared/[string userId](string? difficulty) returns data_model:Challenge[]|http:InternalServerError|http:BadRequest {

        if difficulty != null {
            if !(difficulty is "EASY" || difficulty is "MEDIUM" || difficulty is "HARD") {
                return http:BAD_REQUEST;
            }
        }

        stream<SharedChallenge, persist:Error?> sharedChallenges = self.db->/challengeaccesses;

        SharedChallenge[]|persist:Error challenges = [];
        if difficulty != null {
            challenges = from SharedChallenge sharedChallenge in sharedChallenges
                where sharedChallenge.challenge.difficulty == difficulty && sharedChallenge.userId == userId
                select sharedChallenge;
        } else {
            challenges = from SharedChallenge sharedChallenge in sharedChallenges
                where sharedChallenge.userId == userId
                select sharedChallenge;
        }
        
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

    resource function get challenges/[string challengeId]/template()
            returns @http:Payload {mediaType: "application/octet-stream"} http:Response|
        http:InternalServerError|http:NotFound {
        record {|byte[] templateFile;|}|persist:Error templateFileRecord = self.db->/challenges/[challengeId];
        if templateFileRecord is persist:NotFoundError {
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

    resource function get challenges/[string challengeId]/readme()
            returns @http:Payload {mediaType: "application/octet-stream"} http:Response|
        http:InternalServerError|http:NotFound {
        record {|byte[] readmeFile;|}|persist:Error readmeFileRecord = self.db->/challenges/[challengeId];
        if readmeFileRecord is persist:NotFoundError {
            return http:NOT_FOUND;
        } else if readmeFileRecord is persist:Error {
            log:printError("Error while retrieving challenge radme by id", challengeId = challengeId,
                'error = readmeFileRecord);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while retrieving readme file by the challenge '${challengeId}'`
                }
            };
        } else {
            http:Response response = new;
            response.setBinaryPayload(readmeFileRecord.readmeFile);
            return response;
        }
    }

    resource function get challenges/[string challengeId]/users\-with\-access() returns Payload|http:InternalServerError {
       do {
            ChallengeAccessAdminsOut[]|persist:Error result = getAccessGrantedUsers(self.db, challengeId) ?: [];

            Payload responsePayload = {
                message: "Challenge access granted users",
                data: check result
            };
            return responsePayload;

        } on fail error e {
            log:printError("Error while retreving accessgranted users", 'error = e);
            return http:INTERNAL_SERVER_ERROR;
        }
    }

    resource function post challenges(http:Request request)
            returns string|http:BadRequest|http:InternalServerError|error {
        mime:Entity[] bodyParts = check request.getBodyParts();

        if bodyParts.length() != 6 {
            return <http:BadRequest>{
                body: {
                    message: string `Expects 6 bodyparts but found ${bodyParts.length()}`
                }
            };
        }

        map<mime:Entity> bodyPartMap = {};
        foreach mime:Entity entity in bodyParts {
            bodyPartMap[entity.getContentDisposition().name] = entity;
        }

        if !bodyPartMap.hasKey("title") || !bodyPartMap.hasKey("difficulty") ||
            !bodyPartMap.hasKey("testCase") || !bodyPartMap.hasKey("template") || !bodyPartMap.hasKey("readme") || !bodyPartMap.hasKey("authorId") {
            return <http:BadRequest>{
                body: {
                    message: string `Expects 6 bodyparts with names 'title', 'readme', 'difficulty', 'testCase' , 'author' and 'template'`
                }
            };
        }

        entities:Challenge entityChallenge = {
            id: uuid:createType4AsString(),
            title: check bodyPartMap.get("title").getText(),
            difficulty: check bodyPartMap.get("difficulty").getText(),
            readmeFile: check readEntityToByteArray("readme", bodyPartMap),
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

    resource function post challenges/[string challengeId]/users\-with\-access(@http:Payload UserAccess userAccess)
            returns string|http:BadRequest|http:InternalServerError {

        string userId = userAccess.userId;

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

    resource function put challenges/[string challengeId](http:Request request) 
            returns UpdatedChallenge|http:InternalServerError|http:NotFound {
        mime:Entity[]|http:ClientError bodyParts = request.getBodyParts();
        map<mime:Entity> bodyPartMap = {};
        if bodyParts is http:ClientError {
            return <http:InternalServerError>{
                body: {
                    message: bodyParts.toString()
                }
            };
        }
        else {
            foreach mime:Entity entity in bodyParts {
                bodyPartMap[entity.getContentDisposition().name] = entity;
            }
        }
        entities:ChallengeUpdate challengeUpdate = {};
        do {
            challengeUpdate = {
                title: check bodyPartMap.get("title").getText(),
                difficulty: check bodyPartMap.get("difficulty").getText(),
                readmeFile: check readEntityToByteArray("readme", bodyPartMap),
                testCasesFile: check readEntityToByteArray("testCase", bodyPartMap),
                templateFile: check readEntityToByteArray("template", bodyPartMap)
            };
        } on fail var e {
        	return <http:InternalServerError>{
                body: {
                    message:e.message()
                }
            };
        }
        entities:Challenge|persist:Error challenge = self.db->/challenges/[challengeId].put(challengeUpdate);
        if challenge is persist:NotFoundError {
            return http:NOT_FOUND;
        } else if challenge is persist:Error {
            log:printError("Error while updating challenge by id", challengeId = challengeId, 'error = challenge);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while updating challenge by ${challengeId}`
                }
            };
        } else {
            UpdatedChallenge updatedChallenge = {
                difficulty: challenge.difficulty, 
                testCasesFile: challenge.testCasesFile,
                templateFile: challenge.templateFile,
                title: challenge.title,
                readmeFile: challenge.readmeFile};
            updatedChallenge["challengeId"] = challengeId;
            return updatedChallenge;
        }
    }

    resource function delete challenges/[string challengeId]() 
            returns http:InternalServerError|http:NotFound|http:Ok {
        entities:Challenge|persist:Error deletedChallenge = self.db->/challenges/[challengeId].delete;
        if deletedChallenge is persist:NotFoundError {
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

    resource function delete challenges/[string challengeId]/users\-with\-access(@http:Payload UserAccess userAccess) returns http:InternalServerError|http:NotFound|http:Ok {

        string userId = userAccess.userId;

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

            if deleteChallengeAccess is persist:NotFoundError {
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
    difficulty: challenge.difficulty,
    testCase: challenge.testCasesFile,
    template: challenge.templateFile,
    authorId: challenge.authorId,
    readme: challenge.readmeFile};

isolated function toSharedChallenge(SharedChallenge challenge) returns data_model:Challenge =>
{
    title: challenge.challenge.title,
    challengeId: challenge.challenge.id,
    difficulty: challenge.challenge.difficulty,
    testCase: challenge.challenge.testCasesFile,
    template: challenge.challenge.templateFile,
    authorId: challenge.challenge.authorId,
    readme: challenge.challenge.readmeFile};

function getAccessGrantedUsers(entities:Client db, string challengeId) returns ChallengeAccessAdminsOut[]|persist:Error? {

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
