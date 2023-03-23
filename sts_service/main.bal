import ballerina/jwt;
import ballerina/http;
import ballerinax/mysql;
import ballerina/sql;
import ballerina/regex;
import ballerinax/mysql.driver as _; // This bundles the driver to the project so that you don't need to bundle it via the `Ballerina.toml` file.
import ballerina/io;


public isolated function verifyIDPToken(string header) returns json | error {
    string idpToken = (regex:split(header, " "))[1];
    http:Client idpClient = check new("https://api.asgardeo.io/t/ravin/oauth2");
    json | error res = idpClient->post("/introspect", 
    headers = ({
        "Content-Type":"application/x-www-form-urlencoded",
        "Connection": "keep-alive", 
        "Authorization":"Basic dEJkVG42NjVtV2F5d2d6bTdkc1MyYUZ4MzVvYTpBS3V3enBORlVCbHBwdjhyazduSFFVQVlNWTBh"})
        ,message = "token="+idpToken, 
        targetType = json);
    return res;
    
}

public isolated function getUserInfoFromIDP(string header) returns json | error {
    string idpToken = (regex:split(header, " "))[1];
    http:Client userClient = check new("https://api.asgardeo.io/t/ravin/oauth2");
    json | error res = userClient->get("/userinfo", headers={
        "Authorization":"Bearer "+ idpToken
    });
    io:println(res);
    return res;
}


public isolated function getUserData(string userID) returns json | error{
    http:Client userClient = check new ("http://localhost:9095/userService");
    json responseData = check userClient->get("/user/" + userID);
    return check responseData.data;
}

public isolated function generateToken(json userData, decimal expTime) returns string | jwt:Error | error{
    jwt:IssuerConfig issueConfig = {
            username: check userData.user_id,
            issuer: tokenIssuer,
            audience: tokenAudience,
            expTime: expTime,
            signatureConfig: {
                config: {
                    keyFile: "./certificates/jwt/server.key"
                }
            },customClaims: {
                user: userData,
                scp: [check userData.role]
            }
    };

    return jwt:issue(issueConfig);
}

public isolated function validateToken(string refreshToken, string storedUserID) returns jwt:Payload | http:Unauthorized | http:Forbidden {
    jwt:ValidatorConfig config = {
        issuer: tokenIssuer,
        audience: tokenAudience,
        signatureConfig: {
            certFile: "./certificates/jwt/server.crt"
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



public isolated function getRefreshTokenUser(string refreshToken) returns string | error{
    final mysql:Client dbClient =  check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);

    string|sql:Error result = dbClient->queryRow(`SELECT user_id FROM refresh_token WHERE refresh_token = ${refreshToken};`);

    check dbClient.close();

    return result;
}

public isolated function storeRefreshTokenUser(string refreshToken, string userID) returns error? {
    final mysql:Client dbClient =  check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);
    _ = check dbClient->execute(`INSERT INTO refresh_token (user_id, refresh_token) VALUES (${userID}, ${refreshToken});`);

    check dbClient.close();
}
