@isTest
private class TestAuctionTrigger {

    static testMethod void myUnitTestforAuction() {
        
        Asset__c at = new Asset__c(Name='VIN1234567980Test', Source_Id__c='OL-123456789', Vehicle_Id__c ='123456789');
        insert at;
              
        Auction__c a = new Auction__c(Name='AuctionTest01', Auction_Id__c='A01010101', Asset__c=at.id,Auction_Status_Name__c='Auction');
        // Auction
        insert a;   
        
        at.Vehicle_Id__c='321456';
        update at;
        
        a.Name='AuctionUpdate01';
        update a; 
        
    }
}