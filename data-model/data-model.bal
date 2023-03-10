import ballerina/time;

public type User record {|
    readonly string user_id;
    string username;
    string name;
    Organization[] organizations;   //MANY TO MANY RELATIONSHIP WITH ORGANIZATION
    Contestant[] contestants;       //ONE TO MANY RELATIONSHIP WITH CONTESTANT
    Moderator[] moderators;         //ONE TO MANY RELATIONSHIP WITH MODERATOR
    Challenge[]  authoredChallenges;        //ONE TO MANY RELATIONSHIP WITH CHALLENGE
|};

public type Organization record {|
    readonly string org_id;
    string name;
    string category;
    User[] members;       //MANY TO MANY RELATIONSHIP WITH USER
    Contest[] contests;     //ONE TO MANY RELATIONSHIP WITH CONTEST
    Challenge[]  poolOfChallenges;        //ONE TO MANY RELATIONSHIP WITH CHALLENGE
|};

public type Moderator record {|
    readonly moderator_id;
    User user;
    Contest contest;        //MANY TO ONE RELATIONSHIP WITH CONTEST
|};

public type Contest record {|
    readonly string contest_id;
    Organization organization;      //MANY TO ONE RELATIONSHIP WITH ORGANIZATION
    string name;
    time:Date start_time;
    time:Date end_time;
    Challenge[] challenges;     //MANY TO MANY RELATIONSHIP WITH ORGANIZATION
    Moderator[] moderators;     //ONE TO MANY RELATIONSHIP WITH MODERATOR
    Contestant[] contestants;     //ONE TO MANY RELATIONSHIP WITH MODERATOR
|};

public type Contestant record {|
    readonly User user;
    readonly Contest contest;       //MANY TO ONE RELATIONSHIP WITH CONTEST
    decimal total_score;
|};

//CHALLENGE_TYPE HAS TO BE EITHER PUBLIC OR PRIVATE
public enum Challenge_Type {
    PUBLIC,
    PRIVATE
}


public type Challenge record {|
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
    Contest[] contests;     //MANY TO MANY RELATIONSHIP WITH CONTEST
|};

public type Submission record {|
    readonly string submission_id;
    string input;
    decimal score;
    time:Date submitted_time;
    Challenge challenge;        //MANY TO ONE RELATIONSHIP WITH SUBMISSION           
    Contestant contestant;      //MANY TO ONE RELATIONSHIP WITH CONTESTANT
|};

public type TestCase record {|
    readonly string testcase_id;
    Challenge challenge;        //MANY TO ONE RELATIONSHIP WITH CHALLENGE
    string input;
    string expected_output;
    decimal weight;
|};

public type Environment record {|
    readonly environtment_id;
    string name;
    string description;
    string stored_url;
    Challenge[] challenges;     //ONE TO MANY RELATIONSHIP WITH CHALLENGE (Same environment maybe used for multiple challenges for common configurations)
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

public type ScoredSubmissionMessage record {
    SubmissionMessage subMsg;
    float score;
};


