global class ObjectLogPurgeBatch implements Database.Batchable<SObject>, Database.Stateful,Schedulable{
    global Integer counter = 0;
    string objectName = 'Object_Log__c';
    public string datestring = string.valueOf(system.today() - Integer.valueOf('30')) + 'T23:01:01Z'; 
    public String query = 'select id, createddate from ' + objectName + ' where createddate < ' + datestring;
    
    
    global void execute(SchedulableContext sc) 
    {
        ObjectLogPurgeBatch proc = new ObjectLogPurgeBatch();
        Database.executeBatch(proc);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {      
        return Database.getQueryLocator(query); 
    } 
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) 
    {   
        System.debug('ObjectLogPurgeBatch:' + query);
        try{
            List<Object_Log__c> objectToProcess = (List<Object_Log__c>) scope;
            List<Object_Log__c> objectToDelete = new List<Object_Log__c>(); 
            for(Object_Log__c col: objectToProcess){
                objectToDelete.add(col);
            }
            counter = objectToDelete.size();
            delete objectToDelete; 
        }
        catch (Exception e)
        {
            System.debug('ObjectLogPurgeBatch Error:'+e);
        }
        
        
    }
    
    global void finish(Database.BatchableContext bc) 
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'SalesforceEngineering@adesa.com'});
        mail.setSubject(objectName + ' Cleanup Job Completed');
        String body = 'There are total of ' + counter + ' ' + objectName + ' object(s) have been deleted.';
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }   
}