import ballerina/http;

http:JwtValidatorConfig config = {
    issuer: "ballroomSTS",
    audience: "ballroomBFF",
    signatureConfig: {
        certFile: "./certificates/server.crt"
    },
    scopeKey: "scp" 
};
service /api on new http:Listener(9099) {
    
    @http:ResourceConfig{
        auth: [
            {
                jwtValidatorConfig : config,
                scopes : ["admin"]
            }
        ]
    }
    resource function get hello(http:Request req) returns string {
        
        return "Hello";
    }
}
