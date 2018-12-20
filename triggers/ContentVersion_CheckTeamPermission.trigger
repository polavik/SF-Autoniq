//
// (c) 2014 Appirio, Inc.
//
// Trigger to check Content Bucket and Team Page Sharing for Social Intranet
//
// February 18th, 2016   Matt Salpietro     Original
//
trigger ContentVersion_CheckTeamPermission on ContentVersion (before insert, before update) {
     if(trigger.isBefore) {
        if(trigger.isInsert || trigger.isUpdate) {
            EF_ContentDocumentSharingTriggerHandler.checkContentShare(trigger.new);
        }
     }
}