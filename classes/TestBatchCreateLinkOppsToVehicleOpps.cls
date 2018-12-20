@isTest private class TestBatchCreateLinkOppsToVehicleOpps   {
static testMethod void testBatch() {
        Test.StartTest();
        BatchCreateLinkOppsToVehicleOpps om = new BatchCreateLinkOppsToVehicleOpps();
        om.query = om.query + ' LIMIT 200 ';
        Database.executeBatch(om);
        Test.StopTest(); 
    }
    
    
}