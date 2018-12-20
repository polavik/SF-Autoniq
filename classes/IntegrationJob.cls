public without sharing class IntegrationJob implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    public static boolean DISABLE_SCHEDULING_INTEGRATION_JOB = Test.isRunningTest();

    /** START STATIC SECTION **/
    // add your mapping between your API_Name__c value and your IntegrationService implementation here
    public static final Map<String, IntegrationService> SERVICES = new Map<String, IntegrationService> {
       'RATEPOINT' => new RatepointService()
       
    };

    // add your mapping between your API_Name__c value and the field the job id will be tracked in here
    public static final Map<String, String> JOB_MAPPING = new Map<String, String> {
        'RATEPOINT' => 'Ratepoint__c'

   };

   public static void scheduleJobs(Set<String> apiNames) {
        if (DISABLE_SCHEDULING_INTEGRATION_JOB) {
            return;
        }

        for (String apiName : apiNames) {
            checkTypeRegistration(apiName);
        }
        boolean didScheduleJob = false;
        

        

        for (String apiName : apiNames) {
            String jobIdField = JOB_MAPPING.get(apiName);
            SYSTEM.DEBUG('jobIdField ' + jobIdField);
            IntegrationService service = SERVICES.get(apiName);
            system.debug('jobs.get(jobIdField) ' + jobs.get(jobIdField));
            if (String.isBlank((String) jobs.get(jobIdField))) {
                String jobId = Database.executeBatch(new IntegrationJob(apiName), service.getBatchSize());
                system.debug('jobId ' + jobId);
                jobs.put(jobIdField, jobId);
                didScheduleJob = true;
            }
        }

        if (didScheduleJob)
            upsert jobs;
    }

    private static void checkTypeRegistration(String type) {
        if (type == null)
            throw new IntegrationJobException('Type was null.');
        else if (!SERVICES.containsKey(type)) {
            throw new IntegrationJobException('No IntegrationService implementation was registered with type "' + type + '". Did you forget to register it with the IntegrationJob class?');
        } else if (!JOB_MAPPING.containsKey(type)) {
            throw new IntegrationJobException('No Integration_Jobs__c field was registered with type "' + type + '". Did you forget to register it with the IntegrationJob class?');
        }
    }
    /** END STATIC SECTION **/

    // tracks the API type of this job
    private String type;

    // used when scheduling the job
    public IntegrationJob(String type) { this.type = type; }

    // used when the job is spun up on SF's async servers to run the individual batches
    public IntegrationJob() { }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        checkTypeRegistration(type);
        String pending = 'Pending';

        String query = String.format('SELECT {0} FROM Integration__c WHERE API_Name__c = :type AND Status__c = :pending', new String[] { String.join(getFieldsToQuery(), ', ') });

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, Integration__c[] records) {
        // type will be null on first run since member level variables don't persist across start/execute calls
        if (type == null){
            type = records[0].API_Name__c;
        }

        IntegrationService service = SERVICES.get(type);

        try {
            service.execute(records);
            // no records threw an exception, so delete them
            delete records;
        } catch (Exception e) {
            for (Integration__c integration : records) {
                integration.Status__c = 'Failed';
                integration.Error_Message__c = e.getMessage() + '\nStack Trace:\n' + e.getStackTraceString();
            }

            Database.SaveResult[] srs = Database.update(records, false);
            for (Database.SaveResult sr : srs) {
                if (!sr.isSuccess()) {
            
                    for (Database.Error err : sr.getErrors()) {
                        if( !(err.getMessage().contains('ENTITY_IS_DELETED') || err.getMessage().contains('entity is deleted')) ){
                            //throw new IntegrationJobException(err.getMessage());
                        }
                    }
            
                }
            }

        }
    }

    private static Integration_Jobs__c jobs {
        get {
                Integration_Jobs__c [] intJobs = [SELECT Id, Unit_Test_Job_Id__c, Ratepoint__c FROM Integration_Jobs__c];
                if (intJobs.size() == 0) {
                   jobs =  new Integration_Jobs__c();
                   insert jobs;
                   return jobs;
                }
                else {
                    jobs = intJobs[0];
                }
            
                return jobs;
        }
        set;
    }

    public void finish(Database.BatchableContext bc) {
        //Integration_Jobs__c jobs = Integration_Jobs__c.getOrgDefaults();
        String jobIdField = JOB_MAPPING.get(type);

        // upsert a new copy, so that we don't change a field that could be
        // getting changed by another process
        Integration_Jobs__c jobToUpdate = new Integration_Jobs__c(
            Id = jobs.Id
        );
        jobToUpdate.put(jobIdField, null);
        update jobToUpdate;

        // check if any new records were inserted while the job was running
        integer countOfPendingJobs = [SELECT COUNT()
                                      FROM Integration__c
                                      WHERE API_Name__c = :type
                                              AND Status__c = 'Pending'];
        
        
        if (countOfPendingJobs > 0) {
            scheduleJobs(new Set<String> { type });
        }
    }

    public class IntegrationJobException extends Exception {}

    private List<String> getFieldsToQuery() {
        Map<String, Schema.SObjectField> fields = Schema.SObjectType.Integration__c.fields.getMap();
        Set<String> fieldsToQuery = new Set<String>();

        for (Schema.SObjectField field : fields.values()) {
            DescribeFieldResult fieldDescribe = field.getDescribe();
            if (fieldDescribe.isUpdateable()) {
                fieldsToQuery.add(fieldDescribe.getName());
            }
        }
        return new List<String>(fieldsToQuery);  
    }
}