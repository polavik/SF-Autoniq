// ------------------------------------------------------------------------------------------ //
// S-448708 -- T-548983
// Developer -- Ankita Sharma, Appirio. 12.12.2016
// KILLSWITCH__C DESCRIPTION:
// Workflows, Assignment Rules, & Triggers need to be disabled for these three Profiles for data migration:
// System Administrator
// AFC Delegated Support
// ADESA Delegated Support
// Turning off the code must be able to be done by a non-Sys Admin Profile user.  Client wants to use their existing custom object Property__c.  
// Write a trigger on Property__c that looks for a "Property Id" of "Killswitch".  If the "Property Value" = true then create/update entries in the Custom // Setting Killswitch__c for the Profiles with the Killswitch__c.Killswitch_Enabled__c checked.  If the "Property Value" = false then create/update
// entries in the Custom Setting Killswitch__c for the Profiles with the Killswitch__c.Killswitch_Enabled__c unchecked.
// 
// This piece of automation has been flagged as a candidate for the Killswitch Global Property.
// 
// This will check if the Killswitch__c object has been toggled on for the given user who is running the automation. If the Killswitch is enabled, the // automation will not run. If the Killswitch is disabled, workflow will fire normally.
// ------------------------------------------------------------------------------------------ //    

trigger CaseSetArbitration on Case (after delete, after insert, after undelete, 
after update) {
   final String ARBITRATION_TYPE = 'Arbitration';
    Set<Id> caseIds = new Set<Id>();
   //Get profile Id of Current User
   Id profileId = Userinfo.getProfileId();
   //Get KillSwitch record for the User's profileId.
   Killswitch__c killSwitch = Killswitch__c.getInstance(profileId);
   
   //Check for KillSwitch flag
   if(killSwitch == null || !killSwitch.Killswitch_Enabled__c){
    
    // djpatel (10-Nov-14): Added condition for Case Migration Process
    if (Trigger.new == null) {
        return;
    }
    for (Case c : Trigger.new) {
    // djpatel (10-Nov-14): Added condition for Case Migration Process
        if(!c.Is_Migrated_Openlane_Case__c)
        {
            if (ARBITRATION_TYPE.equalsIgnoreCase(c.type)) {
                caseIds.add(c.Id);
            }
        }
    }
    if (caseIds.size() == 0) {
        return;
    }            
    
    Set<Id> acctIds = new Set<Id>();
    List<Case> cases = [SELECT AccountId
                   FROM Case
                   WHERE Type =: ARBITRATION_TYPE
                   AND CreatedDate > :Datetime.now().addDays(-180)
                   AND Id IN : caseIds];
    for (Case c : cases) {
        acctIds.add(c.AccountId);
    }
    updateAccount(acctIds);
    updateAdesaComDetail(acctIds);
   }
    private void updateAccount(Set<Id> ids) {
        Map<Id,Integer> resultMap = new Map<Id, Integer>();
        AggregateResult[] arResults = [SELECT AccountId, Count(Id) num
                            FROM Case 
                            WHERE Type = :ARBITRATION_TYPE
                            AND CreatedDate > :Datetime.now().addDays(-180)
                            AND AccountId IN :ids              
                            GROUP BY AccountId];
        for (AggregateResult ar : arResults) {
            resultMap.put(String.valueOf(ar.get('AccountId')), Integer.valueOf(ar.get('num')));
        }
        List<Account> accts = [SELECT Id from Account WHERE Id IN :resultMap.keySet()]; 
        for (Account ac : accts) {
            ac.Arbitrations__c = resultMap.get(ac.Id);
        }
        update accts;
    }
    
    private void updateAdesaComDetail(Set<Id> ids) {
        List<Adesa_com_Detail__c> orgs = new List<Adesa_com_Detail__c>();
        //TODO with migration of Case object
    }
}