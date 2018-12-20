@isTest private class TestBatchCleanUpSellerRetentionOpps {
      static testMethod void testBatch() {
        Test.StartTest();
        BatchCleanUpSellerRetentionOpps om = new BatchCleanUpSellerRetentionOpps();
        om.query = om.query + ' LIMIT 200 ';
        Database.executeBatch(om);
        Test.StopTest(); 
    }
}