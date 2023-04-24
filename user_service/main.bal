import ballroom/data_model;
import ballerinax/mysql;
import ballerina/sql;
import ballerina/log;
import ballerinax/mysql.driver as _; // This bundles the driver to the project so that you don't need to bundle it via the `Ballerina.toml` file.
public type Payload record {
    string message;
    anydata data;
};

final mysql:Client db = check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);

isolated function getUserData(string userID) returns data_model:User | error {
    data_model:User|sql:Error result = db->queryRow(`SELECT * FROM user WHERE user_id = ${userID};`);
    return result;
}

isolated function createUser(data_model:User user) returns error? {
    log:printInfo("Creating user: " + user.username);
    log:printInfo("Created dbClient");
    _ = check db->execute(`INSERT INTO user (user_id, username, fullname, role) VALUES (${user.user_id}, ${user.username}, ${user.fullname}, ${user.role})`);
    log:printInfo("Executed query");
}

function getUsersByRole(string role) returns data_model:User[]|sql:Error?{
    stream<data_model:User,sql:Error?> result = db->query(`SELECT * FROM user WHERE role = ${role}`);
    data_model:User[]|sql:Error? listOfUsers = from data_model:User user in result select user;
    return listOfUsers;
}

isolated function updateUserRole(string userId, string role) returns error?{
    // check if role is valid
    if role != "admin" && role != "contestant" {
        return error("INVALID ROLE.");
    }
    sql:ExecutionResult execRes = check db->execute(`
        UPDATE user SET role = ${role} WHERE user_id = ${userId};
    `);
    if execRes.affectedRowCount == 0 {
        return error("INVALID USER_ID.");
    }
    return;
}

isolated function getUserRole(string userId) returns string | error {
    return check db->queryRow(`SELECT role from user WHERE user_id = ${userId};`);
}