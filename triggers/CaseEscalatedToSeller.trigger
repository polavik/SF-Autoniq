trigger CaseEscalatedToSeller on Case (after insert, after update) 
{
    // This code is modified by the KAR Killswitch.
    //Get profile Id of Current User
    Id profileId = Userinfo.getProfileId();
    //Get KillSwitch record for the User's profileId.
    Killswitch__c killSwitch = Killswitch__c.getInstance(profileId);
    //Check for KillSwitch flag
    if(killSwitch == null || !killSwitch.Killswitch_Enabled__c){
        // If Escalated_to_Seller__c has been set, mark case as casesToEscalate
        // If already escalated but owner changes, need to reapply case sharing rules.  Add to casesToReshare
        Map<ID, Case> casesToEscalate = new Map<ID, Case>();
        List<Case> casesToReshare = new List<Case>();
        for (Case newCase : Trigger.new) 
        {
            // djpatel (10-Nov-14): Added condition for Case Migration Process
            if(!newCase.Is_Migrated_Openlane_Case__c)
            {
                if (Trigger.isUpdate && !'YES'.equalsIgnoreCase(newCase.archived__c)) 
                {
                    Case oldCase = Trigger.oldMap.get(newCase.Id);
                    if (newCase.Escalated_To_Seller__c && !oldCase.Escalated_To_Seller__c) 
                    {
                        casesToEscalate.put(newCase.Id, newCase);
                    }
                    else if (newCase.Escalated_To_Seller__c && newCase.OwnerId != oldCase.OwnerId)
                    {
                        casesToReshare.add(newCase);
                    }
                } 
                else if (Trigger.isInsert && newCase.Escalated_to_Seller__c  && !'YES'.equalsIgnoreCase(newCase.archived__c))
                {
                    casesToEscalate.put(newCase.Id, newCase);
                }
            }
        }    
        
        // Perform Case Escalation for casesToEscalate
        if (casesToEscalate.size() > 0)
        {
            CaseEscalationSharing.createAndShareEscalations(
                [SELECT Id, Seller__c, (SELECT Id FROM Case_Escalations__r)
                 FROM Case
                 WHERE Id IN :casesToEscalate.keySet()]); 
        }

        // Perform sharing recalculation for casesToReshare
        if (casesToReshare.size() > 0)
        {
            CaseEscalationSharing.resetCaseSharing(casesToReshare);
        }
    }   
}