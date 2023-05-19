import ballerina/http;
import ballerina/jwt;
import ballroom/data_model;
import ballerina/log;
import ballerina/io;

import sts_service.user;

configurable string tokenIssuer = ?;
configurable string tokenAudience = ?;

public type Payload record {
    Data data;
};

public type Data record {
    string accessToken;
};

# A service representing a network-accessible API
# bound to port `9090`.
@display {
    label: "STS Service",
    id: "STSService"
}
@http:ServiceConfig {
    cors: {
        allowOrigins: ["https://localhost:3000"],
        allowCredentials: true,
        allowHeaders: ["CORELATION_ID", "Authorization", "ngrok-skip-browser-warning"],
        exposeHeaders: ["X-CUSTOM-HEADER"],
        maxAge: 84900
    }
}
service /sts on new http:Listener(9093) {

    function init() {
        log:printInfo("STS service started...");
    }

    resource function get accessToken(@http:Header string Authorization)
            returns http:Forbidden|http:Response|http:InternalServerError {
        log:printInfo("Access token request received");
        do {
            // TODO Refactor this code to work with application-specific types
            json idpResult = check verifyIDPToken(Authorization);
            if check idpResult.active == false {
                return http:FORBIDDEN;
            }

            string userId = check idpResult.sub;
            log:printInfo("User id: ", userId = userId);

            json userInfo = check getUserInfoFromIDP(Authorization);
            log:printInfo("User info: ", userInfo = userInfo);

            json|error userData = getUserData(userId);
            if userData is error? {
                // User does not exist in the database. Add the user to the database
                data_model:User newUser = {
                    fullname: check userInfo?.name,
                    role: "contestant",
                    user_id: userId,
                    username: check userInfo?.username
                };
                log:printInfo("Adding a new user: ", user = newUser);
                user:Payload payload = check userService->/users.post(newUser);
                log:printInfo("User added to the database");
                userData = payload.data.toJson();
            }

            io:println("Generating access token");
            string accessToken = check generateToken(check userData, 3600);
            log:printInfo("Access token generated", accessToken = accessToken);

            string refreshToken = check generateToken(check userData, 3600 * 24 * 30);
            log:printInfo("Access token generated", accessToken = accessToken);

            check storeRefreshTokenUser(refreshToken, userId);
            log:printInfo("Refresh token stored");

            http:CookieOptions cookieOptions = {
                maxAge: 300,
                httpOnly: true,
                secure: true
            };

            http:Cookie refreshTokenCookie = new ("refreshToken", refreshToken, cookieOptions);
            http:Response response = new;
            response.addCookie(refreshTokenCookie);
            Payload responsePayload = {
                data: {
                    accessToken
                }
            };

            response.setPayload(responsePayload.toJson());
            response.statusCode = 200;
            return response;
        }
        on fail error e {
            log:printError("Error occured", 'error = e);
            return http:INTERNAL_SERVER_ERROR;
        }
    }

    resource function get refreshToken(http:Request request)
            returns http:Unauthorized|http:Forbidden|http:Response|http:InternalServerError {
        http:Response response = new;
        do {
            http:Cookie[] cookies = request.getCookies();
            string? refreshToken = ();
            foreach http:Cookie cookie in cookies {
                if cookie.name == "refreshToken" && check cookie.isValid() {
                    refreshToken = cookie.toStringValue();
                    break;
                }
            }

            if refreshToken is () {
                return http:UNAUTHORIZED;
            }

            string storedUserID = check getRefreshTokenUser(refreshToken);
            jwt:Payload|http:Forbidden|http:Unauthorized tokenPayload = validateToken(refreshToken, storedUserID);
            if tokenPayload is http:Unauthorized || tokenPayload is http:Forbidden {
                return tokenPayload;
            }

            json userData = check getUserData(storedUserID);
            string accessToken = check generateToken(userData, 3600);
            Payload responsePayload = {
                data: {
                    accessToken
                }
            };

            response.setPayload(responsePayload.toJson());
            response.statusCode = 200;
            return response;
        }
        on fail {
            return http:INTERNAL_SERVER_ERROR;
        }
    }
}
