import ballerinax/mysql;
import ballerina/http;
import ballerina/sql;
import ballerinax/mysql.driver as _; // This bundles the driver to the project so that you don't need to bundle it via the `Ballerina.toml` file.


configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

# A service representing a network-accessible API
# bound to port `9090`.
service /score on new http:Listener(9092) {

    # A resource for generating greetings
    #
    # + submissionId - Parameter Description
    # + return - string name with hello message or error
    resource function get submissionScore(string submissionId) returns json {
        final mysql:Client | sql:Error dbClient = new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);
        if(dbClient is sql:Error){
            return respondDatabaseError();
        }
        string | sql:Error result = dbClient->queryRow(`
            SELECT submission_score FROM submissions WHERE submission_id = ${submissionId};
        `);

        sql:Error? close = dbClient.close();
        if close is sql:Error {
            return respondDatabaseError();
        }


        if(result is sql:Error){
            return respondDatabaseError();
        }


        if(result.length() == 0){
            return {
                message : "No submission found",
                data : ""
            }.toJson();
        }

        return {
            message : "Submission found",
            data : result
        }.toJson();
    }
}


public function respondDatabaseError() returns json {

    return {
                message : "Database error",
                data : ""
            }.toJson();
}
