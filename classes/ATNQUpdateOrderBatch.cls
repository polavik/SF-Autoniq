global class ATNQUpdateOrderBatch implements Database.Batchable<sObject>, Schedulable {
    String query;
    global ATNQUpdateOrderBatch() {
        
    integer daysBefore_monthly, daysBefore_annually;


      string draftStatuses = '\'DRAFT\'';

       // string subscriptionItemsQuery = ' (SELECT Id, Product__r.ProductCode, Start_Date__c, Cancel_Date__c FROM Subscription_Item__r WHERE Status__c IN (' + activeStatuses + '))' ;
        query = 'SELECT EffectiveDate,ID,Status,EndDate FROM Order ' + 
                'WHERE Status IN (' + draftStatuses + ') AND ' +
                 'EndDate = ' + system.now().format('yyyy') + '-' + system.now().format('MM') + '-' + system.now().format('dd') ;
                // 'Next_Bill_Date__c = TOMORROW.addDays(-2)';


                
        system.debug('query ' + query);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Order> o) {
        
        ATNQUpdateOrders.UpdateOrders(o);
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(this);
    }
    
}