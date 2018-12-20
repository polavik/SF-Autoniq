@isTest
private class TestBatchCleanupMVGPrice {
    static testmethod void test1() {
             
       Test.startTest();
        
       Cleanup_Properties__c cp = TestUtility.createCleanProperties('MVGPrice', false);
       cp.date__c='5';
       insert cp;
       MVG_Price__c mvgPrice = TestUtility.createMvgPrice(false);
       mvgPrice.createddate = system.today() - 130;
       
       List<MVG_Price__c> ListMvgPrice = new List<MVG_Price__c>();
       ListMvgPrice.add(mvgPrice);
       insert ListMvgPrice;
       
       BatchCleanupMVGPrice objBatchCleanupMVGPrice = new BatchCleanupMVGPrice();
       Database.executeBatch(objBatchCleanupMVGPrice);
       Test.stopTest();        
    }
}