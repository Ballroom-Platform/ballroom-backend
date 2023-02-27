import ballerina/http;
import ballerinax/mysql;
import ballerina/sql;
import ballerinax/mysql.driver as _; // This bundles the driver to the project so that you don't need to bundle it via the `Ballerina.toml` file.
import wso2/data_model;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

# A service representing a network-accessible API
# bound to port `9090`.
service /userService on new http:Listener(9090) {


    resource function get user/[string userID]() returns json|error {
        
        final mysql:Client | sql:Error dbClient = new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);
        if(dbClient is sql:Error){
            return respondDatabaseError();
        }

        data_model:User?|sql:Error result = dbClient->queryRow(`SELECT * FROM user WHERE user_id = ${userID};`);

        sql:Error? close = dbClient.close();
        if close is sql:Error {
            return respondDatabaseError();
        }


        if(result is sql:Error){
            return respondDatabaseError();
        }


        if(result is ()){
            return {
                message : "No User found",
                data : ""
            }.toJson();
        }

        return {
            message : "User found",
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
