import ballerina/http;
import ballerina/sql;

public type User record {|
    int id;
    string username;
    string profile_picture_url;
    string usertype;
    string email;
    string phone_number;
    string password;
    string additional_details;
    string created_at;
|};

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type"]
    }
}

service /user on ln {
    resource function get details() returns User[]|error {
        stream<User, sql:Error?> resultStream =
            dbClient->query(`SELECT * FROM Users`);

        User[] users = [];
        check resultStream.forEach(function(User user) {
            users.push(user);
        });

        return users;
    }
}
