@isTest
private class IntegrationJob_Test {
    private static final String API_NAME = 'Unit_Test';

    @isTest
    static void test_scheduleJob_noJobScheduled() {
       
        registerTypeWithJob(new GoodMock());

        IntegrationJob.DISABLE_SCHEDULING_INTEGRATION_JOB = false;
        IntegrationJob.scheduleJobs(new Set<String> { API_NAME });

        Integration_Jobs__c jobs = [SELECT Unit_Test_Job_Id__c FROM Integration_Jobs__c LIMIT 1 ];
       
        System.assertEquals(null, jobs.Unit_Test_Job_Id__c);
    }

    @isTest
    static void test_scheduleJob_wrongType() {
        //insert new Pardot_Setting__c(Name = 'A', API_User_Key__c ='1');
        registerTypeWithJob(new GoodMock());

        try {
            IntegrationJob.DISABLE_SCHEDULING_INTEGRATION_JOB = false;
            IntegrationJob.scheduleJobs(new Set<String> { API_NAME, 'Test' });
            // IntegrationJob.scheduleJobs(new Set<String> { API_NAME });
            System.assertEquals(false, true, 'No exception was thrown');
        }
        catch (IntegrationJob.IntegrationJobException e) {
            IntegrationJob.JOB_MAPPING.remove(API_NAME);
            // expected
        }

       System.assertEquals(0 , [SELECT Unit_Test_Job_Id__c  FROM Integration_Jobs__c LIMIT 1 ].size());
    }

    @isTest
    static void test_scheduleJob_missingJobMapping() {
        //insert new Pardot_Setting__c(Name = 'A', API_User_Key__c ='1');
        registerTypeWithJob(new GoodMock());
        IntegrationJob.JOB_MAPPING.remove(API_NAME);

        try {
            IntegrationJob.DISABLE_SCHEDULING_INTEGRATION_JOB = false;
            IntegrationJob.scheduleJobs(new Set<String> { API_NAME });
            System.assertEquals(false, true, 'No exception was thrown');
        }
        catch (IntegrationJob.IntegrationJobException e) {
            // expected
        }
       
       
       System.assertEquals(0 , [SELECT Unit_Test_Job_Id__c  FROM Integration_Jobs__c LIMIT 1 ].size());       
       
    }

    @isTest
    static void test_scheduleJob_missingServices() {
//        insert new Pardot_Setting__c(Name = 'A', API_User_Key__c ='1');
        registerTypeWithJob(new GoodMock());
        IntegrationJob.SERVICES.remove(API_NAME);

        try {
            IntegrationJob.DISABLE_SCHEDULING_INTEGRATION_JOB = false;
            IntegrationJob.scheduleJobs(new Set<String> { API_NAME });
            System.assertEquals(false, true, 'No exception was thrown');
        }
        catch (IntegrationJob.IntegrationJobException e) {
            // expected
        }

        System.assertEquals(0 , [SELECT Unit_Test_Job_Id__c  FROM Integration_Jobs__c LIMIT 1 ].size());
    }

    @isTest
    static void test_jobDeletesCompletedRecords() {
       
        registerTypeWithJob(new GoodMock());

        insert new Integration__c(API_Name__c = API_NAME, Status__c = 'Pending');

        Test.startTest();
            IntegrationJob.DISABLE_SCHEDULING_INTEGRATION_JOB = false;
            IntegrationJob.scheduleJobs(new Set<String> { API_NAME });
        Test.stopTest();

        integer recordsCnt = [SELECT COUNT() FROM Integration__c];
        System.assertEquals(0, recordsCnt);
    }

    @isTest
    static void test_jobIgnoreNonPendingRecords() {
      
        registerTypeWithJob(new GoodMock());

        insert new Integration__c[] {
                new Integration__c(API_Name__c = API_NAME, Status__c = 'Pending'),
                new Integration__c(API_Name__c = API_NAME, Status__c = 'Test')
        };

        Test.startTest();
            IntegrationJob.DISABLE_SCHEDULING_INTEGRATION_JOB = false;
            IntegrationJob.scheduleJobs(new Set<String> { API_NAME });
        Test.stopTest();

        integer recordsCnt = [SELECT COUNT() FROM Integration__c];
        System.assertEquals(1, recordsCnt);
    }

    @isTest
    static void test_jobRecordsErrors() {
        
        registerTypeWithJob(new BadMock());

        insert new Integration__c(API_Name__c = API_NAME, Status__c = 'Pending');

        Test.startTest();
            IntegrationJob.DISABLE_SCHEDULING_INTEGRATION_JOB = false;
            IntegrationJob.scheduleJobs(new Set<String> { API_NAME });
        Test.stopTest();

        Integration__c integration = [SELECT Status__c, Error_Message__c FROM Integration__c];

        System.assertEquals('Failed', integration.Status__c);
        System.assertNotEquals(null, integration.Error_Message__c);
    }

    private static void registerTypeWithJob(IntegrationService service) {
        IntegrationJob.JOB_MAPPING.put(API_NAME, 'Unit_Test_Job_Id__c');
        IntegrationJob.SERVICES.put(API_NAME, service);
    }

    private class BadMock implements IntegrationService {
        public integer getBatchSize() { return 200; }

        public void execute(Integration__c[] records) {
            throw new IntegrationJob.IntegrationJobException('Dummy error');
        }
    }

    private class GoodMock implements IntegrationService {
        public integer getBatchSize() { return 200; }

        public void execute(Integration__c[] records) { }
    }
}