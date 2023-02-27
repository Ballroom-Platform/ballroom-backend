import ballerina/jwt;
import ballerina/http;
import ballerinax/mysql;
import ballerina/sql;
import ballerinax/mysql.driver as _; // This bundles the driver to the project so that you don't need to bundle it via the `Ballerina.toml` file.

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

configurable string tokenIssuer = ?;
configurable string tokenAudience = ?;


# A service representing a network-accessible API
# bound to port `9090`.
service /sts on new http:Listener(9093) {


    resource function get accessToken(http:Request request, http:Caller caller) returns http:ListenerError?|error {


        http:Response response = new;

        //Verify IDP token here

        string userID = "001";

        json? | error userData = getUserData(response, caller, userID);

        if userData is error || userData is (){
            return respondError(response, caller, 500);
        }

        string|jwt:Error | error accessToken = generateToken(userData, 3600);

        string|jwt:Error | error refreshToken = generateToken(userData, 3600*24*30);

        if accessToken is jwt:Error || accessToken is error || refreshToken is jwt:Error || refreshToken is error{
            return respondError(response, caller, 500);
        }

        error? queryResult = storeRefreshTokenUser(refreshToken, userID);

        if queryResult is error{
            return respondError(response, caller, 500);
        }

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
        http:ListenerError? result = caller->respond(response);
        return result;
    }

    resource function get refreshToken(http:Request request, http:Caller caller) returns http:ListenerError?|error {
        http:Response response = new;
        http:Cookie[] cookies = request.getCookies();
        string? refreshToken = ();
        foreach http:Cookie cookie in cookies {
            if cookie.name == "refreshToken" && check cookie.isValid(){
                refreshToken = cookie.toStringValue();
                break;
            }
        }

        if refreshToken is () {
            return respondError(response, caller, 401);
        }

        string? | error storedUserID = getRefreshTokenUser(refreshToken);

        if(storedUserID is error){
            return respondError(response, caller, 500);
        }

        if(storedUserID is ()){
            return respondError(response, caller, 401);
        }

        jwt:Payload | http:ListenerError? payload = validateToken(refreshToken, storedUserID, response, caller);
        if payload is http:ListenerError {
            return payload;
        }

        json? | error userData = getUserData(response, caller, storedUserID);

        if userData is error || userData is (){
            return respondError(response, caller, 500);
        }

        string|jwt:Error | error accessToken = generateToken(userData, 3600);

        if accessToken is jwt:Error || accessToken is error{
            return respondError(response, caller, 500);
        }

        response.setPayload({
            data:{
                accessToken
            }
        });
        response.statusCode = 200;
        http:ListenerError? result = caller->respond(response);
        return result;
    }
}


public function getUserData(http:Response response, http:Caller caller, string userID) returns json? | error{
    http:Client userClient = check new ("http://localhost:9095/userService");
    json | error responseData = userClient->get("/user/" + userID);
    if (responseData is error){
        return respondError(response, caller, 500);
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



public function getRefreshTokenUser(string refreshToken) returns string? | error{
    final mysql:Client dbClient =  check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);

    string?|sql:Error result = dbClient->queryRow(`SELECT user_id FROM refresh_token WHERE refresh_token = ${refreshToken};`);

    check dbClient.close();

    if(result is error){
        return ();
    }

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
