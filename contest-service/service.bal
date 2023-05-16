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
        allowHeaders: ["CORELATION_ID", "Authorization", "Content-Type"],
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

function getContestsWithStatus(entities:Client db, string status) returns data_model:Contest[]|persist:Error {
    // Optimization possible
    stream<entities:Contest, persist:Error?> contestStream = db->/contests;
    entities:Contest[] contests = check from var contest in contestStream
        // TODO start time comparison
        select contest;

    // sql:ParameterizedQuery query = ``;
    // if status.equalsIgnoreCaseAscii("future") {
    //     query = `SELECT * FROM contest WHERE CURRENT_TIMESTAMP() <= start_time;`;
    // } else if status.equalsIgnoreCaseAscii("present") {
    //     query = `SELECT * FROM contest WHERE CURRENT_TIMESTAMP() BETWEEN start_time AND end_time;`;
    // } else if status.equalsIgnoreCaseAscii("past") {
    //     query = `SELECT * FROM contest WHERE CURRENT_TIMESTAMP() >= end_time;`;
    // } else {
    //     return error("INVALID STATUS!!");
    // }

    return from var contest in contests
        select toDataModelContest(contest);
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

