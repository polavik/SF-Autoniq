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

trigger TaskBeforeInsertUpdate on Task (before insert, before update){
   //Get profile Id of Current User
   Id profileId = Userinfo.getProfileId();
   //Get KillSwitch record for the User's profileId.
   Killswitch__c killSwitch = Killswitch__c.getInstance(profileId);
   
   //Check for KillSwitch flag
   if(killSwitch == null || !killSwitch.Killswitch_Enabled__c){
        boolean IsMigrationRuning = false;   
        IsMigrationRuning = Utils.getIsMigrationRuning('is.migration.running');

            
        List<Purchase__c> ps = new List<Purchase__c>();    
        Map<String, Task> vehicleIDTaskMap = new Map<String, Task>();
        List<String> vids= new List<String>();
        
        for(Task t:Trigger.new){
            //Added Condition for Task Records Migration (PPM#97274) (By djpatel - ADESA Canada Salesforce Team)
            if(!(IsMigrationRuning && t.Openlane_Task_SF_ID__c!=null && t.Openlane_Task_SF_ID__c!=''))
            {   
                if(t.ATC_Activity_ID__c != null && t.ATC_Activity_ID__c.SubString(0,3) == 'CA-'){
                    vehicleIDTaskMap.put(t.vehicle_ID__c, t);
                    vids.add(t.vehicle_ID__c);
                }
            }
        }
       
        if(vehicleIDTaskMap != null)
        {
            // In purchase__c object, "Source_Id__c" is the same as "Vehicle_ID__c". But "Source_Id__c" is external ID, so it is indexed
            ps = 
            [
                select Id, Source_Id__c
                from Purchase__c 
                where Source_Id__c in :vehicleIDTaskMap.keySet()
            ];
            
            for(String vid:vids){
                for(Purchase__c p:ps){
                    if(vid == p.Source_Id__c){
                        vehicleIDTaskMap.get(vid).WhatId = p.Id;
                    }
                }
            }
            
         }
         
         // Code Added By Hanisha For Batch Classes
         
         
         Set<Id> OwnerId = new Set<Id>();
         
         for(Task t:trigger.new){
         if(Trigger.Isinsert){
         
         OwnerId.add(t.ownerid);
         
         }
         if(trigger.isUpdate){
         if(t.ownerId != trigger.oldmap.get(t.Id).ownerid){
         OwnerId.add(t.ownerid);
         }
         }
         }
         
         if(OwnerId.size()>0){
             Map<Id,User> Mapusers = new Map<Id,User>([Select id,name,manager.name from user where Id In:OwnerId]);
             
             for(task t : trigger.new){
             if(t.ownerId == Mapusers.get(t.ownerId).Id ){
             t.Manager_Name__c = Mapusers.get(t.ownerId).manager.name;
             }
             }
         }
    }
   
 }