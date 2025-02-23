import ballerina/http;
import ballerina/sql;

type MealEvent record {|
    int id?;
    string meal_time;
    string meal_type;
    int user_id;
    string submitted_date;
    string meal_request_date;
|};

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type"]
    }
}
service /mealevents on new http:Listener(9093) {

    resource function get .() returns MealEvent[]|error {
        stream<MealEvent, sql:Error?> resultStream = 
            dbClient->query(`SELECT * FROM MealEvents`);
        
        MealEvent[] events = [];
        check resultStream.forEach(function(MealEvent event) {
            events.push(event);
        });

        return events;
    }

    resource function post add(@http:Payload MealEvent event) returns json|error {
        sql:ExecutionResult result = check dbClient->execute(`
            INSERT INTO MealEvents (meal_time, meal_type, user_id, submitted_date, meal_request_date)
            VALUES (${event.meal_time}, ${event.meal_type}, ${event.user_id}, ${event.submitted_date}, ${event.meal_request_date})
        `);

        int|string? lastInsertId = result.lastInsertId;
        if lastInsertId is int {
            event.id = lastInsertId;
            return { message: "Meal event added successfully", id: lastInsertId };
        }

        return { message: "Failed to add meal event" };
    }

    resource function delete [int id]() returns json|error {
        sql:ExecutionResult result = check dbClient->execute(`
            DELETE FROM MealEvents WHERE id = ${id}
        `);

        if result.affectedRowCount == 0 {
            return { message: "Meal event not found" };
        }

        return { message: "Meal event deleted successfully" };
    }

    resource function options .() returns http:Ok {
        return http:OK;
    }
}
