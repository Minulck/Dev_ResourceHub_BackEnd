import ballerina/http;
import ballerina/sql;
import ballerina/io;

public type MealType record {|
    int mealtype_id?;
    string mealtype_name;
    string mealtype_image_url;
|};

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type"]
    }
}

service /mealtype on ln{
     // MealType endpoints
    resource function get details() returns MealType[]|error {
        stream<MealType, sql:Error?> resultStream = 
            dbClient->query(`SELECT mealtype_id, mealtype_name , mealtype_image_url  FROM mealtypes`);
        
        MealType[] mealtypes = [];
        check resultStream.forEach(function(MealType meal) {
            mealtypes.push(meal);
        });

        return mealtypes;
    }

    resource function post add(@http:Payload MealType mealType) returns json|error {
        io:println("Received meal type data: " + mealType.toJsonString());

        sql:ExecutionResult result = check dbClient->execute(`
            INSERT INTO mealtypes (mealtype_name, mealtype_image_url)
            VALUES (${mealType.mealtype_name}, ${mealType.mealtype_image_url})
        `);

        int|string? lastInsertId = result.lastInsertId;
        if lastInsertId is int {
            mealType.mealtype_id = lastInsertId;
        }

        return {
            message: "Meal type added successfully",
            mealType: mealType
        };
    }

    resource function put details/[int id](@http:Payload MealType mealType) returns json|error {
        sql:ExecutionResult result = check dbClient->execute(`
            UPDATE mealtypes 
            SET mealtype_name = ${mealType.mealtype_name}, mealtype_image_url = ${mealType.mealtype_image_url}
            WHERE mealtype_id = ${id}
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

    resource function delete details/[int id]() returns json|error {
        sql:ExecutionResult result = check dbClient->execute(`
            DELETE FROM mealtypes WHERE mealtype_id = ${id}
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

public function startMealTypeService() returns error? {
    io:println("Meal Type service started on port 9090");
}
