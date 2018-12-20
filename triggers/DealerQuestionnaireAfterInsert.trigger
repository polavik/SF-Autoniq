trigger DealerQuestionnaireAfterInsert on Dealer_Questionnaire__c (after insert) {

    Map<Id, Id> dqLeadMap = new Map<Id, Id>();
    List<Lead> leads = new List<Lead>();
    Set<Lead> leadSetToUpdate = new Set<Lead>();
    List<Lead> leadsToUpdate = new List<Lead>();


    for(Dealer_Questionnaire__c dq: trigger.new)
    {
        System.Debug('Account is: ' + dq.Lead__r.Account_DQ_Id__c);
        System.Debug('Lead is: ' + dq.Lead__c);
        System.Debug('Id is: ' + dq.Id);
        
        dqLeadMap.put(dq.Lead__c, dq.Id);
    }
    
    leads =
    [
    SELECT Id, Account_DQ_Id__c, Oppertunity_DQ_Id__c
    FROM Lead
    WHERE Lead.Id in: dqLeadMap.keySet()
    ];
    
    for(Lead l: leads)
    {
        l.Account_DQ_Id__c = dqLeadMap.get(l.Id);
        l.Oppertunity_DQ_Id__c = dqLeadMap.get(l.Id);
        leadSetToUpdate.add(l);
    }
    
    for(Lead l: leadSetToUpdate)
    {
        leadsToUpdate.add(l);
    }
    Database.update(leadsToUpdate);
    
}