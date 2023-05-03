import ballerina/http;
import ballerina/jwt;
import ballroom/data_model;
import ballerina/log;
import ballerina/io;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

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
        allowHeaders: ["CORELATION_ID", "Authorization"],
        exposeHeaders: ["X-CUSTOM-HEADER"],
        maxAge: 84900
    }
}
service /sts on new http:Listener(9093) {

    function init() {
        log:printInfo("STS service started...");
    }

    isolated resource function get accessToken(@http:Header string Authorization) returns http:Forbidden|http:Response|http:InternalServerError {
        log:printInfo("Access token request received");
        do {
            json idpResult = check verifyIDPToken(Authorization);

            if check idpResult.active == false {
                return http:FORBIDDEN;
            }

            string userID = check idpResult.sub;
            log:printInfo("User ID: ", userID = userID);
            json? userInfo = check getUserInfoFromIDP(Authorization);
            log:printInfo("User info: ", userInfo = userInfo.toString());
            json?|error userData = getUserData(userID);
            if userData is error? {
                data_model:User user = {
                    fullname: check userInfo?.name,
                    role: "contestant",
                    user_id: userID,
                    username: check userInfo?.username
                };
                log:printInfo("User: ", user = user);

                _ = check userService->/users.post(user);
                log:printInfo("User added to the database");

                userData = check getUserData(userID);
                log:printInfo("User data recived ");
            }

            io:println("Generating access token");
            string accessToken = check generateToken(check userData, 3600);
            log:printInfo("Access token generated", accessToken = accessToken);

            string refreshToken = check generateToken(check userData, 3600 * 24 * 30);
            log:printInfo("Access token generated", accessToken = accessToken);

            check storeRefreshTokenUser(refreshToken, userID);
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

    isolated resource function get refreshToken(http:Request request) returns http:Unauthorized|http:Forbidden|http:Response|http:InternalServerError {
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
