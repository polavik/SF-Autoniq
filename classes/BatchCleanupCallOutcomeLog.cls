Global class BatchCleanupCallOutcomeLog implements Database.Batchable<SObject>, Database.Stateful, Schedulable{
    
    global Integer counter = 0;
    string objectName = 'Call_Outcome_Log__c';
    public String deleteDate = [select date__c from Cleanup_Properties__c where name = 'CallOutcomeLog'].date__c; //3 Years
    public string datestring = string.valueOf(system.today() - Integer.valueOf(deleteDate)) + 'T23:01:01Z'; 
    public String query = 'select id, createddate from ' + objectName + ' where createddate < ' + datestring;
       
    global void execute(SchedulableContext sc) 
    {
        BatchCleanupCallOutcomeLog proc = new BatchCleanupCallOutcomeLog();
        Database.executeBatch(proc);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {      
        return Database.getQueryLocator(query); 
    } 
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) 
    {   
        List<Call_Outcome_Log__c> objectToProcess = (List<Call_Outcome_Log__c>) scope;
        List<Call_Outcome_Log__c> objectToDelete = new List<Call_Outcome_Log__c>(); 
        for(Call_Outcome_Log__c col: objectToProcess){
            objectToDelete.add(col);
            counter += objectToDelete.size();
        }
        delete objectToDelete;    
    }
    
    global void finish(Database.BatchableContext bc) 
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'rli@openlane.com'});
        mail.setSubject(objectName + ' Cleanup Job Completed');
        String body = 'There are total of ' + counter + ' ' + objectName + 'object(s) have been deleted.';
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}