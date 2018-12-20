global class BatchExpireAuctionCredits implements Database.Batchable<SObject>, Database.Stateful, Schedulable
{

  public static String results = 'Expired Credits:\n';
  global string Summary;
  public String strError ='' ;

  public String query = 
    'SELECT Expires__c, Status__c ' + 
    'FROM Auction_Credit__c ' +
    'WHERE Status__c = \'Available\' AND Expires__c < TODAY ';


  global void execute(SchedulableContext sc) 
  {
    BatchExpireAuctionCredits proc = new BatchExpireAuctionCredits();
    Database.executeBatch(proc, 1);
  }

  global Database.QueryLocator start(Database.BatchableContext bc) 
  {
    return Database.getQueryLocator(query); 
  } 
  
  global void execute(Database.BatchableContext bc, List<SObject> scope) 
  {
    List<Auction_Credit__c> allCredits = (List<Auction_Credit__c>) scope;
    List<Auction_Credit__c> creditsToExpire = new List<Auction_Credit__c>();
    for (Auction_Credit__c credit : allCredits)
    {
      if ('AVAILABLE'.equalsIgnoreCase(credit.Status__c) && Date.today().daysBetween(credit.Expires__c) < 0)
      {
        creditsToExpire.add(credit);
        results += credit.Id + '\n';
      }
    }
    
    AuctionCreditHelper.expireCredits(creditsToExpire);
    
    Logger.flush();
  }
  
  global void finish(Database.BatchableContext bc) 
  {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        String[] toAddresses = new String[] {'lily.wu@openlane.com'}; 
        String Org = UserInfo.getOrganizationName();
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Salesforce Support - Batch Complete Notification');
        mail.setSubject('Finished processing Batch_RepStatus_Update in '+Org+' Organization'); 
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.sethtmlBody(Summary);
        //if(!Test.isRunningTest())
        //{ 
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        //}}
     }
    }
 //BatchExpireAuctionCredits objBatchExpireAuctionCredits = new BatchExpireAuctionCredits();
//Database.executeBatch(objBatchExpireAuctionCredits);