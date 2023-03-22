import ballerina/http;

http:JwtValidatorConfig config = {
    issuer: "ballroomSTS",
    audience: "ballroomBFF",
    signatureConfig: {
        certFile: "./certificates/jwt/server.crt"
    },
    scopeKey: "scp" 
};
service /api on new http:Listener(9099) {
    
    @http:ResourceConfig{
        auth: [
            {
                jwtValidatorConfig : config,
                scopes : ["contestant", "admin"]
            }
        ]
    }
    resource function get contests/[string status]() returns json | http:InternalServerError {
        
        do{
            http:Client contestService = check new("http://localhost:9097/contestService");
            json res = check contestService->get("/contest/active");
            return res;
        }on fail{
            return http:INTERNAL_SERVER_ERROR;
        }
        
    }
}
