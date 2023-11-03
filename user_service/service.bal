// Copyright (c) 2023 WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/log;
import tharinduu/data_model;
import tharinduu/entities;
import ballerinax/scim;
import ballerina/mime;
import ballerina/persist;

configurable string orgName = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string adminGroupId = ?;
configurable string contestantGroupId = ?;

scim:ConnectorConfig config = {
    orgName: orgName,
    clientId: clientId,
    clientSecret: clientSecret,
    scope: ["internal_group_mgt_view", "internal_user_mgt_view", "internal_group_mgt_update", "internal_user_mgt_list"]
};

public type Payload record {
    string message;
    anydata data;
};

type UserData record {|
    string id;
    string username;
    string fullname;
|};

public type Role record {
    json[] groups;
};

final entities:Client db = check new ();

# A service representing a network-accessible API
# bound to port `9090`.
@display {
    label: "User Service",
    id: "UserService"
}
@http:ServiceConfig {
    cors: {
        allowOrigins: ["https://localhost:3000","https://ballroom.ballerina.io"],
        allowCredentials: true,
        allowHeaders: ["CORELATION_ID", "Authorization", "Content-type", "ngrok-skip-browser-warning"],
        exposeHeaders: ["X-CUSTOM-HEADER"],
        maxAge: 84900
    }
}
service /userService on new http:Listener(9095) {
    private final entities:Client db;
    private final scim:Client scimClient;

    function init() returns error? {
        self.db = check new ();
        self.scimClient = check new (config);
        log:printInfo("User service started...");
    }

    resource isolated function get users/[string userId]() returns Payload|http:NotFound|http:InternalServerError {
        scim:UserResource|scim:ErrorResponse|error userData = self.scimClient->getUser(userId);
        if userData is scim:UserResource {
            string username = userData.userName ?: "";
            username = username.substring(8);
            scim:Name name = userData.name ?: {};
            string givenName = name.givenName ?: "";
            string familyName = name.familyName ?: "";
            string fullname = givenName + " " + familyName;
            json groups = userData.toJson();
            Role|error roles = groups.cloneWithType();
            if roles is error {
                log:printError("Error while retrieving user", userId = userId, 'error = roles);
                return http:INTERNAL_SERVER_ERROR;
            } else {
                json|error roleJson = roles.groups[0].display;
                if roleJson is error {
                    log:printError("Error while retrieving user", userId = userId, 'error = roleJson);
                    return http:INTERNAL_SERVER_ERROR;
                } else {
                    string role = roleJson.toString().substring(8);
                    data_model:User user = {
                        user_id: userId,
                        username: username,
                        fullname: fullname,
                        role: role
                    };
                    Payload responsePayload = {
                        message: "User found",
                        data: user
                    };
                    return responsePayload;
                }
            }
        } else if userData is scim:ErrorResponse {
            log:printError("Error while retrieving user", userId = userId, 'error = userData);
            return http:INTERNAL_SERVER_ERROR;
        } else {
            log:printError("Error while retrieving user", userId = userId, 'error = userData);
            return http:INTERNAL_SERVER_ERROR;
        }
    }

    resource isolated function get users(string? role) returns data_model:User[]|http:NotFound|http:InternalServerError {
        scim:UserResponse|scim:ErrorResponse|error usersData = self.scimClient->getUsers();
        if usersData is scim:UserResponse {
            scim:UserResource[] resources = usersData.Resources ?: [];
            data_model:User[] users = [];
            foreach scim:UserResource item in resources {
                string userId = item.id ?: "";
                string username = item.userName ?: "";
                username = username.substring(8);
                scim:Name name = item.name ?: {};
                string givenName = name.givenName ?: "";
                string familyName = name.familyName ?: "";
                string fullname = givenName + " " + familyName;
                json groups = item.toJson();
                Role|error roles = groups.cloneWithType();
                if roles is error {
                    log:printError("Error while retrieving users", userId = userId, 'error = roles);
                    return http:INTERNAL_SERVER_ERROR;
                } else {
                    json|error roleJson = roles.groups[0].display;
                    if roleJson is error {
                        log:printError("Error while retrieving users", userId = userId, 'error = roleJson);
                        return http:INTERNAL_SERVER_ERROR;
                    } else {
                        string userrole = roleJson.toString().substring(8);
                        if role != null {
                            if role == userrole {
                                data_model:User user = {
                                    user_id: userId,
                                    username: username,
                                    fullname: fullname,
                                    role: role
                                };
                                users.push(user);
                            }
                        } else {
                            data_model:User user = {
                                user_id: userId,
                                username: username,
                                fullname: fullname,
                                role: userrole
                            };
                            users.push(user);
                        }
                    }
                }
            }
            return users;
        } else if usersData is scim:ErrorResponse {
            log:printError("Error while retrieving users", 'error = usersData);
            return http:INTERNAL_SERVER_ERROR;
        } else {
            log:printError("Error while retrieving users", 'error = usersData);
            return http:INTERNAL_SERVER_ERROR;
        }
    }

    resource isolated function get users/[string userId]/roles() returns Payload|http:NotFound|http:InternalServerError {
        scim:UserResource|scim:ErrorResponse|error userData = self.scimClient->getUser(userId);
        if userData is scim:UserResource {
            json groups = userData.toJson();
            Role|error roles = groups.cloneWithType();
            if roles is error {
                log:printError("Error while retrieving user", userId = userId, 'error = roles);
                return http:INTERNAL_SERVER_ERROR;
            } else {
                json|error roleJson = roles.groups[0].display;
                if roleJson is error {
                    log:printError("Error while retrieving user", userId = userId, 'error = roleJson);
                    return http:INTERNAL_SERVER_ERROR;
                } else {
                    string role = roleJson.toString().substring(8);
                    Payload responsePayload = {
                        message: "Role found",
                        data: {
                            "role": role
                        }
                    };
                    return responsePayload;
                }
            }
        } else if userData is scim:ErrorResponse {
            log:printError("Error while retrieving user", userId = userId, 'error = userData);
            return http:INTERNAL_SERVER_ERROR;
        } else {
            log:printError("Error while retrieving user", userId = userId, 'error = userData);
            return http:INTERNAL_SERVER_ERROR;
        }
    }

    resource isolated function post users(http:Request request) returns string|http:BadRequest|http:InternalServerError|http:Conflict|error {
        mime:Entity[] bodyParts = check request.getBodyParts();
        if bodyParts.length() != 3 {
            return <http:BadRequest>{
                body: {
                    message: string `Expects 3 bodyparts but found ${bodyParts.length()}`

                }
            };
        }
        map<mime:Entity> bodyPartMap = {};
        foreach mime:Entity entity in bodyParts {
            bodyPartMap[entity.getContentDisposition().name] = entity;
        }
        if !bodyPartMap.hasKey("userId") || !bodyPartMap.hasKey("username") ||
            !bodyPartMap.hasKey("fullname") {
            return <http:BadRequest>{
                body: {
                    message: string `Expects 3 bodyparts with names 'userId', 'username' and 'fullname'`
                }
            };
        }

        entities:User entityUser = {
            id: check bodyPartMap.get("userId").getText(),
            username: check bodyPartMap.get("username").getText(),
            fullname: check bodyPartMap.get("fullname").getText()
        };

        stream<UserData, persist:Error?> users = self.db->/users;
        UserData[]|persist:Error duplicates = from var user in users
            where user.id == entityUser.id
            select user;
        if duplicates is persist:Error {
            log:printError("Error while reading users data", 'error = duplicates);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while adding user`
                }
            };
        }

        if duplicates.length() > 0 {
            return <http:Conflict>{
                body: {
                    message: string `User already in database`
                }
            };
        }

        string[]|persist:Error insertedIds = self.db->/users.post([entityUser]);
        if insertedIds is persist:Error {
            return <http:InternalServerError>{
                body: {
                    message: string `Error while adding user`
                }
            };
        } else {
            return insertedIds[0];
        }
    }

    resource isolated function patch users/[string userId]/changerole(http:Request request) returns http:NoContent|http:BadRequest|http:NotFound|http:InternalServerError {
        string role = "";
        string userName = "";
        mime:Entity[]|http:ClientError bodyParts = request.getBodyParts();
        map<mime:Entity> bodyPartMap = {};
        if bodyParts is http:ClientError {
            return <http:InternalServerError>{
                body: {
                    message: bodyParts.toString()
                }
            };
        }
        else {
            foreach mime:Entity entity in bodyParts {
                bodyPartMap[entity.getContentDisposition().name] = entity;
            }
        }
        do {
            role = check bodyPartMap.get("role").getText();
            userName = check bodyPartMap.get("userName").getText();
        } on fail var e {
            return <http:InternalServerError>{
                body: {
                    message: e.message()
                }
            };
        }
        if role != "admin" && role != "contestant" {
            return <http:BadRequest>{
                body: string `Invalid role '${role}'`
            };
        }
        scim:GroupPatch updateData = {
            schemas: ["urn:ietf:params:scim:api:messages:2.0:PatchOp"],
            Operations: [
                {
                    op: "add",
                    value: {
                        members: [
                            {
                                display: userName,
                                value: userId
                            }
                        ]
                    }
                }
            ]
        };
        scim:GroupPatch removeData = {
            schemas: ["urn:ietf:params:scim:api:messages:2.0:PatchOp"],
            Operations: [
                {
                    op: "remove",
                    path: "members[value eq \"" + userId + "\"]",
                    value: {
                        members: [
                            {
                                display: userName,
                                value: userId
                            }
                        ]
                    }
                }
            ]
        };
        if role == "admin" {
            scim:GroupResponse|scim:ErrorResponse|error updateGroup = self.scimClient->patchGroup(adminGroupId, updateData);
            if updateGroup is error {
                log:printError(updateGroup.toBalString());
                return http:INTERNAL_SERVER_ERROR;
            } else {
                scim:GroupResponse|scim:ErrorResponse|error removeFromGroup = self.scimClient->patchGroup(contestantGroupId, removeData);
                if removeFromGroup is error {
                    log:printError(removeFromGroup.toBalString());
                    return http:INTERNAL_SERVER_ERROR;
                } else {
                    return http:NO_CONTENT;
                }
            }
        } else if role == "contestant" {
            scim:GroupResponse|scim:ErrorResponse|error updateGroup = self.scimClient->patchGroup(contestantGroupId, updateData);
            if updateGroup is error {
                log:printError(updateGroup.toBalString());
                return http:INTERNAL_SERVER_ERROR;
            } else {
                scim:GroupResponse|scim:ErrorResponse|error removeFromGroup = self.scimClient->patchGroup(adminGroupId, removeData);
                if removeFromGroup is error {
                    log:printError(removeFromGroup.toBalString());
                    return http:INTERNAL_SERVER_ERROR;
                } else {
                    return http:NO_CONTENT;
                }
            }
        }
    }
}
