import ballerina/time;

type User record {|
    readonly string user_id;
    string username;
    string name;
    Organization[] organizations;
    Contestant[] contestants;
|};

type Organization record {|
    readonly string org_id;
    string category;
    User[] users;
    Contest[] contests;
|};

type Moderator record {|
    readonly moderator_id;
    Contest contest;
|};

type Contest record {|
    readonly string contest_id;
    Organization organization;
    string name;
    time:Date start_time;
    time:Date end_time;
    Challenge[] challenges;
    Moderator[] moderators;
|};

type Contestant record {|
    readonly User user;
    readonly Contest contest;
    decimal total_score;
|};

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
    Environment environment;
    TestCase[] testcases;
    Submission[] submissions;
|};

type Submission record {|
    readonly string submission_id;
    string input;
    decimal score;
    time:Date submitted_time;
    Challenge challenge;
    Contestant contestant;
|};

type TestCase record {|
    readonly string testcase_id;
    Challenge challenge;
    string input;
    string expected_output;
    decimal weight;
|};

type Environment record {|
    readonly environtment_id;
    string stored_url;
    // HAD TO PUT TO SHOW THE ONE TO MANY RELAIONSHIP
    Challenge[] challenges;
|};



