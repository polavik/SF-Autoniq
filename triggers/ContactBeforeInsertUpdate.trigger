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

trigger ContactBeforeInsertUpdate on Contact (before insert, before update) {
  //Get profile Id of Current User
   Id profileId = Userinfo.getProfileId();
   //Get KillSwitch record for the User's profileId.
   Killswitch__c killSwitch = Killswitch__c.getInstance(profileId);
   
   //Check for KillSwitch flag
   if(killSwitch == null || !killSwitch.Killswitch_Enabled__c){
    String contactType = utils.getRecordTypeId('Contact', 'Contact');
    String parContactType = utils.getRecordTypeId('Contact', 'PAR Contact');
    for(Contact c: Trigger.new){
          //PPM103787 set contact record type
          if(c.recordtypeid == parContactType){
              //do nothing
          }else{
              c.recordtypeid = contactType;
          }
          
          if(c.Rep_Auction_Access_Number__c == '0' ){
             c.Rep_Auction_Access_Number__c = null;
          }
          c.Last_Login_PL_Update__c = false; //reset update field to false
          if(Trigger.isInsert){
            if(c.Last_Login_Time_to_PL__c != null)
                c.Last_Login_PL_Update__c = true;
          }else if(Trigger.isUpdate){
            Contact oldC = Trigger.oldMap.get(c.Id);
            if(oldC.Last_Login_Time_to_PL__c == null && c.Last_Login_Time_to_PL__c != null){
                c.Last_Login_PL_Update__c = true;
            }else if(c.Last_Login_Time_to_PL__c > oldC.Last_Login_Time_to_PL__c){
                c.Last_Login_PL_Update__c = true;
            }
          }
    }
    // Salesforce Gateway Code
    /*Set<String> gatewayUsers = Data_Gateway_Users__c.getAll().keySet();
    if(gatewayUsers == null || gatewayUsers.size() == 0 || gatewayUsers.contains(UserInfo.getUsername())){*/
        if(Data_Gateway_Users__c.getAll().keySet().contains(UserInfo.getUsername())){
        List<DataGatewayManager.GatewayViolation>  violationsList = new List<DataGatewayManager.GatewayViolation>();
        if(DataGatewayTriggerHelper.hasAlreadyFired()){
            DataGatewayTriggerHelper.resetTrigger();
        } else {
            DataGatewayTriggerHelper.setAlreadyFired();

            // Used to validate insert source and for MDM Service Invocation (Contact Verification and Update)
            if (Trigger.isInsert){
                if(!DataGatewayManager.sourceCanInsert('Contact')){
                    for(Contact a : Trigger.New){
                        DataGatewayManager.GatewayViolation gv = new DataGatewayManager.GatewayViolation(Trigger.new[0].Id,'Improper Insert User');
                        gv.reasonList.add(new DataGatewayManager.GatewayChange('Record', 'null', 'New'));
                        violationsList.add(gv);
                        a.addError('This user is not authorized to insert Contact records');        
                    }
                }
            } else if(Trigger.isUpdate){
                // Check for key field deletions.  If one is attempted, log a GatewayViolationNotification and roll back the update for that field.
                List<DataGatewayManager.GatewayViolation> keyFieldViolationList = DataGatewayManager.checkContactKeyFieldDeletion(Trigger.oldMap,Trigger.newMap);
                if(keyFieldViolationList.size() > 0){
                    for(DataGatewayManager.GatewayViolation gv : keyFieldViolationList){
                        for(DataGatewayManager.GatewayChange gc : gv.reasonList){
                          Trigger.newMap.get(gv.recordId).put(gc.field,Trigger.oldMap.get(gv.recordId).get(gc.field));                  
                        }
                    }
                }
                violationsList.addAll(keyFieldViolationList); // Add to the overall job violations list

                // Check for Flipping.  If the record is Flip Locked, prevent it and log a GatewayViolation.  If it is not, update the record and log a GatewayViolationNotification
                List<DataGatewayManager.GatewayViolation> flipViolationList = DataGatewayManager.checkContactFlipping(Trigger.oldMap,Trigger.newMap);
                // Used for unit testing.  Not relevant to production execution
                if(Test.isRunningTest()){
                    if(TestDataGatewayContact.currentTest == 'testMockWithViolations'){
                        DataGatewayManager.GatewayViolation gv = new DataGatewayManager.GatewayViolation(Trigger.new[0].Id,'Attribute Flipping');
                        DataGatewayManager.GatewayChange gc = new DataGatewayManager.GatewayChange('Rep_Auction_Access_Number__c', 'oldValue', 'newValue');
                        gv.reasonList.add(gc);                    
                        flipViolationList.clear();
                        flipViolationList.add(gv);
                    }
                }

                for(DataGatewayManager.GatewayViolation violation: flipViolationList){
                    // If the flip lock is set, then roll violation changes back and log the Violation as Declined
                    if(Trigger.newMap.get(violation.recordId).Gateway_Flip_Lock__c == true){
                        for(DataGatewayManager.GatewayChange reason : violation.reasonList){
                            Trigger.newMap.get(violation.recordId).put(reason.field,reason.oldValue);
                            violation.result = 'Update Declined';
                        }
                    // If the flip lock is not set, let the update happen and then set the Flip Lock, so no future updates can be made
                    } else {
                        violation.result = 'Update Applied';
                        Trigger.newMap.get(violation.recordId).Gateway_Flip_Lock__c = true;
                    }
                }            
                
                violationsList.addAll(flipViolationList); // Add to the overall job violations list
            }
            if(violationsList.size() > 0){
                Gateway_Violation__c gvRecord = new Gateway_Violation__c(User__c=UserInfo.getUserId(), Date_Time__c=System.now(), Number_of_Records__c=violationsList.size());
                gvRecord.Violations_Content__c = JSON.serialize(violationsList);
                insert gvRecord;       

                List<Gateway_Violation_Detail__c> gvdList = new List<Gateway_Violation_Detail__c>();
                for(DataGatewayManager.GatewayViolation gv : violationsList){
                    gvdList.add(new Gateway_Violation_Detail__c(
                                    Gateway_Violation__c=gvRecord.id,
                                    Salesforce_Record_Id__c=gv.recordId,
                                    Violation_Detail_Content__c=JSON.serialize(gv.reasonList)));
                }
                insert gvdList;
            }
        }
    }
    }
}