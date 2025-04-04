import backend.resourcehubservices as resourcehubservices;
public function main() returns error? {
    check resourcehubservices:ConnectDatabase();
    check resourcehubservices:startMealTypeService();
    check resourcehubservices:startMealTimeService();
    check resourcehubservices:startCalanderService();
    check resourcehubservices:startAssetService();
    check resourcehubservices:UserManagementService();
    check resourcehubservices:maintenancesManagementService();
    
    //__________uncomment the below line to start the email service (only if you want to send emails)
    // 🛑🛑 still fixig the email service, so it is commented out for now 🛑🛑
    // resourcehubservices:emailservice();
}