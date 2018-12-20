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

trigger ContactBeforeUpdate on Contact (before update) {
   //Get profile Id of Current User
   Id profileId = Userinfo.getProfileId();
   //Get KillSwitch record for the User's profileId.
   Killswitch__c killSwitch = Killswitch__c.getInstance(profileId);
   
   //Check for KillSwitch flag
   if(killSwitch == null || !killSwitch.Killswitch_Enabled__c){
        if (Trigger.isUpdate) {
    
            // Check Cosmos Sync pending checkbox if certain fields are changed
            ContactServices.checkForCosmosSync(Trigger.oldMap, Trigger.new);
    
             String afc1 = 'AFC'; //Assuming all AFC party ID starts with 'AFC'
             String f3SourceId = '';
             //Profile prof = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];        
             String name = UserInfo.getUserName();         
             for (Contact c : Trigger.new) {
                Contact oldContact = System.Trigger.oldMap.get(c.Id);
                //CMDM hierarch updating process for Contact
                // FirstName 
                // LastName 
                // Birthdate
                // Email 
                // MailingCity, MailingCountry, MailingState, MailingStreet, MailingPostalCode
                // Phone
                // Title 
                // Rep_Auction_Access_Number__c
             
                Boolean updateflag = true;  // Flag to determine if trigger is going to update those CMDM key fileds.
                Boolean afcct = false;
                f3SourceId = '';
                if (c.Source_Id__c != null && c.Source_Id__c != '' ){
                    f3SourceId = c.Source_Id__c.left(3).capitalize();
                    if  (f3SourceId == afc1){
                        afcct = true;   // AFC Contact
                    }
                }
                
              // ppm 101357 SF: Issues with Account Records being updated with incorrect information,apply same login on contact
              
                //if (c.Process_Identifier__c ==null||c.Process_Identifier__c =='' && prof.name!='System Administrator'){
                //if (c.Process_Identifier__c ==null||c.Process_Identifier__c =='' ){
                      if (!(name.startsWith('sfintegration       ')||name.startsWith('svc_ihub'))) {
                         updateflag = true;
                       }else if (c.Process_Identifier__c ==null||c.Process_Identifier__c =='' ){
                          updateflag = false;
                       }else if (c.Process_Identifier__c=='MDM'){                     
                           updateflag = true;     
                       //PPM105489    
                       //}else if (oldContact.Mdm_Id__c != Null && oldContact.Mdm_Id__c != ''){
                       //       updateflag = false;                          
                       }else if (c.Process_Identifier__c=='AFC' ){
                              updateflag = true;    
                       }else if ( c.Process_Identifier__c.startsWith('OPENLANE') && (oldContact.Source_Id__c == Null || oldContact.Source_Id__c == '' ||oldContact.Source_Id__c.left(3).capitalize() != afc1)) {
                              updateflag = true;                         
                       }else if(c.Process_Identifier__c=='IAA' && (oldContact.Person_ID__c == null || oldContact.Person_ID__c == '' )
                                &&(oldContact.Source_Id__c == Null || oldContact.Source_Id__c == '' || oldContact.Source_Id__c.left(3).capitalize() != afc1)){
                              updateflag = true;    
                       }else {
                              updateflag = false;                         
                       }
                       
                if (updateflag == false ){
                        //No MDM Key fields updating. Update incoming data with existing value
                        c.FirstName = oldContact.FirstName;
                        c.LastName = oldContact.LastName;
                        c.Birthdate = oldContact.Birthdate;
                        c.Email = oldContact.Email;
                        //Mailing Address
                        c.MailingCity = oldContact.MailingCity;
                        c.MailingCountry = oldContact.MailingCountry;
                        c.MailingState = oldContact.MailingState;
                        c.MailingStreet = oldContact.MailingStreet;
                        c.MailingPostalCode = oldContact.MailingPostalCode;
                        //
                        c.Phone = oldContact.Phone;
                        c.Title = oldContact.Title;
                        c.Rep_Auction_Access_Number__c = oldContact.Rep_Auction_Access_Number__c;
    
                            
                }
            }
        }
        }
}