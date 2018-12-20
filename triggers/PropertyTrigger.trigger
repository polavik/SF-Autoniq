/*
* (c) 2016 Appirio, Inc.
* 
* Apex Trigger Name   : PropertyTrigger
*
* Description         : Trigger to sync KillSwitch custom setting with Property object's KillSwitch record values.
*
* 12 Nov 2016         Ankita Sharma(Appirio)   Original ( T-548983) - Please see the Task description for more details.
*
*/

trigger PropertyTrigger on Property__c (after insert, after update, after delete) {
  
    if(trigger.isAfter){
        if(trigger.isInsert){
            PropertyTriggerHandler.onAfterInsert(trigger.new);
        }
        if(trigger.isUpdate){
            PropertyTriggerHandler.onAfterUpdate(trigger.new);
        }
        if(trigger.isDelete){
            PropertyTriggerHandler.onAfterDelete(trigger.old);
        }
    }
}