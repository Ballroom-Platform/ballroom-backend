import ballerina/time;

type User record {|
    readonly string user_id;
    string username;
    string name;
    Organization[] organizations;   //MANY TO MANY RELATIONSHIP WITH ORGANIZATION
    Contestant[] contestants;       //ONE TO MANY RELATIONSHIP WITH CONTESTANT
|};

type Organization record {|
    readonly string org_id;
    string category;
    User[] members;       //MANY TO MANY RELATIONSHIP WITH USER
    Contest[] contests;     //ONE TO MANY RELATIONSHIP WITH CONTEST
|};

type Moderator record {|
    readonly moderator_id;
    Contest contest;        //MANY TO ONE RELATIONSHIP WITH CONTEST
|};

type Contest record {|
    readonly string contest_id;
    Organization organization;      //MANY TO ONE RELATIONSHIP WITH ORGANIZATION
    string name;
    time:Date start_time;
    time:Date end_time;
    Challenge[] challenges;     //MANY TO MANY RELATIONSHIP WITH ORGANIZATION
    Moderator[] moderators;     //ONE TO MANY RELATIONSHIP WITH MODERATOR
    Contestant[] contestants;     //ONE TO MANY RELATIONSHIP WITH MODERATOR
|};

type Contestant record {|
    readonly User user;
    readonly Contest contest;       //MANY TO ONE RELATIONSHIP WITH CONTEST
    decimal total_score;
|};

//CHALLENGE_TYPE HAS TO BE EITHER PUBLIC OR PRIVATE
enum Challenge_Type {
    PUBLIC,
    PRIVATE
}


type Challenge record {|
    readonly string challenge_id;
    string name;
    Challenge_Type type_of_challenge;
    string editorial;
    string problem_description;
    Environment environment;        //MANY TO ONE RELATIONSHIP WITH ENVIRONMENT
    TestCase[] testcases;       //ONE TO MANY RELATIONSHIP WITH TESTCASE
    Submission[] submissions;       //ONE TO MANY RELATIONSHIP WITH SUBMISSION
    Contest[] contests;     //MANY TO MANY RELATIONSHIP WITH CONTEST
|};

type Submission record {|
    readonly string submission_id;
    string input;
    decimal score;
    time:Date submitted_time;
    Challenge challenge;        //MANY TO ONE RELATIONSHIP WITH SUBMISSION           
    Contestant contestant;      //MANY TO ONE RELATIONSHIP WITH CONTESTANT
|};

type TestCase record {|
    readonly string testcase_id;
    Challenge challenge;        //MANY TO ONE RELATIONSHIP WITH CHALLENGE
    string input;
    string expected_output;
    decimal weight;
|};

type Environment record {|
    readonly environtment_id;
    string stored_url;
    Challenge[] challenges;     //ONE TO MANY RELATIONSHIP WITH CHALLENGE (Same environment maybe used for multiple challenges for common configurations)
|};



