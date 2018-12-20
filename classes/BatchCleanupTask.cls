Global class BatchCleanupTask implements Database.Batchable<SObject>, Database.Stateful, Schedulable{
    
    global Integer counter = 0;
    public String taskdate1 = [select date__c from Cleanup_Properties__c where name = 'TaskDate1'].date__c; //6 month
    public String taskdate2 = [select date__c from Cleanup_Properties__c where name = 'TaskDate2'].date__c; //18 month
    public String email = [select date__c from Cleanup_Properties__c where name = 'Email'].date__c; //email notification
    public string datestring = string.valueOf(system.today() - Integer.valueOf(taskdate1)) + 'T23:01:01Z'; 
    public String query = 'select id,createddate,Description,IsRecurrence from Task where createddate < ' + datestring;
       
    global void execute(SchedulableContext sc) 
    {
        BatchCleanupTask proc = new BatchCleanupTask();
        Database.executeBatch(proc);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {      
        return Database.getQueryLocator(query); 
    } 
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) 
    {     
        List<Task> tasksToProcess = (List<Task>) scope;    
        List<Task> tasksToDelete = new List<Task>();
        for(Task t: tasksToProcess){
            
            if(t.IsRecurrence==false) 
            {
                if(t.Description == '' || t.Description == null){
                    tasksToDelete.add(t);
                    counter++;
                }else if(t.createdDate < System.today() - Integer.valueOf(taskdate2)){                
                    tasksToDelete.add(t);
                    counter++;
                }
            }
        }
        delete tasksToDelete;
    
    }
    
    global void finish(Database.BatchableContext bc) 
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {email});
        mail.setSubject('Task Cleanup Job Completed');
        String body = 'There are total of ' + counter + ' Tasks have been deleted.';
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}