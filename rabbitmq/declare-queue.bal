import ballerinax/rabbitmq;
import ballerina/log;
import ballroom/data_model;

public function main() returns error? {
    // Creates a ballerina RabbitMQ client.
    rabbitmq:Client newClient = check new (rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);
    log:printInfo("RabbitMQ client created successfully.");

    // Declares the queue, OrderQueue.
    check newClient->queueDeclare(data_model:QUEUE_NAME);
    log:printInfo("OrderQueue declared successfully.");
    check newClient->queueDeclare(data_model:EXEC_TO_SCORE_QUEUE_NAME);
    log:printInfo("ExecToScoreQueue declared successfully.");
}
