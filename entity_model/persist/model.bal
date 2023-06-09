import ballerina/time;
import ballerina/persist as _;

type User record {|
    readonly string id;
    // TODO unique
    string username;
    // @constraint:String
    string fullname;
    string role;
	Contest[] moderatedContests;
	UsersOnContests[] registeredContests;
	Submission[] submissions;
	RefreshToken[] refreshtokens;
	contestAccess[] contestaccess;
	ChallengeAccess[] challengeaccess;
	Challenge[] challenge;
	Registrants[] registrants;
|};

type Contest record {|
    readonly string id;
    string title;
    // TODO VARCHAR(1000)
    string description;
    // MySQL type => TIMESTAMP
    time:Civil startTime;
    time:Civil endTime;
    string imageUrl;
    // CHECK (starTime < endTime) constraint
    User moderator;
	ChallengesOnContests[] challenges;
	UsersOnContests[] registeredUsers;
	Submission[] submissions;
	contestAccess[] contestaccess;
	Registrants[] registrants;
|};

// enum Difficulty {
//     EASY,
//     MEDIUM,
//     HARD
// };

type Challenge record {|
    readonly string id;
    string title;
    // TODO VARCHAR(1000)
    string description;
    // TODO VARCHAR(500)
    string constraints;
    time:Civil createdTime;
    byte[] templateFile;
    // difficulty ENUM('EASY', 'MEDIUM', 'HARD') NOT NULL,
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
    //User assignedBy; // Introduce this later
|};

type UsersOnContests record {|
    readonly string id;
    User user;
    Contest contest;
    time:Civil registeredTime;
    //User joinedBy; // Introduce this later
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

type RefreshToken record {|
    readonly string id;
    // VARCHAR(1000)
    string token;
    User user;
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