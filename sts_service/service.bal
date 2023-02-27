import ballerina/jwt;
import ballerina/http;


configurable string tokenUsername = ?;
configurable string tokenIssuer = ?;
configurable string tokenAudience = ?;


# A service representing a network-accessible API
# bound to port `9090`.
service /sts on new http:Listener(9091) {


    resource function get accessToken(http:Request request, http:Caller caller) returns http:ListenerError? {


        //Verify IDP token here
        
        //Get user info from DB here

        jwt:IssuerConfig issueConfig = {
            username: tokenUsername,
            issuer: tokenIssuer,
            audience: tokenAudience,
            expTime: 3600,
            signatureConfig: {
                config: {
                    keyFile: "./certificates/server.key"
                }
            },customClaims: {
                user: "",
                scp: ["contestant"]
            }
        };

        string|jwt:Error accessToken = jwt:issue(issueConfig);

        issueConfig.expTime = 3600*24*30;

        string|jwt:Error refreshToken = jwt:issue(issueConfig);

        http:Response response = new;
        
        if accessToken is jwt:Error || refreshToken is jwt:Error{
            response.statusCode = 500;
            http:ListenerError? result = caller->respond(response);
            return result;
        }

        http:CookieOptions cookieOptions = {
            maxAge: 300,
            httpOnly: true,
            secure: true
        };

        http:Cookie refreshTokenCookie = new("refreshToken", refreshToken, cookieOptions);

        response.addCookie(refreshTokenCookie);

        response.setPayload({
            data:{
                accessToken
            }
        });

        response.statusCode = 200;

        http:ListenerError? result = caller->respond(response);
        return result;
    }
}
