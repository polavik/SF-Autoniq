//============================================================================================//
//      THIS TRIGGER IS USED BY IAA-Remarketing APP
// ============================================================================================//
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

trigger IAAILeadTrigger on Lead (before insert, before update) {
     
   //Get profile Id of Current User
   Id profileId = Userinfo.getProfileId();
   //Get KillSwitch record for the User's profileId.
   Killswitch__c killSwitch = Killswitch__c.getInstance(profileId);
   
   //Check for KillSwitch flag
   if(killSwitch == null || !killSwitch.Killswitch_Enabled__c){
    list<Lead> leads = new list<Lead>();
       
    //BEGIN: S-444340 T-561808 - Process only IAA Remarketing Recordtype data
    Map<ID,Schema.RecordTypeInfo> rt_Map = Lead.sObjectType.getDescribe().getRecordTypeInfosById();
    
    /*RecordType recordtypes = [SELECT Id, name
                                         FROM RecordType
                                         WHERE SobjectType = 'Lead' AND Name = 'IAA Buyer Services'
                                         LIMIT 1];*/ //Changed by Santosh Sahani
    //Looks up the branches based on the Lead PostalCode
    if(trigger.isBefore){
        
        for(Lead ld : trigger.new){
        //BEGIN: S-444340 T-561808 - Process only IAA Remarketing Recordtype data
         if (rt_map.get(ld.recordTypeID).getName().containsIgnoreCase('IAA Remarketing'))
            //if (ld.recordtype.name==recordtypes.name) **Changed by Santosh Sahani
          //END:  S-444340 T-561808 - Process only IAA Remarketing Recordtype data
              if( trigger.isInsert || 
                  (trigger.isUpdate && ld.Branch__c == null) ||
                  (trigger.isUpdate && ld.PostalCode != trigger.oldMap.get(ld.id).PostalCode)
              ){
                  leads.add(ld);
              }
         }    
      }        
        //Only check the leads that are in the lead list and NOT the full trigger.new list
        if(!leads.isEmpty()){
            LeadController.GetLeadBranches(leads);  
        }
    }
    
}