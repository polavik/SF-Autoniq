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

trigger CaseSetSellerRatingFlag on Case (before insert, before update) {

   //Get profile Id of Current User
   Id profileId = Userinfo.getProfileId();
   //Get KillSwitch record for the User's profileId.
   Killswitch__c killSwitch = Killswitch__c.getInstance(profileId);
   
   //Check for KillSwitch flag
   if(killSwitch == null || !killSwitch.Killswitch_Enabled__c){
        Set<String> typeSet = new Set<String>();
        Set<String> reasonSet = new Set<String>();
        Set<String> resolutionSet = new Set<String>();
        
        typeSet.add('ARBITRATION');
        typeSet.add('INTERNAL ISSUE');
        
        reasonSet.add('STRUCTURAL/FRAME DAMAGE');
        reasonSet.add('MECHANICAL PROBLEMS');
        reasonSet.add('MISSING EQUIPMENT');
        reasonSet.add('ODOMETER DISCREPANCY');
        reasonSet.add('UNDISCLOSED POOR PRIOR REPAIR');
        reasonSet.add('TITLE ISSUES');
        reasonSet.add('UNDISCLOSED DAMAGE');
        reasonSet.add('UNDISCLOSED PREVIOUS REPAIR');
        reasonSet.add('LISTING ERROR');
        reasonSet.add('TITLE ISSUES');
        reasonSet.add('VEHICLE UNAVAILABLE');
        
        resolutionSet.add('VOID');
        resolutionSet.add('CONCESSIONS');
        
        for (Case c : Trigger.new) {
            // djpatel (10-Nov-14): Added condition for Case Migration Process
            if(!c.Is_Migrated_Openlane_Case__c)
            {
                if(c.archived__c != 'Yes'){
                    c.Used_For_Seller_Rating__c = 'No'; 
                    
                    if (c.Type != null && typeSet.contains(c.Type.toUpperCase())) {
                        if (c.Reason != null && reasonSet.contains(c.Reason.toUpperCase())) {
                            if (c.Claim_Resolution__c != null && resolutionSet.contains(c.Claim_Resolution__c.toUpperCase())){
                                if (c.Resolution_Subtype__c != null && c.Resolution_Subtype__c.equalsIgnoreCase('Seller')) {
                                    c.Used_For_Seller_Rating__c = 'Yes';
                                }
                            } 
                        }
                    } 
                }
             }
        } 
    }
}