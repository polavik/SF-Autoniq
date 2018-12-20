public class RulesEngineTest {
    
    public static void testRuleEng(){
        Id testSubId = 'a5S2D0000008eOQUAY';
List<Subscription__c> subscriptions=[select Id, Term__c, Sign_up_Date__c, Next_Bill_Date__c, Contact__c, Contact__r.AccountId,
                                     (select AutoniqAccountType__c, Subscription_Term__c, No_OfActiveSubscriptions__c, Product_Name__c,
                                      Amount__c, Today__c, Description__c, Status__c, Start_Date__c, Internal_User__c, Cancel_Reason__c,
                                      Recurring__c, Subscription_Status__c, Cancel_Date__c, Subscription__c, IsActive__c, Name, Id, CreatedDate,
                                      CurrencyIsoCode, CreatedById, LastModifiedDate, LastActivityDate, LastViewedDate, LastReferencedDate,
                                      ProductCode__c from subscription_item__r) from subscription__c where id='a5S2D0000008eOQUAY'];
        //system.debug();
     //   List<Subscription__c> subscriptions = Database.Query(query);
        system.debug('Subscription size>'+subscriptions.size());
        ATNQCreateOrders.CreateOrders(subscriptions);
        Set<Id> subIds = new Set<Id>();
        for (Subscription__c subscription : subscriptions) { 
            subIds.add(subscription.Id);//
   		}
        //testing rules engine functionality
        ATNQAssignDiscounts.Assign(subIds);
        //  
    }

}