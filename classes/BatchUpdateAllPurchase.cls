global class BatchUpdateAllPurchase implements Database.Batchable<SObject>, Database.Stateful, Schedulable{
    public String query = 'SELECT id, data_source__c,RECORDTYPEID,LastModifiedDate' + 
        ' FROM Purchase__c where data_source__c=\'ADESA\' AND RECORDTYPEID=null  ' ;
        
  global Database.QueryLocator start(Database.BatchableContext ctx) 
  {
    return Database.getQueryLocator(query); 
  } 
     
    global void execute(Database.BatchableContext ctx, List<SObject> objs) 
  {
    List<Purchase__c> pList = (List<Purchase__c>) objs;
        PurchaseTriggerHandler.updateRecordType(pList);
        Database.update(pList);
        System.debug('updated Old Purchase records:' + pList.size());
    }

    global void finish(Database.BatchableContext ctx) 
    {
    }
    
    global void execute(SchedulableContext ctx) 
    {
        Database.executeBatch(this);
    }
}