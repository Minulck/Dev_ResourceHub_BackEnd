import ballerina/io;
import ballerina/http;

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
        return [
            {
                title: "Total Users",
                value: 2458,
                icon: "Users",
                monthlyData: [150, 160, 170, 165, 180, 195, 210, 220, 230, 240, 255, 270]
            },
            {
                title: "Meals Served",
                value: 12345,
                icon: "Utensils",
                monthlyData: [980, 1020, 1050, 1080, 1100, 1090, 1120, 1140, 1160, 1180, 1200, 1220]
            },
            {
                title: "Resources",
                value: 867,
                icon: "Box",
                monthlyData: [70, 72, 75, 68, 80, 82, 85, 90, 88, 92, 95, 100]
            },
            {
                title: "Services",
                value: 328,
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
