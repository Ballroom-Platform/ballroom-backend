import ballerina/http;
import ballerina/log;
import ballroom/data_model;
import ballroom/entities;
import ballerina/persist;

public type Payload record {
    string message;
    anydata data;
};

final entities:Client db = check new ();

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

    resource function get users/[string userId]() returns Payload|http:NotFound|http:InternalServerError {
        entities:User|persist:Error userEntity = db->/users/[userId];
        if userEntity is persist:InvalidKeyError {
            return http:NOT_FOUND;
        } else if userEntity is persist:Error {
            log:printError("Error while retrieving user", userId = userId, 'error = userEntity);
            return http:INTERNAL_SERVER_ERROR;
        } else {
            data_model:User user = toDataModelUser(userEntity);
            Payload responsePayload = {
                message: "User found",
                data: user
            };
            return responsePayload;
        }
    }

    resource function get users(string? role) returns data_model:User[]|http:NotFound|http:InternalServerError {
        stream<entities:User, persist:Error?> userStream = db->/users;
        data_model:User[]|persist:Error users = [];
        if role != null {
            users = from entities:User user in userStream
                where user.role == role
                select toDataModelUser(user);
        } else {
            users = from entities:User user in userStream
            select toDataModelUser(user);
        }

        if users is persist:Error {
            log:printError("Error while retrieving users", 'error = users);
            return http:INTERNAL_SERVER_ERROR;
        } else {
            return users;
        }
    }

    resource function get users/[string userId]/roles() returns Payload|http:NotFound|http:InternalServerError {
        entities:User|persist:Error userEntity = db->/users/[userId];
        if userEntity is persist:InvalidKeyError {
            return http:NOT_FOUND;
        } else if userEntity is persist:Error {
            log:printError("Error while retrieving user role", userId = userId, 'error = userEntity);
            return http:INTERNAL_SERVER_ERROR;
        } else {
            Payload payload = {
                message: "Role found",
                data: {
                    "role": userEntity.role
                }
            };
            return payload;
        }
    }

    resource function post users(@http:Payload data_model:User user) returns Payload|http:InternalServerError {
        log:printInfo("Post user invoked", user = user);
        string[]|persist:Error userEntity = db->/users.post([{
            id: user.user_id,
            username: user.username,
            fullname: user.fullname,
            role: user.role
        }]);
        if userEntity is persist:Error {
            log:printError("Error while creating user", user = user, 'error = userEntity);
            return http:INTERNAL_SERVER_ERROR;
        } else {
            Payload responsePayload = {
                message: "User created",
                data: user
            };
            return responsePayload;
        }
    }

    resource function put users/[string userId]/roles/[string role]() returns http:NoContent|http:BadRequest|http:NotFound|http:InternalServerError {
        log:printInfo("Put user invoked", userId = userId, role = role);
        if role != "admin" && role != "contestant" {
            return <http:BadRequest>{
                body: string `Invalid role '${role}'`
            };
        }

        entities:User|persist:Error updatedUser = db->/users/[userId].put({role: role});
        if updatedUser is persist:InvalidKeyError {
            return http:NOT_FOUND;
        } else if updatedUser is persist:Error {
            log:printError("Error while updating user role", userId = userId, role = role, 'error = updatedUser);
            return http:INTERNAL_SERVER_ERROR;
        } else {
            return http:NO_CONTENT;
        }
    }
}

function toDataModelUser(entities:User userEntity) returns data_model:User => {
    user_id: userEntity.id,
    username: userEntity.username,
    fullname: userEntity.fullname,
    role: userEntity.role
};
