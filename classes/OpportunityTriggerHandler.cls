/*
*Appirio Inc. 2016
*Name  : OpportunityTriggerHandler
*Author: Amit SanWariya (Appirio)
*Date  : 12 Oct, 2016
*Description: Filters Opportunites to restrict open Opportunity count to 100 for an owner
20th December, 2016         Arvind Thakur           Modified            I-249303
*/
public class OpportunityTriggerHandler {
  
    private static final Id ADESADSTOPPORTUNITY = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('ADESA DST CLOSE').getRecordTypeId();
    
    //Method to filter newly created Opportunities and their owners
    public static void BeforeInsert(List<Opportunity> newOppList) {
        populateInlaneSellerAndBuyerOpportunity(newOppList);
        List<Opportunity> oppToProcess = new List<Opportunity>();
        Map<Id, Integer> ownerIdToCountMap = new Map<Id, Integer>();
        for (Opportunity opp: newOppList) {
            if(opp.RecordTypeId != null && opp.RecordTypeId == ADESADSTOPPORTUNITY && !opp.isClosed){
              oppToProcess.add(opp);
              ownerIdToCountMap.put(opp.OwnerId, 0);
            }
        }
        if(oppToProcess.size() > 0){
          OpportunityTriggerManager.setAccountInlaneStatusFields(oppToProcess);
          OpportunityTriggerManager.setOpportunityStartFields(oppToProcess);
        }
        if (ownerIdToCountMap.size() > 0) {
            OpportunityTriggerManager.LimitOpportunityCreation(newOppList, ownerIdToCountMap);
        }
    }
    
    //Method to filter updated Opportunities and their owners, where owner has been changed
    public static void BeforeUpdate(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap) {
        Map<Id, Integer> ownerIdToCountMap = new Map<Id, Integer>();
        List<Opportunity> oppToProcess = new List<Opportunity>();
        
        //Get only the opportunity where owner has been changed
        for (Opportunity opp: newOppList) {
            if(opp.RecordTypeId != null && opp.RecordTypeId == ADESADSTOPPORTUNITY){
              oppToProcess.add(opp);
	            if (opp.OwnerID != oldOppMap.get(opp.Id).OwnerId && !opp.isClosed) {
	                ownerIdToCountMap.put(opp.OwnerId, 0);
	            }
            }
        }
        if(oppToProcess.size() > 0){
          OpportunityTriggerManager.recalculateFieldsOnBypass(newOppList);
        }
        if (ownerIdToCountMap.size() > 0) {
            OpportunityTriggerManager.LimitOpportunityCreation(newOppList, ownerIdToCountMap);
        }
    }
    
    //Added for issue I-249303
    public static void populateInlaneSellerAndBuyerOpportunity (List<Opportunity> newList) {
        Map<Id, List<Opportunity>> accountIdOpportunityListMap = new Map<Id, List<Opportunity>>();
        Map<Id, List<Auction_Detail__c>> accountIdAuctionDetailMap = new Map<Id, List<Auction_Detail__c>>();
        for(Opportunity newOpp : newList) {
            if(newOpp.AccountId != null && newOpp.Assigned_To_Auction__c != null) {
                if(!accountIdOpportunityListMap.containsKey(newOpp.AccountId)) {
                    accountIdOpportunityListMap.put(newOpp.AccountId, new List<Opportunity>());
                }
                
                List<Opportunity> oldList = accountIdOpportunityListMap.get(newOpp.AccountId);
                oldList.add(newOpp);
                accountIdOpportunityListMap.put(newOpp.AccountId, oldList);
            }
        }
        
        for(Auction_Detail__c accountauctionDetail : [SELECT Id, Account__c, Auction__c, Buyer_Category__c, Auction__r.Name, Inlane_Seller_Status__c
                                                        FROM Auction_Detail__c 
                                                        WHERE Account__c IN:accountIdOpportunityListMap.keySet()
                                                        AND Auction__c != null]) {
            if(!accountIdAuctionDetailMap.containsKey(accountauctionDetail.Account__c)) {
                accountIdAuctionDetailMap.put(accountauctionDetail.Account__c, new List<Auction_Detail__c>());
            }
            
            List<Auction_Detail__c> oldList = accountIdAuctionDetailMap.get(accountauctionDetail.Account__c);
            oldList.add(accountauctionDetail);
            accountIdAuctionDetailMap.put(accountauctionDetail.Account__c, oldList);
        }
        
        for(Id accountId : accountIdOpportunityListMap.keySet()) {
            for(Opportunity thisOpp : accountIdOpportunityListMap.get(accountId)) {
                if(accountIdAuctionDetailMap.containsKey(accountId)) {
                    for(Auction_Detail__c oppAccountAuctionDetail : accountIdAuctionDetailMap.get(accountId)) {
                        if(oppAccountAuctionDetail.Auction__r.Name == thisOpp.Assigned_To_Auction__c) {
                            thisOpp.Account_Inlane_Seller_Status_at_Opportun__c = oppAccountAuctionDetail.Inlane_Seller_Status__c;
                            thisOpp.Account_Buyer_Category_Status_Op_Start__c = oppAccountAuctionDetail.Buyer_Category__c;
                        }
                    }
                }
            }
        }
    }
}