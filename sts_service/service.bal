import ballerina/jwt;
import ballerina/http;

configurable string tokenIssuer = ?;
configurable string tokenAudience = ?;


# A service representing a network-accessible API
# bound to port `9090`.
service /sts on new http:Listener(9093) {


    resource function get accessToken(http:Request request, http:Caller caller) returns http:ListenerError?|error {


        http:Response response = new;

        //Verify IDP token here
        
        http:Client userClient = check new ("http://localhost:9095/userService");
        json | error responseData = userClient->get("/user/001");
        if (responseData is error){
            response.statusCode = 500;
            http:ListenerError? result = caller->respond(response);
            return result;
        }
        json userData = check responseData.data;

        jwt:IssuerConfig issueConfig = {
            username: "username",
            issuer: tokenIssuer,
            audience: tokenAudience,
            expTime: 3600,
            signatureConfig: {
                config: {
                    keyFile: "./certificates/server.key"
                }
            },customClaims: {
                user: userData,
                scp: [check userData.role]
            }
        };

        string|jwt:Error accessToken = jwt:issue(issueConfig);

        issueConfig.expTime = 3600*24*30;

        string|jwt:Error refreshToken = jwt:issue(issueConfig);
        
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
