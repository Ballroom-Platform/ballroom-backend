import ballerina/http;
import ballerina/log;
import ballerina/time;

configurable string contestServiceUrl = ?;

public type Contest record {
    string contestId;
    string title;
    string? description;
    time:Civil startTime;
    time:Civil endTime;
    string moderator;
};

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

    function init() returns error? {
        self.contestService = check new (contestServiceUrl);
        log:printInfo("BFF service started...1");
    }

    resource function get contests/[string status]() returns Contest[]|error {
        log:printInfo("Invoking GET contests by status...");
        return check self.contestService->/contests/[status];
    }

    // resource function get contestService/[string... paths](http:Request req) returns http:Response|error {
    //     log:printInfo("Invoking GET contest service...");
    //     // return self.contestService->forward("/" + string:'join("/", ...paths), req);
    //     return self.contestService->forward(req.rawPath, req);
    // }

    // resource function post contestService/[string... paths](http:Request req) returns http:Response|error {
    //     log:printInfo("Invoking GET contest service...");
    //     // return self.contestService->forward("/" + string:'join("/", ...paths), req);
    //     return self.contestService->forward(req.rawPath, req);
    // }

    // resource function put contestService/[string... paths](http:Request req) returns http:Response|error {
    //     log:printInfo("Invoking GET contest service...");
    //     // return self.contestService->forward("/" + string:'join("/", ...paths), req);
    //     return self.contestService->forward(req.rawPath, req);
    // }

    // resource function delete contestService/[string... paths](http:Request req) returns http:Response|error {
    //     log:printInfo("Invoking GET contest service...");
    //     // return self.contestService->forward("/" + string:'join("/", ...paths), req);
    //     return self.contestService->forward(req.rawPath, req);
    // }
}
