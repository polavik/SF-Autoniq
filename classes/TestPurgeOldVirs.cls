@isTest private class TestPurgeOldVirs  {
   static testMethod void testBatch() {
        Test.StartTest();
        PurgeOldVirs om = new PurgeOldVirs();
        om.query = om.query + ' LIMIT 200 ';
        Database.executeBatch(om);
        Test.StopTest(); 
    }
    
}