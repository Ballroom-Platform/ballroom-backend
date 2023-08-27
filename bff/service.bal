import ballerina/http;
import ballerina/log;
// import ballerina/regex;
// import ballerina/jwt;

configurable string contestServiceUrl = ?;
configurable string challengeServiceUrl = ?;
configurable string uploadServiceUrl = ?;
configurable string userServiceUrl = ?;
configurable string submissionServiceUrl = ?;

// configurable string idpUrl = ?;
// configurable string clientId = ?;

// jwt:ValidatorConfig config = {
//         issuer: "https://api.asgardeo.io/t/ballroomhackathon/oauth2/token",
//         audience: clientId,
//         signatureConfig: {
//         jwksConfig: {
//             url: idpUrl + "/jwks"}
//         }
//     };

@display {
    label: "BFF for Ballroom Webapp",
    id: "BFFBallroomWebapp"
}
@http:ServiceConfig {
    cors: {
        allowOrigins: ["https://localhost:3000"],
        allowCredentials: true,
        allowHeaders: ["CORELATION_ID", "Authorization", "Content-Type", "authorization", "ngrok-skip-browser-warning"],
        exposeHeaders: ["X-CUSTOM-HEADER"],
        maxAge: 84900
    }
}
service / on new http:Listener(9099) {
    @display {
        label: "Contest Service",
        id: "ContestService"
    }
    private final http:Client contestService;

    @display {
        label: "Challenge Service",
        id: "ChallengeService"
    }
    private final http:Client challengeService;

    @display {
        label: "Upload Service",
        id: "UploadService"
    }
    private final http:Client uploadService;

    @display {
        label: "User Service",
        id: "UserService"
    }
    private final http:Client userService;

    @display {
        label: "Submission Service",
        id: "SubmissionService"
    }
    private final http:Client submissionService;

    function init() returns error? {
        self.contestService = check new (contestServiceUrl);
        self.challengeService = check new (challengeServiceUrl);
        self.uploadService = check new (uploadServiceUrl);
        self.userService = check new (userServiceUrl);
        self.submissionService = check new (submissionServiceUrl);
        log:printInfo("BFF service started...");
    }

    // Challenge service
    resource function 'default challengeService/[string... paths](http:Request req) returns http:Response|error {
        // string|http:HeaderNotFoundError authorizationString = req.getHeader("Authorization");
        // if authorizationString is http:HeaderNotFoundError {
        //     return error("Authorization header not found");
        // } else {
        //     string idpToken = (regex:split(authorizationString, " "))[1];
        //     jwt:Payload|jwt:Error payload = jwt:validate(idpToken, config);
        //     if payload is jwt:Error {
        //         log:printError("Error while verifying IDP Token", 'error = payload);
        //         return payload;
        //     }
        //     json|error res = payload.toJson();
        //     if res is error {
        //         log:printError("Error while getting playload", 'error = res);
        //         return res;
        //     } else {
        //         log:printInfo("IDP Token verified", 'res = res);
                return check self.challengeService->forward(req.rawPath, req);
        //     }  
        // }
    }

    // Contest service
    resource function 'default contestService/[string... paths](http:Request req) returns http:Response|error {
        // string|http:HeaderNotFoundError authorizationString = req.getHeader("Authorization");
        // if authorizationString is http:HeaderNotFoundError {
        //     return error("Authorization header not found");
        // } else {
        //     string idpToken = (regex:split(authorizationString, " "))[1];
        //     jwt:Payload|jwt:Error payload = jwt:validate(idpToken, config);
        //     if payload is jwt:Error {
        //         log:printError("Error while verifying IDP Token", 'error = payload);
        //         return payload;
        //     }
        //     json|error res = payload.toJson();
        //     if res is error {
        //         log:printError("Error while getting playload", 'error = res);
        //         return res;
        //     } else {
        //         log:printInfo("IDP Token verified", 'res = res);
                return check self.contestService->forward(req.rawPath, req);
        //     }
        // }
    }

    // Upload service
    resource function 'default uploadService/[string... paths](http:Request req) returns http:Response|error {
        // string|http:HeaderNotFoundError authorizationString = req.getHeader("Authorization");
        // if authorizationString is http:HeaderNotFoundError {
        //     return error("Authorization header not found");
        // } else {
        //     string idpToken = (regex:split(authorizationString, " "))[1];
        //     jwt:Payload|jwt:Error payload = jwt:validate(idpToken, config);
        //     if payload is jwt:Error {
        //         log:printError("Error while verifying IDP Token", 'error = payload);
        //         return payload;
        //     }
        //     json|error res = payload.toJson();
        //     if res is error {
        //         log:printError("Error while getting playload", 'error = res);
        //         return res;
        //     } else {
        //         log:printInfo("IDP Token verified", 'res = res);
                return check self.uploadService->forward(req.rawPath, req);
        //     }
        // }
    }

    // User service
    resource function 'default userService/[string... paths](http:Request req) returns http:Response|error {
        // string|http:HeaderNotFoundError authorizationString = req.getHeader("Authorization");
        // if authorizationString is http:HeaderNotFoundError {
        //     return error("Authorization header not found");
        // } else {
        //     string idpToken = (regex:split(authorizationString, " "))[1];
        //     jwt:Payload|jwt:Error payload = jwt:validate(idpToken, config);
        //     if payload is jwt:Error {
        //         log:printError("Error while verifying IDP Token", 'error = payload);
        //         return payload;
        //     }
        //     json|error res = payload.toJson();
        //     if res is error {
        //         log:printError("Error while getting playload", 'error = res);
        //         return res;
        //     } else {
        //         log:printInfo("IDP Token verified", 'res = res);
                return check self.userService->forward(req.rawPath, req);
        //     }
        // }
    }

    // Submission service
    resource function 'default submissionService/[string... paths](http:Request req) returns http:Response|error {
        // string|http:HeaderNotFoundError authorizationString = req.getHeader("Authorization");
        // if authorizationString is http:HeaderNotFoundError {
        //     return error("Authorization header not found");
        // } else {
        //     string idpToken = (regex:split(authorizationString, " "))[1];
        //     jwt:Payload|jwt:Error payload = jwt:validate(idpToken, config);
        //     if payload is jwt:Error {
        //         log:printError("Error while verifying IDP Token", 'error = payload);
        //         return payload;
        //     }
        //     json|error res = payload.toJson();
        //     if res is error {
        //         log:printError("Error while getting playload", 'error = res);
        //         return res;
        //     } else {
        //         log:printInfo("IDP Token verified", 'res = res);
                return check self.submissionService->forward(req.rawPath, req);
        //     }
        // }
    }
}

