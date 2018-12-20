/* A helper class that lets the DataGateway know if the Trigger has already fired.
   This way, if the trigger fires twice (due to a workflow update), the Gateway_Violation__c won't be created again.
   Keep in mind that this only works for Triggers that are fired twice (not more times) */

public with sharing class DataGatewayTriggerHelper {

    private static boolean triggerAlreadyFired = false;
    public static boolean hasAlreadyfired() {
        return triggerAlreadyFired;
    }

    public static void setAlreadyfired() {
        triggerAlreadyFired = true;
    }

    public static void resetTrigger(){
        triggerAlreadyFired = false;
    }
}