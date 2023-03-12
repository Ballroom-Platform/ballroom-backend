import ballerinax/rabbitmq;
import wso2/data_model;
import ballerina/http;
import ballerina/sql;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

// The consumer service listens to the "RequestQueue" queue.
listener rabbitmq:Listener channelListener= new(rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);
   
@rabbitmq:ServiceConfig {
    queueName: data_model:EXEC_TO_SCORE_QUEUE_NAME
}

service rabbitmq:Service on channelListener {

    private final rabbitmq:Client rabbitmqClient;

    function init() returns error? {
        // Initiate the RabbitMQ client at the start of the service. This will be used
        // throughout the lifetime of the service.
        self.rabbitmqClient = check new (rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);
    }

    remote function onMessage(data_model:ScoredSubmissionMessage scoredSubmissionEvent) returns error? {

        // Throw the error for now
        _ = check updateScore(scoredSubmissionEvent.score.toString(),scoredSubmissionEvent.subMsg.submissionId);
        return;
    }
}
# A service representing a network-accessible API
# bound to port `9090`.
# // The service-level CORS config applies globally to each `resource`.
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://www.m3.com", "http://www.hello.com", "http://localhost:3000"],
        allowCredentials: false,
        allowHeaders: ["CORELATION_ID"],
        exposeHeaders: ["X-CUSTOM-HEADER"],
        maxAge: 84900
    }
}
service /score on new http:Listener(9092) {

    # A resource for generating greetings
    #
    # + submissionId - Parameter Description
    # + return - string name with hello message or error
    isolated resource function get submissionScore/[string submissionId]() returns http:InternalServerError | Payload {
        do{
            
            string | sql:Error result = check getSubmissionScore(submissionId);
            
            if(result is sql:Error){
                Payload responsePayload = {
                    message : "No submission found",
                    data : ""
                };
                return responsePayload;
            }

            Payload responsePayload = {
                message : "Submission found",
                data : result
            };

            return responsePayload;
        }
        on fail {
            return http:INTERNAL_SERVER_ERROR;
        }
        
    }
}
