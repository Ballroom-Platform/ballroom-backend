import ballerina/http;

public isolated client class Client {
    final http:Client clientEp;
    # Gets invoked to initialize the `connector`.
    #
    # + config - The configurations to be used when initializing the `connector` 
    # + serviceUrl - URL of the target service 
    # + return - An error if connector initialization failed 
    public isolated function init(ConnectionConfig config =  {}, string serviceUrl = "http://localhost:9095/userService") returns error? {
        http:ClientConfiguration httpClientConfig = {httpVersion: config.httpVersion, timeout: config.timeout, forwarded: config.forwarded, poolConfig: config.poolConfig, compression: config.compression, circuitBreaker: config.circuitBreaker, retryConfig: config.retryConfig, validation: config.validation};
        do {
            if config.http1Settings is ClientHttp1Settings {
                ClientHttp1Settings settings = check config.http1Settings.ensureType(ClientHttp1Settings);
                httpClientConfig.http1Settings = {...settings};
            }
            if config.http2Settings is http:ClientHttp2Settings {
                httpClientConfig.http2Settings = check config.http2Settings.ensureType(http:ClientHttp2Settings);
            }
            if config.cache is http:CacheConfig {
                httpClientConfig.cache = check config.cache.ensureType(http:CacheConfig);
            }
            if config.responseLimits is http:ResponseLimitConfigs {
                httpClientConfig.responseLimits = check config.responseLimits.ensureType(http:ResponseLimitConfigs);
            }
            if config.secureSocket is http:ClientSecureSocket {
                httpClientConfig.secureSocket = check config.secureSocket.ensureType(http:ClientSecureSocket);
            }
            if config.proxy is http:ProxyConfig {
                httpClientConfig.proxy = check config.proxy.ensureType(http:ProxyConfig);
            }
        }
        http:Client httpEp = check new (serviceUrl, httpClientConfig);
        self.clientEp = httpEp;
        return;
    }
    #
    # + return - Ok 
    resource isolated function get users/[string userID]() returns Payload|error {
        string resourcePath = string `/users/${getEncodedUri(userID)}`;
        Payload response = check self.clientEp->get(resourcePath);
        return response;
    }
    #
    # + return - Ok 
    resource isolated function get users(string role) returns User[]|error {
        string resourcePath = string `/users`;
        map<anydata> queryParam = {"role": role};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        User[] response = check self.clientEp->get(resourcePath);
        return response;
    }
    #
    # + return - Created 
    resource isolated function post users(User payload) returns Payload|error {
        string resourcePath = string `/users`;
        http:Request request = new;
        json jsonBody = payload.toJson();
        request.setPayload(jsonBody, "application/json");
        Payload response = check self.clientEp->post(resourcePath, request);
        return response;
    }
    #
    # + return - Ok 
    resource isolated function get users/[string userId]/roles() returns Payload|error {
        string resourcePath = string `/users/${getEncodedUri(userId)}/roles`;
        Payload response = check self.clientEp->get(resourcePath);
        return response;
    }
    #
    # + return - Internal server error 
    resource isolated function put users/[string userId]/roles/[string role]() returns http:Response|error {
        string resourcePath = string `/users/${getEncodedUri(userId)}/roles/${getEncodedUri(role)}`;
        http:Request request = new;
        //TODO: Update the request as needed;
        http:Response response = check self.clientEp-> put(resourcePath, request);
        return response;
    }
}
