import backend.resourcehubservices as resourcehubservices;
public function main() returns error? {
    check resourcehubservices:startMealTypeService();
    check resourcehubservices:startMealTimeService();
    check resourcehubservices:startCalanderService();
}