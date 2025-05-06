import ballerina/http;
import ballerina/io;
import ballerina/sql;

public type MealEvent record {| 
    int requestedmeal_id?; 
    int mealtime_id; 
    int mealtype_id; 
    string mealtype_name?; 
    string mealtime_name?; 
    string username?; 
    int user_id; 
    string submitted_date; 
    string meal_request_date; 
|};

@http:ServiceConfig { 
    cors: { 
        allowOrigins: ["http://localhost:5173", "*"], 
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"], 
        allowHeaders: ["Content-Type"] 
    } 
} 
service /calander on ln { 
    // MealEvents endpoints 
    resource function get mealevents/[int userid]() returns MealEvent[]|error { 
        stream<MealEvent, sql:Error?> resultStream = 
            dbClient->query(`SELECT requestedmeals.requestedmeal_id, mealtime_id,mealtimes.mealtime_name , mealtype_id,mealtypes.mealtype_name , username,users.user_id, submitted_date, meal_request_date 
            FROM requestedmeals
            JOIN users ON requestedmeals.user_id = users.user_id 
            join mealtypes ON requestedmeals.meal_type_id = mealtypes.mealtype_id
            join mealtimes ON requestedmeals.meal_time_id = mealtimes.mealtime_id 
            WHERE requestedmeals.user_id = ${userid}`); 

        MealEvent[] events = []; 
        check resultStream.forEach(function(MealEvent event) { 
            events.push(event); 
        }); 

        return events; 
    } 

    resource function get mealevents() returns MealEvent[]|error { 
        stream<MealEvent, sql:Error?> resultStream = 
                      dbClient->query(`SELECT requestedmeals.requestedmeal_id, mealtime_id,mealtimes.mealtime_name , mealtype_id,mealtypes.mealtype_name , username,users.user_id, submitted_date, meal_request_date 
            FROM requestedmeals
            JOIN users ON requestedmeals.user_id = users.user_id 
            join mealtypes ON requestedmeals.meal_type_id = mealtypes.mealtype_id
            join mealtimes ON requestedmeals.meal_time_id = mealtimes.mealtime_id`); 

        MealEvent[] events = []; 
        check resultStream.forEach(function(MealEvent event) { 
            events.push(event); 
        }); 

        return events; 
    } 

    resource function post mealevents/add(@http:Payload MealEvent event) returns json|error { 
        sql:ExecutionResult result = check dbClient->execute(` 
            INSERT INTO requestedmeals (meal_time_id, meal_type_id, user_id, submitted_date, meal_request_date) 
            VALUES (${event.mealtime_id}, ${event.mealtype_id}, ${event.user_id}, ${event.submitted_date}, ${event.meal_request_date}) 
        `); 

       if result.affectedRowCount == 0 { 
            return {message: "Failed to add meal event"}; 
        } 

        return {message: "Meal event added successfully", event: event};
    } 

    resource function delete mealevents/[int id]() returns json|error { 
        sql:ExecutionResult result = check dbClient->execute(` 
            DELETE FROM requestedmeals WHERE requestedmeal_id = ${id} 
        `); 

        if result.affectedRowCount == 0 { 
            return {message: "Meal event not found"}; 
        } 

        return {message: "Meal event deleted successfully"}; 
    } 
} 

public function startCalendarService() returns error? { 
    io:println("Calander service started on port 9090"); 
}
