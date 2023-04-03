import ballerinax/mysql;
import ballerina/sql;
import ballerinax/mysql.driver as _;

public type Payload record {
    string message;
    anydata data;
};


isolated function updateScore(string score, string submission_id) returns sql:ExecutionResult|sql:Error {
    final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);
     sql:ExecutionResult|sql:Error execute = dbClient->execute(
        `UPDATE submission SET score = ${score} WHERE submission_id=${submission_id};`
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

isolated function getSubmissionList(string userId, string contestId, string challengeId) returns Submission[] | sql:Error? {
    
	final mysql:Client | sql:Error dbClient = new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);
    
    if dbClient is sql:Error{
        return dbClient;
    }

    stream<Submission, sql:Error?> result = dbClient->query(`
        SELECT * FROM submission WHERE user_id = ${userId} AND contest_id = ${contestId} AND challenge_id = ${challengeId};
    `, rowType = Submission);
    check dbClient.close();

    Submission[]|sql:Error? listOfSubmissions = from Submission item in result select item;

    return listOfSubmissions;
}

isolated function getSubmissionFile(string submissionId) returns byte[] | error {
    
	final mysql:Client | sql:Error dbClient = new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);
    
    if dbClient is sql:Error{
        return error("Database error: " + dbClient.message());
    }

    byte[] | sql:Error result = dbClient->queryRow(`
        SELECT submission_file FROM submission WHERE submission_id = ${submissionId};`);
    check dbClient.close();
    return result;
}