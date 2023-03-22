import ballerina/http;
import ballerina/jwt;

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

    isolated resource function get accessToken(@http:Header string Authorization) returns http:Forbidden | http:Response | http:InternalServerError {

        do{
            // json idpResult = check verifyIDPToken(authorization);

            // if check idpResult.active == false {
            //     return http:FORBIDDEN;
            // }

            // string userID = check idpResult.sub;
            string userID = "baf7303c-f34a-4c7e-b11d-4ed8186ad29c";

            json? userData = check getUserData(userID);

            string accessToken = check generateToken(userData, 3600);

            string refreshToken = check generateToken(userData, 3600*24*30);

            check storeRefreshTokenUser(refreshToken, userID);


            http:CookieOptions cookieOptions = {
                maxAge: 300,
                httpOnly: true,
                secure: true
            };

            http:Cookie refreshTokenCookie = new("refreshToken", refreshToken, cookieOptions);

            http:Response response = new;

            response.addCookie(refreshTokenCookie);

            Payload responsePayload = {
                data : {
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

    isolated resource function get refreshToken(http:Request request) returns http:Unauthorized | http:Forbidden | http:Response | http:InternalServerError{
        http:Response response = new;
        do{
            http:Cookie[] cookies = request.getCookies();
            string? refreshToken = ();
            foreach http:Cookie cookie in cookies {
                if cookie.name == "refreshToken" && check cookie.isValid(){
                    refreshToken = cookie.toStringValue();
                    break;
                }
            }

            if refreshToken is () {
                return http:UNAUTHORIZED;
            }

            string storedUserID = check getRefreshTokenUser(refreshToken);

            jwt:Payload | http:Forbidden | http:Unauthorized tokenPayload = validateToken(refreshToken, storedUserID);

            if tokenPayload is http:Unauthorized || tokenPayload is http:Forbidden {
                return tokenPayload;
            }

            json userData = check getUserData(storedUserID);

            string accessToken = check generateToken(userData, 3600);

            Payload responsePayload = {
                data : {
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
