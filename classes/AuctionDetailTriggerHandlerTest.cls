/*
*Appirio Inc. 2016
*Name  : AuctionDetailTriggerHandlerTest
*Author: Amit SanWariya (Appirio)
*Date  : 25 Oct, 2016
*Description: To check if an Auction exists on Account related to Auction Detail
*/
@isTest
public class AuctionDetailTriggerHandlerTest {
	//Method to test the updating of Auction_Detail_at_Assigned_Auction__c field on Account
    private static testmethod void checkAccountUpdate() {
        User tstUser = TestUtility.createTestUser(false);
        tstUser.ADESAAUCTION__c = 'ADESA Atlanta';
        insert tstUser;
        
        //Create Territory for updateFieldsbyTerritory trigger
        Territory__c tert = TestUtility.createTerritory('54321', 'Territory', false);
        tert.DOSS__c = tstUser.id;
        insert tert;
        
        //Create to account for Auction Detail's master and Auction
        List<Account> accList = new List<Account>();
        for (Integer i=0; i<2; i++) {
            accList.add(TestUtility.createAccount(i, false));
        }
        System.debug('tstUserr'+tstUser+tstUser.Id);
        accList[0].Name = 'ADESA Atlanta';
        accList[1].BillingPostalCode = '54321';
        accList[1].BillingCountry = 'USA';
        accList[1].Field_Sales_Rep__c = tstUser.Id;
        system.debug('accList[1].Field_Sales_Rep__cc'+accList[1].Field_Sales_Rep__c);
        insert accList;
        
        //Create Auction Detail
        Auction_Detail__c aucDetail = TestUtility.createAuctionDetail(0, accList[1].Id, false);
        aucDetail.Auction__c = accList[0].Id;
        insert aucDetail;
        
        //Test checking Auction_Detail_at_Assigned_Auction__c
        Account acc = [SELECT Id, DOSS_Assigned_Auction__c, Field_Sales_Rep__c, Field_Sales_Rep__r.ADESAAUCTION__c, Auction_Detail_at_Assigned_Auction__c FROM Account WHERE Id = :accList[1].Id];
        System.debug('acc1'+acc);
        System.assert(acc.Auction_Detail_at_Assigned_Auction__c);
        
        //Test unchecking Auction_Detail_at_Assigned_Auction__c
        aucDetail.Auction__c = accList[1].Id;
        aucDetail.Account__c = accList[0].Id;
        update aucDetail;
        
        acc = [SELECT Id, DOSS_Assigned_Auction__c, Field_Sales_Rep__c, Field_Sales_Rep__r.ADESAAUCTION__c, Auction_Detail_at_Assigned_Auction__c FROM Account WHERE Id = :accList[1].Id];
        System.debug('acc2'+acc);
        System.assert(!acc.Auction_Detail_at_Assigned_Auction__c);
    }
}