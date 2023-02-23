import ballerinax/rabbitmq;
import wso2/data_model;
import ballerinax/mysql;
import ballerina/sql;
import ballerinax/mysql.driver as _;
import ballerina/io;

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
         io:println(scoredSubmissionEvent.subMsg.submissionId + " updated");

    }
}

isolated function updateScore(string score, string submission_id) returns sql:ExecutionResult|sql:Error {
    final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);
     sql:ExecutionResult|sql:Error execute = dbClient->execute(
        `UPDATE submission SET submission_score = ${score} WHERE submission_id=${submission_id};`
    );
    check dbClient.close();

    return execute;
}
