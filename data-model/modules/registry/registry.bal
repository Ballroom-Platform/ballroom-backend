configurable map<string> serviceIds = {};

public isolated function lookup(string serviceId) returns string|error {
    if (serviceIds.hasKey(serviceId)) {
        return serviceIds.get(serviceId);
    } else {
        return error(string `ServiceId  ${serviceId} not found`);
    }
}
