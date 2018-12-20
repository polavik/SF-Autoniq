trigger SubscriptionTrigger on Subscription__c (after insert,after update) {
SubscriptionTriggerHandler handler=new SubscriptionTriggerHandler();
if(Trigger.isInsert && Trigger.isAfter) {
    handler.OnAfterInsert(Trigger.new);
    
  }/*else if(Trigger.isUpdate && Trigger.isAfter) { 
   handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
   
  }*/

}