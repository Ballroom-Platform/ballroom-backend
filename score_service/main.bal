import ballerinax/mysql;
import ballerina/sql;
import ballerinax/mysql.driver as _;
import wso2/data_model;
import ballerina/http;

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

isolated function getLeaderboard(string contestId) returns LeaderboardRow[] | error? {
    
	final mysql:Client | sql:Error dbClient = new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);
    
    if dbClient is sql:Error{
        return error("Database initialization failed");
    }

    stream<LeaderboardRow, sql:Error?> result = dbClient->query(`
        SELECT 
    s.user_id AS userId,
    SUM(m.max_score) AS score
FROM 
    submission s
INNER JOIN (
    SELECT 
        user_id,
        contest_id,
        challenge_id,
        MAX(score) AS max_score
    FROM 
        submission
    GROUP BY 
        user_id,
        contest_id,
        challenge_id
) m ON 
    s.user_id = m.user_id 
    AND s.contest_id = m.contest_id 
    AND s.challenge_id = m.challenge_id 
    AND s.score = m.max_score
INNER JOIN (
    SELECT 
        user_id,
        contest_id,
        challenge_id,
        MAX(submission_id) AS max_submission_id
    FROM 
        submission
    GROUP BY 
        user_id,
        contest_id,
        challenge_id,
        score
) d ON 
    s.user_id = d.user_id 
    AND s.contest_id = d.contest_id 
    AND s.challenge_id = d.challenge_id 
    AND s.submission_id = d.max_submission_id
WHERE 
    s.contest_id = ${contestId}
GROUP BY 
    s.user_id
ORDER BY 
    score DESC;

    `, rowType = LeaderboardRow);
    check dbClient.close();

    LeaderboardRow[]|sql:Error? leaderboard = from LeaderboardRow item in result select item;

    if leaderboard is sql:Error{
        return error("Query failed");
    }

    if leaderboard is () {
        return ();
    }else{
        foreach int i in 0...(leaderboard.length() - 1) {
            data_model:User temp = check getUserData(leaderboard[i].userId);
            leaderboard[i].name = temp.fullname;
        }
    }

    return leaderboard;
}

public isolated function getUserData(string userID) returns data_model:User | error{
    http:Client userClient = check new ("http://localhost:9095/userService");
    json responseData = check userClient->get("/user/" + userID);
    
    data_model:User userData = check (check responseData.data).cloneWithType(data_model:User);

    return userData;
}