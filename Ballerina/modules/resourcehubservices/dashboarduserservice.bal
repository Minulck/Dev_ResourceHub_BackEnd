import ballerina/io;
import ballerina/http;
import ballerina/time;

// Dashboard User Service to handle user dashboard data
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type"]
    }
}
service /dashboard/user on ln {

    // Get user statistics for dashboard
    resource function get stats() returns json|error {
        json[] mealsMonthlyData = [12, 9, 15, 18, 14, 13, 16, 20, 25, 22, 18, 19];
        json[] assetsMonthlyData = [5, 5, 6, 8, 9, 7, 6, 5, 4, 5, 6, 7];
        json[] maintenanceMonthlyData = [3, 2, 4, 1, 3, 5, 2, 3, 4, 2, 1, 3];

        return {
            "mealsToday": 2,
            "assets": 6,
            "maintenanceRequests": 3,
            "mealsMonthlyData": mealsMonthlyData,
            "assetsMonthlyData": assetsMonthlyData,
            "maintenanceMonthlyData": maintenanceMonthlyData
        };
    }

    // Get user recent activities
    resource function get activities() returns json[]|error {
        time:Utc now = time:utcNow();

        return [
            {
                "id": "1",
                "type": "meal",
                "title": "Breakfast Served",
                "description": "Your breakfast has been served",
                "timestamp": time:utcToString(time:utcAddSeconds(now, -3600))
            },
            {
                "id": "2",
                "type": "asset",
                "title": "New Asset Assigned",
                "description": "Laptop has been assigned to you",
                "timestamp": time:utcToString(time:utcAddSeconds(now, -7200))
            },
            {
                "id": "3",
                "type": "maintenance",
                "title": "Maintenance Request Approved",
                "description": "Your maintenance request for room cleaning has been approved",
                "timestamp": time:utcToString(time:utcAddSeconds(now, -86400))
            },
            {
                "id": "4",
                "type": "meal",
                "title": "Lunch Scheduled",
                "description": "Your lunch is scheduled for 12:30 PM",
                "timestamp": time:utcToString(time:utcAddSeconds(now, -172800))
            },
            {
                "id": "5",
                "type": "asset",
                "title": "Asset Return Reminder",
                "description": "Please return your temporary badge by Friday",
                "timestamp": time:utcToString(time:utcAddSeconds(now, -259200))
            }
        ];
    }

    // Get quick actions available for the user
    resource function get quickActions() returns json|error {
        return {
            "actions": [
                {
                    "id": "1",
                    "title": "Request Meal",
                    "icon": "utensils",
                    "path": "/meal-request"
                },
                {
                    "id": "2",
                    "title": "Request Asset",
                    "icon": "box",
                    "path": "/asset-request"
                },
                {
                    "id": "3",
                    "title": "Maintenance Request",
                    "icon": "wrench",
                    "path": "/maintenance-request"
                },
                {
                    "id": "4",
                    "title": "View Schedule",
                    "icon": "calendar",
                    "path": "/schedule"
                }
            ]
        };
    }

    resource function options .() returns http:Ok {
        return http:OK;
    }
}

public function startDashboardUserService() returns error? {
    // Function to integrate with the service start pattern
    io:println("Dashboard User service started on port 9090");
}