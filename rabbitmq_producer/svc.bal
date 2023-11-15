import ballerinax/rabbitmq;
import ballerina/log;
service "OrderQueue" on new rabbitmq:Listener("puffin.rmq2.cloudamqp.com", rabbitmq:DEFAULT_PORT,(),connectionConfig) {

    remote function onMessage(json j) returns error? {
        log:printInfo(j.toJsonString());
    }
}