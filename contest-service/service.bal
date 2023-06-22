import ballerina/http;
import ballerina/time;
import ballerina/uuid;
import ballerina/log;
import ballerina/persist;

import ballroom/data_model;
import ballroom/entities;
import ballerina/mime;
import ballerina/io;

type UpdatedContest record {
    string title;
    time:Civil startTime;
    time:Civil endTime;
    string moderator;
};

type UserAccess record {
    string userId;
    string accessType?;
};

type NewContest record {
    string title;
    byte[] readmeFile;
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
        byte[] readmeFile;
        time:Civil startTime;
        time:Civil endTime;
        string imageUrl;
        string moderatorId;
    |} contest;
|};

type SharedContestOut record {
    string contestId;
    string title;
    byte[] readmeFile;
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

type SubmissionData record {|
    string id;
    float score;
    string contestId;
    record {|
        string id;
        string fullname;
        string username;
    |} user;
    time:Civil submittedTime;
    record {|
        string id;
        string title;
    |} challenge;
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

    resource function get contests/[string contestId]/report()
            returns http:InternalServerError|string[][] {
        stream<SubmissionData, persist:Error?> submissionstream = self.db->/submissions;
        string[][]|persist:Error csvContentdata = from var submission in submissionstream
            where submission.contestId == contestId
            select [submission.id, submission.challenge.id, submission.challenge.title, submission.user.id, submission.user.username, submission.user.fullname, timeToString(submission.submittedTime), submission.score.toString()];
        if csvContentdata is persist:Error {
            log:printError("Error while reading submission data", 'error = csvContentdata);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while reading submission data`
                }
            };
        } else {
        string[] headers = ["submissionId", "challengeId", "challageTitle", "userId", "userName", "fullname", "submittedTime", "score"];
        string[][] csvData= [headers, ...csvContentdata];
        return csvData;
        }
    }

    resource function get contests/[string userId]/registered()
            returns data_model:Contest[]|MyInternalServerError {

        stream<entities:Registrants, persist:Error?> registrantstream = self.db->/registrants;

        string[]|persist:Error registeredContestIds = from var registrant in registrantstream
            where registrant.userId == userId
            select registrant.contestId;

        if registeredContestIds is persist:Error {
            log:printError("Error while reading registrants data", 'error = registeredContestIds);
            return <MyInternalServerError>{
                body: {
                    message: string `Error while reading registrants data`
                }
            };
        } else {
            stream<entities:Contest, persist:Error?> contestStream = self.db->/contests;

            data_model:Contest[]|persist:Error contests = from var contest in contestStream
                from var registeredContestId in registeredContestIds
                where contest.id == registeredContestId
                select toDataModelContest(contest);
            
            if contests is persist:Error {
                log:printError("Error while reading contests data", 'error = contests);
                return <MyInternalServerError>{
                    body: {
                        message: string `Error while reading contests data`
                    }
                };
            } else {
                return contests;
            }
        }
    }

    resource function get contests/owned/[string userId](string status) returns data_model:Contest[]|http:InternalServerError|http:NotFound {

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

    resource function get contests/shared/[string userId](string status) returns SharedContestOut[]|http:InternalServerError|http:NotFound {

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

    resource function get contests/[string contestId]/users\-with\-access() returns Payload|http:InternalServerError {
        do {
            contestAccessAdminsOut[]|persist:Error result = getAccessGrantedUsers(self.db, contestId) ?: [];

            Payload responsePayload = {
                message: "Contest access granted users",
                data: check result
            };
            return responsePayload;

        } on fail error e {
            log:printError("Error while retreving accessgranted userd", 'error = e);
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

    resource function get contests/[string contestId]/readme()
            returns @http:Payload {mediaType: "application/octet-stream"} http:Response|
        http:InternalServerError|http:NotFound {
        record {|byte[] readmeFile;|}|persist:Error readmeFileRecord = self.db->/contests/[contestId];
        if readmeFileRecord is persist:InvalidKeyError {
            return http:NOT_FOUND;
        } else if readmeFileRecord is persist:Error {
            log:printError("Error while retrieving contest radme by id", contestId = contestId,
                'error = readmeFileRecord);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while retrieving readme file by the contest '${contestId}'`
                }
            };
        } else {
            http:Response response = new;
            response.setBinaryPayload(readmeFileRecord.readmeFile);
            return response;
        }
    }


    resource function post contests(http:Request request) returns string|http:BadRequest|http:InternalServerError|error {
        mime:Entity[] bodyParts = check request.getBodyParts();
        // Check if the request has 5 body parts
        if bodyParts.length() != 5 {
            return <http:BadRequest>{
                body: {
                    message: string `Expects 4 bodyparts but found ${bodyParts.length()}`

                }
            };
        }
         // Creates a map with the body part name as the key and the body part as the value
        map<mime:Entity> bodyPartMap = {};
        foreach mime:Entity entity in bodyParts {
            bodyPartMap[entity.getContentDisposition().name] = entity;
        }
        // Check if all the required body parts are present
        if !bodyPartMap.hasKey("title") || !bodyPartMap.hasKey("readme") ||
            !bodyPartMap.hasKey("startTime") || !bodyPartMap.hasKey("endTime") || !bodyPartMap.hasKey("moderator") {
            return <http:BadRequest>{
                body: {
                    message: string `Expects 4 bodyparts with names 'title', 'readme', 'startTime', 'endTime' and 'moderator'`
                }
            };
        }

        entities:Contest entityContest = {
            id: uuid:createType4AsString(),
            title: check bodyPartMap.get("title").getText(),
            readmeFile: check readEntityToByteArray("readme", bodyPartMap),
            moderatorId: check bodyPartMap.get("moderator").getText(),
            imageUrl: "",
            startTime: check readEntityToTime("startTime", bodyPartMap),
            endTime: check readEntityToTime("endTime", bodyPartMap)};

        string[]|persist:Error insertedIds = self.db->/contests.post([entityContest]);
        if insertedIds is persist:Error {
            log:printError("Error while adding contest", 'error = insertedIds);
            return <http:InternalServerError>{
                body: {
                    message: string `Error while adding contest`
                }
            };
        } else {
            return insertedIds[0];
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

    resource function post contests/[string contestId]/users\-with\-access(@http:Payload UserAccess userAccess) returns string|http:BadRequest|http:InternalServerError {

        string userId = userAccess.userId;
        string? accessType = userAccess.accessType;

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

        if accessType != null {
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
        } else {
            log:printError("Error while adding admin to contest");
            return <http:InternalServerError>{
                body: {
                    message: string `Error while adding admin to contest`
                }
            };
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

    resource function delete contests/[string contestId]/users\-with\-access(@http:Payload UserAccess userAccess) returns http:InternalServerError|http:NotFound|http:Ok {

        string userId = userAccess.userId;

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
    readmeFile: contest.contest.readmeFile,
    startTime: contest.contest.startTime,
    endTime: contest.contest.endTime,
    moderator: contest.contest.moderatorId,
    accessType: contest.accessType
};

function getAccessGrantedUsers(entities:Client db, string contestId) returns contestAccessAdminsOut[]|persist:Error? {

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

function toDataModelContest(entities:Contest contest) returns data_model:Contest => {
    contestId: contest.id,
    title: contest.title,
    readme: contest.readmeFile,
    startTime: contest.startTime,
    endTime: contest.endTime,
    moderator: contest.moderatorId
};

function fromDataModelContest(data_model:Contest contest, string contestId) returns entities:Contest => {
    id: contestId,
    title: contest.title,
    readmeFile: contest.readme,
    startTime: contest.startTime,
    endTime: contest.endTime,
    moderatorId: contest.moderator,
    imageUrl: ""
};

function readEntityToByteArray(string entityName, map<mime:Entity> entityMap) returns byte[]|error {
    stream<byte[], io:Error?> testCaseStream = check entityMap.get(entityName).getByteStream();
    byte[] testCaseFile = [];
    check from var bytes in testCaseStream
        do {
            testCaseFile.push(...bytes);
        };
    return testCaseFile;
}

function readEntityToTime(string entityName, map<mime:Entity> entityMap) returns time:Civil|error {
    //get the time from the entity 
    string timeString = check entityMap.get(entityName).getText();
    
    //get year 
    string yearString = timeString.substring(0, 4);
    int year = check int:fromString(yearString);

    //get month
    string monthString = timeString.substring(5, 7);
    int month = check int:fromString(monthString);

    //get day
    string dayString = timeString.substring(8, 10);
    int day = check int:fromString(dayString);

    //get hour
    string hourString = timeString.substring(11, 13);
    int hour = check int:fromString(hourString);

    //get minute
    string minuteString = timeString.substring(14, 16);
    int minute = check int:fromString(minuteString);

    //make the time object
    time:Civil time = {
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute
    };

    return time;
}

function timeToString(time:Civil time) returns string {
    string timeString = time.year.toBalString() + "-" + time.month.toBalString() + "-" + time.day.toBalString() + " " + time.hour.toBalString() + ":" + time.minute.toBalString();
    return timeString;
}