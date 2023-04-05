import wso2/data_model;
import ballerinax/mysql;
import ballerina/sql;
import ballerinax/mysql.driver as _; // This bundles the driver to the project so that you don't need to bundle it via the `Ballerina.toml` file.
public type Payload record {
    string message;
    anydata data;
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

function getUsersByRole(string role) returns data_model:User[]|sql:Error?{
    final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);
    stream<data_model:User,sql:Error?> result = dbClient->query(`SELECT * FROM user WHERE role = ${role}`);
    check dbClient.close();

    data_model:User[]|sql:Error? listOfUsers = from data_model:User user in result select user;
    return listOfUsers;
}

isolated function updateUserRole(string userId, string role) returns error?{
    final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);

    // check if role is valid
    if role != "admin" && role != "contestant" {
        return error("INVALID ROLE.");
    }
    sql:ExecutionResult execRes = check dbClient->execute(`
        UPDATE user SET role = ${role} WHERE user_id = ${userId};
    `);
    if execRes.affectedRowCount == 0 {
        return error("INVALID USER_ID.");
    }
    check dbClient.close();
    return;
}

isolated function getUserRole(string userId) returns string | error {
    final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT,database=DATABASE);

    string role = check dbClient->queryRow(`SELECT role from user WHERE user_id = ${userId};`);
    _ = check dbClient.close();

    return role;
}