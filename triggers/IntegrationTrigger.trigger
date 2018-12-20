trigger IntegrationTrigger on Integration__c (after insert, after update) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            IntegrationTriggerHelper.scheduleJobs(Trigger.new, null);
        }
        else if (Trigger.isUpdate) {
            IntegrationTriggerHelper.scheduleJobs(Trigger.new, Trigger.oldMap);
        }
    }
}