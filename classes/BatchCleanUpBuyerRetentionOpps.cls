global class BatchCleanUpBuyerRetentionOpps implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    
    global String saveResults = '';
    global String deleteResults = '';
    private String buyerRecordTypeId = Utils.getRecordTypeId('Opportunity', 'Retention-Buyer');    

    public String query = 'select id, stageName, closeDate from opportunity where recordTypeId in  (:buyerRecordTypeId) and stageName not in ( \'Closed Won\', \'Closed Lost\')';


    global void execute(SchedulableContext sc) 
    {
       BatchCleanUpBuyerRetentionOpps retention = new BatchCleanUpBuyerRetentionOpps();
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
        mail.setSubject('Finished processing BatchCleanUpBuyerRetentionOpps.'); 
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setPlainTextBody('');
        if(!Test.isRunningTest())
        {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
   
}