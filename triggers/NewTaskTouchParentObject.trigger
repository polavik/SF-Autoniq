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

trigger NewTaskTouchParentObject on Task (after insert) {
   //Get profile Id of Current User
   Id profileId = Userinfo.getProfileId();
   //Get KillSwitch record for the User's profileId.
   Killswitch__c killSwitch = Killswitch__c.getInstance(profileId);
   
   //Check for KillSwitch flag
   if(killSwitch == null || !killSwitch.Killswitch_Enabled__c){
        boolean IsMigrationRuning = false;   
        IsMigrationRuning = Utils.getIsMigrationRuning('is.migration.running');

        //Put these in maps to ensure that each object is only in there once
        Map<Id,Account> accountsToUpdate = new Map<Id,Account>();
        Map<Id,Lead> leadsToUpdate = new Map<Id,Lead>();
        Map<Id,Opportunity> oppsToUpdate = new Map<Id,Opportunity>();
        Map<Id,Campaign> campsToUpdate = new Map<Id,Campaign>();
        Map<Id,Contact> contsToUpdate = new Map<Id,Contact>();
        Map<Id,Contract> contrsToUpdate = new Map<Id,Contract>();
        Map<Id, Basic_Listing_Interest__c> bliToUpdate = new Map<Id, Basic_Listing_Interest__c>();
        Map<Id, Auction__c> auctionToUpdate = new Map<Id, Auction__c>();
        Map<Id, Best_Offers__c> boToUpdate = new Map<Id, Best_Offers__c>();
        
        for (Task tsk:System.Trigger.new) {
        
        // Added Condition for Task Records Migration (PPM#97274) (By djpatel - ADESA Canada Salesforce Team)
        if(!(IsMigrationRuning && tsk.Openlane_Task_SF_ID__c!=null && tsk.Openlane_Task_SF_ID__c!=''))
        {       
            //Only CTI would set the CallType field
            if (tsk.CallType!=null && tsk.CallType!='') {
                if (tsk.WhoId!=null) {
                    String whoId = tsk.WhoId;
                    String whoIdPrefix = whoId.substring(0,3);

                    if (whoIdPrefix.equalsIgnoreCase('00Q')) {
                        Lead lead = new Lead(Id=tsk.WhoId, Last_Activity_Datetime__c=System.now());

                        leadsToUpdate.put(tsk.WhoId, lead);
                    } else if (whoIdPrefix.equalsIgnoreCase('003')) {
                        Contact lead = new Contact(Id=tsk.WhoId, Last_Activity_Datetime__c=System.now());

                        contsToUpdate.put(tsk.WhoId, lead);
                    }
                }                
                if (tsk.WhatId!=null) {
                    String whatId = tsk.WhatId;
                    String whatIdPrefix = whatId.substring(0,3);
                    
					String keyPrefix_BLI  =  Basic_Listing_Interest__c.sObjectType.getDescribe().getKeyPrefix();
					String keyPrefix_BO	  =  Best_Offers__c.sObjectType.getDescribe().getKeyPrefix();
					String keyPrefix_Auc  =  Auction__c.sObjectType.getDescribe().getKeyPrefix();
					
                    //Only CTI would fill the CallType field
                    if (whatIdPrefix.equalsIgnoreCase('001')) {
                        // Story B-43665 [IAA Migration] Code refactoring to remove deprecated fields (Account.Last_Activity_Datetime__c)
                        //Account acc = new Account(Id=tsk.WhatId, Last_Activity_Datetime__c=System.now());
                        Account acc = new Account(Id=tsk.WhatId);

                        accountsToUpdate.put(tsk.WhatId, acc);
                    } else if (whatIdPrefix.equalsIgnoreCase('006')) {
                        Opportunity acc = new Opportunity(Id=tsk.WhatId, Last_Activity_Datetime__c=System.now());                   

                        oppsToUpdate.put(tsk.WhatId, acc);
                    } else if (whatIdPrefix.equalsIgnoreCase('701')) {
                        Campaign acc = new Campaign(Id=tsk.WhatId, Last_Activity_Datetime__c=System.now());

                        campsToUpdate.put(tsk.WhatId, acc);
                    } else if (whatIdPrefix.equalsIgnoreCase('800')) {
                        Contract acc = new Contract(Id=tsk.WhatId, Last_Activity_Datetime__c=System.now());

                        contrsToUpdate.put(tsk.WhatId, acc);
                        
//                     Apr/18/2017- 5A17  changed to current value , because 'a13' is not exsiting in this ORG    
                    } else if(whatIdPrefix.equalsIgnoreCase(keyPrefix_BLI)){
						System.debug('-----keyPrefix_Basic_Listing_Interest__c--' + keyPrefix_BLI );
                        Basic_Listing_Interest__c bli = new Basic_Listing_Interest__c(Id=tsk.WhatId, Last_Activity_Datetime__c=System.now());
                        bliToupdate.put(tsk.WhatId, bli);
//                     Apr/18/2017- 5A17  changed to current value , because 'a0n' is not exsiting in this ORG    
                    } else if(whatIdPrefix.equalsIgnoreCase(keyPrefix_BO)){
						System.debug('-----keyPrefix_Best_Offers__c--' + keyPrefix_BO );
                        Best_Offers__c bo = new Best_Offers__c(Id=tsk.WhatId, Last_Activity_Datetime__c=System.now());
                        boToupdate.put(tsk.WhatId, bo);
//                     Apr/18/2017- 5A17  changed to current value , because 'a0o' is not exsiting in this ORG    
                    }else if(whatIdPrefix.equalsIgnoreCase(keyPrefix_Auc)){
						System.debug('-----keyPrefix_Auction__c--' + keyPrefix_Auc );                    
                        Auction__c auc = new Auction__c(Id=tsk.WhatId, Last_Activity_Datetime__c=System.now());
                        auctionToupdate.put(tsk.WhatId, auc);
                    }
                }
            }
        }
        }
        
        if(oppsToUpdate.size() > 0){
           Set<Id> oppIds = oppsToUpdate.keySet();
           List<Opportunity> op = [select id, stageName
                                     from opportunity
                                    where id in :oppIds];
          for(Opportunity o: op){
             if(o.stageName.equals('Open')){
                o.stageName = 'Contact Attempted';
                
              }
              o.Last_Activity_Datetime__c=System.now();
              oppsToUpdate.put(o.id, o);

          }
        }

        try {
            if (accountsToUpdate.size()>0) {
                List<Account> accounts = accountsToUpdate.values();
                update accounts;
            }

            if (leadsToUpdate.size()>0) {
                List<Lead> leads = leadsToUpdate.values();
                update leads;
            }

            if (oppsToUpdate.size()>0) {
                List<Opportunity> opps = oppsToUpdate.values();
                
                update opps;
            }

            if (contsToUpdate.size()>0) {
                List<Contact> conts = contsToUpdate.values();
                update conts;
            }

            if (contrsToUpdate.size()>0) {
                List<Contract> contrs = contrsToUpdate.values();
                update contrs;
            }

            if (campsToUpdate.size()>0) {
                List<Campaign> camps = campsToUpdate.values();
                update camps;
            }
            if(bliToUpdate.size() > 0){
                List<Basic_Listing_Interest__c> basics = bliToUpdate.values();
                update basics;
            }
            if(auctionToUpdate.size()>0){
                List<Auction__c> auctions = auctionToUpdate.values();
                update auctions;
            }
            if(boToUpdate.size()>0){
                List<Best_Offers__c> bos = boToUpdate.values();
                update bos;
            }

        } catch (System.DmlException e) {
            System.debug('##DEBUGGING##' + e.getMessage());
        }
    }
}