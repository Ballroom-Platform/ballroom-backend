import ballerina/http;
import ballerina/log;
import samjs/ballroom.data_model;

configurable string contestServiceUrl = ?;
configurable string challengeServiceUrl = ?;

// http:JwtValidatorConfig config = {
//     issuer: "ballroomSTS",
//     audience: "ballroomBFF",
//     signatureConfig: {
//         certFile: "./certificates/jwt/server.crt"
//     },
//     scopeKey: "scp" 
// };
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://www.m3.com", "http://www.hello.com", "https://localhost:3000"],
        allowCredentials: true,
        allowHeaders: ["CORELATION_ID", "Authorization"],
        exposeHeaders: ["X-CUSTOM-HEADER"],
        maxAge: 84900
    }
}
service /web on new http:Listener(9099) {
    private final http:Client contestService;
    private final http:Client challengeService;

    function init() returns error? {
        self.contestService = check new (contestServiceUrl);
        self.challengeService = check new (challengeServiceUrl);
        log:printInfo("BFF service started...");
    }

    resource function get contests/[string contestId]() returns data_model:Contest|error {
        log:printInfo("Invoking GET contests by status...");
        return check self.contestService->/contest/[contestId];
    }

    resource function get contests(string status) returns data_model:Contest[]|error {
        log:printInfo("Invoking GET contests by status...");
        return check self.contestService->/contests/[status];
    }

    resource function get contests/[string contestId]/challenges() returns error|string[] {
        log:printInfo("Invoking GET challenges by contest...");
        return check self.contestService->/contest/[contestId]/challenges;
    }

    // Challenge Service Calls
    resource function get challenges/[string challengeId]() returns data_model:Challenge|error {
        log:printInfo("Invoking GET challenge by id...");
        return check self.challengeService->/challenge/[challengeId];
    }

    resource function get challenges(string difficulty) returns data_model:Challenge[]|error {
        log:printInfo("Invoking GET challenges by difficulty...");
        return check self.challengeService->/challenges/difficulty/[difficulty];
    }

    resource function get challenges/[string challengeId]/template() returns byte[]|error {
        log:printInfo("Invoking GET challenge template by id...");
        return check self.challengeService->/challenge/template/[challengeId];
    }
}
