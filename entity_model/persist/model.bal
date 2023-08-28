import ballerina/time;
import ballerina/persist as _;

type User record {|
    readonly string id;
    string username;
    string fullname;
	Contest[] moderatedContests;
	Submission[] submissions;
	contestAccess[] contestaccess;
	ChallengeAccess[] challengeaccess;
	Challenge[] challenge;
	Registrants[] registrants;
|};

type Contest record {|
    readonly string id;
    string title;
    byte[] readmeFile;
    time:Civil startTime;
    time:Civil endTime;
    string imageUrl;
    User moderator;
	ChallengesOnContests[] challenges;
	Submission[] submissions;
	contestAccess[] contestaccess;
	Registrants[] registrants;
|};

type Challenge record {|
    readonly string id;
    string title;
    time:Civil createdTime;
    byte[] templateFile;
    byte[] readmeFile;
    string difficulty;
    byte[] testCasesFile;
	ChallengesOnContests[] contests;
	Submission[] submissions;
	ChallengeAccess[] challengeaccess;
    User author;
|};

// Many-to-many relations between Challenge and Contest
type ChallengesOnContests record {|
    readonly string id;
    Challenge challenge;
    Contest contest;
    time:Civil assignedTime;
|};

type Submission record {|
    readonly string id;
    time:Civil submittedTime;
    float score;
    User user;
    Challenge challenge;
    Contest contest;
	SubmittedFile submittedfile;
|};

type SubmittedFile record {|
    readonly string id;
    string fileName;
    string fileExtension;
    byte[] file;
    Submission? submission;
|};

// Many-to-many relations between user and Contest
type contestAccess record {|
    readonly string id;
    Contest contest;
    User user;
    string accessType;
|};


// Many-to-many relations between user and Challenge
type ChallengeAccess record {|
    readonly string id;
    Challenge challenge;
    User user;
|};

type Registrants record {|
    readonly string id;
    time:Civil registeredTime;
    User user;
    Contest contest;
|};