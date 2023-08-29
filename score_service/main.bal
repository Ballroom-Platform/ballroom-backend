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

import ballroom/data_model;
import score_service.user;
import ballroom/entities;
import ballerina/persist;
import ballroom/data_model.registry;

public type Payload record {
    string message;
    anydata data;
};

final entities:Client db = check new ();

@display {
    label: "User Service",
    id: "UserService"
}
final user:Client userService = check new (serviceUrl = check registry:lookup("\"ballroom/UserService\""));

isolated function getSubmissionList(string userId, string contestId, string challengeId) returns Submission[]|persist:Error? {
    stream<entities:Submission, persist:Error?> submissionStream = db->/submissions;
    return from var submission in submissionStream
        where submission.userId == userId && submission.contestId == contestId && submission.challengeId == challengeId
        select toDataModelSubmission(submission);
}

isolated function toDataModelSubmission(entities:Submission subEntity) returns Submission => {
    submission_id: subEntity.id,
    user_id: subEntity.userId,
    contest_id: subEntity.contestId,
    challenge_id: subEntity.challengeId,
    score: subEntity.score,
    submitted_time: subEntity.submittedTime
};

public isolated function getUserData(string userID) returns data_model:User|error {
    Payload payload = check userService->/users/[userID];
    data_model:User userData = check payload.data.cloneWithType(data_model:User);
    return userData;
}
