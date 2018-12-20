//
// (c) 2014 Appirio, Inc.
//
// trigger IntranetContent_AutoTagCreation
//
// November 7th, 2014   Sidhant Agarwal     Original T-332237
// 
trigger IntranetContent_AutoTagCreation on Intranet_Content__c (after insert, after update) {
    if(trigger.isAfter) {
        if (trigger.isInsert) {
            EF_AutoTagCreation.createTags(trigger.newmap);
        }if(trigger.isUpdate) {
            EF_AutoTagCreation.updateTags(trigger.oldMap, trigger.newMap);
        }
    }
}