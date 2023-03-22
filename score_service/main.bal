import ballerinax/mysql;
import ballerina/sql;
import ballerinax/mysql.driver as _;

public type Payload record {
    string message;
    string data;
};


isolated function updateScore(string score, string submission_id) returns sql:ExecutionResult|sql:Error {
    final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);
     sql:ExecutionResult|sql:Error execute = dbClient->execute(
        `UPDATE submission SET submission_score = ${score} WHERE submission_id=${submission_id};`
    );
    check dbClient.close();

    return execute;
}

isolated function getSubmissionScore(string submissionId) returns string | sql:Error | error {
    final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);
    string | sql:Error result = dbClient->queryRow(`
        SELECT submission_score FROM submission WHERE submission_id = ${submissionId};
    `);
    check dbClient.close();

    return result;
}