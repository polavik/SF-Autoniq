/*
*Appirio Inc. 2016
*Name  : PurchaseTrigger
*Author: Sumit Tanwar (Appirio)
*Date  : 26th OCT 2016
*Description: Original (Task # T-547678) - Please see the task description for more details.
*Modification: Amit Sanwariya - 11/11/2016 - Update New Seller at Assigned Auction fields on Accounts
*/
trigger PurchaseTrigger on Purchase__c (After Insert, After Update) {
    if (Trigger.isAfter 
       		&& (Trigger.isInsert || Trigger.isUpdate)){
        PurchaseTriggerManager.updateOpportunity(Trigger.new, Trigger.oldMap, Trigger.isInsert);
        PurchaseTriggerManager.updateAccount(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
    }
}