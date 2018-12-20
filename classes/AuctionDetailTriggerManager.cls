/*
*Appirio Inc. 2016
*Name  : AuctionDetailTriggerManager
*Author: Amit SanWariya (Appirio)
*Date  : 25 Oct, 2016
*Description: To update on Auction_Detail_at_Assigned_Auction__c on Account related to Auction Detail
*/
public class AuctionDetailTriggerManager {
    //check the Auction_Detail_at_Assigned_Auction__c field if the if the Auction__r.Assigned Auction field on the Auction Detail matches the Assigned Auction field of the account
    public static void checkAuctionOnAccount(Map<String, Auction_Detail__c> accIdToAucDetailMap) {
        List<Account> accountsToUpdate = new List<Account>();
        for (Account acc :[SELECT Id, Name, DOSS_Assigned_Auction__c, Auction_Detail_at_Assigned_Auction__c
                           FROM Account 
                           WHERE Id IN :accIdToAucDetailMap.keySet()]) {
        	if (acc.DOSS_Assigned_Auction__c != null
               		&& accIdToAucDetailMap.get(acc.Id).Auction__c != null
               		&& acc.DOSS_Assigned_Auction__c.equalsIgnoreCase(accIdToAucDetailMap.get(acc.Id).Auction__r.Name)){
                acc.Auction_Detail_at_Assigned_Auction__c = true;
                accountsToUpdate.add(acc);
            } else {
                acc.Auction_Detail_at_Assigned_Auction__c = false;
                accountsToUpdate.add(acc);
            }
        }
        update accountsToUpdate;
    }
}