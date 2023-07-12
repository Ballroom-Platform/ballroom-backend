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
configurable string clientId = ?;

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
    jwt:ValidatorConfig config = {
        issuer: "https://api.asgardeo.io/t/ballroomhackathon/oauth2/token",
        audience: clientId,
        signatureConfig: {
        jwksConfig: {
            url: idpUrl + "/jwks"}
        }
    };

    jwt:Payload|jwt:Error payload = jwt:validate(idpToken, config);
    if payload is jwt:Error {
        log:printError("Error while verifying IDP Token", 'error = payload);
        return payload;
    }
    json|error res = payload.toJson();
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
