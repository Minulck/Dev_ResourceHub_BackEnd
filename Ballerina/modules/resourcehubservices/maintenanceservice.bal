import ballerina/http;
import ballerina/io;
import ballerina/sql;

public type Maintenance record {|
    int id?;
    int user_id;
    string? name;
    string description;
    string priorityLevel;
    string status?;
    string request_date?;
    string profilePicture?;
    string username?;
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
            dbClient->query(`SELECT 
                u.profile_picture_url AS profilePicture,
                u.username AS username,
                m.name AS name,
                m.description,
                m.priority_level AS priorityLevel,
                m.status,
                m.request_date,
                m.id ,
                u.id as user_id
                FROM maintenance m
                JOIN users u ON m.user_id = u.id;
        `);

        Maintenance[] maintenances = [];
        check resultStream.forEach(function(Maintenance maintenance) {
            maintenances.push(maintenance);
        });

        return maintenances;
    }

    resource function post add(@http:Payload Maintenance maintenance) returns json|error {
        io:println("Received maintenance data: " + maintenance.toJsonString());

        sql:ExecutionResult result = check dbClient->execute(`
            INSERT INTO maintenance (name, user_id, description, priority_level, status, request_date)
            VALUES (${maintenance.name}, ${maintenance.user_id}, ${maintenance.description}, ${maintenance.priorityLevel}, 'Pending', NOW())
        `);

        if (result.affectedRowCount == 0) {
            return error("Failed to add maintenance request");
        }

    }

    resource function delete details/[int id]() returns json|error {

        sql:ExecutionResult result = check dbClient->execute(
        `DELETE from maintenance where id=${id}`);

        if (result.affectedRowCount == 0) {
            return error("No maintenance found with the given ID");
        }
    };

    resource function put details/[int id](@http:Payload Maintenance maintenace) returns json|error {
        sql:ExecutionResult result = check dbClient->execute(
            `UPDATE maintenance 
            SET description = ${maintenace.description}, 
            priority_level = ${maintenace.priorityLevel}, 
            status = ${maintenace.status} 
            WHERE id = ${id}`
        );

        if (result.affectedRowCount == 0) {
            return error("No maintenance found with the given ID");
        }
    }

}

public function maintenancesManagementService() returns error? {
    io:println("maintenancesManagement service started on port: 9090");
}
