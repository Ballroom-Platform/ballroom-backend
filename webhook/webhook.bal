import ballerinax/trigger.asgardeo;
import ballerina/log;
import ballerina/http;
import ballerinax/scim;

configurable asgardeo:ListenerConfig config = ?;
configurable string orgName = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string contestantGroupId = ?;

scim:ConnectorConfig configscim = {
    orgName: orgName,
    clientId: clientId,
    clientSecret : clientSecret,
    scope : ["internal_group_mgt_update"]
};

listener http:Listener httpListener = new(8090);
listener asgardeo:Listener webhookListener =  new(config,httpListener);

service asgardeo:RegistrationService on webhookListener {

    remote function onAddUser(asgardeo:AddUserEvent event ) returns error? {
        json user = event.toJson();
        json|error userName = user.eventData.userName;
        json|error userId = user.eventData.userId;
        if userName is error {
            log:printError("Error while getting username", 'error = userName);
            return userName;
        } else if userId is error {
            log:printError("Error while getting userId", 'error = userId);
            return userId;
        } else {
            string userNameStr = userName.toString();
            string userIdStr = userId.toString();

            scim:Client|error clientuser = new(configscim);
            if clientuser is error {
                log:printError("Error while creating scim client", 'error = clientuser);
                return clientuser;
            } else {
                scim:GroupPatch updateData = {
                    schemas: ["urn:ietf:params:scim:api:messages:2.0:PatchOp"],
                    Operations: [{
                        op: "add",
                        value: {
                            members: [{
                                display: userNameStr,
                                value: userIdStr
                            }]
                        }
                    }]
                };
                
                scim:GroupResponse|scim:ErrorResponse|error updateGroup = clientuser->patchGroup(contestantGroupId, updateData);
                if updateGroup is error {
                    log:printError(updateGroup.toBalString());
                    return updateGroup;
                } else {
                    return ();
                }
            }
        }
    }
    
    remote function onConfirmSelfSignup(asgardeo:GenericEvent event ) returns error? {
        
        log:printInfo(event.toJsonString());
    }
    
    remote function onAcceptUserInvite(asgardeo:GenericEvent event ) returns error? {
        
        log:printInfo(event.toJsonString());
    }
}

service /ignore on httpListener {}