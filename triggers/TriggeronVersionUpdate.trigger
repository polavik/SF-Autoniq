trigger TriggeronVersionUpdate on Intranet_Content_Version__c (before update) {
     // AA: W-000042 Hawkins, Justin
     // We don't want new versions created during batch jobs.
     if(trigger.isBefore && trigger.isUpdate && !System.isBatch()){
        EdgeforceVersionUpdateTrigger.createNewVersion(trigger.oldmap,trigger.newMap);
     }
}