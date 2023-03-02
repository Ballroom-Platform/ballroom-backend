import ballerina/jwt;
import ballerina/http;
import ballerinax/mysql;
import ballerina/sql;
import ballerina/regex;
import ballerinax/mysql.driver as _; // This bundles the driver to the project so that you don't need to bundle it via the `Ballerina.toml` file.
import ballerina/io;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

configurable string tokenIssuer = ?;
configurable string tokenAudience = ?;


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

    resource function get accessToken(http:Request request, http:Caller caller) returns ()|error {


        http:Response response = new;

        do{
            // json | error idpResult = verifyIDPToken(request, response, caller);

            // if idpResult is error{
            //     check idpResult;
            //     return;
            // }

            // if check idpResult.active == false {
            //     check respondError(response, caller, 403);
            //     return;
            // }

            // string userID = check idpResult.sub;
            string userID = "baf7303c-f34a-4c7e-b11d-4ed8186ad29c";

            json? userData = check getUserData(response, caller, userID);

            string accessToken = check generateToken(userData, 3600);

            string refreshToken = check generateToken(userData, 3600*24*30);

            check storeRefreshTokenUser(refreshToken, userID);


            http:CookieOptions cookieOptions = {
                maxAge: 300,
                httpOnly: true,
                secure: true
            };

            http:Cookie refreshTokenCookie = new("refreshToken", refreshToken, cookieOptions);

            response.addCookie(refreshTokenCookie);

            response.setPayload({
                data:{
                    accessToken
                }
            });

            response.statusCode = 200;
            check caller->respond(response);
        }
        on fail {
            response.statusCode = 500;
            check caller->respond(response);
        }
        return;
        
    }

    resource function get refreshToken(http:Request request, http:Caller caller) returns ()|error{
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
                check respondError(response, caller, 401);
                return;
            }

            string storedUserID = check getRefreshTokenUser(refreshToken);

            jwt:Payload? _ = check validateToken(refreshToken, storedUserID, response, caller);

            json? userData = check getUserData(response, caller, storedUserID);

            string accessToken = check generateToken(userData, 3600);

            response.setPayload({
                data:{
                    accessToken
                }
            });
            response.statusCode = 200;
            check caller->respond(response);
        }
        on fail {
            check respondError(response, caller, 500);
        }
        return;
    }
}

public function verifyIDPToken(http:Request request, http:Response response, http:Caller caller) returns json | error {
    string header = check request.getHeader("Authorization");
    string idpToken = (regex:split(header, " "))[1];
    http:Client idpClient = check new("https://api.asgardeo.io/t/ravin/oauth2");
    json | error res = idpClient->post("/introspect", headers = ({"Content-Type":"application/x-www-form-urlencoded","Connection": "keep-alive", "Authorization":"Basic dEJkVG42NjVtV2F5d2d6bTdkc1MyYUZ4MzVvYTpBS3V3enBORlVCbHBwdjhyazduSFFVQVlNWTBh"}),message = "token="+idpToken, targetType = json);
    io:println(res);
    return {};
    
}


public function getUserData(http:Response response, http:Caller caller, string userID) returns json | error{
    http:Client userClient = check new ("http://localhost:9095/userService");
    json | error responseData = userClient->get("/user/" + userID);
    if (responseData is error){
        return responseData;
    }
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

public function validateToken(string refreshToken, string storedUserID,  http:Response response, http:Caller caller) returns jwt:Payload | http:ListenerError? {
    jwt:ValidatorConfig config = {
        issuer: tokenIssuer,
        audience: tokenAudience,
        signatureConfig: {
            certFile: "./certificates/server.crt"
        }
    };


    jwt:Payload | jwt:Error payload = jwt:validate(refreshToken, config);

    if payload is jwt:Error{
        return respondError(response, caller, 401);
        
    }

    if payload.sub != storedUserID {
        return respondError(response, caller, 403);
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

public function respondError(http:Response response, http:Caller caller, int statusCode) returns http:ListenerError? {
    response.statusCode = statusCode;
    http:ListenerError? result = caller->respond(response);
    return result;
}
