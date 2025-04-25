import ballerina/http;
import ballerina/io;
import ballerina/sql;

type MonthlyUserData record {|
    int month;
    int count;
|};

type MonthlyMealData record {|
    int month;
    int count;
|};

type MonthlyAssetRequestData record {|
    int month;
    int count;
|};

type MonthlyMaintenanceData record {|
    int month;
    int count;
|};

// DashboardAdminService - RESTful service to provide data for admin dashboard
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type"]
    }
}
service /dashboard/admin on ln {
    // Resource to get summary statistics for the dashboard
    resource function get stats() returns json|error {

        record {|int user_count;|} userresult = check dbClient->queryRow(`SELECT COUNT(id) AS user_count FROM users`);
        int userCount = userresult.user_count;

        record {|int mealevents_count;|} mealresult = check dbClient->queryRow(`SELECT COUNT(id) AS mealevents_count FROM mealevents`);
        int mealeventsCount = mealresult.mealevents_count;

        record {|int assetrequests_count;|} assetrequestsresult = check dbClient->queryRow(`SELECT COUNT(id) AS assetrequests_count FROM assetrequests`);
        int assetrequestsCount = assetrequestsresult.assetrequests_count;

        record {|int maintenance_count;|} maintenanceresult = check dbClient->queryRow(`SELECT COUNT(id) AS maintenance_count FROM maintenance`);
        int maintenanceCount = maintenanceresult.maintenance_count;

        // Query to get user count by month
        stream<MonthlyUserData, sql:Error?> monthlyUserStream = dbClient->query(
            `SELECT EXTRACT(MONTH FROM created_at) AS month, COUNT(id) AS count 
            FROM users 
            GROUP BY EXTRACT(MONTH FROM created_at) 
            ORDER BY month`,
            MonthlyUserData
        );

        // Convert stream to array
        MonthlyUserData[] monthlyUserData = [];
        check from MonthlyUserData row in monthlyUserStream
            do {
                monthlyUserData.push(row);
            };

        // Create an array for all 12 months, initialized with 0
        int[] monthlyUserCounts = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]; // Index 0 = Jan, 1 = Feb, ..., 11 = Dec

        // Populate counts for months with data
        foreach var row in monthlyUserData {
            // SQL EXTRACT(MONTH) returns 1-12, so adjust to 0-based index
            monthlyUserCounts[row.month - 1] = row.count;
        }

            // Query to get meal events count by month
        stream<MonthlyMealData, sql:Error?> monthlyMealStream = dbClient->query(
            `SELECT EXTRACT(MONTH FROM meal_request_date) AS month, COUNT(id) AS count 
            FROM mealevents 
            GROUP BY EXTRACT(MONTH FROM meal_request_date) 
            ORDER BY month`,
            MonthlyMealData
        );

        // Convert meal stream to array
        MonthlyMealData[] monthlyMealData = [];
        check from MonthlyMealData row in monthlyMealStream
            do {
                monthlyMealData.push(row);
            };

        // Create an array for all 12 months for meal events, initialized with 0
        int[] monthlyMealCounts = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        foreach var row in monthlyMealData {
            monthlyMealCounts[row.month - 1] = row.count;
        }

        return [
            {
                title: "Total Users",
                value: userCount,
                icon: "Users",
                monthlyData: monthlyUserCounts
            },
            {
                title: "Meals Served",
                value: mealeventsCount,
                icon: "Utensils",
                monthlyData: monthlyMealCounts
            },
            {
                title: "Resources",
                value: assetrequestsCount,
                icon: "Box",
                monthlyData: [70, 72, 75, 68, 80, 82, 85, 90, 88, 92, 95, 100]
            },
            {
                title: "Services",
                value: maintenanceCount,
                icon: "Wrench",
                monthlyData: [25, 28, 30, 32, 35, 38, 40, 42, 45, 48, 50, 52]
            }
        ];
    }

    // Resource to get data for resource cards
    resource function get resources() returns json|error {

        return [
            {
                title: "Food Supplies",
                total: 1250,
                highPriority: 45,
                progress: 75
            },
            {
                title: "Medical Kits",
                total: 358,
                highPriority: 20,
                progress: 60
            },
            {
                title: "Shelter Equipment",
                total: 523,
                highPriority: 32,
                progress: 85
            }
        ];
    }

    // Resource to get meal distribution data for pie chart
    resource function get mealdistribution() returns json|error {

        return {
            labels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
            datasets: [
                {
                    label: "Breakfast",
                    data: [10, 15, 20, 25, 30, 35, 40],
                    borderColor: "#4C51BF",
                    tension: 0.4
                },
                {
                    label: "Lunch",
                    data: [20, 25, 30, 35, 40, 45, 50],
                    borderColor: "#38B2AC",
                    tension: 0.4
                },
                {
                    label: "Dinner",
                    data: [5, 10, 15, 20, 25, 30, 35],
                    borderColor: "#ED8936",
                    tension: 0.4
                }
            ]
        };
    }

    // Resource to get resource allocation data
    resource function get resourceallocation() returns json|error {
        return [
            {
                category: "Food",
                allocated: 65,
                total: 100
            },
            {
                category: "Medicine",
                allocated: 40,
                total: 50
            },
            {
                category: "Shelter",
                allocated: 25,
                total: 30
            },
            {
                category: "Clothing",
                allocated: 15,
                total: 20
            }
        ];
    }

    resource function options .() returns http:Ok {
        return http:OK;
    }
}

public function startDashboardAdminService() returns error? {
    // Function to integrate with the service start pattern
    io:println("Dashboard Admin service started on port 9090");
}
