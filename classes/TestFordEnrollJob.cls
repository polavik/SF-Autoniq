@isTest
private class TestFordEnrollJob {
      static testMethod void testJob() {
        Test.StartTest();
        FordEnrollJob job = new FordEnrollJob();
        job.execute(null);
        Test.StopTest(); 
    }
}