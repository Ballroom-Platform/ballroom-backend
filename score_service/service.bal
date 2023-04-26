import ballerinax/rabbitmq;
import ballroom/data_model;
import ballerina/http;
import ballerina/sql;
import ballerina/time;
import ballerina/log;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

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
        // Throw the error for now
        _ = check updateScore(scoredSubmissionEvent.score.toString(), scoredSubmissionEvent.subMsg.submissionId);
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
        allowHeaders: ["CORELATION_ID", "Authorization", "Content-Type"],
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
    isolated resource function get submissions/[string submissionId]/score() returns http:InternalServerError|Payload {
        do {

            string|sql:Error result = check getSubmissionScore(submissionId);

            if (result is sql:Error) {
                Payload responsePayload = {
                    message: "No submission found",
                    data: ""
                };
                return responsePayload;
            }

            Payload responsePayload = {
                message: "Submission found",
                data: result
            };

            return responsePayload;
        }
        on fail {
            return http:INTERNAL_SERVER_ERROR;
        }

    }

    isolated resource function get submissions(string userId, string contestId, string challengeId) returns http:InternalServerError|Payload {
        do {
            Submission[] list = check getSubmissionList(userId, contestId, challengeId) ?: [];

            Payload responsePayload = {
                message: "Submission found",
                data: list
            };

            return responsePayload;
        } on fail {
            return http:INTERNAL_SERVER_ERROR;
        }
    }

    isolated resource function get submissions/[string submissionId]/solution() returns http:InternalServerError|byte[] {

        do {
            byte[] file = check getSubmissionFile(submissionId);

            return file;
        } on fail {
            return http:INTERNAL_SERVER_ERROR;
        }
    }

    isolated resource function get leaderboard/[string contestId]() returns http:InternalServerError|Payload {
        do {
            LeaderboardRow[] result = check getLeaderboard(contestId) ?: [];

            Payload responsePayload = {
                message: "Leaderboard created",
                data: result
            };

            return responsePayload;
        } on fail error e {
            log:printError("Error while creating leaderboard", 'error = e);
            return http:INTERNAL_SERVER_ERROR;
        }
    }
}
