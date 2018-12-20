/*
*Appirio Inc. 2016
*Name  : AuctionDetailTrigger
*Author: Amit SanWariya (Appirio)
*Date  : 25 Oct, 2016
*Description: To check if an Auction exists on Account related to Auction Detail
*/
trigger AuctionDetailTrigger on Auction_Detail__c (after insert, after update) {
    if (Trigger.isInsert && Trigger.isAfter){
        AuctionDetailTriggerHandler.AfterInsert(Trigger.new);    
    } 
    else if (Trigger.isUpdate && Trigger.isAfter){
        AuctionDetailTriggerHandler.AfterUpdate(Trigger.new, Trigger.oldMap);    
    } 
}