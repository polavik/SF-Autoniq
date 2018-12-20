global class BatchPurgeOldPromotions implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    
    global String saveResults = '';
    global String deleteResults = '';

    private String query ='select id,Expiry_Date__c from Promotions__c where Expiry_Date__c < LAST_N_DAYS:14 ';


    global void execute(SchedulableContext sc) 
    {
        BatchPurgeOldPromotions oldPromo = new BatchPurgeOldPromotions ();
        Database.executeBatch(oldPromo);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) 
    {
        
        List<Promotions__c> promotionlist = (List<Promotions__c>) scope;
        
        
        Database.DeleteResult[] drs = Database.delete(promotionlist, false);
        for (Database.DeleteResult dr : drs) {
            deleteResults = deleteResults + dr + '\n';
        }
    }
    
    global void finish(Database.BatchableContext bc) 
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
         Map<String, SF_Tech_Admin_Email__c> emails= SF_Tech_Admin_Email__c.getAll();
        List<String> emailList= new List<String>();
        emailList.addAll(emails.keySet());
        String[] toAddresses = new String[] {};
        
        for (String emailName : emailList) {
         SF_Tech_Admin_Email__c email= emails.get(emailName);
         
         toAddresses.add(email.email__c); 
        }
        
        //String[] toAddresses = new String[] {'SFTechAdminTeam@openlane.com'}; 
        mail.setToAddresses(toAddresses);
        mail.setSubject('Purging over 14 days old Promotions__c records Completed');
        
        String body = 'Delete Results:\n' + deleteResults;
            
        mail.setPlainTextBody(body);
        if(!Test.isRunningTest())
        {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }           
        
    }
    
    
}