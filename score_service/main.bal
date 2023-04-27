import ballerinax/mysql;
import ballerina/sql;
import ballerinax/mysql.driver as _;
import ballroom/data_model;
import score_service.user;

// configurable string userServiceUrl = ?;

public type Payload record {
    string message;
    anydata data;
};

@display {
   label: "User Service",
   id: "UserService"
}
final user:Client userService = check new ();

final mysql:Client db = check new (host = HOST, user = USER, password = PASSWORD, port = PORT, database = DATABASE);

isolated function updateScore(string score, string submission_id) returns sql:ExecutionResult|sql:Error {
    sql:ExecutionResult|sql:Error execute = db->execute(
        `UPDATE submission SET score = ${score} WHERE submission_id=${submission_id};`
    );
    return execute;
}

isolated function getSubmissionScore(string submissionId) returns string|sql:Error|error {
    string|sql:Error result = db->queryRow(`
        SELECT submission_score FROM submission WHERE submission_id = ${submissionId};
    `);
    return result;
}

isolated function getSubmissionList(string userId, string contestId, string challengeId) returns Submission[]|sql:Error? {
    stream<Submission, sql:Error?> result = db->query(`
        SELECT * FROM submission WHERE user_id = ${userId} AND contest_id = ${contestId} AND challenge_id = ${challengeId};
    `, rowType = Submission);
    Submission[]|sql:Error? listOfSubmissions = from Submission item in result
        select item;

    return listOfSubmissions;
}

isolated function getSubmissionFile(string submissionId) returns byte[] | error {
    byte[] | sql:Error result = db->queryRow(`
        SELECT submission_file FROM submission_file_table WHERE submission_id = ${submissionId};`);
    return result;
}

isolated function getLeaderboard(string contestId) returns LeaderboardRow[]|error? {
    stream<LeaderboardRow, sql:Error?> result = db->query(`
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

    LeaderboardRow[]|sql:Error? leaderboard = from LeaderboardRow item in result
        select item;

    if leaderboard is sql:Error {
        return error("Query failed");
    }

    if leaderboard is () {
        return ();
    } else {
        foreach int i in 0 ... (leaderboard.length() - 1) {
            data_model:User temp = check getUserData(leaderboard[i].userId);
            leaderboard[i].name = temp.fullname;
        }
    }

    return leaderboard;
}

public isolated function getUserData(string userID) returns data_model:User|error {
    Payload payload = check userService->/users/[userID];
    data_model:User userData = check payload.data.cloneWithType(data_model:User);
    return userData;
}
