@isTest
private class AccountTriggerHandler_Test {
    private static testmethod void updatePurchase_Test(){
        Id RecordType_ADESA_AMS_Purchase = Schema.SObjectType.Purchase__c.getRecordTypeInfosByName().get('ADESA AMS Purchase').getRecordTypeId();
        
        User testUser = TestUtility.createTestUser(false);
        testUser.ADESAAUCTION__c = 'ADESA Montreal';
        insert testUser;
        
        Territory__c tert = TestUtility.createTerritory('54321', 'Territory', false);
        tert.DOSS__c = testUser.id;
        insert tert;
        
        List<Account> ListAccounts = TestUtility.createAccountRecords('Test Account', 2, false);
        ListAccounts.get(0).BillingCountry = 'USA';
        ListAccounts.get(0).BillingPostalCode = '54322';
        ListAccounts.get(0).Field_Sales_Rep__c = testUser.Id;
        insert ListAccounts;
        
        List<Purchase__c> ListPurchases = TestUtility.createPurchaseRecords('Test Purchase', 'Test Source', ListAccounts.get(0).Id, ListAccounts.get(0).Id, 2, false);
        ListPurchases.get(0).RecordTypeId = RecordType_ADESA_AMS_Purchase;
 		ListPurchases.get(0).Purchase_Date__c = System.today()-45;
        ListPurchases.get(0).ADESA_Auction__c = 'ADESA Montreal';
        ListPurchases.get(1).RecordTypeId = RecordType_ADESA_AMS_Purchase;
		ListPurchases.get(1).Purchase_Date__c = System.today()-181;
        ListPurchases.get(1).ADESA_Auction__c = 'ADESA Montreal';
        ListPurchases.get(1).ATC_Seller__c = ListAccounts.get(1).Id;
        ListPurchases.get(1).ATC_Buyer__c = ListAccounts.get(1).Id;
        insert ListPurchases;
        
        System.debug('AccountListQuery'+[SELECT ID,
                              (SELECT ID, ADESA_Auction__c, Purchase_Date__c, CreatedDate 
                               FROM R00N300000011ixmEAA__r 
                               WHERE ADESA_Auction__c != null
                               ORDER BY CreatedDate DESC) 
                      FROM Account 
                      WHERE ID IN :ListAccounts]);
        
        Test.startTest();
        ListAccounts.get(0).BillingPostalCode = '54321';
        ListAccounts.get(1).BillingPostalCode = '54322';
        update ListAccounts;
        
        List<Account> updatedAccountList = [SELECT ID, New_Seller_at_Assigned_Auction__c, New_Seller_at_Assigned_Auction_Date__c FROM Account WHERE ID IN: ListAccounts ];
        System.debug('updatedAccountListt'+updatedAccountList);
        System.assertEquals(true, updatedAccountList.get(0).New_Seller_at_Assigned_Auction__c);
        System.assertEquals(false, updatedAccountList.get(1).New_Seller_at_Assigned_Auction__c);
    	Test.stopTest();
    }
    
    private static testmethod void updateAuctionDetailatAssigned_Test(){
        try{
            User testUser = TestUtility.createTestUser(false);
            testUser.ADESAAUCTION__c = 'ADESA Boston';
            insert testUser;
            
            Territory__c tert = TestUtility.createTerritory('54321', 'Territory', false);
            tert.DOSS__c = testUser.id;
            insert tert;            
            
            Account acc = TestUtility.createAccount(1, false);
            acc.Name = 'ADESA Boston';
            acc.DST_Outside_Sales_Rep_Lookup__c = testUser.Id;
            insert acc;
            
            Auction_Detail__c aucDetail = TestUtility.createAuctionDetail(1, acc.Id, false);
            aucDetail.Auction__c = acc.Id;
            aucDetail.Outside_Sales_Rep__c = testUser.Id;
            insert aucDetail;
            
            acc.BillingCountry = 'USA';
            acc.BillingPostalCode = '54321';
            acc.Field_Sales_Rep__c = testUser.Id;
            update acc;
            
            List<Account> updatedAccountList = [SELECT ID, Auction_Detail_at_Assigned_Auction__c FROM Account WHERE ID = :acc.Id ];
            System.assertEquals(true, updatedAccountList.get(0).Auction_Detail_at_Assigned_Auction__c);
        } catch(Exception e) {
            system.debug('>>>>>>>>>>>>>>>>>>>>>>>>'+e.getMessage()+' ----line no.'+e.getStackTraceString());
        }
    }
}