@isTest private class TestBatchCreateBuyerRetentionOpps  {
    static testMethod void testBatch() {
        Test.StartTest();
        BatchCreateBuyerRetentionOpps om = new BatchCreateBuyerRetentionOpps();
        om.query = om.query + ' LIMIT 200 ';
        Database.executeBatch(om);
        Test.StopTest(); 
    }
    
}