import ballerina/http;
import ballerina/sql;
import ballerina/log;
import ballroom/data_model;
import ballerina/io;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

# A service representing a network-accessible API
# bound to port `9090`.
#
@display {
    label: "User Service",
    id: "UserService"
}
@http:ServiceConfig {
    cors: {
        allowOrigins: ["https://localhost:3000"],
        allowCredentials: true,
        allowHeaders: ["CORELATION_ID", "Authorization", "Content-type", "ngrok-skip-browser-warning"],
        exposeHeaders: ["X-CUSTOM-HEADER"],
        maxAge: 84900
    }
}
service /userService on new http:Listener(9095) {

    function init() {
        log:printInfo("User service started...");
    }

    resource function get users/[string userID]() returns Payload|http:InternalServerError|http:STATUS_NOT_FOUND {
        io:println("Get user invoked");
        do {
            data_model:User|error result = getUserData(userID);

            if (result is error) {
                return http:STATUS_NOT_FOUND;
            }
            Payload responsePayload = {
                message: "User found",
                data: result
            };
            return responsePayload;
        }
        on fail {
            return http:INTERNAL_SERVER_ERROR;
        }

    }

    resource function get users(string role) returns data_model:User[]|http:InternalServerError|http:STATUS_NOT_FOUND {
        do {

            data_model:User[]|sql:Error? usersByRole = getUsersByRole(role);

            if usersByRole is data_model:User[] {
                return usersByRole;
            } else {
                return http:STATUS_NOT_FOUND;
            }

        }
        on fail {
            return http:INTERNAL_SERVER_ERROR;
        }
    }

    resource function get users/[string userId]/roles() returns Payload|http:InternalServerError|http:STATUS_NOT_FOUND {

        do {

            string role = check getUserRole(userId);
            Payload payload = {
                message: "Role found",
                data: {
                    "role": role
                }
            };
            return payload;

        }
        on fail {
            return http:STATUS_NOT_FOUND;
        }

    }

    resource function post users(@http:Payload data_model:User user) returns Payload|http:InternalServerError {
        log:printInfo("Post user invoked", user = user);
        do {
            _ = check createUser(user);

            Payload responsePayload = {
                message: "User created",
                data: user
            };
            return responsePayload;
        }
        on fail {
            return http:INTERNAL_SERVER_ERROR;
        }

    }

    resource function put users/[string userId]/roles/[string role]() returns error? {
        log:printInfo("Put user invoked", userId = userId, role = role);
        error? userRole = updateUserRole(userId, role);
        return userRole;
    }
}
