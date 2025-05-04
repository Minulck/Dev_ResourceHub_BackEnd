import backend.resourcehubservices as resourcehubservices;
public function main() returns error? {
    check resourcehubservices:connectDatabase();
    check resourcehubservices:startMealTypeService();
    check resourcehubservices:startMealTimeService();
    check resourcehubservices:startCalendarService();
    check resourcehubservices:startAssetService();
    check resourcehubservices:startUserManagementService();
    check resourcehubservices:startMaintenanceManagementService();
    check resourcehubservices:startDashboardAdminService();
    check resourcehubservices:startDashboardUserService();

    //__________uncomment the below line to start the email service (only if you want to send emails)
    // 🛑🛑 still fixig the email service, so it is commented out for now 🛑🛑
    // resourcehubservices:emailservice();
}