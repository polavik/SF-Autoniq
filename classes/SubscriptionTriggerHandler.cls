public with sharing class SubscriptionTriggerHandler {
  public void OnAfterInsert(List<Subscription__c  > newRecords){
        CountofSubscriptions(newRecords); //salesorder=account,salesorderitem=subscription
        }
    // update the subscription when records are updated from trigger  
    public void OnAfterUpdate(List<Subscription__c > oldRecords, 
      List<Subscription__c  > updatedRecords,  Map<ID, Subscription__c  > oldMap, 
      Map<ID, Subscription__c  > newMap){
         CountofSubscriptions(updatedRecords); 
        }
  public void CountofSubscriptions(List< Subscription__c > newRecords) {
    // create a new map to hold the autoniq acount id  values
      Map<ID,Integer> NoofSubscriptionsMap = new Map<ID,Integer>();
  for (Subscription__c  sub : newRecords) {
    System.debug('i am in sub for loop');
      if(!sub.Internal_User__c==TRUE && sub.Status__c=='Active' && !String.isEmpty(sub.Autoniq_Account__c)){

        //if(!String.isEmpty(sub.Autoniq_Account__c)){
                if(!NoofSubscriptionsMap.containsKey(sub.Autoniq_Account__c)) {
                  system.debug('i am in if loop for autoniqaccount'+sub.Autoniq_Account__c);
                    NoofSubscriptionsMap.put(sub.Autoniq_Account__c, 1);

                } else {
            system.debug('i am in else of count');
                    NoofSubscriptionsMap.put(sub.Autoniq_Account__c, NoofSubscriptionsMap.get(sub.Autoniq_Account__c) + 1);

                }
            }
       else if(!sub.Internal_User__c==True && sub.Status__c=='Inactive' && !String.isEmpty(sub.Autoniq_Account__c)){
          //if(sub.Autoniq_Account__c != null){
                if(!NoofSubscriptionsMap.containsKey(sub.Autoniq_Account__c)) {

                    NoofSubscriptionsMap.put(sub.Autoniq_Account__c, -1);

                } else {

                    NoofSubscriptionsMap.put(sub.Autoniq_Account__c, NoofSubscriptionsMap.get(sub.Autoniq_Account__c) - 1);

                }
        } 
  }
    // query for the autoniqaccount in the context to update
    
        List<Autoniq_Account__c> aa = [select id, No_Of_Subscriptions__c from Autoniq_Account__c  where id IN :NoofSubscriptionsMap.keyset()];
        system.debug('the size of the account is'+aa.size());
      
        for (Autoniq_Account__c a : aa)
          {system.debug('i am in for loop for account');
            system.debug('the size of map is'+NoofSubscriptionsMap.size());
            if(NoofSubscriptionsMap.size()>0)
            {system.debug('i am in if of no of subscriptions'+NoofSubscriptionsMap.size());
          a.No_Of_Subscriptions__c  += NoofSubscriptionsMap.get(a.id);}
        /*else
           {system.debug('i am in else of no of subscriptons if loop');
          a.No_Of_Subscriptions__c = 0;
          }*/}
      try {

       update aa;

   } catch(DmlException e) {

       System.debug(e.getMessage());

   }
   
      
    

    }

  /*public void Calculate(Map <Id, Subscription__c> subscriptions) {
      AggregateResult[] groupedResults = [SELECT Autoniq_Account__c, COUNT(Id)
      FROM SUbscription__c WHERE Status__c = 'Active' GROUP BY Autoniq_Account__c ];
      List <Autoniq_Account__c> autnoiqAccounts = new List <Autoniq_Account__c>();
      for (AggregateResult ar : groupedResults) {
                      Id aaId = (Id) ar.get('Autoniq_Account__c');
                      Integer count = (Integer) ar.get('expr0');
                      autnoiqAccounts.add(new Autoniq_Account__c(Id = aaId, No_Of_Subscriptions__c = count));
      }

      update autnoiqAccounts;
  } */

  
}