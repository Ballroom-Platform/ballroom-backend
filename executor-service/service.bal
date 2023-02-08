import ballerina/io;
import ballerinax/rabbitmq;
import ballerina/file;
import wso2/data_model;
import ballerinax/mysql;
import ballerinax/mysql.driver as _; // This bundles the driver to the project so that you don't need to bundle it via the `Ballerina.toml` file.
import ballerina/regex;


configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;


// const SCORE_OUTPUT_FILEPATH = "";

// The consumer service listens to the "RequestQueue" queue.
listener rabbitmq:Listener channelListener= new(rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);
   
@rabbitmq:ServiceConfig {
    queueName: data_model:QUEUE_NAME
}
service rabbitmq:Service on channelListener {

    private final rabbitmq:Client rabbitmqClient;

    function init() returns error? {
        // Initiate the RabbitMQ client at the start of the service. This will be used
        // throughout the lifetime of the service.
        self.rabbitmqClient = check new (rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);
    }

    remote function onMessage(data_model:SubmissionMessage submissionEvent) returns error? {

        io:println(submissionEvent);
        // need to evaluate the score
        data_model:ScoredSubmissionMessage scoredSubMsg = check handleEvent(submissionEvent);

        check self.rabbitmqClient->publishMessage({
            content: scoredSubMsg,
            routingKey: data_model:EXEC_TO_SCORE_QUEUE_NAME
        });
    }
}

function handleEvent(data_model:SubmissionMessage submissionEvent) returns error|data_model:ScoredSubmissionMessage {
    string basePath = "../storedFiles/";
    string fileNameWithExtension = submissionEvent.fileName + submissionEvent.fileExtension;
    
    // get the file
    string|error storedLocation = getAndStoreFile(submissionEvent.fileName, submissionEvent.fileExtension, submissionEvent.submissionId);


    // unzip the submissionZip
    // string subProblemDir = "problem_" + string:substring(event.problemId, 0, <int>string:indexOf(event.problemId, ".", 0)) + "_" +
    // string:substring(event.problemId, <int>string:indexOf(event.problemId, ".", 0) + 1, string:length(event.problemId));
    // string submissionDir = check file:joinPath(tempDir, regex:split(event.wso2Email, "@")[0] + "_" + subProblemDir);
    // string[] unzipArguments = ["unzip -d " + submissionDir + " " + submissionZipFilePath];
    string[] unzipArguments = ["unzip " + basePath + fileNameWithExtension + " -d " + basePath + submissionEvent.fileName + "/"];

    _ = check executeCommand(unzipArguments);


    // replace the test cases
    string testsDirPath = getTestDirPath(submissionEvent.challengeId);
    check file:remove(basePath + submissionEvent.fileName + "/tests", file:RECURSIVE);
    check file:copy(testsDirPath,check storedLocation + "/tests/");

    // run the test cases
    string[] testCommand = ["cd " + check storedLocation +  " && bal test"];
    string[] executeCommandResult = check executeCommand(testCommand);

    // calculate a score from the output
    float score = check calculateScore(executeCommandResult);

    data_model:ScoredSubmissionMessage scoredSubMsg = {subMsg: submissionEvent, score: score};

    

    // output to a file (for now)
    string[] content = [submissionEvent.userId + "|" + submissionEvent.challengeId + "|" + submissionEvent.contestId + "|" + fileNameWithExtension + " ----> " + score.toString()];
    io:Error? fileWriteLines = io:fileWriteLines("./scores/scores.txt", content);

    return scoredSubMsg;

}

function calculateScore(string[] executeCommandResult) returns float|error {

    string balCommandOutput = "";
    float score = 0.0;
    foreach string line in executeCommandResult {
        balCommandOutput += "\n" + line;
    }

    // calculate scores
    int passingTests = 0;
    int totalTests = 0;
    string[] reversedConsoleContent = executeCommandResult.reverse();

    boolean processPassing = false;
    boolean processFailing = false;
    boolean processSkipped = false;
    foreach string line in reversedConsoleContent {
        if (processPassing && processFailing && processSkipped) {
            break;
        } else {
            if (string:includes(line, "passing") && !processPassing) {
            passingTests = check int:fromString(regex:split(string:trim(line), " ")[0]);
            totalTests += check int:fromString(regex:split(string:trim(line), " ")[0]);
            processPassing = true;
        }
        if (string:includes(line, "failing") && !processFailing) {
            totalTests += check int:fromString(regex:split(string:trim(line), " ")[0]);
            processFailing = true;
        }
        if (string:includes(line, "skipped") && !processSkipped) {
            totalTests += check int:fromString(regex:split(string:trim(line), " ")[0]);
            processSkipped = true;
        }
        }
    }
    if totalTests > 0 {
        score = (10.0 * <float>passingTests) / <float>totalTests;
    }
    return score;
}

function getTestDirPath(string challengeId) returns string {
    // hardcoding a value for now (ideally should be generated using the challenge id)
    return "./challengetests/tests/";
}

function getAndStoreFile(string fileName, string fileExtension, string submissionId) returns string|error{
    string basePath = "../storedFiles";
    string fileLocation = fileName + fileExtension;
    // should get the file from the given location and store it somewhere, then return where you stored it
    boolean dirExists = check file:test(basePath, file:EXISTS);
    if(!dirExists){
        check file:createDir(basePath, file:RECURSIVE);
    }
    //check file:copy("../upload-service/files/" + fileLocation,  "../storedFiles/" + fileLocation, file:REPLACE_EXISTING);

    // The Redis Configuration
    // redis:ConnectionConfig redisConfig = {
    //         host: "127.0.0.1:6379",
    //         password: "",
    //         options: {
    //             connectionPooling: true,
    //             isClusterConnection: false,
    //             ssl: false,
    //             startTls: false,
    //             verifyPeer: false,
    //             connectionTimeout: 500
    //         }
    //     };

    // redis:Client redisConn = check new (redisConfig);
    // string? redisString = check redisConn->get(redisKey);
    // redisConn.stop();
    // if (redisString is ()) {
    //     return error("Submission missing in datastore.");
    // }
    // byte[] byteArray = string:toBytes(redisString);
    // byte[] byteStream = <byte[]>(check mime:base64Decode(byteArray));

    byte[] fileFromDB = check getFileFromDB(submissionId);

    check io:fileWriteBytes(basePath + "/" + fileLocation, fileFromDB);


    return basePath + "/" + fileName + "/";
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

isolated function getFileFromDB(string submissionId) returns byte[]|error {
    final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);
    byte[] submissionFileBlob = check dbClient->queryRow(
        `SELECT submission_file FROM submissions WHERE submission_id = ${submissionId}`
    );
    check dbClient.close();
    return submissionFileBlob;
}