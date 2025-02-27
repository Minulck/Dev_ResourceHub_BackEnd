import ballerina/http;
import ballerina/sql;

public type Asset record {|
    int id;
    string asset_name;
    string category;
    int quantity;
    string condition_type;
    string location;
|};

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type"]
    }
}

service /asset on ln{
    resource function get details() returns Asset[]|error{
        stream<Asset, sql:Error?> resultStream = dbClient->query(`SELECT * FROM Assets`);

        Asset[] assets = [];
        check resultStream.forEach(function(Asset asset){
            assets.push(asset);
        });

        return assets;
    }
}