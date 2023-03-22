import ballerina/http;
import wso2/data_model;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

# A service representing a network-accessible API
# bound to port `9090`.
service /userService on new http:Listener(9095) {


    resource function get user/[string userID]() returns Payload | http:InternalServerError {
        
        do{
            data_model:User | error result = getUserData(userID);

            if(result is error){
                Payload responsePayload = {
                    message : "No User found",
                    data : ()
                };
                return responsePayload;
            }
            Payload responsePayload = {
                message : "User found",
                data : result
            };
            return responsePayload;
        }
        on fail{
            return http:INTERNAL_SERVER_ERROR;
        }
        
    }
}
