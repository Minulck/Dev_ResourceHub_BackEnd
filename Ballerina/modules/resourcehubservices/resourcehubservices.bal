// import ballerina/http;
// import ballerina/sql;
// import ballerina/io;
// import ballerinax/mysql;


// configurable string USER = "root";
// configurable string PASSWORD ="Chathumal@12";
// configurable string HOST = "localhost";
// configurable int PORT =3306;
// configurable string DATABASE = "company";

// final mysql:Client dbClient = check new(
//     host=HOST, user=USER, password=PASSWORD, port=PORT, database=DATABASE
// );

// public type MealEvent record {|
//     int id?;
//     string meal_time;
//     string meal_type;
//     int user_id;
//     string submitted_date;
//     string meal_request_date;
// |};

// public type MealTime record {|
//     int id?;
//     string mealName;
//     string mealImageUrl;
// |};

// public type MealType record {|
//     int id?;
//     string mealName;
//     string mealImageUrl;
// |};

// @http:ServiceConfig {
//     cors: {
//         allowOrigins: ["http://localhost:5173", "*"],
//         allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
//         allowHeaders: ["Content-Type"]
//     }
// }
// service / on new http:Listener(9090) {

    // // MealEvents endpoints
    // resource function get mealevents() returns MealEvent[]|error {
    //     stream<MealEvent, sql:Error?> resultStream = 
    //         dbClient->query(`SELECT * FROM MealEvents`);
        
    //     MealEvent[] events = [];
    //     check resultStream.forEach(function(MealEvent event) {
    //         events.push(event);
    //     });

    //     return events;
    // }

    // resource function post mealevents/add(@http:Payload MealEvent event) returns json|error {
    //     sql:ExecutionResult result = check dbClient->execute(`
    //         INSERT INTO MealEvents (meal_time, meal_type, user_id, submitted_date, meal_request_date)
    //         VALUES (${event.meal_time}, ${event.meal_type}, ${event.user_id}, ${event.submitted_date}, ${event.meal_request_date})
    //     `);

    //     int|string? lastInsertId = result.lastInsertId;
    //     if lastInsertId is int {
    //         event.id = lastInsertId;
    //         return { message: "Meal event added successfully", id: lastInsertId };
    //     }

    //     return { message: "Failed to add meal event" };
    // }

    // resource function delete mealevents/[int id]() returns json|error {
    //     sql:ExecutionResult result = check dbClient->execute(`
    //         DELETE FROM MealEvents WHERE id = ${id}
    //     `);

    //     if result.affectedRowCount == 0 {
    //         return { message: "Meal event not found" };
    //     }

    //     return { message: "Meal event deleted successfully" };
    // }

    // // MealTime endpoints
    // resource function get mealtime() returns MealTime[]|error {
    //     stream<MealTime, sql:Error?> resultStream = 
    //         dbClient->query(`SELECT id, meal_name as mealName, meal_image_url as mealImageUrl FROM MealTimes`);
        
    //     MealTime[] mealtimes = [];
    //     check resultStream.forEach(function(MealTime meal) {
    //         mealtimes.push(meal);
    //     });

    //     return mealtimes;
    // }

    // resource function post mealtime/add(@http:Payload MealTime mealTime) returns json|error {
    //     io:println("Received meal time data: " + mealTime.toJsonString());

    //     sql:ExecutionResult result = check dbClient->execute(`
    //         INSERT INTO MealTimes (meal_name, meal_image_url)
    //         VALUES (${mealTime.mealName}, ${mealTime.mealImageUrl})
    //     `);

    //     int|string? lastInsertId = result.lastInsertId;
    //     if lastInsertId is int {
    //         mealTime.id = lastInsertId;
    //     }

    //     return {
    //         message: "Meal time added successfully",
    //         mealTime: mealTime
    //     };
    // }

    // resource function put mealtime/[int id](@http:Payload MealTime mealTime) returns json|error {
    //     sql:ExecutionResult result = check dbClient->execute(`
    //         UPDATE MealTimes 
    //         SET meal_name = ${mealTime.mealName}, meal_image_url = ${mealTime.mealImageUrl}
    //         WHERE id = ${id}
    //     `);

    //     if result.affectedRowCount == 0 {
    //         return {
    //             message: "Meal time not found"
    //         };
    //     }

    //     return {
    //         message: "Meal time updated successfully",
    //         mealTime: mealTime
    //     };
    // }

    // resource function delete mealtime/[int id]() returns json|error {
    //     sql:ExecutionResult result = check dbClient->execute(`
    //         DELETE FROM MealTimes WHERE id = ${id}
    //     `);

    //     if result.affectedRowCount == 0 {
    //         return {
    //             message: "Meal time not found"
    //         };
    //     }

    //     return {
    //         message: "Meal time deleted successfully"
    //     };
    // }

    // // MealType endpoints
    // resource function get mealtype() returns MealType[]|error {
    //     stream<MealType, sql:Error?> resultStream = 
    //         dbClient->query(`SELECT id, meal_name as mealName, meal_image_url as mealImageUrl FROM MealTypes`);
        
    //     MealType[] mealtypes = [];
    //     check resultStream.forEach(function(MealType meal) {
    //         mealtypes.push(meal);
    //     });

    //     return mealtypes;
    // }

    // resource function post mealtype/add(@http:Payload MealType mealType) returns json|error {
    //     io:println("Received meal type data: " + mealType.toJsonString());

    //     sql:ExecutionResult result = check dbClient->execute(`
    //         INSERT INTO MealTypes (meal_name, meal_image_url)
    //         VALUES (${mealType.mealName}, ${mealType.mealImageUrl})
    //     `);

    //     int|string? lastInsertId = result.lastInsertId;
    //     if lastInsertId is int {
    //         mealType.id = lastInsertId;
    //     }

    //     return {
    //         message: "Meal type added successfully",
    //         mealType: mealType
    //     };
    // }

    // resource function put mealtype/[int id](@http:Payload MealType mealType) returns json|error {
    //     sql:ExecutionResult result = check dbClient->execute(`
    //         UPDATE MealTypes 
    //         SET meal_name = ${mealType.mealName}, meal_image_url = ${mealType.mealImageUrl}
    //         WHERE id = ${id}
    //     `);

    //     if result.affectedRowCount == 0 {
    //         return {
    //             message: "Meal type not found"
    //         };
    //     }

    //     return {
    //         message: "Meal type updated successfully",
    //         mealType: mealType
    //     };
    // }

    // resource function delete mealtype/[int id]() returns json|error {
    //     sql:ExecutionResult result = check dbClient->execute(`
    //         DELETE FROM MealTypes WHERE id = ${id}
    //     `);

    //     if result.affectedRowCount == 0 {
    //         return {
    //             message: "Meal type not found"
    //         };
    //     }

    //     return {
    //         message: "Meal type deleted successfully"
    //     };
    // }

    // resource function options .() returns http:Ok {
    //     return http:OK;
    // }
// }

// public function starMealTimetService() returns error? {
//     io:println("Meal Time service started on port 9090");
// }
