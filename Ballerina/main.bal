import backend.resourcehubservices as resourcehubservices;
public function main() returns error? {
    check resourcehubservices:ConnectDatabase();
    check resourcehubservices:startMealTypeService();
    check resourcehubservices:startMealTimeService();
    check resourcehubservices:startCalanderService();
    check resourcehubservices:startAssetService();
    check resourcehubservices:UserManagementService();
    check resourcehubservices:maintenancesManagementService();

}