import ballerinax/rabbitmq;
import ballerina/log;
import ballroom/data_model;

// configurable string rabbitmqHost = ?;
// configurable int rabbitmqPort = ?;
// configurable string rabbitmqUser = ?;
// configurable string rabbitmqPassword = ?;

public function main() returns error? {
    // rabbitmq:ConnectionConfiguration config = {
    //     username: rabbitmqUser,
    //     password: rabbitmqPassword
    // };
    // rabbitmq:Client newClient = check new(rabbitmqHost, rabbitmqPort, config);
    rabbitmq:Client newClient = check new (rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);
    log:printInfo("RabbitMQ client created successfully.");

    check newClient->queueDeclare(data_model:QUEUE_NAME);
    log:printInfo("OrderQueue declared successfully.");
    check newClient->queueDeclare(data_model:EXEC_TO_SCORE_QUEUE_NAME);
    log:printInfo("ExecToScoreQueue declared successfully.");
}
