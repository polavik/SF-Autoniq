@isTest
private class TestAuctionDetailSetSalesRepFields {
  
  static testMethod void testCreate() {
    
    Account a = new Account(Name='Test ADESA Auction Detail Account');
    insert a;
    Auction_Detail__c detail = new Auction_Detail__c(Name = 'Test', Account__c = a.Id, Source_Id__c = 'Test', Inside_Sales_Rep_First_Name__c = 'Test', Inside_Sales_Rep_Last_Name__c = 'Test', Outside_Sales_Rep_First_Name__c = 'Test', Outside_Sales_Rep_Last_Name__c = 'Test');
    insert detail;    
  }
}