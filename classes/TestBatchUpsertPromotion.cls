@isTest
private class TestBatchUpsertPromotion {

    static testMethod void myUnitTest() {
        Test.StartTest();
        Promotions__c p = new Promotions__c(Auction_Title_Reference__c = 'Test Promotion', Active_Promotion__c = true, Display_Title__c = 'Promotion Title');
        insert p;
        BatchUpsertPromotions om = new BatchUpsertPromotions();
        //om.query = om.query + ' LIMIT 10 ';
        Database.executeBatch(om);
        Test.StopTest(); 
    }
}