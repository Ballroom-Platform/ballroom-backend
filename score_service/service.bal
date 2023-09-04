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

import ballerinax/rabbitmq;
import ballroom/data_model;
import ballerina/http;
import ballerina/time;
import ballerina/log;
import ballroom/entities;
import ballerina/persist;

configurable string rabbitmqHost = ?;
configurable int rabbitmqPort = ?;

// configurable string rabbitmqUser = ?;
// configurable string rabbitmqPassword = ?;

public type Submission record {
    readonly string submission_id;
    string user_id;
    string contest_id;
    string challenge_id;
    time:Civil submitted_time;
    float? score;
};

public type LeaderboardRow record {
    string username;
    string fullname;
    float score;
};

// rabbitmq:ConnectionConfiguration config = {
//     username: rabbitmqUser,
//     password: rabbitmqPassword
// };

// rabbitmq:QosSettings qosSettings = {
//     prefetchCount: 0
// };

// The consumer service listens to the "RequestQueue" queue.
listener rabbitmq:Listener channelListener = new (rabbitmqHost, rabbitmqPort);

// listener rabbitmq:Listener channelListener = new (rabbitmqHost, rabbitmqPort,qosSettings,config);

@rabbitmq:ServiceConfig {
    queueName: data_model:EXEC_TO_SCORE_QUEUE_NAME
}
service rabbitmq:Service on channelListener {

    function init() returns error? {
        // Initiate the RabbitMQ client at the start of the service. This will be used
        // throughout the lifetime of the service.
    }

    remote function onMessage(data_model:ScoredSubmissionMessage scoredSubmissionEvent) returns error? {
        entities:Submission|persist:Error sumissionEntity =
            db->/submissions/[scoredSubmissionEvent.subMsg.submissionId].put({score: scoredSubmissionEvent.score});
        if sumissionEntity is persist:Error {
            log:printError("Error while updating submission score", sumissionEntity);
            return sumissionEntity;
        }
        return;
    }
}

# A service representing a network-accessible API
# bound to port `9090`.
# // The service-level CORS config applies globally to each `resource`.
@http:ServiceConfig {
    cors: {
        allowOrigins: ["https://localhost:3000"],
        allowCredentials: true,
        allowHeaders: ["CORELATION_ID", "Authorization", "Content-Type", "ngrok-skip-browser-warning"],
        exposeHeaders: ["X-CUSTOM-HEADER"],
        maxAge: 84900
    }
}
@display {
    label: "Submission Service",
    id: "SubmissionService"
}
service /submissionService on new http:Listener(9092) {

    function init() {
        log:printInfo("Score service started...");
    }

    resource function get submissions/[string submissionId]/score()
            returns Payload|http:NotFound|http:InternalServerError {
        record {|
            float score;
        |}|persist:Error scoreRecord = db->/submissions/[submissionId];
        if scoreRecord is persist:NotFoundError {
            return http:NOT_FOUND;
        } else if scoreRecord is persist:Error {
            log:printError("Error while retrieving submission score", scoreRecord);
            return http:INTERNAL_SERVER_ERROR;
        } else {
            Payload responsePayload = {
                message: "Submission found",
                data: scoreRecord.score
            };

            return responsePayload;
        }
    }

    resource function get submissions(string userId, string contestId, string challengeId)
            returns http:InternalServerError|Payload {
        Submission[]|persist:Error submissionList = getSubmissionList(userId, contestId, challengeId) ?: [];
        if submissionList is persist:Error {
            log:printError("Error while retrieving submission list", userId = userId, contestId = contestId,
                challengeId = challengeId, 'error = submissionList);
            return http:INTERNAL_SERVER_ERROR;
        } else {
            Payload responsePayload = {
                message: "Submission found",
                data: submissionList
            };
            return responsePayload;
        }
    }

    resource function get submissions/[string submissionId]/solution()
            returns byte[]|http:NotFound|http:InternalServerError {
        record {|
            byte[] file;
        |}|persist:Error fileRecord = db->/submittedfiles/[submissionId];
        if fileRecord is persist:NotFoundError {
            return http:NOT_FOUND;
        } else if fileRecord is persist:Error {
            log:printError("Error while retrieving submission file", submissionId = submissionId, 'error = fileRecord);
            return http:INTERNAL_SERVER_ERROR;
        } else {
            return fileRecord.file;
        }
    }

    resource function get leaderboard/[string contestId]() returns http:InternalServerError|Payload {
        stream<SubmissionWithUserData, persist:Error?> submissionStream = db->/submissions;
        SubmissionWithUserData[]|persist:Error submissions = from var submission in submissionStream
            where submission.contestId == contestId
            select submission;
        if submissions is persist:Error {
            log:printError("Error while retrieving submissions", contestId = contestId, 'error = submissions);
            return http:INTERNAL_SERVER_ERROR;
        }

        table<SubmissionsByUser> key(userId) submissionsByUserTable = table [];
        foreach var submission in submissions {
            string userId = submission.userId;
            if (submissionsByUserTable[userId] is ()) {
                SubmissionsByUser submissionsByUserRecord = {
                    userId: userId,
                    username: submission.user.username,
                    fullname: submission.user.fullname,
                    submissions: []
                };
                submissionsByUserTable.add(submissionsByUserRecord);
            }
            submissionsByUserTable.get(userId).submissions.push(submission);
        }

        LeaderboardRow[] leaderBoard = [];
        foreach var SubmissionsByUser in submissionsByUserTable {
            map<SubmissionWithUserData[]> submissionsByUserAndChallenge = {};
            foreach var submission in SubmissionsByUser.submissions {
                string challengeId = submission.challengeId;
                if (submissionsByUserAndChallenge[challengeId] is ()) {
                    submissionsByUserAndChallenge[challengeId] = [];
                }
                submissionsByUserAndChallenge.get(challengeId).push(submission);
            }

            map<SubmissionWithUserData> submissionWithMaxScoreByChallenge = {};
            foreach var challengeId in submissionsByUserAndChallenge.keys() {
                SubmissionWithUserData[] submissionsByChallenge = submissionsByUserAndChallenge.get(challengeId);
                SubmissionWithUserData submissionWithMaxScore = submissionsByChallenge[0];
                foreach var submission in submissionsByChallenge {
                    if (submission.score > submissionWithMaxScore.score) {
                        submissionWithMaxScore = submission;
                    }
                }
                submissionWithMaxScoreByChallenge[challengeId] = submissionWithMaxScore;
            }

            float score = 0;
            foreach var submission in submissionWithMaxScoreByChallenge {
                score = score + submission.score;
            }
            LeaderboardRow leaderboardRow = {
                username: SubmissionsByUser.username,
                fullname: SubmissionsByUser.fullname,
                score: score
            };
            leaderBoard.push(leaderboardRow);
        }

        leaderBoard = from var leaderboardRow in leaderBoard
            order by leaderboardRow.score descending
            select leaderboardRow;

        Payload responsePayload = {
            message: "Leaderboard created",
            data: leaderBoard
        };
        return responsePayload;
    }

    resource function get scoreboard/[string contestId]/[string userId]() returns http:InternalServerError|Payload {

        stream<ScoreBoard, persist:Error?> submissionStream = db->/submissions;
        ScoreBoard[]|persist:Error submissions = from var submission in submissionStream
            where submission.contestId == contestId && submission.userId == userId
            select submission;
        if submissions is persist:Error {
            log:printError("Error while retrieving submissions", contestId = contestId, 'error = submissions);
            return http:INTERNAL_SERVER_ERROR;
        }

        map<ScoreBoard[]> submissionsByChallenge = {};
        foreach var submission in submissions {
            string challengeId = submission.challenge.id;
            if (submissionsByChallenge[challengeId] is ()) {
                submissionsByChallenge[challengeId] = [];
            }
            submissionsByChallenge.get(challengeId).push(submission);
        }

        map<ScoreBoard> submissionWithMaxScoreByChallenge = {};
        foreach var challengeId in submissionsByChallenge.keys() {
            ScoreBoard[] submissionsByChallengeId = submissionsByChallenge.get(challengeId);
            ScoreBoard submissionWithMaxScore = submissionsByChallengeId[0];
            foreach var submission in submissionsByChallengeId {
                if (submission.score > submissionWithMaxScore.score) {
                    submissionWithMaxScore = submission;
                }
            }
            submissionWithMaxScoreByChallenge[challengeId] = submissionWithMaxScore;
        }

        ScoreBoardOut[] scoreboard = [];
        foreach var submission in submissionWithMaxScoreByChallenge {
            ScoreBoardOut scoreBoardOut = {
                score: submission.score,
                submittedTime: submission.submittedTime,
                title: submission.challenge.title
            };
            scoreboard.push(scoreBoardOut);
        }

        Payload responsePayload = {
            message: "Scoreboard created",
            data: scoreboard
        };
        return responsePayload;
    }
}

type SubmissionWithUserData record {|
    string id;
    float score;
    string userId;
    string challengeId;
    string contestId;
    record {|
        string fullname;
        string username;
    |} user;
|};

type SubmissionsByUser record {|
    readonly string userId;
    string username;
    string fullname;
    SubmissionWithUserData[] submissions;
|};

type ScoreBoard record {|
    string id;
    float score;
    string userId;
    string contestId;
    time:Civil submittedTime;
    record {|
        string id;
        string title;
    |} challenge;
|};

type ScoreBoardOut record {|
    float score;
    time:Civil submittedTime;
    string title;
|};

