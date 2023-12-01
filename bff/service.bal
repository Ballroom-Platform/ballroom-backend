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
import ballerina/log;

configurable string contestServiceUrl = ?;
configurable string challengeServiceUrl = ?;
configurable string uploadServiceUrl = ?;
configurable string userServiceUrl = ?;
configurable string submissionServiceUrl = ?;

@display {
    label: "BFF for Ballroom Webapp",
    id: "BFFBallroomWebapp"
}
@http:ServiceConfig {
    cors: {
        allowOrigins: ["https://localhost:3000","https://ballroom.ballerina.io","https://bf76bdf6-c8a9-4aa0-ab62-1c36858b0358.e1-us-east-azure.choreoapps.dev"],
        allowCredentials: true,
        allowHeaders: ["CORELATION_ID", "Authorization", "Content-Type", "authorization", "ngrok-skip-browser-warning"],
        exposeHeaders: ["X-CUSTOM-HEADER"],
        maxAge: 84900
    }
}
service / on new http:Listener(9099) {
    @display {
        label: "Contest Service",
        id: "ContestService"
    }
    private final http:Client contestService;

    @display {
        label: "Challenge Service",
        id: "ChallengeService"
    }
    private final http:Client challengeService;

    @display {
        label: "Upload Service",
        id: "UploadService"
    }
    private final http:Client uploadService;

    @display {
        label: "User Service",
        id: "UserService"
    }
    private final http:Client userService;

    @display {
        label: "Submission Service",
        id: "SubmissionService"
    }
    private final http:Client submissionService;

    function init() returns error? {
        self.contestService = check new (contestServiceUrl);
        self.challengeService = check new (challengeServiceUrl);
        self.uploadService = check new (uploadServiceUrl);
        self.userService = check new (userServiceUrl);
        self.submissionService = check new (submissionServiceUrl);
        log:printInfo("BFF service started...");
    }

    // Challenge service
    resource function 'default challengeService/[string... paths](http:Request req) returns http:Response|error {
        return check self.challengeService->forward(req.rawPath, req);
    }

    // Contest service
    resource function 'default contestService/[string... paths](http:Request req) returns http:Response|error {
        return check self.contestService->forward(req.rawPath, req);
    }

   // Upload service
    resource function 'default uploadService/[string... paths](http:Request req) returns http:Response|error {
        return check self.uploadService->forward(req.rawPath, req);
    }

  // User service
    resource function 'default userService/[string... paths](http:Request req) returns http:Response|error {
        return check self.userService->forward(req.rawPath, req);
    }

    // Submission service
    resource function 'default submissionService/[string... paths](http:Request req) returns http:Response|error {
        return check self.submissionService->forward(req.rawPath, req);
    }
}

