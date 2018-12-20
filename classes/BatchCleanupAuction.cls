Global class BatchCleanupAuction implements Database.Batchable<SObject>,Database.Stateful, Schedulable{    
    global Integer intDeleteCounter = 0;   
    global string Summary='';
    public Integer intDaysForAuction  = Integer.valueof([select date__c from Cleanup_Properties__c where name = 'Auctions_Purge_BeforeDays'].date__c); //12 month   
    public String email = [select date__c from Cleanup_Properties__c where name = 'Email'].date__c; //email notification
        
    global String strPurgeDateAction  = string.valueOf(system.today() - intDaysForAuction) + 'T23:01:01Z';                 
    public String query = 'select id from Auction__c where createddate<'+strPurgeDateAction+' and (Asset__r.System_Id__c!=\'3\' and Asset__r.System_Id__c!=\'4\')' ;
     public String query2 = 'select id from Auction__c where  CreatedDate < 2014-09-01T00:00:00Z   and (Asset__r.System_Id__c!=\'3\' and Asset__r.System_Id__c!=\'4\')' ;
   
  
   global void execute(SchedulableContext sc) 
    {
        BatchCleanupAuction objProcess = new BatchCleanupAuction();
        Database.executeBatch(objProcess);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {      
        return Database.getQueryLocator(query); 
    } 
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) 
    {     
        try{
            List<Auction__c> AuctionToProcess = (List<Auction__c>) scope;    
            List<Auction__c> AuctionToDelete = new List<Auction__c>();            
            
            for(Auction__c obj: AuctionToProcess){
                AuctionToDelete.add(obj);
                intDeleteCounter++;               
             
            }
            delete AuctionToDelete;
        }
        catch (Exception e)
        {
            System.debug('>>>> Error:'+e);
            Summary+='Error Detail : '+e.getmessage()+'<br/><br/>';
        }
       
    }
    
    global void finish(Database.BatchableContext bc) 
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {email});
        mail.setSubject('Auction Cleanup Job Completed');
        String body = 'There are total of ' + intDeleteCounter + ' Auctions had been deleted. <br/><br/> Error:'+Summary;
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}