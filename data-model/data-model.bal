import ballerina/time;
import ballerina/sql;

public type User_idel record {|
    readonly string user_id;
    string username;
    string fullname;
    string role;
    Organization[] organizations;   //MANY TO MANY RELATIONSHIP WITH ORGANIZATION
    Contestant[] contestants;       //ONE TO MANY RELATIONSHIP WITH CONTESTANT
    Moderator[] moderators;         //ONE TO MANY RELATIONSHIP WITH MODERATOR
    Challenge_Ideal[]  authoredChallenges;        //ONE TO MANY RELATIONSHIP WITH CHALLENGE
|};

public type User record {|
    readonly string user_id;
    string username;
    string fullname;
    string role;
|};

public type Organization record {|
    readonly string org_id;
    string name;
    string category;
    User[] members;       //MANY TO MANY RELATIONSHIP WITH USER
    Contest_Ideal[] contests;     //ONE TO MANY RELATIONSHIP WITH CONTEST
    Challenge[]  poolOfChallenges;        //ONE TO MANY RELATIONSHIP WITH CHALLENGE
|};

public type Moderator record {|
    readonly moderator_id;
    User user;
    Contest_Ideal contest;        //MANY TO ONE RELATIONSHIP WITH CONTEST
|};

public type Contest_Ideal record {|
    readonly string contest_id;
    Organization organization;      //MANY TO ONE RELATIONSHIP WITH ORGANIZATION
    string name;
    time:Date start_time;
    time:Date end_time;
    Challenge_Ideal[] challenges;     //MANY TO MANY RELATIONSHIP WITH ORGANIZATION
    Moderator[] moderators;     //ONE TO MANY RELATIONSHIP WITH MODERATOR
    Contestant[] contestants;     //ONE TO MANY RELATIONSHIP WITH MODERATOR
|};

public type Contestant record {|
    readonly User user;
    readonly Contest_Ideal contest;       //MANY TO ONE RELATIONSHIP WITH CONTEST
    decimal total_score;
|};

//CHALLENGE_TYPE HAS TO BE EITHER PUBLIC OR PRIVATE
public enum Challenge_Type {
    PUBLIC,
    PRIVATE
}


public type Challenge_Ideal record {|
    readonly string challenge_id;
    string name;
    Challenge_Type type_of_challenge;
    User author;        //ONE TO ONE RELATIONSHIP WITH USER
    Organization owner;     //ONE TO ONE RELATIONSHIP WITH ORGANIZATION
    string editorial;
    string problem_description;
    Environment environment;        //MANY TO ONE RELATIONSHIP WITH ENVIRONMENT
    TestCase[] testcases;       //ONE TO MANY RELATIONSHIP WITH TESTCASE
    Submission[] submissions;       //ONE TO MANY RELATIONSHIP WITH SUBMISSION
    Contest_Ideal[] contests;     //MANY TO MANY RELATIONSHIP WITH CONTEST
|};

public type Submission record {|
    readonly string submission_id;
    string input;
    decimal score;
    time:Date submitted_time;
    Challenge_Ideal challenge;        //MANY TO ONE RELATIONSHIP WITH SUBMISSION           
    Contestant contestant;      //MANY TO ONE RELATIONSHIP WITH CONTESTANT
|};

public type TestCase record {|
    readonly string testcase_id;
    Challenge_Ideal challenge;        //MANY TO ONE RELATIONSHIP WITH CHALLENGE
    string input;
    string expected_output;
    decimal weight;
|};

public type Environment record {|
    readonly environtment_id;
    string name;
    string description;
    string stored_url;
    Challenge_Ideal[] challenges;     //ONE TO MANY RELATIONSHIP WITH CHALLENGE (Same environment maybe used for multiple challenges for common configurations)
|};


// ------------------------------------------------

public const QUEUE_NAME = "RequestQueue";
public const EXEC_TO_SCORE_QUEUE_NAME = "ExecToScoreQueue";


public type SubmissionMessage record {
    string userId;
    string contestId;
    string challengeId;
    string fileName;
    string fileExtension;
    string submissionId;
};

public type ScoredSubmissionMessage record {|
    SubmissionMessage subMsg;
    float score;
|};

// public enum ChallengeDifficulty {
//     EASY = "EASY",
//     MEDIUM = "MEDIUM",
//     HARD = "HARD"
// }
public type Challenge record{
    @sql:Column {name: "challenge_id"}
    string challengeId;
    string title;
    string description;
    string constraints;
    // Not sure about the type here, byte[]?
    // ChallengeDifficulty difficulty; 
    string difficulty;
    byte[] testCase;
    @sql:Column {name: "challenge_template"}
    byte[]? template;
};


public type Contest record {
    @sql:Column {name: "contest_id"}
    string contestId;
    string title;
    string? description;
    @sql:Column {name: "start_time"}
    time:Civil startTime;
    @sql:Column {name: "end_time"}
    time:Civil endTime;
    string moderator;
};