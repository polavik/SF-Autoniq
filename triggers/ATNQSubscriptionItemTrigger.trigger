trigger ATNQSubscriptionItemTrigger on Subscription_Item__c (After Insert,After Update) {

  if((trigger.isInsert && trigger.isAfter) ){//|| (trigger.isUpdate && trigger.isAfter)){
       // ATNQSubItemFeeAssignmentTriggerHandler.UpdateOrderWithFee(trigger.newMap);
       // ATNQSubscriptionItemTriggerHandler.CreateMidmonthOrderItem (trigger.new);
  }
}