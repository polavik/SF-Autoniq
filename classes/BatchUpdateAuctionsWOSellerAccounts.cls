global class BatchUpdateAuctionsWOSellerAccounts implements Database.Batchable<SObject>, Database.Stateful, Schedulable, Database.AllowsCallouts {
    
    public String query =
    'SELECT Id, Seller_Account__c ' +
    'FROM Auction__c ' +
    'WHERE Seller_Account__c = NULL';


  global void execute(SchedulableContext sc) 
  {
    BatchUpdateAuctionsWOSellerAccounts proc = new BatchUpdateAuctionsWOSellerAccounts();
    Database.executeBatch(proc);
  }

  global Database.QueryLocator start(Database.BatchableContext bc) 
  {
    return Database.getQueryLocator(query); 
  } 
  
  global void execute(Database.BatchableContext bc, List<SObject> scope) 
  {
    List<Auction__c> allObj = (List<Auction__c>) scope;
       
    update allObj;
    
  }
  
  global void finish(Database.BatchableContext bc) 
  {
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(new String[] {Utils.getProperty('batch.notifications.email')});
    mail.setSubject('Update Auctions where Seller Account was missing');
    
    String body = '';
      
    mail.setPlainTextBody(body);
    
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  }
  
  /*public static testMethod void testBatch() {
        test.startTest();
        BatchUpdateAuctionsWOSellerAccounts om = new BatchUpdateAuctionsWOSellerAccounts();
        om.query = om.query + ' LIMIT 200 ';
        Database.executeBatch(om);
        test.stopTest(); 
  }*/
    
}