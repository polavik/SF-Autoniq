@isTest
private class TestBatchCleanupCallOutcomeLog {
    static testmethod void test1() {
             
       Test.startTest();
        
       Cleanup_Properties__c cp = TestUtility.createCleanProperties('CallOutcomeLog', false);
       cp.date__c='5';
       insert cp;
       Call_Outcome_Log__c callOutcomeLog = TestUtility.createCallOutcomeLog(false);
       callOutcomeLog.createddate = system.today() - 130;
       
       List<Call_Outcome_Log__c> ListCallOutcomeLog = new List<Call_Outcome_Log__c>();
       ListCallOutcomeLog.add(callOutcomeLog);
       insert ListCallOutcomeLog;
       
       BatchCleanupCallOutcomeLog objBatchCleanupCallOutcomeLog = new BatchCleanupCallOutcomeLog();
       Database.executeBatch(objBatchCleanupCallOutcomeLog);
       Test.stopTest();        
    }
}