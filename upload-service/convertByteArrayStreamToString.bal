import ballerina/mime;
import ballerina/io;


function convertByteArrayStreamToString(stream<byte[], io:Error?> streamer) returns string|error {

        string returnString = "";

        while true {
            
            record {|byte[] value;|}|io:Error? nextByteArray = streamer.next();

            if nextByteArray is record {|byte[] value;|} {

                string|byte[]|io:ReadableByteChannel|mime:EncodeError base64EncodeByteArray = mime:base64Encode(nextByteArray.value);
                if base64EncodeByteArray is string {
                    return error("Custom Error --> Invalid input: Expected 'byte[]', found 'string'");
                } else if base64EncodeByteArray is byte[] {
                    // Actual code we need to run (All else are error handling. Need to find better way to do later.)
                    string base64EncodedString = check string:fromBytes(base64EncodeByteArray);
                    returnString = returnString.concat(base64EncodedString);

                } else if base64EncodeByteArray is io:ReadableByteChannel {
                    return error("Custom Error --> Invalid input: Expected 'byte[]', found 'io:ReadableByteChannel'");
                } else {
                    return error("Custom Error --> Invalid input: Expected 'byte[]', found nothing");
                }
                
            } else {

                break;
            }
        }

        return returnString;
    }