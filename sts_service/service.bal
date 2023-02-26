import ballerina/jwt;
import ballerina/http;

configurable string tokenSecret = ?;
configurable string tokenUsername = ?;
configurable string tokenIssuer = ?;
configurable string tokenAudience = ?;


# A service representing a network-accessible API
# bound to port `9090`.
service /sts on new http:Listener(9090) {


    resource function get accessToken(http:Request request, http:Caller caller) returns http:ListenerError? {


        //Verify IDP token here
        
        //Get user info from DB here

        jwt:IssuerConfig issuerConfig = {
            username: tokenUsername,
            issuer: tokenIssuer,
            audience: tokenAudience,
            expTime: 3600,
            signatureConfig: {
                config: {
                    keyFile: "./certificates/private_key.pem",
                    keyPassword: tokenSecret
                }
            },customClaims: {
                user: "",
                roles: ["Contestant"]
            }
        };

        string|jwt:Error accessToken = jwt:issue(issuerConfig);
        string|jwt:Error refreshToken = jwt:issue(issuerConfig);

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
