import ballerina/http;
import ballerina/sql;
import ballerina/io;

// Defines the structure of a MealTime object
public type MealTime record {| 
    int mealtime_id?;
    string mealtime_name;
    string mealtime_image_url;
|};

// CORS configuration for cross-origin requests
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type"]
    }
}

// MealTime service with CRUD operations
service /mealtime on ln{

    // Fetch all mealtime records
    resource function get details() returns MealTime[]|error {
        stream<MealTime, sql:Error?> resultStream = 
            dbClient->query(`SELECT mealtime_id,mealtime_name , mealtime_image_url FROM mealtimes`);
        
        MealTime[] mealtimes = [];
        check resultStream.forEach(function(MealTime meal) {
            mealtimes.push(meal);
        });

        return mealtimes;
    }

    // Add a new mealtime record
    resource function post add(@http:Payload MealTime mealTime) returns json|error {
        io:println("Received meal time data: " + mealTime.toJsonString());

        sql:ExecutionResult result = check dbClient->execute(`
            INSERT INTO mealtimes (mealtime_name, mealtime_image_url)
            VALUES (${mealTime.mealtime_name}, ${mealTime.mealtime_image_url})
        `);

        int|string? lastInsertId = result.lastInsertId;
        if lastInsertId is int {
            mealTime.mealtime_id = lastInsertId;
        }

        return {
            message: "Meal time added successfully",
            mealTime: mealTime
        };
    }

    // Update an existing mealtime by ID
    resource function put details/[int id](@http:Payload MealTime mealTime) returns json|error {
        sql:ExecutionResult result = check dbClient->execute(`
            UPDATE mealtimes 
            SET mealtime_name = ${mealTime.mealtime_name}, mealtime_image_url = ${mealTime.mealtime_image_url}
            WHERE mealtime_id = ${id}
        `);

        if result.affectedRowCount == 0 {
            return {
                message: "Meal time not found"
            };
        }

        return {
            message: "Meal time updated successfully",
            mealTime: mealTime
        };
    }

    // Delete a mealtime by ID
    resource function delete details/[int id]() returns json|error {
        sql:ExecutionResult result = check dbClient->execute(`
            DELETE FROM mealtimes WHERE mealtime_id = ${id}
        `);

        if result.affectedRowCount == 0 {
            return {
                message: "Meal time not found"
            };
        }

        return {
            message: "Meal time deleted successfully"
        };
    }

}

// Logs service start on port 9090
public function startMealTimeService() returns error? {
    io:println("Meal Time service started on port 9090");
}
