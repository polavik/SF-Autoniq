public without sharing class IntegrationTriggerHelper {
    public static void scheduleJobs(Integration__c[] records, Map<Id, Integration__c> oldMap) {
        Set<String> apiNames = new Set<String>();
        for(Integration__c record : records) {
            Integration__c old = (oldMap == null ? null : oldMap.get(record.Id));
            
             if ((record.Status__c == 'Pending' && old == null )||(record.status__c=='Pending' && record.Status__c != old.Status__c)) {
                apiNames.add(record.API_Name__c);
            }
        }

        if (apiNames.size() > 0) {
            IntegrationJob.scheduleJobs(apiNames);
        }
    }
}