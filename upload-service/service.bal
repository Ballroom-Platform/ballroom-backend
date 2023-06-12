import ballerina/http;
import ballerina/mime;
import ballerina/io;
import ballerinax/rabbitmq;
import ballerina/uuid;
import ballroom/data_model;
import ballerina/log;
import ballerina/time;
import ballerina/persist;
import ballroom/entities;

configurable string rabbitmqHost = ?;
configurable int rabbitmqPort = ?;

final entities:Client db = check new ();

# A service representing a network-accessible API
# bound to port `9090`.
# // The service-level CORS config applies globally to each `resource`.
@display {
    label: "Upload Service",
    id: "UploadService"
}
@http:ServiceConfig {
    cors: {
        allowOrigins: ["https://localhost:3000"],
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
        self.rabbitmqClient = check new (rabbitmqHost, rabbitmqPort);
        log:printInfo("Upload service started...");
    }

    # A resource for uploading solutions to challenges
    # + request - the input solution file as a multipart request with userId, challengeId & the solution as a zip file
    # + return - response message from server
    resource function post solution(http:Request request, http:Caller caller) returns error? {
        http:Response response = new;
        mime:Entity[]|error bodyParts = request.getBodyParts();
        if bodyParts is error {
            response.statusCode = 500;
            response.setTextPayload(string `Error occurred while reading the request body`);
            check caller->respond(response);
            return;
        }

        // check if the request contains 4 body parts
        if bodyParts.length() != 4 {
            response.statusCode = 400;
            response.setTextPayload(string `Expects 4 bodyparts but found ${bodyParts.length()}`);
            check caller->respond(response);
            return;
        }

        // Creates a map with the body part name as the key and the body part as the value
        map<mime:Entity> bodyPartMap = {};
        foreach mime:Entity entity in bodyParts {
            bodyPartMap[entity.getContentDisposition().name] = entity;
        }

        // check if the request contains all the required body parts
        if !bodyPartMap.hasKey("userId") || !bodyPartMap.hasKey("challengeId") || !bodyPartMap.hasKey("contestId") || !bodyPartMap.hasKey("submission") {
            response.statusCode = 400;
            response.setTextPayload(string `Expects bodyparts with names userId, challengeId, contestId & submission`);
            check caller->respond(response);
            return;
        }

        do {
            // Respond with a generated submission id
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
    // TODO These two queries should be in a transaction
    string submissionFileId = uuid:createType4AsString();
    _ = check db->/submittedfiles.post([
        {
            id: submissionFileId,
            fileName: submissionMessage.fileName,
            fileExtension: submissionMessage.fileExtension,
            file: submissionFile
        }
    ]);

        time:Civil nowTime = time:utcToCivil(time:utcNow());
        nowTime.hour = nowTime.hour + 5;
        nowTime.minute = nowTime.minute + 30;

    _ = check db->/submissions.post([
        {
            id: submissionMessage.submissionId,
            submittedTime: nowTime,
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
