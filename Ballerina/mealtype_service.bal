import ballerina/http;
import ballerina/sql;
import ballerina/io;

type MealType record {|
    int id?;
    string mealName;
    string mealImageUrl;
|};

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type"]
    }
}
service /mealtype on new http:Listener(9092) {

    resource function get .() returns MealType[]|error {
        stream<MealType, sql:Error?> resultStream = 
            dbClient->query(`SELECT id, meal_name as mealName, meal_image_url as mealImageUrl FROM MealTypes`);
        
        MealType[] mealtypes = [];
        check resultStream.forEach(function(MealType meal) {
            mealtypes.push(meal);
        });

        return mealtypes;
    }

    resource function post add(@http:Payload MealType mealType) returns json|error {
        io:println("Received meal type data: " + mealType.toJsonString());

        sql:ExecutionResult result = check dbClient->execute(`
            INSERT INTO MealTypes (meal_name, meal_image_url)
            VALUES (${mealType.mealName}, ${mealType.mealImageUrl})
        `);

        int|string? lastInsertId = result.lastInsertId;
        if lastInsertId is int {
            mealType.id = lastInsertId;
        }

        return {
            message: "Meal type added successfully",
            mealType: mealType
        };
    }

    resource function put [int id](@http:Payload MealType mealType) returns json|error {
        sql:ExecutionResult result = check dbClient->execute(`
            UPDATE MealTypes 
            SET meal_name = ${mealType.mealName}, meal_image_url = ${mealType.mealImageUrl}
            WHERE id = ${id}
        `);

        if result.affectedRowCount == 0 {
            return {
                message: "Meal type not found"
            };
        }

        return {
            message: "Meal type updated successfully",
            mealType: mealType
        };
    }

    resource function delete [int id]() returns json|error {
        sql:ExecutionResult result = check dbClient->execute(`
            DELETE FROM MealTypes WHERE id = ${id}
        `);

        if result.affectedRowCount == 0 {
            return {
                message: "Meal type not found"
            };
        }

        return {
            message: "Meal type deleted successfully"
        };
    }

    resource function options .() returns http:Ok {
        return http:OK;
    }
}
