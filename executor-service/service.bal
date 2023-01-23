import ballerina/io;
import ballerinax/rabbitmq;
import wso2/data_model;
import ballerina/file;


// const SCORE_OUTPUT_FILEPATH = "";

// The consumer service listens to the "RequestQueue" queue.
listener rabbitmq:Listener channelListener= new(rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);
   
@rabbitmq:ServiceConfig {
    queueName: data_model:QUEUE_NAME
}
service rabbitmq:Service on channelListener {
    remote function onMessage(data_model:SubmissionMessage submissionEvent) returns error? {

        io:println(submissionEvent);
        // need to evaluate the score
        check handleEvent(submissionEvent);
    }
}

function handleEvent(data_model:SubmissionMessage submissionEvent) returns error? {
    
    // get the file
    string|error storedLocation = getAndStoreFile(submissionEvent.fileLocation);

    // unzip the submissionZip
    // string subProblemDir = "problem_" + string:substring(event.problemId, 0, <int>string:indexOf(event.problemId, ".", 0)) + "_" +
    // string:substring(event.problemId, <int>string:indexOf(event.problemId, ".", 0) + 1, string:length(event.problemId));
    // string submissionDir = check file:joinPath(tempDir, regex:split(event.wso2Email, "@")[0] + "_" + subProblemDir);
    // string[] unzipArguments = ["unzip -d " + submissionDir + " " + submissionZipFilePath];
    string[] unzipArguments = ["unzip -d ./storedFiles/" + submissionEvent.fileLocation];

    _ = check executeCommand(unzipArguments);


    // replace the test cases
    string testsDirPath = getTestDirPath(submissionEvent.challengeId);
    check file:remove("./storedFiles/" + submissionEvent.fileLocation + "/tests", file:RECURSIVE);
    check file:copy(check storedLocation, testsDirPath);

    // run the test cases
    string[] testCommand = ["bal test"];
    string[] executeCommandResult = check executeCommand(testCommand, check storedLocation);

    // calculate a score from the output
    float score = calculateScore(executeCommandResult);

    // output to a file (for now)
    string[] content = [submissionEvent.userId + "|" + submissionEvent.challengeId + "|" + submissionEvent.contestId + "|" + submissionEvent.fileLocation + " ----> " + score.toString()];
    io:Error? fileWriteLines = io:fileWriteLines("./scores/scores.txt", content);

}

function calculateScore(string[] executeCommandResult) returns float {
    return 0.0;
}

function getTestDirPath(string challengeId) returns string {
    // hardcoding a value for now (ideally should be generated using the challenge id)
    return "./challengetests/tests";
}

function getAndStoreFile(string fileLocation) returns string|error{

    // should get the file from the given location and store it somewhere, then return where you stored it
    check file:copy("../upload-service/files/" + fileLocation,  "./storedFiles/" + fileLocation, file:REPLACE_EXISTING);
    return "./storedFiles/" + fileLocation;
}

# Description
#
# + arguments - String array which contains arguments to execute
# + workdingDir - Working directory
# + return - Returns an error if exists
function executeCommand(string[] arguments, string? workdingDir = ()) returns string[]|error {
    string[] newArgs = [];
    newArgs.push("/bin/bash", "-c");
    arguments.forEach(function(string arg) {
        newArgs.push(arg, "&&");
    });
    _ = newArgs.pop();

    ProcessBuilder builder = check newProcessBuilder2(newArgs);
    if workdingDir is string {
        builder = builder.directory2(newFile2(workdingDir));
    }
    _ = builder.redirectErrorStream2(true);

    Process p = check builder.start();
    BufferedReader r = newBufferedReader1(newInputStreamReader1(p.getInputStream()));
    string?|IOException line;
    string[] output = [];
    while (true) {
        line = check r.readLine();
        if (line == ()) {
            break;
        }
        io:println(line);
        output.push(check line);
    }
    return output;
}
