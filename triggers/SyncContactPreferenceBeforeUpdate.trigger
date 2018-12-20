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

trigger SyncContactPreferenceBeforeUpdate on Contact (after update) {
   //Get profile Id of Current User
   Id profileId = Userinfo.getProfileId();
   //Get KillSwitch record for the User's profileId.
   Killswitch__c killSwitch = Killswitch__c.getInstance(profileId);
   
   //Check for KillSwitch flag
   if(killSwitch == null || !killSwitch.Killswitch_Enabled__c){
    // Only work on Contact where the Location__c field has changed
    List<Contact> changed = new List<Contact>();
    List<Contact> ContactToUpdate = new List<Contact>();
    
    ContactSyncHelper updateHelper = new ContactSyncHelper();

    
        
    if (Trigger.isUpdate) {
        for (Contact newCont : Trigger.new) {
            Contact oldCont = Trigger.oldMap.get(newCont.Id);
            //Sync_Contact__c
            //if (oldCont.Location__c != newCont.Location__c) {
            if (newCont.Sync_Contact__c==True) {
                System.debug('Sync True');
                changed.add(newCont);
            }
        }
    }
    /*
        select id,location__c,email from contact where email = '10252@dealers.mmsa.com' 286154
        select id,location__c,email from contact where email = '417automall@sympatico.ca' 298573
        select id,location__c,email from contact where email = '1@2.com'                    143748
        select id,location__c,email from contact where email = '88leasing@gmail.com'        351536
        select  Id , Email ,location__C from Contact where Email !='' and Active__c=True order by Email asc limit 200
    */
    System.debug(changed.size());
    for (Contact cont :changed)
    {
        System.debug(cont.Email);
        System.debug(cont.Email__c);
        String temEmail = cont.Email;

    
                System.debug('Location.....'+ cont.location__c);
                System.debug('Email '+ cont.Email);
                
    
            cont = updateHelper.UpdateContactList(cont.Email,cont.location__c);

    }   
    }
}