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
import ballerina/mime;
import ballerina/io;
import ballerinax/rabbitmq;
import ballerina/uuid;
import tharinduu/data_model;
import ballerina/log;
import ballerina/time;
import ballerina/persist;
import tharinduu/entities;
import ballerinax/mysql;

configurable string rabbitmqHost = ?;
configurable int rabbitmqPort = ?;
configurable string rabbitmqUser = ?;
configurable string rabbitmqPassword = ?;

configurable int port = ?;
configurable string host = ?;
configurable string user = ?;
configurable string database = ?;
configurable string password = ?;
configurable mysql:Options & readonly connectionOptions = {};

final entities:Client db = check new (host, port, user, database, password, connectionOptions);
rabbitmq:ConnectionConfiguration config = {
        username: rabbitmqUser,
        password: rabbitmqPassword,
        virtualHost: rabbitmqUser
    };

# A service representing a network-accessible API
# bound to port `9090`.
# // The service-level CORS config applies globally to each `resource`.
@display {
    label: "Upload Service",
    id: "UploadService"
}
@http:ServiceConfig {
    cors: {
        allowOrigins: ["https://localhost:3000","https://ballroom.ballerina.io"],
        allowCredentials: false,
        allowHeaders: ["CORELATION_ID", "Authorization", "Content-Type", "ngrok-skip-browser-warning"],
        exposeHeaders: ["X-CUSTOM-HEADER"],
        maxAge: 84900
    }
}
service /uploadService on new http:Listener(9094) {
    private final rabbitmq:Client rabbitmqClient;

    function init() returns error? {
        // Initiate the RabbitMQ client at the start of the service. This will be used
        // throughout the lifetime of the service.
        self.rabbitmqClient = check new (rabbitmqHost, rabbitmqPort, config);
        // self.rabbitmqClient = check new (rabbitmqHost, rabbitmqPort);
        log:printInfo("Upload service started...");
    }

    resource function post solution(http:Request request, http:Caller caller) returns error? {
        http:Response response = new;
        mime:Entity[]|error bodyParts = request.getBodyParts();
        if bodyParts is error {
            response.statusCode = 500;
            response.setTextPayload(string `Error occurred while reading the request body`);
            check caller->respond(response);
            return;
        }

        if bodyParts.length() != 4 {
            response.statusCode = 400;
            response.setTextPayload(string `Expects 4 bodyparts but found ${bodyParts.length()}`);
            check caller->respond(response);
            return;
        }

        map<mime:Entity> bodyPartMap = {};
        foreach mime:Entity entity in bodyParts {
            bodyPartMap[entity.getContentDisposition().name] = entity;
        }

        if !bodyPartMap.hasKey("userId") || !bodyPartMap.hasKey("challengeId") || !bodyPartMap.hasKey("contestId") || !bodyPartMap.hasKey("submission") {
            response.statusCode = 400;
            response.setTextPayload(string `Expects bodyparts with names userId, challengeId, contestId & submission`);
            check caller->respond(response);
            return;
        }

        do {
            string generatedSubmissionId = uuid:createType1AsString();
            response.setPayload(generatedSubmissionId);
            check caller->respond(response);

            data_model:SubmissionMessage subMsg = {
                userId: check bodyPartMap.get("userId").getText(),
                challengeId: check bodyPartMap.get("challengeId").getText(),
                contestId: check bodyPartMap.get("contestId").getText(),
                fileName: bodyPartMap.get("submission").getContentDisposition().fileName,
                fileExtension: ".zip",
                submissionId: generatedSubmissionId
            };

            byte[] submittedFile = check readEntityToByteArray("submission", bodyPartMap);
            persist:Error? result = addSubmission(subMsg, submittedFile);
            if result is persist:Error {
                fail error("Error occurred while adding submission to the database", cause = result);
            }

            check self.rabbitmqClient->publishMessage({
                content: subMsg,
                routingKey: data_model:QUEUE_NAME
            });
        } on fail var err {
            log:printError("Error occurred while storing the submitted file.", 'error = err);
        }
    }
}

function addSubmission(data_model:SubmissionMessage submissionMessage, byte[] submissionFile) returns persist:Error? {
    string submissionFileId = uuid:createType4AsString();
    _ = check db->/submittedfiles.post([
        {
            id: submissionFileId,
            fileName: submissionMessage.fileName,
            fileExtension: submissionMessage.fileExtension,
            file: submissionFile
        }
    ]);

    _ = check db->/submissions.post([
        {
            id: submissionMessage.submissionId,
            submittedTime: time:utcToCivil(time:utcNow()),
            score: 0,
            userId: submissionMessage.userId,
            challengeId: submissionMessage.challengeId,
            contestId: submissionMessage.contestId,
            submittedfileId: submissionFileId
        }
    ]);
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
