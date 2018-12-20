Global class BatchCleanupVIR implements Database.Batchable<SObject>, Database.Stateful, Schedulable{
    
    global Integer counter = 0;
    string objectName = 'VIR__c';
    public String deleteDate = [select date__c from Cleanup_Properties__c where name = 'VIR'].date__c; // 6 months
    public string datestring = string.valueOf(system.today() - Integer.valueOf(deleteDate)) + 'T23:01:01Z'; 
    public String query = 'select id, createddate from ' + objectName + ' where createddate < ' + datestring;
    public String email = [select date__c from Cleanup_Properties__c where name = 'Email'].date__c; //email notification   
    global void execute(SchedulableContext sc) 
    {
        BatchCleanupVIR proc = new BatchCleanupVIR(); 
        Database.executeBatch(proc);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {      
        return Database.getQueryLocator(query); 
    } 
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) 
    {     
        List<VIR__c> objectToProcess = (List<VIR__c>) scope;
        List<VIR__c> objectToDelete = new List<VIR__c>();
        
        For(VIR__c vir: objectToProcess){
            objectToDelete.add(vir);
            counter++;
        }        
        delete objectToDelete;    
    }
    
    global void finish(Database.BatchableContext bc) 
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {email});
        mail.setSubject(objectName + ' Cleanup Job Completed');
        String body = 'There are total of ' + counter + ' ' + objectName + 'object(s) have been deleted.';
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}