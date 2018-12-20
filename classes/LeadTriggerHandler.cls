// Created By: Amit SanWariya (Appirio)
// Created On: 14-Oct-2016
// Purpose: Filters new leads to restrict task creation on lead conversion
public class LeadTriggerHandler {
    
    //Method to filter leads under conversion with Do_Not_Create_a_Task__c checked
    public static void AfterUpdate(List<Lead> newLeadList, Map<Id, Lead> oldLeadMap) {
        Set<Id> whatIdSet = new Set<Id>();
        //filter the whatIds for newly created Tasks
        for (Lead led: newLeadList) {
            if (led.IsConverted !=  oldLeadMap.get(led.Id).IsConverted
                	&& led.IsConverted == true
               		&& led.Do_Not_Create_a_Task__c == true) {
                if (led.ConvertedOpportunityId != null) {
                    whatIdSet.add(led.ConvertedOpportunityId);  
                } else {
                    whatIdSet.add(led.ConvertedAccountId);  
                }     
            }
        }
        //Send filtered whatIds to LeadTriggerManager for removal of Tasks
        if (whatIdSet.size() > 0) {
            //future method
            LeadTriggerManager.DeleteNewlyCreatedTask(whatIdSet);
        }
    }
}