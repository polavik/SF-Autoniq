/*
* (c) 2016 Appirio, Inc.
* 
* Apex Class Name   : PropertyTriggerHandler
*
* For Apex Trigger  : PropertyTrigger
*
* Description       : Class to sync KillSwitch custom setting with Property object's KillSwitch record values.
*
* 12 Nov 2016         Ankita Sharma(Appirio)   Original ( T-548983) - Please see the Task description for more details.
*
*/
public class PropertyTriggerHandler {
    
    //Trigger after insert method.
    public static void onAfterInsert(List<Property__c> propertyList){
        updateCustomSetting(propertyList);
    }
    
    //Trigger after update method.
    public static void onAfterUpdate(List<Property__c> propertyList){
        updateCustomSetting(propertyList);
    }
    
    //Trigger after delete method.
    public static void onAfterDelete(List<Property__c> propertyList){
        updateCustomSettingOnDelete(propertyList);
    }

    //================================================================      
    // Name         : updateCustomSetting
    // Description  : Method to sync KillSwitch custom setting with Property 
    //                object's KillSwitch record values on insert and update of 
    //                Property object's record.
    // Created Date : 12 November 2016 
    // Created By   : Ankita Sharma (Appirio)
    //==================================================================    
    private static void updateCustomSetting(List<Property__c> propertyList){
        
        //KillSwitch records list to insert.
        List<Killswitch__c> killSwitchtoInsert = new List<Killswitch__c>();
        //KillSwitch records list to update.
        List<Killswitch__c> killSwitchtoUpdate = new List<Killswitch__c>();
        
        //Query Profile records.
        
        Map<Id, Profile> profileMap = new Map<Id, Profile>([SELECT Id FROM Profile 
                                        WHERE 
                                        Name =: Constants.SYS_ADMIN OR 
                                        Name =: Constants.AFC_DEL_SUP OR
                                        Name =: Constants.DATA_MIGRAT OR 
                                        Name =: Constants.AD_DEL_SUP]);                                
        
        //Loop over propertyList
        for(Property__c prop : propertyList){
            //Check if Property_Id__c of property is KillSwitch
            if((prop.Property_Id__c).equalsIgnoreCase(Label.KillSwitch)){
                //Loop over profileList
                for(ID profileID : profileMap.keyset()){
                    Killswitch__c profileSwitch = KillSwitch__c.getValues(profileID);
                    if(profileSwitch == null){
                        killSwitchtoInsert.add(new Killswitch__c(SetupOwnerId = profileID, 
                        Killswitch_Enabled__c = (prop.Property_value__c.equalsIgnoreCase('true') ? true : false)));
                        
                    }else{
                        //Update existing record.                        
                        profileSwitch.Killswitch_Enabled__c = (prop.Property_value__c.equalsIgnoreCase('true') ? true : false);
                        killSwitchtoUpdate.add(profileSwitch);
                    }
                    
                }
            }
        }
        //Insert DML.
        if(killSwitchtoInsert.size()>0){
            insert killSwitchtoInsert;
        }
        //Update DML
        if(killSwitchtoUpdate.size()>0){
            update killSwitchtoUpdate;
        }
    }   
   //================================================================      
   // Name         : updateCustomSettingOnDelete
   // Description  : Method to Update Killswitch_Enabled__c field value 
   //                with false on delete of Property record.
   // Created Date : 12 November 2016 
   // Created By   : Ankita Sharma (Appirio)
   //==================================================================
    
    private static void updateCustomSettingOnDelete(List<Property__c> propertyList){
        
        //KillSwitch records list to update.
        List<Killswitch__c> killSwitchtoUpdate = new List<Killswitch__c>();
        
        //Query Killswitch__c Custom setting records.
        List<Killswitch__c> killSwitchRecords = [SELECT Id, SetupOwnerId, Killswitch_Enabled__c 
                                                 FROM Killswitch__c];
        //Loop over propertyList.
        for(Property__c prop : propertyList){
            if((prop.Property_Id__c).equalsIgnoreCase(Label.KillSwitch)){
                if(killSwitchRecords.size() > 0){
                    for(Killswitch__c kill : killSwitchRecords){
                        //Update existing record.
                        kill.Killswitch_Enabled__c = false;
                        killSwitchtoUpdate.add(kill);
                    }
                }
            }
        }
        
        //Update DML.
        if(killSwitchtoUpdate.size()>0){
            update killSwitchtoUpdate;
        }
    }
}