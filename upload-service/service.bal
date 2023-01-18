import ballerina/http;
import ballerina/mime;
import ballerina/regex;
import ballerina/io;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for uploading solutions to challenges
    # + request - the input solution file as a multipart request with userId, challengeId & the solution as a zip file
    # + return - response message from server
    resource function post uploadSolution(http:Request request) returns string|error {
        
        mime:Entity[] bodyParts = check request.getBodyParts();
        foreach mime:Entity item in bodyParts {

            // check if the body part is a zipped file or normal text
            if item.getContentType().length() == 0  {
                io:println(item.getText());
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
                check streamer.close();
            }
        }
    
        return "Recieved Submission.";
    }
}
