import ballerina/jwt;
import ballerina/http;
import ballerinax/mysql;
import ballerina/sql;
import ballerina/regex;
import ballerinax/mysql.driver as _; // This bundles the driver to the project so that you don't need to bundle it via the `Ballerina.toml` file.

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
        allowCredentials: false,
        allowHeaders: ["CORELATION_ID"],
        exposeHeaders: ["X-CUSTOM-HEADER"],
        maxAge: 84900
    }
}
service /sts on new http:Listener(9093) {

    resource function get accessToken(@http:Header string authorization) returns http:Forbidden | http:Response | http:InternalServerError {

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

            response.setPayload(<json>responsePayload);

            response.statusCode = 200;
            return response;
        }
        on fail {
            return http:INTERNAL_SERVER_ERROR;
        }
        
    }

    resource function get refreshToken(http:Request request) returns http:Unauthorized | http:Forbidden | http:Response | http:InternalServerError{
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

            response.setPayload(<json>responsePayload);
            response.statusCode = 200;
            return response;
        }
        on fail {
            return http:INTERNAL_SERVER_ERROR;
        }
    }
}

public function verifyIDPToken(string header) returns json | error {
    string idpToken = (regex:split(header, " "))[1];
    http:Client idpClient = check new("https://api.asgardeo.io/t/ravin/oauth2");
    json res = check idpClient->post("/introspect", headers = ({"Content-Type":"application/x-www-form-urlencoded","Connection": "keep-alive", "Authorization":"Basic dEJkVG42NjVtV2F5d2d6bTdkc1MyYUZ4MzVvYTpBS3V3enBORlVCbHBwdjhyazduSFFVQVlNWTBh"}),message = "token="+idpToken, targetType = json);
    return res;
    
}


public function getUserData(string userID) returns json | error{
    http:Client userClient = check new ("http://localhost:9095/userService");
    json responseData = check userClient->get("/user/" + userID);
    return check responseData.data;
}

public function generateToken(json userData, decimal expTime) returns string | jwt:Error | error{
    jwt:IssuerConfig issueConfig = {
            username: check userData.user_id,
            issuer: tokenIssuer,
            audience: tokenAudience,
            expTime: expTime,
            signatureConfig: {
                config: {
                    keyFile: "./certificates/server.key"
                }
            },customClaims: {
                user: userData,
                scp: [check userData.role]
            }
    };

    return jwt:issue(issueConfig);
}

public function validateToken(string refreshToken, string storedUserID) returns jwt:Payload | http:Unauthorized | http:Forbidden {
    jwt:ValidatorConfig config = {
        issuer: tokenIssuer,
        audience: tokenAudience,
        signatureConfig: {
            certFile: "./certificates/server.crt"
        }
    };


    jwt:Payload | jwt:Error payload = jwt:validate(refreshToken, config);

    if payload is jwt:Error{
        return http:UNAUTHORIZED;       
    }

    if payload.sub != storedUserID {
        return http:FORBIDDEN;
    }

    return payload;
}



public function getRefreshTokenUser(string refreshToken) returns string | error{
    final mysql:Client dbClient =  check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);

    string|sql:Error result = dbClient->queryRow(`SELECT user_id FROM refresh_token WHERE refresh_token = ${refreshToken};`);

    check dbClient.close();

    return result;
}

public function storeRefreshTokenUser(string refreshToken, string userID) returns error? {
    final mysql:Client dbClient =  check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);
    _ = check dbClient->execute(`INSERT INTO refresh_token (user_id, refresh_token) VALUES (${userID}, ${refreshToken});`);

    check dbClient.close();
}
