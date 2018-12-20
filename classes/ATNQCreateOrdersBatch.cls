global class ATNQCreateOrdersBatch implements Database.Batchable<sObject>, Schedulable {
    
    String query;
    integer daysBefore_monthly, daysBefore_annually;

    global ATNQCreateOrdersBatch() {

        string activeStatuses = '\'Active\'';

        string subscriptionItemsQuery = ' (SELECT Id, Product__r.ProductCode, Start_Date__c, Cancel_Date__c FROM Subscription_Item__r WHERE Status__c IN (' + activeStatuses + '))' ;
        query = 'SELECT Id, Term__c, Sign_up_Date__c, Next_Bill_Date__c, Contact__c, Contact__r.AccountId, ' + subscriptionItemsQuery + ' FROM Subscription__c ' + 
                'WHERE Status__c IN (' + activeStatuses + ') AND ' +
                 //'Next_Bill_Date__c = ' + system.now().format('yyyy') + '-' + system.now().format('MM') + '-' + system.now().format('dd') ;
                'Next_Bill_Date__c = TOMORROW';

		String newQuery = ' SELECT Id, Product__r.ProductCode, Start_Date__c, Cancel_Date__c, Subscription__r.Id, Subscription__r.Term__c, Subscription__r.Sign_up_Date__c,Subscription__r.Next_Bill_Date__c, Subscription__r.Contact__c, Subscription__r.Contact__r.AccountId FROM Subscription_Item__c WHERE Status__c IN (\'Active\') AND Subscription__r.Status__c IN (\'Active\') AND (( Subscription__r.Next_Bill_Date__c = TOMORROW AND Subscription__r.Term__c = \'Monthly\') OR (Subscription__r.Next_Bill_Date__c = NEXT_N_DAYS:45 AND Subscription__r.Term__c =\'Annual\'))';
            
          
                
        system.debug('query ' + query);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Subscription__c> subscriptions) {
        
        ATNQCreateOrders.CreateOrders(subscriptions);
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(this);
    }
    
}