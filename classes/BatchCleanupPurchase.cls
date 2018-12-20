Global class BatchCleanupPurchase implements Database.Batchable<SObject>,Database.Stateful, Schedulable{
    
    global integer purchaseDeleCounter = 0;
    public String purchaseDate = [select date__c from Cleanup_Properties__c where name = 'PurchaseDate'].date__c; //36 month
    public String email = [select date__c from Cleanup_Properties__c where name = 'Email'].date__c; //email notification   
    public string datestring = string.valueOf(system.today() - Integer.valueOf(purchaseDate)) + 'T23:01:01Z'; 
    public String query = 'select id,createddate,(select id from cases__r) from Purchase__c where createddate < ' + datestring; 
    public String query2 = 'select id,createddate,(select id from cases__r) from Purchase__c where CreatedDate >= 2012-05-01T00:00:00Z and  CreatedDate <2013-01-01T00:00:00Z  ' ; 
       
    global void execute(SchedulableContext sc) 
    {
        BatchCleanupPurchase proc = new BatchCleanupPurchase();
        Database.executeBatch(proc);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {      
        return Database.getQueryLocator(query); 
    } 
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) 
    {     
        List<Purchase__c> purchasesProcess = (List<Purchase__c>) scope;    
        List<Purchase__c> purchasesToDelete = new List<Purchase__c>();
        for(Purchase__c p: purchasesProcess){
            if(p.cases__r.size()<1){
                purchasesToDelete.add(p);
                purchaseDelecounter++;
            }
        }
        delete purchasesToDelete ;    
    }
    
    global void finish(Database.BatchableContext bc) 
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {email});
        mail.setSubject('Purchases Cleanup Job Completed');
        String body = 'There are total of ' + purchaseDeleCounter + ' Purchases have been deleted.';
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}