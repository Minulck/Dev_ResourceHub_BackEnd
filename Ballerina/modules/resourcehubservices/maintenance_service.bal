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

public type Notification record {|
    int maintenance_id;
    int user_id;
    string name?;
    string description?;
    string priorityLevel?;
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

    // POST: Add a new maintenance request
    resource function post add(@http:Payload Maintenance maintenance) returns json|error {
        
        // Use parameterized query to prevent SQL injection
        sql:ExecutionResult result = check dbClient->execute(
            `INSERT INTO maintenance (name, user_id, description, priority_level, status, request_date)
                                   VALUES (${maintenance.name}, ${maintenance.user_id}, ${maintenance.description}, 
                                           ${maintenance.priorityLevel}, 'Pending', NOW())`
        );

        if (result.affectedRowCount == 0) {
            return error("Failed to add maintenance request");
        }

        return {"message": "Maintenance request has been added "};
    }

    // DELETE: Remove a maintenance request by ID
    resource function delete details/[int id]() returns json|error {

        sql:ExecutionResult result = check dbClient->execute(
            `DELETE FROM maintenance WHERE id = ${id}`
        );

        if (result.affectedRowCount == 0) {
            return error("No maintenance found with the given ID");
        }

        return {"message": "Maintenance request has been deleted "};
    }

    // PUT: Update a maintenance request by ID
    resource function put details/[int id](@http:Payload Maintenance maintenance) returns json|error {

        sql:ExecutionResult result = check dbClient->execute(
            `UPDATE maintenance 
            SET description = ${maintenance.description}, 
            priority_level = ${maintenance.priorityLevel}, 
            status = ${maintenance.status ?: "Pending"} 
            WHERE id = ${id}`
        );

        if (result.affectedRowCount == 0) {
            return error("No maintenance found with the given ID");
        }

        return {"message": "Maintenance request has been updated "};
    }

    resource function get notification() returns Notification[]|error{
        stream< Notification ,sql:Error?> resultstream = dbClient->query(
            `select m.request_date,u.username,m.description,m.priority_level AS priorityLevel,m.status,m.name
            from notification n
            join users u on n.user_id=u.id
            join maintenance m on n.maintenance_id=m.id`
            );
            Notification[] notifications =[];
            check resultstream.forEach(function(Notification notification){
                notifications.push(notification);
            });
            return notifications;
    }

    resource function post addnotification(@http:Payload Notification notification) returns json|error{
        sql:ExecutionResult result = check dbClient->execute(`
        insert into notification (user_id,maintenance_id)
        values(${notification.user_id},${notification.maintenance_id})`
        );
         if (result.affectedRowCount == 0) {
            return error("No Notification found with the given ID");
        }

        return {"message": "Notification request has been updated."};
    }
}

public function startMaintenanceManagementService() returns error? {
    io:println("maintenancesManagement service started on port: 9090");
}
