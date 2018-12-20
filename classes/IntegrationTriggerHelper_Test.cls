@isTest
private class IntegrationTriggerHelper_Test {
    @testSetup
    static void testSetup() {
        
    }

    @isTest
    static void test_scheduleJobs_insert_pending() {
        IntegrationJob.DISABLE_SCHEDULING_INTEGRATION_JOB = false;
        Test.startTest();
        insert new Integration__c(API_Name__c = 'RATEPOINT', Status__c = 'Pending');
        Test.stopTest();
        Integration_Jobs__c jobs = [SELECT Ratepoint__c FROM Integration_Jobs__c LIMIT 1 ];
        system.assert([SELECT Ratepoint__c FROM Integration_Jobs__c LIMIT 1 ].size()>0);
        //System.assertNotEquals(null, jobs.Ratepoint__c);
    }

    @isTest
    static void test_scheduleJobs_insert_failed() {
        IntegrationJob.DISABLE_SCHEDULING_INTEGRATION_JOB = false;
        insert new Integration__c(API_Name__c = 'RATEPOINT', Status__c = 'Failed');

        
        System.assertEquals(0 , [SELECT Ratepoint__c FROM Integration_Jobs__c LIMIT 1 ].size());
    }

    @isTest
    static void test_scheduleJobs_updateToPending() {
        Integration__c integration = new Integration__c(API_Name__c = 'RATEPOINT', Status__c = 'Failed');
        insert integration;

        IntegrationJob.DISABLE_SCHEDULING_INTEGRATION_JOB = false;
        integration.Status__c = 'Pending';
        update integration;

        Integration_Jobs__c jobs = [SELECT Ratepoint__c FROM Integration_Jobs__c LIMIT 1 ];
        system.assert([SELECT Ratepoint__c FROM Integration_Jobs__c LIMIT 1 ].size()>0);
        //System.assertNotEquals(null, jobs.Ratepoint__c);
    }
}