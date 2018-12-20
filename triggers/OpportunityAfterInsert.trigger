/*
*Name  : OpportunityAfterInsert
*Author: 
*Date  : 
*Description:
*Modified By: Amit SanWariya (Appirio) 12 Oct 2016 - Added Call to OpportunityTriggerHandler to restrict open opportunities to 50 for an owner
*/
trigger OpportunityAfterInsert on Opportunity (before insert, before update, after insert) {
    //Added By Amit SanWariya
    if ( trigger.isInsert && trigger.isBefore) {
        OpportunityTriggerHandler.BeforeInsert(trigger.new);
    }
    else if ( trigger.isUpdate && trigger.isBefore) {
        OpportunityTriggerHandler.BeforeUpdate(trigger.new, trigger.oldMap);
    }
    
    else if ( trigger.isInsert && trigger.isAfter) {
        Map<Id, Id> opportunityDQMap = new Map<Id, Id>();
        List<Dealer_Questionnaire__c> dqs = new List<Dealer_Questionnaire__c>();
        Set<Dealer_Questionnaire__c> dqSetToUpdate = new Set<Dealer_Questionnaire__c>();
        List<Dealer_Questionnaire__c> dqsToUpdate = new List<Dealer_Questionnaire__c>();
                
        for (Opportunity o : Trigger.new)
        {
             if(o.Dealer_Questionnaire_Id__c != null)
             {
                 opportunityDQMap.put(o.Dealer_Questionnaire_Id__c, o.Id);
             }  
        }
        
        if(opportunityDQMap != null) {
            dqs =
                [
                    SELECT Id, Opportunity__c
                    FROM Dealer_Questionnaire__c
                    WHERE Id in: opportunityDQMap.keySet()
                ];
            
            for(Dealer_Questionnaire__c dq: dqs)
            {
                dq.Opportunity__c = opportunityDQMap.get(dq.Id);
                dqSetToUpdate.add(dq);
            }
            
            if(dqSetToUpdate != null)
            {
                for(Dealer_Questionnaire__c dq: dqSetToUpdate)
                {
                    dqsToUpdate.add(dq);
                }
                Database.update(dqsToUpdate);
            }
    
        }
    }
}