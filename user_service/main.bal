import wso2/data_model;
import ballerinax/mysql;
import ballerina/sql;
import ballerinax/mysql.driver as _; // This bundles the driver to the project so that you don't need to bundle it via the `Ballerina.toml` file.
public type Payload record {
    string message;
    data_model:User? data;
};


isolated function getUserData(string userID) returns data_model:User | error {
    final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);

    data_model:User|sql:Error result = dbClient->queryRow(`SELECT * FROM user WHERE user_id = ${userID};`);

    _ = check dbClient.close();
    return result;
}

isolated function createUser(data_model:User user) returns error? {
    final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);

    _ = check dbClient->execute(`INSERT INTO user (user_id, username, fullname, role) VALUES (${user.user_id}, ${user.username}, ${user.fullname}, ${user.role})`);

    _ = check dbClient.close();
}