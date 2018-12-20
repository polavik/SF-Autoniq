global class BatchUpdateRecentPurchase implements Database.Batchable<SObject>, Database.Stateful, Schedulable{
    private String query = 'SELECT Name, Vehicle_ID__c, Source_Id__c,Data_Source__c, AMS_Inventory_ID__c, RecordTypeId, YMMS__c, Country__c, ATC_Sale_Date__c ' + 
        ' FROM Purchase__c where RecordType.name = \'Recent Purchase\' ' + 
        ' and  AMS_Inventory_ID__c = null and ATC_Sale_Date__c = LAST_N_DAYS:5 and ATC_Sale_Date__c < TODAY';
    global Database.QueryLocator start(Database.BatchableContext ctx) 
    {
        return Database.getQueryLocator(query); 
    } 
     
    global void execute(Database.BatchableContext ctx, List<SObject> objs) 
    {
        List<Purchase__c> pList = (List<Purchase__c>) objs;
        PurchaseTriggerHandler.updateRecordType(pList);
        Database.update(pList);
        System.debug('updated Recent Purchase records:' + pList.size());
    }

    global void finish(Database.BatchableContext ctx) 
    {
    }
    
    global void execute(SchedulableContext ctx) 
    {
        Database.executeBatch(this);
    }
}