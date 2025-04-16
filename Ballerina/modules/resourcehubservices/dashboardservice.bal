import ballerina/http;
import ballerina/io;

public type Stat record {|
    string title;
    int value;
    int[] monthlyData;
|};

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET"],
        allowHeaders: ["Content-Type"]
    }
}
service /dashboard on ln {

    resource function get stats() returns Stat[]|error {
        Stat[] stats = [];

        // Total Employees
        stats.push({
            title: "Total Employees",
            value: 452,
            monthlyData: [420, 435, 440, 448, 452, 450, 445, 440, 435, 430, 425, 420]
        });

        // Today Total Meals
        stats.push({
            title: "Today Total Meals",
            value: 360,
            monthlyData: [380, 410, 425, 440, 460, 450, 440, 430, 420, 410, 400, 390]
        });

        // Due Assets
        stats.push({
            title: "Due Assets",
            value: 30,
            monthlyData: [25, 28, 32, 35, 30, 28, 27, 30, 32, 35, 30, 28]
        });

        // New Maintenance
        stats.push({
            title: "New Maintenance",
            value: 10,
            monthlyData: [8, 12, 15, 11, 10, 9, 10, 11, 12, 13, 14, 10]
        });

        return stats;
    }

    resource function get resources() returns json|error {
        json resources = [
            {title: "Materials And IT", total: 50, highPriority: 12, progress: 75},
            {title: "Stationary", total: 30, highPriority: 8, progress: 60},
            {title: "Wellness", total: 40, highPriority: 15, progress: 85},
            {title: "Facilities", total: 25, highPriority: 5, progress: 45},
            {title: "Maintenance Tools", total: 60, highPriority: 20, progress: 70},
            {title: "Extra Items", total: 15, highPriority: 3, progress: 30}
        ];

        return resources;
    }
}

public function startDashboardService() returns error? {
    io:println("Dashboard service started on port 9090");
}
