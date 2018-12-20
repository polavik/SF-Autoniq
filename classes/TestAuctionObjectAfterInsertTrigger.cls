@isTest
private class TestAuctionObjectAfterInsertTrigger {

    static testMethod void myUnitTest() {
    Account acct = new Account();
    //acct.ATC_Organization_ID__c = '123456';
    acct.Name = 'Mr Stevebobs Volvo';
    insert acct;
    
    
    Asset__c v = new Asset__c(vehicle_id__c='v12345', source_id__c='v12345');
    insert v;
    
    Auction__c a = new Auction__c
    (
    auction_id__c='a12345', 
    Highest_Bidder_Account__c=acct.id, 
    Seller_Account__c=acct.id, 
    Asset__c=v.id,
    Auction_Status_Name__c='Auction'
    );
    insert a;
    update a;    

    }
}