/*
*Appirio Inc. 2016
*Name  : PurchaseTriggerManager
*Author: Sumit Tanwar (Appirio)
*Date  : 26th OCT 2016
*Description: Original (Task # T-547678) - Please see the task description for more details.
*Modification: Amit Sanwariya - 11/11/2016 - Update New Seller at Assigned Auction fields on Accounts
*/
public class PurchaseTriggerManager {
    public static void updateOpportunity(List<Purchase__c> listNew, Map<Id, Purchase__c> oldMap, Boolean isInsert){
        Set<Id> accIds = new Set<Id>();
        List<Opportunity> listToUpdate = new List<Opportunity>();        
        Map<Id, List<Opportunity>> mapOwnerOpps = new Map<Id, List<Opportunity>>();
        
        for(Purchase__c p: listNew){
            if(isInsert){
                if(p.ATC_Seller__c != null && p.Segment_Name__c!=null && p.Segment_Name__c.equals('ADESA INLANE')){
                    accIds.add(p.ATC_Seller__c);
                }
            }
            else {
                if(p.ATC_Seller__c !=null && (p.ATC_Seller__c != oldMap.get(p.Id).ATC_Seller__c || (p.Segment_Name__c!=null && p.Segment_Name__c.equals('ADESA INLANE') && p.Segment_Name__c != oldMap.get(p.Id).Segment_Name__c))){
                    accIds.add(p.ATC_Seller__c);
                }
            }
        }
        
        if (accIds.size() > 0) {
            for(Opportunity o: [SELECT Id, Vehicle_Sold_During_Opportunity__c, Assigned_Auction__c, StageName, OwnerId 
                                FROM Opportunity 
                                WHERE AccountId IN: accIds AND
                               RecordType.Name = 'ADESA DST CLOSE']){
                if(!mapOwnerOpps.containsKey(o.OwnerId)){
                    mapOwnerOpps.put(o.OwnerId, new List<Opportunity>());
                }
                mapOwnerOpps.get(o.OwnerId).add(o);
               
            }
        }
        
        if (mapOwnerOpps.size() > 0) {
            for(User u: [SELECT Id, ADESAAUCTION__c 
                         FROM User
                         WHERE Id IN: mapOwnerOpps.keySet()]){
                if(mapOwnerOpps.containsKey(u.Id)){
                    for(Opportunity o: mapOwnerOpps.get(u.Id)){
                   
                    if(o.StageName !=null && o.StageName.indexOf('Closed') < 0 && o.Assigned_Auction__c == u.ADESAAUCTION__c){
                            o.Vehicle_Sold_During_Opportunity__c = 'Yes';
                            listToUpdate.add(o);
                        }
                    }
                }
            }
        }
        
        if(!listToUpdate.isEmpty()){
            database.update(listToUpdate,false);
        }
    }
    
    public static void updateAccount(List<Purchase__c> newPurchaseList, Map<Id, Purchase__c> oldPurchaseMap, Boolean isInsert, Boolean isUpdate) {
        Map<Id, Purchase__c> accIdToPurchaseMap = new Map<Id, Purchase__c>();
        Map<Id, Purchase__c> oldAccIdToPurchaseMap = new Map<Id, Purchase__c>();
        List<Account> accountToUpdate = new List<Account>();
        List<Purchase__c> filteredPurchaseList = new List<Purchase__c>();
        
        for(Purchase__c purch : newPurchaseList) {
            if((isInsert || (isUpdate && purch.ATC_Seller__c != oldPurchaseMap.get(purch.Id).ATC_Seller__c))
                    && purch.ATC_Seller__c != null
                    && purch.ADESA_Auction__c != null) {
                filteredPurchaseList.add(purch);    
            }
        }
        
        if (filteredPurchaseList.size() > 0) {
            for (Purchase__c purch :[SELECT Id, Name, ATC_Seller__c, ATC_Seller__r.DOSS_Assigned_Auction__c, ADESA_Auction__c,
                                            ATC_Seller__r.BillingPostalCode, ATC_Seller__r.New_Seller_at_Assigned_Auction_Date__c
                                     FROM Purchase__c
                                     WHERE Id IN :filteredPurchaseList]) {
                if (isInsert
                        && purch.ATC_Seller__r.DOSS_Assigned_Auction__c != null
                        && (purch.ATC_Seller__r.New_Seller_at_Assigned_Auction_Date__c == null 
                            || purch.ATC_Seller__r.New_Seller_at_Assigned_Auction_Date__c > (System.today() - 180))) {
                    accIdToPurchaseMap.put(purch.ATC_Seller__c, purch);
                } else if (isUpdate
                           && purch.ATC_Seller__r.DOSS_Assigned_Auction__c != null
                           && purch.ATC_Seller__c != oldPurchaseMap.get(purch.Id).ATC_Seller__c
                           && (purch.ATC_Seller__r.New_Seller_at_Assigned_Auction_Date__c == null
                               || purch.ATC_Seller__r.New_Seller_at_Assigned_Auction_Date__c > (System.today() - 180))) {
                    accIdToPurchaseMap.put(purch.ATC_Seller__c, purch);
                    oldAccIdToPurchaseMap.put(oldPurchaseMap.get(purch.Id).ATC_Seller__c, purch);
                } else if (isUpdate
                           && oldPurchaseMap.get(purch.Id).ATC_Seller__c != null
                           && (purch.ATC_Seller__c == null
                               || purch.ATC_Seller__r.DOSS_Assigned_Auction__c == null)
                           && purch.ATC_Seller__c != oldPurchaseMap.get(purch.Id).ATC_Seller__c) {
                    oldAccIdToPurchaseMap.put(oldPurchaseMap.get(purch.Id).ATC_Seller__c, purch);
                }
            }
        }
        if (oldAccIdToPurchaseMap.size() > 0 || accIdToPurchaseMap.size() > 0) {
            for (Account acc :[SELECT Id, New_Seller_at_Assigned_Auction__c, New_Seller_at_Assigned_Auction_Date__c, DOSS_Assigned_Auction__c
                               FROM Account
                               WHERE ID IN :oldAccIdToPurchaseMap.keySet()
                              		 OR ID IN :accIdToPurchaseMap.keySet()]) {                
                if (oldAccIdToPurchaseMap.size() > 0
                   		&& oldAccIdToPurchaseMap.containsKey(acc.Id)) {
               		acc.New_Seller_at_Assigned_Auction__c = false;
                    acc.New_Seller_at_Assigned_Auction_Date__c = null;
                    accountToUpdate.add(acc);                
                }
                if (accIdToPurchaseMap.size() > 0
                    	&& accIdToPurchaseMap.containsKey(acc.Id)
                    	&& acc.DOSS_Assigned_Auction__c == accIdToPurchaseMap.get(acc.Id).ADESA_Auction__c) {
                	acc.New_Seller_at_Assigned_Auction__c = true;
                    acc.New_Seller_at_Assigned_Auction_Date__c = System.today();
                    accountToUpdate.add(acc);
                }
            }
        }
        if (accountToUpdate.size() > 0) {
            update accountToUpdate; 
        }
    }
}