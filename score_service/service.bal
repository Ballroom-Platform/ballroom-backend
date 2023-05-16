import ballerinax/rabbitmq;
import ballroom/data_model;
import ballerina/http;
import ballerina/time;
import ballerina/log;
import ballroom/entities;
import ballerina/persist;

configurable string rabbitmqHost = ?;
configurable int rabbitmqPort = ?;

public type Submission record {
    readonly string submission_id;
    string user_id;
    string contest_id;
    string challenge_id;
    time:Civil submitted_time;
    float? score;
};

public type LeaderboardRow record {
    string userId;
    string? name;
    float score;
};

// The consumer service listens to the "RequestQueue" queue.
listener rabbitmq:Listener channelListener = new (rabbitmqHost, rabbitmqPort);

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

    # A resource for generating greetings
    #
    # + submissionId - Parameter Description
    # + return - string name with hello message or error
    resource function get submissions/[string submissionId]/score() 
            returns Payload|http:NotFound|http:InternalServerError {
        record {|
            float score;
        |}|persist:Error scoreRecord = db->/submissions/[submissionId];
        if scoreRecord is persist:InvalidKeyError {
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
        if fileRecord is persist:InvalidKeyError {
            return http:NOT_FOUND;
        } else if fileRecord is persist:Error {
            log:printError("Error while retrieving submission file", submissionId = submissionId, 'error = fileRecord);
            return http:INTERNAL_SERVER_ERROR;
        } else {
            return fileRecord.file;
        }
    }

    resource function get leaderboard/[string contestId]() returns http:InternalServerError|Payload {
        // Since bal persit does not support complicated database joins and aggregations. 
        // The following code performs an in-memory join and aggregation.

        // Retrieve all submissions
        // Filter out submissions that doesnt match with the contest 
        stream<SubmissionWithUserData, persist:Error?> submissionStream = db->/submissions;
        SubmissionWithUserData[]|persist:Error submissions = from var submission in submissionStream
            where submission.contestId == contestId
            select submission;
        if submissions is persist:Error {
            log:printError("Error while retrieving submissions", contestId = contestId, 'error = submissions);
            return http:INTERNAL_SERVER_ERROR;
        }

        // Group submissions by user
        // user ids are keys of the map
        table<SubmissionsByUser> key(userId) submissionsByUserTable = table [];
        // map<SubmissionWithUserData[]> submissionsByUser = {};
        foreach var submission in submissions {
            string userId = submission.userId;
            if (submissionsByUserTable[userId] is ()) {
                SubmissionsByUser submissionsByUserRecord = {
                    userId: userId,
                    fullname: submission.user.fullname,
                    submissions: []
                };
                submissionsByUserTable.add(submissionsByUserRecord);
            }
            submissionsByUserTable.get(userId).submissions.push(submission);
        }

        // Group user submissions by challenge
        // challenge ids are keys of the map
        LeaderboardRow[] leaderBoard = [];
        foreach var SubmissionsByUser in submissionsByUserTable {
            // Group submissions by challenge for each user
            map<SubmissionWithUserData[]> submissionsByUserAndChallenge = {};
            foreach var submission in SubmissionsByUser.submissions {
                string challengeId = submission.challengeId;
                if (submissionsByUserAndChallenge[challengeId] is ()) {
                    submissionsByUserAndChallenge[challengeId] = [];
                }
                submissionsByUserAndChallenge.get(challengeId).push(submission);
            } 

            // Find the submission with the max score for each challenge
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

            // Calculate user score
            float score = 0;
            foreach var submission in submissionWithMaxScoreByChallenge {
                score = score + submission.score;
            }
            LeaderboardRow leaderboardRow = {
                userId: SubmissionsByUser.userId,
                name: SubmissionsByUser.fullname,
                score: score
            };
            leaderBoard.push(leaderboardRow);
        }

        // Sort leaderboard by score
        leaderBoard = from var leaderboardRow in leaderBoard
        order by leaderboardRow.score descending
        select leaderboardRow;

        // TODO Leaderboard
        Payload responsePayload = {
            message: "Leaderboard created",
            data: leaderBoard
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
    |} user;
|};

type SubmissionsByUser record {|
    readonly string userId;
    string fullname;
    SubmissionWithUserData[] submissions;
|};


