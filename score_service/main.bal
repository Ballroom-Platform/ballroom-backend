import ballroom/data_model;
import score_service.user;
import ballroom/entities;
import ballerina/persist;
import ballroom/data_model.registry;


public type Payload record {
    string message;
    anydata data;
};

final entities:Client db = check new ();

@display {
    label: "User Service",
    id: "UserService"
}
final user:Client userService = check new (serviceUrl = check registry:lookup("\"ballroom/UserService\""));

function getSubmissionList(string userId, string contestId, string challengeId) returns Submission[]|persist:Error? {
    stream<entities:Submission, persist:Error?> submissionStream = db->/submissions;
    return from var submission in submissionStream
        where submission.userId == userId && submission.contestId == contestId && submission.challengeId == challengeId
        select toDataModelSubmission(submission);
}

function toDataModelSubmission(entities:Submission subEntity) returns Submission => {
    submission_id: subEntity.id,
    user_id: subEntity.userId,
    contest_id: subEntity.contestId,
    challenge_id: subEntity.challengeId,
    score: subEntity.score,
    submitted_time: subEntity.submittedTime
};

// isolated function getLeaderboard(string contestId) returns LeaderboardRow[]|error? {
//     stream<LeaderboardRow, sql:Error?> result = db->query(`
//         SELECT 
//     s.user_id AS userId,
//     SUM(m.max_score) AS score
// FROM 
//     submission s
// INNER JOIN (
//     SELECT 
//         user_id,
//         contest_id,
//         challenge_id,
//         MAX(score) AS max_score
//     FROM 
//         submission
//     GROUP BY 
//         user_id,
//         contest_id,
//         challenge_id
// ) m ON 
//     s.user_id = m.user_id 
//     AND s.contest_id = m.contest_id 
//     AND s.challenge_id = m.challenge_id 
//     AND s.score = m.max_score
// INNER JOIN (
//     SELECT 
//         user_id,
//         contest_id,
//         challenge_id,
//         MAX(submission_id) AS max_submission_id
//     FROM 
//         submission
//     GROUP BY 
//         user_id,
//         contest_id,
//         challenge_id,
//         score
// ) d ON 
//     s.user_id = d.user_id 
//     AND s.contest_id = d.contest_id 
//     AND s.challenge_id = d.challenge_id 
//     AND s.submission_id = d.max_submission_id
// WHERE 
//     s.contest_id = ${contestId}
// GROUP BY 
//     s.user_id
// ORDER BY 
//     score DESC;

//     `, rowType = LeaderboardRow);

//     LeaderboardRow[]|sql:Error? leaderboard = from LeaderboardRow item in result
//         select item;

//     if leaderboard is sql:Error {
//         return error("Query failed");
//     }

//     if leaderboard is () {
//         return ();
//     } else {
//         foreach int i in 0 ... (leaderboard.length() - 1) {
//             data_model:User temp = check getUserData(leaderboard[i].userId);
//             leaderboard[i].name = temp.fullname;
//         }
//     }

//     return leaderboard;
// }

public isolated function getUserData(string userID) returns data_model:User|error {
    Payload payload = check userService->/users/[userID];
    data_model:User userData = check payload.data.cloneWithType(data_model:User);
    return userData;
}
