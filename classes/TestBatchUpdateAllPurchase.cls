@isTest private class TestBatchUpdateAllPurchase {
      static testMethod void testBatch() {
        Test.StartTest();
        BatchUpdateAllPurchase om = new BatchUpdateAllPurchase();
        om.query = om.query + ' LIMIT 200 ';
        Database.executeBatch(om);
        Test.StopTest(); 
    }
}