import ballerinax/rabbitmq;
import wso2/data_model;

public function main() returns error? {
    // Creates a ballerina RabbitMQ client.
    rabbitmq:Client newClient = check new (rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);

    // Declares the queue, OrderQueue.
    check newClient->queueDeclare(data_model:QUEUE_NAME);
    check newClient->queueDeclare(data_model:EXEC_TO_SCORE_QUEUE_NAME);

}
