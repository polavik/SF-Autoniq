/*
*Appirio Inc. 2016
*Name  : AuctionDetailTriggerHandler
*Author: Amit SanWariya (Appirio)
*Date  : 25 Oct, 2016
*Description: To filter the account ids from auction details
*/
public class AuctionDetailTriggerHandler {
    //Method to fetch the Account Ids on Auction Detail records
    public static void AfterInsert(List<Auction_Detail__c> newAuctionDetailList) {
        Map<String, Auction_Detail__c> accIdToAucDetailMap = new Map<String, Auction_Detail__c>();
        for (Auction_Detail__c aucDetail :[SELECT Id, Name, Account__c, Auction__c, Auction__r.Name
                                          FROM Auction_Detail__c
                                          WHERE Id IN :newAuctionDetailList]){
            accIdToAucDetailMap.put(aucDetail.Account__c, aucDetail);
        }
        if (accIdToAucDetailMap.size() > 0){
            AuctionDetailTriggerManager.checkAuctionOnAccount(accIdToAucDetailMap);
        }
    }
    
    //Method to fetch the Account Ids on Auction Detail records when master account has been changed
    public static void AfterUpdate(List<Auction_Detail__c> newAuctionDetailList, Map<Id, Auction_Detail__c> oldAuctionDetailMap) {
        Map<String, Auction_Detail__c> accIdToAucDetailMap = new Map<String, Auction_Detail__c>();
        for (Auction_Detail__c aucDetail :newAuctionDetailList){
            if (aucDetail.Account__c != oldAuctionDetailMap.get(aucDetail.Id).Account__c 
                	|| aucDetail.Auction__c != oldAuctionDetailMap.get(aucDetail.Id).Auction__c) {
	            accIdToAucDetailMap.put(aucDetail.Account__c, aucDetail);
                accIdToAucDetailMap.put(oldAuctionDetailMap.get(aucDetail.Id).Account__c, aucDetail);
            }
        }
        if (accIdToAucDetailMap.size() > 0){
            AuctionDetailTriggerManager.checkAuctionOnAccount(accIdToAucDetailMap);
        }
    }
}