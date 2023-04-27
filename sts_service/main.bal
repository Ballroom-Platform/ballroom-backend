import ballerina/jwt;
import ballerina/http;
import ballerinax/mysql;
import ballerina/sql;
import ballerina/regex;
import ballerinax/mysql.driver as _; // This bundles the driver to the project so that you don't need to bundle it via the `Ballerina.toml` file.
import ballerina/log;
import sts_service.user;

configurable string userServiceUrl = ?;
configurable string idpUrl = ?;

@display {
    label: "User Service",
    id: "UserService"
}
final user:Client userService = check new (serviceUrl = userServiceUrl);

@display {
    label: "IDP Service",
    id: "IDPService"
}
final http:Client idp = check new (idpUrl, config = {httpVersion: "1.1"});
final mysql:Client db = check new (host = HOST, user = USER, password = PASSWORD, port = PORT, database = DATABASE);

public isolated function verifyIDPToken(string header) returns json|error {
    log:printInfo("Verifying IDP Token");
    string idpToken = (regex:split(header, " "))[1];
    json|error res = idp->post("/introspect",
    headers = ({
        "Content-Type": "application/x-www-form-urlencoded",
        "Connection": "keep-alive",
        "Authorization": "Basic dEJkVG42NjVtV2F5d2d6bTdkc1MyYUZ4MzVvYTpBS3V3enBORlVCbHBwdjhyazduSFFVQVlNWTBh"
    })
        , message = "token=" + idpToken,
        targetType = json);

    if res is error {
        log:printError("Error while verifying IDP Token", 'error = res);
    } else {
        log:printInfo("IDP Token verified", 'res = res);
    }
    return res;
}

public isolated function getUserInfoFromIDP(string header) returns json|error {
    string idpToken = (regex:split(header, " "))[1];
    json|error res = idp->get("/userinfo", headers = {
        "Authorization": "Bearer " + idpToken
    });
    return res;
}

public isolated function getUserData(string userID) returns json|error {
    user:Payload payload = check userService->/users/[userID];
    return payload.data.toJson();
}

public isolated function generateToken(json userData, decimal expTime) returns string|jwt:Error|error {
    jwt:IssuerConfig issueConfig = {
        username: check userData.user_id,
        issuer: tokenIssuer,
        audience: tokenAudience,
        expTime: expTime,
        signatureConfig: {
            config: {
                keyFile: "./certificates/jwt/server.key"
            }
        },
        customClaims: {
            user: userData,
            scp: [check userData.role]
        }
    };

    return jwt:issue(issueConfig);
}

public isolated function validateToken(string refreshToken, string storedUserID) returns jwt:Payload|http:Unauthorized|http:Forbidden {
    jwt:ValidatorConfig config = {
        issuer: tokenIssuer,
        audience: tokenAudience,
        signatureConfig: {
            certFile: "./certificates/jwt/server.crt"
        }
    };

    jwt:Payload|jwt:Error payload = jwt:validate(refreshToken, config);

    if payload is jwt:Error {
        return http:UNAUTHORIZED;
    }

    if payload.sub != storedUserID {
        return http:FORBIDDEN;
    }

    return payload;
}

public isolated function getRefreshTokenUser(string refreshToken) returns string|error {
    string|sql:Error result = db->queryRow(`SELECT user_id FROM refresh_token WHERE refresh_token = ${refreshToken};`);
    return result;
}

public isolated function storeRefreshTokenUser(string refreshToken, string userID) returns error? {
    _ = check db->execute(`INSERT INTO refresh_token (user_id, refresh_token) VALUES (${userID}, ${refreshToken});`);
}
