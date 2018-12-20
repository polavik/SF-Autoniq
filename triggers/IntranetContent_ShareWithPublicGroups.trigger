//
// (c) 2014 Appirio, Inc.
//
// Trigger to create a sharing setting for the Intranet Content Record whenever it is created
//
// November 3rd, 2014   Sidhant Agarwal     Original T-330482
// November 12th 2014   Sidhant Agarwal     Modified T-333321
//
trigger IntranetContent_ShareWithPublicGroups on Intranet_Content__c (before insert, before update, after insert, after update) {
     if(trigger.isAfter) {
        if(trigger.isInsert || trigger.isUpdate) {
            EF_ShareWithPublicGroupTriggerHandler.verifyBucketMatch(trigger.newmap);
            EF_ShareWithPublicGroupTriggerHandler.createICSharing(trigger.newmap,trigger.oldmap);
        }
     }
}