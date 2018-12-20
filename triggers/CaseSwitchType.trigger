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

trigger CaseSwitchType on Case (after insert, after update){
   //Get profile Id of Current User
   Id profileId = Userinfo.getProfileId();
   //Get KillSwitch record for the User's profileId.
   Killswitch__c killSwitch = Killswitch__c.getInstance(profileId);
   
   //Check for KillSwitch flag
   if(killSwitch == null || !killSwitch.Killswitch_Enabled__c){
        String ArbNew = Utils.getRecordTypeId('Case', 'Arbitration - New');
        String CusSerInqNew = Utils.getRecordTypeId('Case', 'Customer Service Inquiry - New');
        String CusSerInqOpen = Utils.getRecordTypeId('Case', 'Customer Service Inquiry - Open');
        String OwnInqNew = Utils.getRecordTypeId('Case', 'Ownership Inquiry - New');
        String OwnInqOpen = Utils.getRecordTypeId('Case', 'Ownership Inquiry - Open');
        String PayInqNew = Utils.getRecordTypeId('Case', 'Payment Inquiry - New');
        String PayInqOpen = Utils.getRecordTypeId('Case', 'Payment Inquiry - Open');
        String SellInqNew = Utils.getRecordTypeId('Case', 'Seller Inquiry - New');
        String SellInqOpen = Utils.getRecordTypeId('Case', 'Seller Inquiry - Open');
        String TitleInqNew = Utils.getRecordTypeId('Case', 'Title Inquiry - New');
        String TitleInqOpen = Utils.getRecordTypeId('Case', 'Title Inquiry - Open');
        String TranInqNew = Utils.getRecordTypeId('Case', 'Transportation Inquiry - New');
        String TranInqOpen = Utils.getRecordTypeId('Case', 'Transportation Inquiry - Open');
        String TranDamClaim = Utils.getRecordTypeId('Case', 'Transport Damage Claim');
        
        List<Case> arbCases = new List<Case>();     
        List<Id> oldCaseIds = new List<Id>();
        List<Case> oldCases = new List<Case>();
        for (Case newCase : Trigger.new){
            // djpatel (10-Nov-14): Added condition for Case Migration Process
            if(!newCase.Is_Migrated_Openlane_Case__c)
            {
                if(newCase.Status != 'Closed' && newCase.Switch_Case_Type__c){
                    if(newCase.RecordTypeId == CusSerInqOpen ||newCase.RecordTypeId == OwnInqOpen || newCase.RecordTypeId == PayInqOpen
                    || newCase.RecordTypeId == SellInqOpen || newCase.RecordTypeId == TitleInqOpen || newCase.RecordTypeId == TranInqOpen
                    || newCase.RecordTypeId == TranDamClaim){
                        if(newCase.Claim_Resolution__c != null){
                            Case arbCase = new Case(RecordTypeId = ArbNew, Assigned_To__c = 'Arbitrations', Reason = 'Undisclosed Damage', OwnerId = '00G60000000vR0f',
                            Description = newCase.Description, VIN__c = newCase.VIN__c, AccountId = newCase.AccountId, ContactId = newCase.ContactId);
                            arbCases.add(arbCase);
                            oldCaseIds.add(newCase.Id);
                        }else{
                            newCase.addError('Please choose a resolution reason.');
                        }
                    }
                }
            }
        }
        if(oldCaseIds != null){
            oldCases = [SELECT Id, Status FROM Case WHERE Id in :oldCaseIds];
        }
        for (integer i=0; i<oldCases.size(); i++){
            oldCases.get(i).Status = 'Closed';
        }
        update oldCases;
        insert arbCases;
    }
}