import ballerina/http;
import ballerina/sql;
import wso2/data_model;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

# A service representing a network-accessible API
# bound to port `9090`.
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://www.m3.com", "http://www.hello.com", "https://localhost:3000"],
        allowCredentials: false,
        allowHeaders: ["CORELATION_ID"],
        exposeHeaders: ["X-CUSTOM-HEADER", "Authorization"],
        maxAge: 84900
    }
}
service /userService on new http:Listener(9095) {


    resource function get user/[string userID]() returns Payload | http:InternalServerError | http:STATUS_NOT_FOUND {
        
        do{
            data_model:User | error result = getUserData(userID);

            if(result is error){
                return http:STATUS_NOT_FOUND;
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

    @http:ResourceConfig {
        cors: {
            allowOrigins: ["http://www.m3.com", "http://www.hello.com", "https://localhost:3000"],
            allowCredentials: true,
            allowHeaders: ["X-Content-Type-Options", "X-PINGOTHER", "Authorization"]
        }
    }
    resource function get users/role/[string role] () returns data_model:User[] | http:InternalServerError | http:STATUS_NOT_FOUND {
        
        do{

            data_model:User[]|sql:Error? usersByRole = getUsersByRole(role);

            if usersByRole is data_model:User[] {
                return usersByRole;
            } else {
                return http:STATUS_NOT_FOUND;
            }

        }
        on fail{
            return http:INTERNAL_SERVER_ERROR;
        }
        
    }

    @http:ResourceConfig {
        cors: {
            allowOrigins: ["http://www.m3.com", "http://www.hello.com", "https://localhost:3000"],
            allowCredentials: true,
            allowHeaders: ["X-Content-Type-Options", "X-PINGOTHER", "Authorization"]
        }
    }
    resource function get user/[string userId]/role () returns Payload | http:InternalServerError | http:STATUS_NOT_FOUND {
        
        do{

            string role = check getUserRole(userId);
            Payload payload = {
                message: "Role found",
                data: {
                    "role" : role
                }
            };
            return payload;

        }
        on fail{
            return http:STATUS_NOT_FOUND;
        }
        
    }


    resource function post user(@http:Payload data_model:User user) returns Payload | http:InternalServerError {
        
        do{
            _ = check createUser(user);

            Payload responsePayload = {
                message : "User created",
                data : user
            };
            return responsePayload;
        }
        on fail{
            return http:INTERNAL_SERVER_ERROR;
        }
        
    }

    @http:ResourceConfig {
        cors: {
            allowOrigins: ["http://www.m3.com", "http://www.hello.com", "https://localhost:3000"],
            allowCredentials: true,
            allowHeaders: ["X-Content-Type-Options", "X-PINGOTHER", "Authorization"]
        }
    }
    resource function put users/[string userId]/role/[string role] () returns error? {
        error? userRole = updateUserRole(userId, role);
        return userRole;
    }
}
