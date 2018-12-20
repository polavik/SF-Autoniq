@isTest private class TestBatchCleanUpBuyerRetentionOpps {
       static testMethod void testBatch() {
        Test.StartTest();
        BatchCleanUpBuyerRetentionOpps om = new BatchCleanUpBuyerRetentionOpps();
        om.query = om.query + ' LIMIT 200 ';
        Database.executeBatch(om);
        Test.StopTest(); 
    }
}