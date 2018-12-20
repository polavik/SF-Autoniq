@isTest
private class MAMetricsTest {

    static testMethod void TriggerTestMethod() 
    {
        sma__MASavedQry__c NewMASavedQry = new sma__MASavedQry__c ();
        NewMASavedQry.Name = 'Test Saved Qry';
        insert NewMASavedQry;
    
    
        for (sma__MASavedQry__c obj : [SELECT Id FROM sma__MASavedQry__c LIMIT 1])
        {
            sma__MALog__c NewMALog = new sma__MALog__c();
            NewMALog.Name = 'Saved Query View';
            NewMALog.sma__Details__c = obj.Id;
            insert NewMALog;
        }   
    }
    
    static testMethod void BatchTestMethod() 
    {
    
        sma__MASavedQry__c NewMASavedQry = new sma__MASavedQry__c ();
        NewMASavedQry.Name = 'Test Saved Qry';
        insert NewMASavedQry;
    
    
        for (sma__MASavedQry__c obj : [SELECT Id FROM sma__MASavedQry__c LIMIT 1])
        {
            sma__MALog__c NewMALog = new sma__MALog__c();
            NewMALog.Name = 'Saved Query View';
            NewMALog.sma__Details__c = obj.Id;
            insert NewMALog;
            
            NewMALog.MASavedQuery__c = null;
            update NewMALog;
            
        } 
    
        Test.StartTest();
        database.executebatch(new CopySavedQueryIdBatch(),100);
        Test.StopTest();          
    }
    
}