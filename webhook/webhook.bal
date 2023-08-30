import ballerinax/trigger.asgardeo;
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
    clientSecret: clientSecret,
    scope: ["internal_group_mgt_update"]
};

listener http:Listener httpListener = new (8090);
listener asgardeo:Listener webhookListener = new (config, httpListener);

service asgardeo:RegistrationService on webhookListener {

    remote function onAddUser(asgardeo:AddUserEvent event) returns error? {
        json user = event.toJson();
        json|error userName = user.eventData.userName;
        json|error userId = user.eventData.userId;
        if userName is error {
            return userName;
        } else if userId is error {
            return userId;
        } else {
            string userNameStr = userName.toString();
            string userIdStr = userId.toString();

            scim:Client|error scimClient = new (configscim);
            if scimClient is error {
                return scimClient;
            } else {
                scim:GroupPatch updateData = {
                    schemas: ["urn:ietf:params:scim:api:messages:2.0:PatchOp"],
                    Operations: [
                        {
                            op: "add",
                            value: {
                                members: [
                                    {
                                        display: userNameStr,
                                        value: userIdStr
                                    }
                                ]
                            }
                        }
                    ]
                };

                scim:GroupResponse|scim:ErrorResponse|error updateGroup = scimClient->patchGroup(contestantGroupId, updateData);
                if updateGroup is error {
                    return updateGroup;
                } else {
                    return ();
                }
            }
        }
    }

    remote function onConfirmSelfSignup(asgardeo:GenericEvent event) returns error? {
    }

    remote function onAcceptUserInvite(asgardeo:GenericEvent event) returns error? {
    }
}

service /ignore on httpListener {}
 