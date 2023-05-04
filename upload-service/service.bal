import ballerina/http;
import ballerina/mime;
import ballerina/regex;
import ballerina/io;
import ballerinax/rabbitmq;
import ballerinax/mysql;
import ballerinax/mysql.driver as _; // This bundles the driver to the project so that you don't need to bundle it via the `Ballerina.toml` file.
import ballerina/sql;
import ballerina/uuid;
import ballroom/data_model;
import ballerina/log;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

configurable string rabbitmqHost = ?;
configurable int rabbitmqPort = ?;

final mysql:Client db = check new (host = HOST, user = USER, password = PASSWORD, port = PORT, database = DATABASE);

# A service representing a network-accessible API
# bound to port `9090`.
# // The service-level CORS config applies globally to each `resource`.
@display {
    label: "Upload Service",
    id: "UploadService"
}
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://www.m3.com", "http://www.hello.com", "https://localhost:3000"],
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
        io:println("ENT");
        string generatedSubmissionId = uuid:createType1AsString();

        http:Response response = new;
        response.setPayload(generatedSubmissionId);
        mime:Entity[] bodyParts = check request.getBodyParts();

        check caller->respond(response);

        data_model:SubmissionMessage subMsg = {userId: "", challengeId: "", contestId: "", fileName: "", fileExtension: "", submissionId: ""};

        foreach mime:Entity item in bodyParts {
            io:println(item.getContentType());
            // check if the body part is a zipped file or normal text
            if item.getContentType().length() == 0 {
                string contentDispositionString = item.getContentDisposition().toString();
                // get the relevant key for the value provided
                string[] keyArray = regex:split(contentDispositionString, "name=\"");
                string key = regex:replaceAll(keyArray[1], "\"", "");
                subMsg[key] = check item.getText();
            }
            // body part is a zipped file
            else {
                // Writes the incoming stream to a file using the `io:fileWriteBlocksFromStream` API
                // by providing the file location to which the content should be written.
                stream<byte[], io:Error?> streamer = check item.getByteStream();

                string fileName = "";
                string|error contentDisposition = item.getHeader("Content-Disposition");
                if (contentDisposition is string) {
                    string[] fileNameArray = regex:split(contentDisposition, "filename=\"");
                    fileName = regex:replaceAll(fileNameArray[1], "\"", "");

                }

                io:Error? fileWriteBlocksFromStream = io:fileWriteBlocksFromStream("/tmp/" + fileName + ".zip", streamer);

                byte[] & readonly fileReadBytes = check io:fileReadBytes("/tmp/" + fileName + ".zip");

                // string base64EncodedString = check convertByteArrayStreamToString(streamer);

                // string _ = check redisConn->set(fileName, base64EncodedString);
                // redisConn.stop();

                // subMsg.fileLocation = "./files/"  + fileName + ".zip";
                subMsg.fileName = fileName;
                subMsg.fileExtension = ".zip";
                subMsg.submissionId = generatedSubmissionId;
                io:println(subMsg);
                check addSubmission(subMsg, fileReadBytes);
                check streamer.close();
            }
        }

        check self.rabbitmqClient->publishMessage({
            content: subMsg,
            routingKey: data_model:QUEUE_NAME
        });

    }

}

isolated function addSubmission(data_model:SubmissionMessage submissionMessage, byte[] submissionFile) returns error? {
    // TODO These two queries should be in a transaction
    sql:ExecutionResult _ = check db->execute(`
        INSERT INTO submission (submission_id, user_id, contest_id, challenge_id, file_name, file_extension, submitted_time)
        VALUES (${submissionMessage.submissionId}, ${submissionMessage.userId}, ${submissionMessage.contestId}, ${submissionMessage.challengeId},  
        ${submissionMessage.fileName}, ${submissionMessage.fileExtension}, CURRENT_TIMESTAMP())
    `);
    sql:ExecutionResult _ = check db->execute(`
        INSERT INTO submission_file_table (submission_id, submission_file)
        VALUES (${submissionMessage.submissionId}, ${submissionFile})
    `);
}
