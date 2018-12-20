global class PurgeOldVirs implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    
    global String saveResults = '';
    global String deleteResults = '';

    public String query ='select id from vir__c where createddate < LAST_N_DAYS:60';


    global void execute(SchedulableContext sc) 
    {
        PurgeOldVirs oldVirs = new PurgeOldVirs ();
        Database.executeBatch(oldVirs);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) 
    {
        
        List<VIR__c> virs = (List<VIR__c>) scope;
        
        
        Database.DeleteResult[] drs = Database.delete(virs, false);
     //   for (Database.DeleteResult dr : drs) {
     //       deleteResults = deleteResults + dr + '\n';
     //   }
    }
    
    global void finish(Database.BatchableContext bc) 
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'Salesforcebatchnotifications@openlane.com'});
        mail.setSubject('Purging over 60 days old VIRS records Completed');
        
        String body = 'Delete Results:\n' + deleteResults;
            
        mail.setPlainTextBody(body);
        
        if(!Test.isRunningTest())
        {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }        
        
    }
    
   
    
}