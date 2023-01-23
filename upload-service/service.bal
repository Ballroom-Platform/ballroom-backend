import ballerina/http;
import ballerina/mime;
import ballerina/regex;
import ballerina/io;
import ballerinax/rabbitmq;
import wso2/data_model;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

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
        
        mime:Entity[] bodyParts = check request.getBodyParts();

        data_model:SubmissionMessage subMsg = {userId: "", challengeId: "", contestId: "", fileLocation: ""};

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
                check io:fileWriteBlocksFromStream("./files/"  + fileName + ".zip", streamer);
                // subMsg.fileLocation = "./files/"  + fileName + ".zip";
                subMsg.fileLocation = fileName + ".zip";
                check streamer.close();
            }
        }

        check self.rabbitmqClient->publishMessage({
            content: subMsg,
            routingKey: "RequestQueue"
        });
    
        return "Recieved Submission.";
    }
}
