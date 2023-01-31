import ballerina/http;
import ballerina/mime;
import ballerina/regex;
import ballerina/io;
import ballerinax/rabbitmq;
import ballerinax/redis;
import ballerinax/mysql;
import ballerinax/mysql.driver as _; // This bundles the driver to the project so that you don't need to bundle it via the `Ballerina.toml` file.
import ballerina/sql;
import wso2/data_model;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;


# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database="Company");

    private final rabbitmq:Client rabbitmqClient;

    function init() returns error? {
        // Initiate the RabbitMQ client at the start of the service. This will be used
        // throughout the lifetime of the service.
        self.rabbitmqClient = check new (rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);
    }

    # A resource for uploading solutions to challenges
    # + request - the input solution file as a multipart request with userId, challengeId & the solution as a zip file
    # + return - response message from server
    resource function post uploadSolution(http:Request request) returns string|error {

        // The Redis Configuration

        // redis:ConnectionConfig redisConfig = {
        //     host: "127.0.0.1:6379",
        //     password: "",
        //     options: {
        //         connectionPooling: true,
        //         isClusterConnection: false,
        //         ssl: false,
        //         startTls: false,
        //         verifyPeer: false,
        //         connectionTimeout: 500
        //     }
        // };

        // redis:Client redisConn = check new (redisConfig);
        
        mime:Entity[] bodyParts = check request.getBodyParts();

        data_model:SubmissionMessage subMsg = {userId: "", challengeId: "", contestId: "", fileName: "", fileExtension: "", submissionId: ""};

        foreach mime:Entity item in bodyParts {

            // check if the body part is a zipped file or normal text
            if item.getContentType().length() == 0  {
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
                string | error contentDisposition = item.getHeader("Content-Disposition");
                if(contentDisposition is string){
                    string[] fileNameArray = regex:split(contentDisposition, "filename=\"");
                    fileName = regex:replaceAll(fileNameArray[1], "\"", "");

                }

                io:Error? fileWriteBlocksFromStream = io:fileWriteBlocksFromStream("/tmp/"+fileName+".zip", streamer);

                byte[] & readonly fileReadBytes = check io:fileReadBytes("/tmp/"+fileName+".zip");


                // string base64EncodedString = check convertByteArrayStreamToString(streamer);
                

                // string _ = check redisConn->set(fileName, base64EncodedString);
                // redisConn.stop();
                
                // subMsg.fileLocation = "./files/"  + fileName + ".zip";
                subMsg.fileName = fileName;
                subMsg.fileExtension = ".zip";
                string submissionId = check addSubmission(subMsg, fileReadBytes);
                subMsg.submissionId = submissionId;

                check streamer.close();
            }
        }
        

        check self.rabbitmqClient->publishMessage({
            content: subMsg,
            routingKey: data_model:QUEUE_NAME
        });
    
        return "Recieved Submission.";
    }

}

isolated function addSubmission(data_model:SubmissionMessage submissionMessage, byte[] submissionFile) returns string|error {
    sql:ExecutionResult result = check dbClient->execute(`
        INSERT INTO Submissions (user_id, contest_id, challenge_id, filename, file_extension)
        VALUES (${submissionMessage.userId}, ${submissionMessage.contestId}, ${submissionMessage.challengeId},  
        ${submissionMessage.fileName}, ${submissionMessage.fileExtension}, ${submissionFile})
    `);
    int|string? lastInsertId = result.lastInsertId;
    if lastInsertId is string {
        return lastInsertId;
    } else {
        return error("Unable to obtain last insert ID");
    }
}