/*
*Appirio Inc. 2016
*Name  : TestUtility
*Author: Sumit Tanwar (Appirio)
*Date  : 2nd Nov 2016
*Description: Test Class for PurchaseTrigger (Task # T-552888)
*Modification: Amit Sanwariya - 11/11/2016 - Update New Seller at Assigned Auction fields on Accounts
*/
@isTest
private class PurchaseTriggerTest{

    @isTest static void TestPurchase(){
        //Create TestUser
        ID REC_TYPE_RECENT = Utils.getRecordTypeId('Purchase__c', 'Recent Purchase');
        String COUNTRY_CA='Canada';
        String COUNTRY_US='United States';
        ID REC_TYPE_CA = Utils.getRecordTypeId('Purchase__c', 'Canadian Purchase');
        Id RecordType_ADESA_DST_CLOSE = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('ADESA DST CLOSE').getRecordTypeId();
        Id RecordType = Schema.SObjectType.Purchase__c.getRecordTypeInfosByName().get('AFC Purchase').getRecordTypeId();
        User testUser = TestUtility.createTestUser(false);
        testUser.ADESAAUCTION__c='ADESA Birmingham';
        insert testUser; 
        
        System.runAs(testUser) {  
            //Create Territory for updateFieldsbyTerritory trigger
            Territory__c tert = TestUtility.createTerritory('35004', 'Birmingham', false);
            tert.DOSS__c = testUser.Id;
            tert.DST_Outside_Sales_Rep__c = testUser.Id;
            insert tert;
            
            //Create to account for Auction Detail's master and Auction
            Account acc = TestUtility.createAccount(1, false);
            acc.Name = 'ADESA Atlanta';
            acc.BillingPostalCode = '35004';
            acc.BillingCountry = 'USA';
            acc.Field_Sales_Rep__c = testUser.Id;
            system.debug('acc.Field_Sales_Rep__cc'+acc.Field_Sales_Rep__c);
            insert acc;

            //Create Opportunity
            Opportunity oppToUpdate = TestUtility.createOpportunity(1, acc.id, false);
            oppToUpdate.StageName='open';
            oppToUpdate.RecordTypeId = RecordType_ADESA_DST_CLOSE;
            oppToUpdate.Opportunity_Product_Type__c = 'Ancillary';
            oppToUpdate.Opportunity_Method__c = 'ADESA Ride Along';
            oppToUpdate.AFC_Branch__c = 'ANAHEIM';
            oppToUpdate.AFC_Region__c = 'Andrews';
            oppToUpdate.type = 'Inactive';
            oppToUpdate.Credit_Limit_Requested__c = 2000.00;
            insert oppToUpdate;
            
            Test.startTest();
            //Create Purchase
           List<Purchase__c> purchaseList = new List<Purchase__c>();
            Purchase__c testPurchase= TestUtility.CreatePurchase(1, acc.id,false);
            testPurchase.ADESA_Auction__c = 'ADESA Birmingham';
            testPurchase.car_Group__c = '123';
            testPurchase.RecordTypeId = REC_TYPE_RECENT;
            testPurchase.ATC_Sale_Date__c =Datetime.now();
            testPurchase.Country__c=COUNTRY_US;
            testPurchase.AMS_Inventory_ID__c = null;
			purchaseList.add(testPurchase) ;           
            
            Purchase__c testPurchase1= TestUtility.CreatePurchase(2, acc.id,false);
            testPurchase1.ADESA_Auction__c = 'ADESA Calgary';
            testPurchase1.Country__c=COUNTRY_US;
            testPurchase1.ATC_Sale_Date__c = Datetime.now().addDays(-2);
            testPurchase1.RecordTypeId = REC_TYPE_RECENT;
            testPurchase1.AMS_Inventory_ID__c = '131';
            purchaseList.add(testPurchase1);
            
            Purchase__c testPurchase2= TestUtility.CreatePurchase(3, acc.id,false);
            testPurchase2.car_Group__c = '123';
            testPurchase2.AMS_Inventory_ID__c = null;
            purchaseList.add(testPurchase2);
                       
            Purchase__c testPurchase3= TestUtility.CreatePurchase(4, acc.id,false);
        	testPurchase3.ATC_Sale_Date__c = Datetime.now().addDays(-2);
        	testPurchase3.Country__c=COUNTRY_US;
        	testPurchase3.RecordTypeId = REC_TYPE_RECENT;
            purchaseList.add(testPurchase3);
            
            insert purchaseList;
            
            acc = [SELECT Id, New_Seller_at_Assigned_Auction__c, New_Seller_at_Assigned_Auction_Date__c 
                   FROM Account
                   WHERE Id = :acc.Id];
            
            Account acc2 = TestUtility.createAccount(2, true);
            testPurchase.ATC_Seller__c = acc2.Id;
            update testPurchase;
            
            acc = [SELECT Id, New_Seller_at_Assigned_Auction__c, New_Seller_at_Assigned_Auction_Date__c 
                   FROM Account
                   WHERE Id = :acc.Id];
            System.assert(!acc.New_Seller_at_Assigned_Auction__c);
            Test.stopTest();
        }
    }
}