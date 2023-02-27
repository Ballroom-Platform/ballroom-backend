import ballerina/jwt;
import ballerina/http;

http:JwtValidatorConfig config = {
    issuer: "ballroomSTS",
    audience: "ballroomBFF",
    signatureConfig: {
        certFile: "./certificates/server.crt"
    },
    scopeKey: "scp" 
};

http:ListenerJwtAuthHandler handler = new (config);

service class RequestInterceptor {
    *http:RequestInterceptor;

    resource function 'default [string ...path] (http:Request request, http:RequestContext ctx, @http:Header string Authorization)
        returns http:Unauthorized|http:Forbidden|http:NextService|error? {
        jwt:Payload|http:Unauthorized authn = handler.authenticate(Authorization);
        if authn is http:Unauthorized {
            return http:UNAUTHORIZED;
        }

        http:Forbidden? authz = handler.authorize(<jwt:Payload>authn, rolesMap[request.method + request.rawPath] ?: rolesList);
        if authz is http:Forbidden {
            return http:FORBIDDEN;
        }
        
        return ctx.next();
    }
}

listener http:Listener interceptorListener = new (9090);

@http:ServiceConfig {
    interceptors: [new RequestInterceptor()]
}
service /api on interceptorListener {

    resource function get hello(http:Request req) returns string {
        
        return "Hello";
    }
}
