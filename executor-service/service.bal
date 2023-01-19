import ballerina/io;
import ballerinax/rabbitmq;
import wso2/data_model;

// The consumer service listens to the "RequestQueue" queue.
listener rabbitmq:Listener channelListener= new(rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);
   
@rabbitmq:ServiceConfig {
    queueName: data_model:QUEUE_NAME
}
service rabbitmq:Service on channelListener {
    remote function onMessage(data_model:SubmissionMessage submissionEvent) {
        io:println(submissionEvent);
    }
}