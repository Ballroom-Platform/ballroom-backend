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

public isolated function getUserData(string userID) returns data_model:User|error {
    Payload payload = check userService->/users/[userID];
    data_model:User userData = check payload.data.cloneWithType(data_model:User);
    return userData;
}
