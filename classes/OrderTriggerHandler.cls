public with sharing class OrderTriggerHandler {
	 public static void SetNextBillingDate (List <Order> orders) { 
        List <Subscription__c> subscriptionsToUpdate = new List <Subscription__c>();
        Set <Id> subscriptionIds = new Set<Id> ();

        integer daysBefore_monthly, daysBefore_annually;
        ATNQ_Order_Creation_Config__mdt [] orderCreationConfig = [SELECT Days_before_creation_Annually__c, Days_before_creation_Monthly__c FROM ATNQ_Order_Creation_Config__mdt];
        daysBefore_monthly =  integer.valueOf(orderCreationConfig[0].Days_before_creation_Monthly__c);
        daysBefore_annually  = integer.valueOf( orderCreationConfig[0].Days_before_creation_Annually__c );

        Date adjustedDateAnnualy, adjustedDateMonthly;
        adjustedDateMonthly = system.today().addDays(daysBefore_monthly * -1);
        adjustedDateAnnualy = system.today().addDays(daysBefore_annually * -1);
        

        for (Order o : orders) {
            subscriptionIds.add ( o.Subscription__c );
        }
        for (Subscription__c subscription : [SELECT Id, Next_Bill_Date__c, Term__c FROM Subscription__c WHERE Id IN : subscriptionIds ]) {
            Subscription__c subscriptionToUpdate = new Subscription__c(Id = subscription.Id);

            if (subscription.Next_Bill_Date__c == null) {
                if (subscription.Term__c == 'Monthly') {
                    subscriptionToUpdate.Next_Bill_Date__c = adjustedDateMonthly.addMonths(1);
                }
                else  if (subscription.Term__c == 'Yearly'){
                    subscriptionToUpdate.Next_Bill_Date__c = adjustedDateAnnualy.addYears(1);
                }
            } 
            else {
                if (subscription.Term__c == 'Monthly') {
                    subscriptionToUpdate.Next_Bill_Date__c = subscription.Next_Bill_Date__c .addMonths(1).addDays(daysBefore_monthly * -1);
                }
                else if (subscription.Term__c == 'Yearly'){
                    subscriptionToUpdate.Next_Bill_Date__c = subscription.Next_Bill_Date__c .addYears(1).addDays(daysBefore_annually * -1);
                }
            }
            subscriptionsToUpdate.add(subscriptionToUpdate);
        }
        update subscriptionsToUpdate;
    }
}