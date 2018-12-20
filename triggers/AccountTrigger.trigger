//
// (c) 2016 Appirio, Inc.
//
// Trigger to Handle Before insert and After update.
//  1.update the Auction_Detail_at_Assigned_Auction__c on account based
//    on Field_Sales_Rep__c changes.
//  2.update New_Seller_at_Assigned_Auction__c and  New_Seller_at_Assigned_Auction_Date__c on account based
//    on BillingPostalCode and Purchases related list.
// 26th OCT 2016  Sumit Tanwar   Original (Task # T-550807) - Please see the task description for more details.
// 14th Nov 2016  Amit Sanwariya Modified update New_Seller_at_Assigned_Auction__c and  New_Seller_at_Assigned_Auction_Date__c on account based
//  
// 
trigger AccountTrigger on Account (before insert, before update) {
    if ((Trigger.isInsert || Trigger.isUpdate)
        	&& Trigger.isBefore) {
        AccountTriggerUpdateFieldsByTerritory.updateFieldsByTerritoryMethod(Trigger.new);
        if (Trigger.isUpdate) {
            AccountTriggerHandler.updateAuctionDetailatAssigned(Trigger.new, Trigger.oldMap);
            AccountTriggerHandler.updatePurchase(Trigger.newMap, Trigger.oldMap);            
        }       
    }
}