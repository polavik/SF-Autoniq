global class BatchCleanUpSellerRetentionOpps implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    
    global String saveResults = '';
    global String deleteResults = '';
    private String sellerRecordTypeId = Utils.getRecordTypeId('Opportunity', 'Retention-Seller');    

    public String query = 'select id, stageName, closeDate from opportunity where recordTypeId in  (:sellerRecordTypeId) and stageName not in ( \'Closed Won\', \'Closed Lost\')';


    global void execute(SchedulableContext sc) 
    {
       BatchCleanUpSellerRetentionOpps retention = new BatchCleanUpSellerRetentionOpps();
       Database.executeBatch(retention);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) 
    {
        
        List<Opportunity> os = (List<Opportunity>) scope;
        for(Opportunity o: os){
            if(o.stageName.equals('Won')){
                o.StageName = 'Closed Won';
            }else{
                o.StageName = 'Closed Lost';
            }
            o.closeDate = System.today();
        }
        update os;
  
    }
    
    global void finish(Database.BatchableContext bc) 
    {

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        String[] toAddresses = new String[] {'Salesforcebatchnotifications@openlane.com'}; 
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('salesforceemails@openlane.com');
        mail.setSenderDisplayName('Salesforce Support');
        mail.setSubject('Finished processing BatchCleanUpSellerRetentionOpps.'); 
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setPlainTextBody('');
        if(!Test.isRunningTest())
        {        
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }    
    }

    
}