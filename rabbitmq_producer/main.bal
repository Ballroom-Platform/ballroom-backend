// import ballerina/http;
import ballerinax/rabbitmq;

type Order readonly & record {
    int orderId;
    string productName;
    decimal price;
    boolean isValid;
};

rabbitmq:ConnectionConfiguration connectionConfig = {
    username: "mmsamaod",
    password: "bEQe7jNvWJOLpmgKNFThmR-9QZmwSYYl",
    connectionTimeout: 10000, // Set an appropriate connection timeout
    virtualHost: "mmsamaod"
    // Add other necessary configurations
};

// service / on new http:Listener(9092) {
//     private final rabbitmq:Client orderClient;

//     function init() returns error? {
//         // Initiate the RabbitMQ client at the start of the service. This will be used
//         // throughout the lifetime of the service.
//         self.orderClient = check new ("puffin.rmq2.cloudamqp.com", 5672, connectionConfig);
//     }

//     resource function post orders(Order newOrder) returns http:Accepted|error {
//         // Publishes the message using the `newClient` and the routing key named `OrderQueue`.
//         check self.orderClient->publishMessage({
//             content: newOrder,
//             routingKey: "OrderQueue"
//         });

//         return http:ACCEPTED;
//     }
// }
