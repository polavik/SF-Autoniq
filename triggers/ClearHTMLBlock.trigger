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

trigger ClearHTMLBlock on Contact (before update) {
   //Get profile Id of Current User
   Id profileId = Userinfo.getProfileId();
   //Get KillSwitch record for the User's profileId.
   Killswitch__c killSwitch = Killswitch__c.getInstance(profileId);
   
   //Check for KillSwitch flag
   if(killSwitch == null || !killSwitch.Killswitch_Enabled__c){
        // Only work on Contact where the Location__c field has changed
        List<Contact> changed = new List<Contact>();
        List<Contact> ContactToUpdate = new List<Contact>();
        
        HtmlClearHelper ClassToClear = new HtmlClearHelper();
        //SingleContactUpdate ClassToUpdate = new SingleContactUpdate();
        
            
        if (Trigger.isUpdate) {
            for (Contact newCont : Trigger.new) {
                Contact oldCont = Trigger.oldMap.get(newCont.Id);
                if (oldCont.Location__c != newCont.Location__c) {
                    newCont=ClassToClear.ClearAuction(newCont);
                    changed.add(newCont);
                    
                    //if(newCont.Location__c!=null && newCont.Location__c!=''){ newCont=ClassToUpdate.FetchContacts(newCont);}
                }
                
                    
            }
        }
    }
}