import ballerina/jwt;
import ballerina/http;
import ballerina/regex;
import ballerina/log;
import sts_service.user;
import ballroom/entities;
import ballerina/uuid;
import ballerina/persist;

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
final entities:Client db = check new ();

public isolated function verifyIDPToken(string header) returns json|error {
    log:printInfo("Verifying IDP Token");
    string idpToken = (regex:split(header, " "))[1];
    json|error res = idp->post("/introspect",
    headers = ({
        "Content-Type": "application/x-www-form-urlencoded",
        "Connection": "keep-alive",
        "Authorization": "Basic YW9nR3Jka1l0eDlBUzJ3VW9QaHRsYlFCcTQ4YTp2MHpUN0hxQWNHWWE3TnBtc01lQ29fdVU4eThh"
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

public isolated function validateToken(string refreshToken, string storedUserID) 
        returns jwt:Payload|http:Unauthorized|http:Forbidden {
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

public function getRefreshTokenUser(string refreshToken) returns string|error {
    stream<entities:RefreshToken, persist:Error?> rtStream = db->/refreshtokens;
    string[]|persist:Error userIds = from var rt in rtStream
        where rt.token == refreshToken
        select rt.userId;

    if userIds is persist:Error {
        return error("Error while getting userId for the refreshtoken", cause = userIds);
    } else if userIds.length() == 0 {
        return error("No user found for the refreshtoken");
    } else {
        return userIds[0];
    }
}

public function storeRefreshTokenUser(string refreshToken, string userId) returns error? {
    string[]|persist:Error unionResult = db->/refreshtokens.post([
        {
            id: uuid:createType4AsString(),
            userId: userId,
            token: refreshToken
        }
    ]);

    if unionResult is persist:Error {
        return error("Error while storing the refreshtoken for the userId", userId = userId, cause = unionResult);
    }
}
