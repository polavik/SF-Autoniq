//
// (c) 2016 Appirio, Inc.
//
// Handler class for AccountTrigger.
//  1.update the Auction_Detail_at_Assigned_Auction__c on account based
//    on Field_Sales_Rep__c changes.
//
// 26th OCT 2016  Sumit Tanwar   Original (Task # T-550807) - Please see the task description for more details.
// 
//
public class AccountTriggerHandler {
    public static void updateAuctionDetailatAssigned(List<Account> newAcc, Map<Id, Account> oldMap){      
        Map<Id, User> newUserMap = new Map<Id, User>();
        Map<Id, User> oldUserMap = new Map<Id, User>();
        Map<Id, List<Auction_Detail__c>> mapAccountAuctionDetails = new Map<Id, List<Auction_Detail__c>>();
		List<Account> listSalesRepUpdated = new List<Account>();
        
        for(Account a: newAcc){
            if(a.Field_Sales_Rep__c !=null && a.Field_Sales_Rep__c != oldMap.get(a.Id).Field_Sales_Rep__c){
                listSalesRepUpdated.add(a);
                newUserMap.put(a.Field_Sales_Rep__c, null);
                oldUserMap.put(oldMap.get(a.Id).Field_Sales_Rep__c, null);
            }
        }
        
        if(newUserMap.keySet().size() > 0 || oldUserMap.keySet().size() > 0 ){
	        for(User u: [SELECT Id, ADESAAUCTION__c 
	                     FROM User 
	                     WHERE Id IN: newUserMap.keySet() 
	                     	   OR Id IN: oldUserMap.keySet()]){
	            if(newUserMap.containsKey(u.Id)){
	                newUserMap.put(u.Id, u);
	            }
	            if(oldUserMap.containsKey(u.Id)){
	                oldUserMap.put(u.Id, u);
	            }
	        }
        }
        
        if (listSalesRepUpdated.size() > 0) {
	        for(Auction_Detail__c ad : [SELECT Id, Auction__c, Auction__r.Name, Account__c 
	                                    FROM Auction_Detail__c 
	                                    WHERE Account__c IN: listSalesRepUpdated]){
	            if(!mapAccountAuctionDetails.containsKey(ad.Account__c)) {
	                mapAccountAuctionDetails.put(ad.Account__c, new List<Auction_Detail__c>());
	            }
	            mapAccountAuctionDetails.get(ad.Account__c).add(ad);
	        }
        
            for(Account a: listSalesRepUpdated) {
                Boolean isMatchFound = false;
                if((newUserMap.containsKey(a.Field_Sales_Rep__c) && oldMap.get(a.Id).Field_Sales_Rep__c == null) 
                   || (newUserMap.containsKey(a.Field_Sales_Rep__c) && oldUserMap.containsKey(oldMap.get(a.Id).Field_Sales_Rep__c) 
                       && newUserMap.get(a.Field_Sales_Rep__c).ADESAAUCTION__c != oldUserMap.get(oldMap.get(a.Id).Field_Sales_Rep__c).ADESAAUCTION__c)){
                    if(mapAccountAuctionDetails.containsKey(a.Id)){
                        for(Auction_Detail__c ad: mapAccountAuctionDetails.get(a.Id)){
                             if(ad.Auction__c != null && ad.Auction__r.Name.equals(newUserMap.get(a.Field_Sales_Rep__c).ADESAAUCTION__c)){
                                 a.Auction_Detail_at_Assigned_Auction__c = true;
                                 isMatchFound = true;
                             }
                         }
                     }
                }
                if(!isMatchFound){
                    a.Auction_Detail_at_Assigned_Auction__c = false;
                }
            }
        }    
    }
    
    //Method to update 'New Seller at Assigned Auction' fields on Account when Zipcode is changed
    public static void updatePurchase(Map<Id, Account> newAccountMap, Map<Id, Account> oldAccountMap){
        Boolean flag = false;
        Map<Id, User> usrMap;
        List<Account> accList = new List<Account>();
        Set<Id> fieldSalesRepIdSet = new Set<Id>(); 
        for(Account acc : newAccountMap.values()) {
            if(acc.BillingPostalCode != oldAccountMap.get(acc.Id).BillingPostalCode
               		&& acc.BillingPostalCode != null
               		&& acc.Field_Sales_Rep__c != null) {
                accList.add(acc);
                fieldSalesRepIdSet.add(acc.Field_Sales_Rep__c);        
            }
        }
        if (fieldSalesRepIdSet.size() > 0) {
            usrMap = new Map<Id, User>(); 
            for(User u : [SELECT Id, ADESAAUCTION__c FROM User WHERE Id IN :fieldSalesRepIdSet] ){
                usrMap.put(u.id,u);
            }
        if (accList.size() > 0) {
            List<Account> filteredAccounts = new List<Account>();
                for( Account acc : [SELECT ID,(SELECT ID, ADESA_Auction__c, Purchase_Date__c, CreatedDate 
                                                      FROM R00N300000011ixmEAA__r 
                                                      WHERE ADESA_Auction__c != null
                                                      ORDER BY CreatedDate DESC) 
                                              FROM Account 
                                        WHERE ID IN :accList]){
                                         filteredAccounts.add(acc);   
                                        }
            for (Account acc : filteredAccounts) {
                flag = false;
                for (Purchase__c pur : acc.R00N300000011ixmEAA__r) {
                    System.debug('purr ' + pur);
                    Date PurchaseCreateDate = pur.CreatedDate.Date();
                    if (PurchaseCreateDate <= System.today()
                            && PurchaseCreateDate > (System.today()- 180) 
                        	&& pur.ADESA_Auction__c == usrMap.get(newAccountMap.get(acc.Id).Field_Sales_Rep__c).ADESAAUCTION__c
                            && flag != true) {
                        newAccountMap.get(acc.Id).New_Seller_at_Assigned_Auction__c = true;
                        newAccountMap.get(acc.Id).New_Seller_at_Assigned_Auction_Date__c = PurchaseCreateDate;
                        flag = true;
                    }
                }
                if (!flag) {
                    newAccountMap.get(acc.Id).New_Seller_at_Assigned_Auction__c = false;
                    newAccountMap.get(acc.Id).New_Seller_at_Assigned_Auction_Date__c = null;
                }
            }
        }
    }
}
}