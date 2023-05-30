import ballerina/http;
import ballerina/time;
import ballerina/uuid;
import ballerina/log;
import ballerina/persist;

import ballroom/data_model;
import ballroom/entities;

type UpdatedContest record {
    string title;
    time:Civil startTime;
    time:Civil endTime;
    string moderator;
};

type NewContest record {
    string title;
    string description;
    time:Civil startTime;
    time:Civil endTime;
    string moderator;
};

type SharedContest record {|
    string userId;
    string accessType;
    record {|
        string id;
        string title;
        string description;
        time:Civil startTime;
        time:Civil endTime;
        string imageUrl;
        string moderatorId;
    |} contest;
|};

type SharedContestOut record {
    string contestId;
    string title;
    string? description;
    time:Civil startTime;
    time:Civil endTime;
    string accessType;
    string moderator;
};

type contestAccessAdmins record {|
    string contestId;
    string accessType;
    record {|
        string id;
        string username;
        string fullname;
    |} user;
|};

type contestAccessAdminsOut record {|
    string userId;
    string userName;
    string fullName;
    string accessType;
|};

type Payload record {
    string message;
    anydata data;
};

type MyInternalServerError record {|
    *http:InternalServerError;
    record{|string message;|} body;
|};

# A service representing a network-accessible API
# bound to port `9098`.
# // TODO Remove this CORS config when the BFF is configured properly
@display {
    label: "Contest Service",
    id: "ContestService"
}
@http:ServiceConfig {
    cors: {
        allowOrigins: ["https://localhost:3000"],
        allowCredentials: true,
        allowHeaders: ["CORELATION_ID", "Authorization", "Content-Type", "ngrok-skip-browser-warning"],
        exposeHeaders: ["X-CUSTOM-HEADER"],
        maxAge: 84900
    }
}
service /contestService on new http:Listener(9098) {
    private final entities:Client db;

    function init() returns error?{
        self.db = check new();
        log:printInfo("Contest service started...");
    }

    resource function get contests/[string contestId]() 
            returns data_model:Contest|MyInternalServerError|http:NotFound {

        entities:Contest|persist:Error entityContest = self.db->/contests/[contestId];
        if entityContest is persist:InvalidKeyError {
            return http:NOT_FOUND;
        } else if entityContest is persist:Error {
            log:printError("Error while retrieving contest by id", contestId = contestId, 'error = entityContest);
            return <MyInternalServerError> {
                body: {
                    message: string `Error while retrieving contest by ${contestId}`
                }
            };
        } else {
            return toDataModelContest(entityContest);
        }
    }

    resource function get contests(string? status) 
            returns data_model:Contest[]|http:InternalServerError|http:NotFound {
        data_model:Contest[]|persist:Error contestsWithStatus = getContestsWithStatus(self.db, status ?: "future");
        if contestsWithStatus is persist:Error {
            log:printError("Error while retrieving contests", 'error = contestsWithStatus);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while retrieving contests`
                }
            };
        } else {
            return contestsWithStatus;
        }
    }

    resource function get contests/[string status]/owned/[string userId]() returns data_model:Contest[]|http:InternalServerError|http:NotFound {

        data_model:Contest[]|persist:Error contests = getOwnerContests(self.db, userId, status);
        if contests is persist:Error {
            log:printError("Error while retrieving contests", 'error = contests);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while retrieving contests`
                }
            };
        } else {
            return contests;
        }
    }

    resource function get contests/[string status]/shared/[string userId]() returns SharedContestOut[]|http:InternalServerError|http:NotFound {

        SharedContestOut[]|persist:Error contests = getSharedContests(self.db, userId, status);
        if contests is persist:Error {
            log:printError("Error while retrieving contests", 'error = contests);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while retrieving contests`
                }
            };
        } else {
            return contests;
        }
    }

    resource function get contests/accessgranted/[string contestId]() returns string[]|http:InternalServerError|http:NotFound {
        string[]|persist:Error users = getAccessGrantedUsers(self.db, contestId);
        if users is persist:Error {
            log:printError("Error while retrieving users", 'error = users);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while retrieving users`
                }
            };
        } else {
            return users;
        }
    }

    resource function get contests/[string contestId]/access() returns Payload|http:InternalServerError {
        do {
            contestAccessAdminsOut[]|persist:Error result = getContestAdmins(self.db, contestId) ?: [];

            Payload responsePayload = {
                message: "Admin access table created",
                data: check result
            };
            return responsePayload;

        } on fail error e {
            log:printError("Error while creating admin access table", 'error = e);
            return http:INTERNAL_SERVER_ERROR;
        }
    }
    resource function get contests/[string contestId]/challenges() returns string[]|http:InternalServerError {
        string[]|persist:Error contestChallenges = getContestChallenges(self.db, contestId);
        if contestChallenges is persist:Error {
            log:printError("Error while retrieving challenges for contest", contestId = contestId, 'error = contestChallenges);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while retrieving challenges for contest ${contestId}`
                }
            };
        } else {
            return contestChallenges;
        }
    }

    resource function post contests(@http:Payload NewContest newContest) returns string|http:InternalServerError {
        string|persist:Error contest = addContest(self.db, newContest);
        if contest is persist:Error {
            log:printError("Error while adding contest", 'error = contest);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while adding contest`
                }
            };
        } else {
            return contest;
        }
    }

    resource function post contests/[string contestId]/challenges/[string challengeId]()
            returns string|http:BadRequest|http:InternalServerError {
        // Check for duplications. 
        stream<entities:ChallengesOnContests, persist:Error?> challengesOnContets = self.db->/challengesoncontests;
        entities:ChallengesOnContests[]|persist:Error duplicates = from var challengesOnContest in challengesOnContets
            where challengesOnContest.contestId == contestId && challengesOnContest.challengeId == challengeId
            select challengesOnContest;
        if duplicates is persist:Error {
            log:printError("Error while reading challengesoncontests data", 'error = duplicates);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while adding challenge to contest`
                }
            };
        }

        if duplicates.length() > 0 {
            return <http:BadRequest>{
                body: {
                    message: string `Challenge already added to contest`
                }
            };
        }

        string[]|persist:Error insertedIds = self.db->/challengesoncontests.post([
            {
                id: uuid:createType4AsString(),
                contestId: contestId,
                challengeId: challengeId,
                assignedTime: time:utcToCivil(time:utcNow())
            }
        ]);

        if insertedIds is persist:Error {
            log:printError("Error while adding challenge to contest", 'error = insertedIds);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while adding challenge to contest`
                }
            };
        } else {
            return insertedIds[0];
        }
    }

    resource function post contests/[string contestId]/access/[string userId]/[string accessType]() returns string|http:BadRequest|http:InternalServerError {
        // Check for duplications.
        stream<entities:contestAccess, persist:Error?> contestAccesses = self.db->/contestaccesses;

        entities:contestAccess[]|persist:Error duplicates = from var contestAccess in contestAccesses
            where contestAccess.contestId == contestId && contestAccess.userId == userId
            select contestAccess;
        if duplicates is persist:Error {
            log:printError("Error while reading contestAccesss data", 'error = duplicates);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while adding admins to contest`
                }
            };
        }

        if duplicates.length() > 0 {
            return <http:BadRequest>{
                body: {
                    message: string `Admin already added to contest`
                }
            };
        }

        string[]|persist:Error insertedIds = self.db->/contestaccesses.post([
            {
                id: uuid:createType4AsString(),
                contestId: contestId,
                userId: userId,
                accessType: accessType
            }
        ]);

        if insertedIds is persist:Error {
            log:printError("Error while adding admin to contest", 'error = insertedIds);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while adding admin to contest`
                }
            };
        } else {
            return insertedIds[0];
        }
    }

    resource function put contests/[string contestId](@http:Payload UpdatedContest toBeUpdatedContest)
            returns UpdatedContest|http:InternalServerError|http:NotFound {
        entities:ContestUpdate contestUpdate = {
            title: toBeUpdatedContest.title,
            startTime: toBeUpdatedContest.startTime,
            endTime: toBeUpdatedContest.endTime,
            moderatorId: toBeUpdatedContest.moderator
        };
        entities:Contest|persist:Error updatedContest = self.db->/contests/[contestId].put(contestUpdate);
        if updatedContest is persist:InvalidKeyError {
            return http:NOT_FOUND;
        } else if updatedContest is persist:Error {
            log:printError("Error while updating contest", contestId = contestId, 'error = updatedContest);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while updating contest ${contestId}`
                }
            };
        } else {
            toBeUpdatedContest["contestId"] = contestId;
            return toBeUpdatedContest;
        }
    }

    resource function delete contests/[string contestId]() returns http:InternalServerError|http:NotFound|http:Ok {
        entities:Contest|persist:Error deletedContest = self.db->/contests/[contestId].delete;
        if deletedContest is persist:InvalidKeyError {
            return http:NOT_FOUND;
        } else if deletedContest is persist:Error {
            log:printError("Error while deleting contest", contestId = contestId, 'error = deletedContest);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while deleting contest ${contestId}`
                }
            };
        } else {
            return http:OK;
        }
    }

    resource function delete contests/[string contestId]/access/[string userId]() returns http:InternalServerError|http:NotFound|http:Ok {
        stream<entities:contestAccess, persist:Error?> contestAccessStream = self.db->/contestaccesses;

        entities:contestAccess[]|persist:Error contestAccesses = from var contestAccess in contestAccessStream
            select contestAccess;

        if contestAccesses is persist:Error {
            log:printError("Error while reading contests access data", 'error = contestAccesses);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while retrieving data`
                }
            };
        } else {
            entities:contestAccess[] listResult = from var contestAccess in contestAccesses
                where contestAccess.contestId == contestId && contestAccess.userId == userId
                select contestAccess;

            if (listResult.length() == 0) {
                return <http:NotFound>{
                    body: {
                        message: string `User ${userId} hasn't access to contest ${contestId}`
                    }
                };
            }

            entities:contestAccess|persist:Error deletedContestAccess = self.db->/contestaccesses/[listResult[0].id].delete;

            if deletedContestAccess is persist:InvalidKeyError {
                return http:NOT_FOUND;
            } else if deletedContestAccess is persist:Error {
                log:printError("Error while deleting ", 'error = deletedContestAccess);
                return <http:InternalServerError>{
                    body: {
                        message: string `Error while deleting contest User ${userId} contest ${contestId} access`
                    }
                };
            } else {
                return http:OK;
            }
        }
    }


    resource function delete contests/[string contestId]/challenges/[string challengeId]()
            returns http:InternalServerError|http:NotFound|http:Ok {
        stream<entities:ChallengesOnContests, persist:Error?> challengesOnContets = self.db->/challengesoncontests;
        entities:ChallengesOnContests[]|persist:Error challengesOnContests = from var challengesOnContest in challengesOnContets
            where challengesOnContest.contestId == contestId && challengesOnContest.challengeId == challengeId
            select challengesOnContest;
        if challengesOnContests is persist:Error {
            log:printError("Error while reading challengesoncontests data", 'error = challengesOnContests);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while deleting the challenge in contest`
                }
            };
        }

        if challengesOnContests.length() == 0 {
            return http:NOT_FOUND;
        }

        entities:ChallengesOnContests|persist:Error challengesOnContestsResult =
            self.db->/challengesoncontests/[challengesOnContests[0].id].delete;
        if challengesOnContestsResult is persist:Error {
            log:printError("Error while deleting the challenge in contest", 'error = challengesOnContestsResult);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while deleting the challenge in contest`
                }
            };
        }
        return http:OK;
    }
}

function getContestChallenges(entities:Client db, string contestId) returns string[]|persist:Error {
    // Optimization possible
    stream<entities:ChallengesOnContests, persist:Error?> challengesOnContets = db->/challengesoncontests;
    return from var challengesOnContest in challengesOnContets
        where challengesOnContest.contestId == contestId
        select challengesOnContest.challengeId;
}

function getOwnerContests(entities:Client db, string userId, string status) returns data_model:Contest[]|persist:Error {

    stream<entities:Contest, persist:Error?> contestStream = db->/contests;

    entities:Contest[]|persist:Error contests = from var contest in contestStream
        select contest;

    if contests is persist:Error {
        log:printError("Error while reading contests data", 'error = contests);
        return contests;
    } else {
        return from var contest in contests
            where compareTime(contest.startTime, contest.endTime) == status && contest.moderatorId == userId
            select toDataModelContest(contest);
    }
}

function getSharedContests(entities:Client db, string userId, string status) returns SharedContestOut[]|persist:Error {

    stream<SharedContest, persist:Error?> sharedContestStream = db->/contestaccesses;

    SharedContest[]|persist:Error sharedContests = from var sharedContest in sharedContestStream
        select sharedContest;

    if sharedContests is persist:Error {
        log:printError("Error while reading contests data", 'error = sharedContests);
        return sharedContests;
    } else {
        return from var sharedContest in sharedContests
            where compareTime(sharedContest.contest.startTime, sharedContest.contest.endTime) == status && sharedContest.userId == userId
            select toSharedContestOut(sharedContest);
    }
}

function toSharedContestOut(SharedContest contest) returns SharedContestOut => {
    contestId: contest.contest.id,
    title: contest.contest.title,
    description: contest.contest.description,
    startTime: contest.contest.startTime,
    endTime: contest.contest.endTime,
    moderator: contest.contest.moderatorId,
    accessType: contest.accessType
};

function getAccessGrantedUsers(entities:Client db, string contestId) returns string[]|persist:Error {

    stream<entities:contestAccess, persist:Error?> contestAccessStream = db->/contestaccesses;

    entities:contestAccess[]|persist:Error contestAccesses = from var contestAccess in contestAccessStream
        select contestAccess;

    if contestAccesses is persist:Error {
        log:printError("Error while reading contests data", 'error = contestAccesses);
        return contestAccesses;
    } else {
        return from var contestAccess in contestAccesses
            where contestAccess.contestId == contestId
            select contestAccess.userId;
    }
}

function getContestAdmins(entities:Client db, string contestId) returns contestAccessAdminsOut[]|persist:Error? {

    stream<contestAccessAdmins, persist:Error?> contestAccessStream = db->/contestaccesses;

    contestAccessAdmins[]|persist:Error contestAccesses = from var contestAccess in contestAccessStream
        select contestAccess;

    if contestAccesses is persist:Error {
        log:printError("Error while reading contests data", 'error = contestAccesses);
        return contestAccesses;
    } else {
        return from var contestAccess in contestAccesses
            where contestAccess.contestId == contestId
            select toContestAccessAdminsOut(contestAccess);
    }
}

function toContestAccessAdminsOut(contestAccessAdmins contestAccess) returns contestAccessAdminsOut => {
    userId: contestAccess.user.id,
    accessType: contestAccess.accessType,
    userName: contestAccess.user.username,
    fullName: contestAccess.user.fullname
};


function getContestsWithStatus(entities:Client db, string status) returns data_model:Contest[]|persist:Error {

    stream<entities:Contest, persist:Error?> contestStream = db->/contests;

    entities:Contest[]|persist:Error contests = from var contest in contestStream
        select contest;

    if contests is persist:Error {
        log:printError("Error while reading contests data", 'error = contests);
        return contests;
    } else {
        return from var contest in contests
            where compareTime(contest.startTime, contest.endTime) == status
            select toDataModelContest(contest);
    }
}

function compareTime(time:Civil startTime, time:Civil endTime) returns string|error {    
    startTime.utcOffset = {
           hours: 5,
           minutes: 30
       };
    endTime.utcOffset = {
           hours: 5,
           minutes: 30
       };
    time:Utc nowTimeUTC = time:utcNow();
    time:Utc|time:Error startTimeUTC = time:utcFromCivil(startTime);
    time:Utc|time:Error endTimeUTC = time:utcFromCivil(endTime);

    if startTimeUTC is time:Error {
        return "Start time error";
    } else if endTimeUTC is time:Error {
        return "End Time error";
    } else if startTimeUTC < endTimeUTC && endTimeUTC < nowTimeUTC {
        return "past";
    } else if startTimeUTC > nowTimeUTC && endTimeUTC > nowTimeUTC {
        return "future";
    } else {
        return "present";
    }
}

function addContest(entities:Client db, NewContest newContest) returns string|persist:Error {
    string contestId = "contest-" + uuid:createType4AsString();
    entities:Contest contest = {
        id: contestId,
        title: newContest.title,
        description: newContest.description,
        startTime: newContest.startTime,
        endTime: newContest.endTime,
        moderatorId: newContest.moderator,
        imageUrl: ""
    };

    string[] lastInsertedIds = check db->/contests.post([contest]);
    return lastInsertedIds[0];
}

function toDataModelContest(entities:Contest contest) returns data_model:Contest => {
    contestId: contest.id,
    title: contest.title,
    description: contest.description,
    startTime: contest.startTime,
    endTime: contest.endTime,
    moderator: contest.moderatorId
};

function fromDataModelContest(data_model:Contest contest, string contestId) returns entities:Contest => {
    id: contestId,
    title: contest.title,
    description: contest.description ?: "",
    startTime: contest.startTime,
    endTime: contest.endTime,
    moderatorId: contest.moderator,
    imageUrl: ""
};

