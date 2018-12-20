@isTest
private class TestPromoBeforeInsertUpdate{
   static testMethod void myUnitTest() {
    Promotions__c a = new Promotions__c(Auction_Title_Reference__c = 'Test Promotion', Active_Promotion__c = true, Display_Title__c = 'Promotion Title');
    insert a;
   }
}