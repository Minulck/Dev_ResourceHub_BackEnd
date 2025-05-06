import ballerina/http;
import ballerina/io;
import ballerina/sql;

public type AssetRequest record {|
    int requestedasset_id?;
    int user_id;
    int asset_id;
    string category?;
    string submitted_date ;
    string handover_date;
    int remaining_days?;
    int quantity;
    string profile_picture_url?;
    string username?;
    string status?;
    boolean is_returning?;
    string asset_name?;
|};

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "DELETE", "OPTIONS", "PUT"],
        allowHeaders: ["Content-Type"]
    }
}

service /assetrequest on ln {
    resource function get details() returns AssetRequest[]|error {
        stream<AssetRequest, sql:Error?> resultstream = dbClient->query
        (`SELECT 
        ra.requestedasset_id,
        u.user_id,
        u.profile_picture_url,
        u.username,
        a.asset_id,
        a.asset_name,
        a.category,
        ra.submitted_date ,
        ra.handover_date,
        ra.status,
        ra.is_returning,
        DATEDIFF(ra.handover_date, CURDATE()) AS remaining_days,
        ra.quantity
        FROM requestedassets ra
        JOIN users u ON ra.user_id = u.user_id
        JOIN assets a ON ra.asset_id = a.asset_id;`);

        AssetRequest[] assetrequests = [];

        check resultstream.forEach(function(AssetRequest assetrequest) {
            assetrequests.push(assetrequest);
        });

        return assetrequests;
    }

    resource function get details/[int userid]() returns AssetRequest[]|error {
        stream<AssetRequest, sql:Error?> resultstream = dbClient->query
        (`SELECT 
        ra.requestedasset_id,
        u.user_id,
        u.profile_picture_url,
        u.username,
        a.asset_id,
        a.asset_name,
        a.category,
        ra.submitted_date ,
        ra.handover_date,
        ra.status,
        ra.is_returning,
        DATEDIFF(ra.handover_date, CURDATE()) AS remaining_days,
        ra.quantity
        FROM requestedassets ra
        JOIN users u ON ra.user_id = u.user_id
        JOIN assets a ON ra.asset_id = a.asset_id
        where ra.user_id=${userid};`);

        AssetRequest[] assetrequests = [];

        check resultstream.forEach(function(AssetRequest assetrequest) {
            assetrequests.push(assetrequest);
        });

        return assetrequests;
    }

    resource function post add(@http:Payload AssetRequest assetrequest) returns json|error {
        io:println("Received Asset Request data :" + assetrequest.toJsonString());

        sql:ExecutionResult result = check dbClient->execute(`
            INSERT INTO requestedassets (user_id, asset_id, submitted_date , handover_date, quantity,is_returning)
            VALUES (${assetrequest.user_id}, ${assetrequest.asset_id}, ${assetrequest.submitted_date }, ${assetrequest.handover_date}, ${assetrequest.quantity},${assetrequest.is_returning})
        `);

        if result.affectedRowCount == 0 {
            return error("Failed to add asset request");
        }

        return {
            message: "Asset request added successfully",
            assetrequest: assetrequest
        };
    }

    resource function delete details/[int id]() returns json|error {
        sql:ExecutionResult result = check dbClient->execute(`
            DELETE FROM requestedassets WHERE requestedasset_id = ${id}
        `);

        if result.affectedRowCount == 0 {
            return {
                message: "Asset request not found"
            };
        }
        return {
            message: "Asset request deleted successfully"
        };
    }

    resource function put details/[int id](@http:Payload AssetRequest assetrequest) returns json|error {
        sql:ExecutionResult result = check dbClient->execute(`
            UPDATE requestedassets 
            SET  handover_date = ${assetrequest.handover_date}, quantity = ${assetrequest.quantity} , status = ${assetrequest.status}
            WHERE requestedasset_id = ${id}
        `);

        if result.affectedRowCount == 0 {
            return {
                message: "Asset request not found"
            };
        }

        return {
            message: "Asset request updated successfully",
            assetrequest: assetrequest
        };
    }
    resource function get dueassets() returns AssetRequest[]|error {
        stream<AssetRequest, sql:Error?> resultstream = dbClient->query
        (`SELECT 
        u.profile_picture_url,
        u.username,
        a.asset_id,
        a.asset_name,
        a.category,
        ra.submitted_date ,
        ra.handover_date,
        DATEDIFF(ra.handover_date, CURDATE()) AS remaining_days,
        ra.quantity
        FROM requestedassets  ra
        JOIN users u ON ra.user_id = u.user_id
        JOIN assets a ON ra.asset_id = a.asset_id
        WHERE DATEDIFF(ra.handover_date, CURDATE()) < 0
        AND ra.is_returning = false
        AND ra.status != 'Pending'
        ORDER BY remaining_days ASC;`
        );

        AssetRequest[] assetrequests = [];

        check resultstream.forEach(function(AssetRequest assetrequest) {
            assetrequests.push(assetrequest);
        });

        return assetrequests;
    }

    resource function get dueassets/[int userid]() returns AssetRequest[]|error {
        stream<AssetRequest, sql:Error?> resultstream = dbClient->query
        (`SELECT 
        u.profile_picture_url,
        u.username,
        a.asset_id,
        a.asset_name,
        a.category,
        ra.submitted_date ,
        ra.handover_date,
        DATEDIFF(ra.handover_date, CURDATE()) AS remaining_days,
        ra.quantity
        FROM requestedassets ra
        JOIN users u ON ra.user_id = u.user_id
        JOIN assets a ON ra.asset_id = a.asset_id
        WHERE DATEDIFF(ra.handover_date, CURDATE()) < 0 AND ra.user_id = ${userid}
        AND ra.is_returning = false
        AND ra.status != 'Pending'
        ORDER BY remaining_days ASC;`
        );

        AssetRequest[] assetrequests = [];

        check resultstream.forEach(function(AssetRequest assetrequest) {
            assetrequests.push(assetrequest);
        });

        return assetrequests;
    }
}

public function AssetRequestService() {
    io:println("Asset request service work on port :9090");
}