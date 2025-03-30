import ballerina/http;
import ballerina/sql;
import ballerina/io;

public type Maintenance record {|
    int id;
    string name;
    string description;
    int priority_level;
    string status;
    string profile_picture;
|};

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type"]
    }
}

service /maintenance on ln {
    resource function get details() returns Maintenance[]|error {
        stream<Maintenance, sql:Error?> resultStream =
            dbClient->query(`SELECT * FROM maintenance`);

        Maintenance[] maintenances = [];
        check resultStream.forEach(function( Maintenance maintenance) {
            maintenances.push(maintenance);
        });

        return maintenances;
    }
}

public function maintenancesManagementService() returns error? {
    io:println("maintenancesManagement service started on port 9090");
}
