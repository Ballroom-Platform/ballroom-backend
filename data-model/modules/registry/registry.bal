import ballerina/io;
configurable map<string> serviceIds = {};

public isolated function lookup(string serviceId) returns string|error {
    io:println("serviceIds: ", serviceIds);
    if (serviceIds.hasKey(serviceId)) {
        return serviceIds.get(serviceId);
    } else {
        return error(string `ServiceId  ${serviceId} not found`);
    }
}