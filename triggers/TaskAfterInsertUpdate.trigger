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

trigger TaskAfterInsertUpdate on Task (after insert, after update) {
  
  Id profileId = Userinfo.getProfileId();
   Killswitch__c killSwitch = Killswitch__c.getInstance(profileId);
   
   if(killSwitch == null || !killSwitch.Killswitch_Enabled__c){ 
    System.debug('>>> Trigger TaskAfterInsertUpdate started');
    
    //Tasks cannot have relationships with other objects, so we are forcing a relationship.
    List<Call_Outcome_Log__c> callOutcomeLogToInsert= new List<Call_Outcome_Log__c>();
    //List<Task> tasksToUpdate= new List<Task>();
    List<Activity_Detail__c > ListActivityDetailsToUpdate= new List<Activity_Detail__c>();
    Map<String,Call_Outcome_Log__c>  mapTaskId_To_CalOutcomeLog = new Map<String, Call_Outcome_Log__c>();
    
    Map<String,String>  mapTaskId_To_ADId = new Map<String, String>();
    Map<String,String>  mapADId_To_TaskId = new Map<String, String>();
    Map<String,Activity_Detail__c>  mapTaskId_To_AD = new Map<String, Activity_Detail__c>();
    
    List<Id> ListADIds = new List<Id>();
    for(Task t: Trigger.new)
    {
        Date hasSaleDate = null;
        Date hasSaleDate2 = null; 
         
        if(Trigger.isUpdate)
        {
            Task oldTask = Trigger.oldMap.get(t.Id);
            hasSaleDate = oldTask.Sale_Event_Date__c;            
        }
        
        //System.debug('>>> hasSaleDate: '+hasSaleDate);
        //System.debug('>>> t.Sale_Event_Date__c: '+t.Sale_Event_Date__c);
        //System.debug('>>> t.Activity_Detail__c: '+t.Activity_Detail__c);
        //System.debug('>>> ListADIds: '+ListADIds);
        
        if(t.Sale_Event_Date__c != null && hasSaleDate == null)
        {
            if(t.Activity_Detail__c!=null)
            {
                ListADIds.Add(t.Activity_Detail__c);
                //mapTaskId_To_ADId.put(t.id,t.Activity_Detail__c);
                mapADId_To_TaskId.put(t.Activity_Detail__c,t.id);
            }
        }
    }
    List<Activity_Detail__c > ListActivityDetails = [SELECT Id,Call_Outcome_Log_1_Link__c,Call_Outcome_Log_2_Link__c,Activity_Type1__c from Activity_Detail__c where id = :ListADIds];
    //System.debug('>>> ListActivityDetails: '+ListActivityDetails);
    for(Activity_Detail__c objAD: ListActivityDetails)
    {
        if(mapADId_To_TaskId.get(objAD.Id)!=null)
        {
            mapTaskId_To_AD.put( mapADId_To_TaskId.get(objAD.Id),objAD);
        }
    }
    
    for(Task t: Trigger.new)
    {
        Date hasSaleDate = null;
        Date hasSaleDate2 = null; 
         
        if(Trigger.isUpdate)
        {
            Task oldTask = Trigger.oldMap.get(t.Id);
            hasSaleDate = oldTask.Sale_Event_Date__c;            
        }
        if(t.Sale_Event_Date__c != null && hasSaleDate == null)
        {
            
            if(t.Activity_Detail__c!=null)
            {
                
                //List<Activity_Detail__c > ListActivityDetails = [SELECT Id from Activity_Detail__c where id = :t.Activity_Detail__c];
                Activity_Detail__c  objActivityDetails = mapTaskId_To_AD.get(t.Id);
                if(objActivityDetails!=null)
                {
                    Call_Outcome_Log__c col = new Call_Outcome_Log__c();
                    col.OwnerId = t.OwnerId;
                    col.Account__c = t.AccountId;
                    col.Auction__c = t.Auction__c ;
                    col.Buy_No_Commitment_Reasons__c = t.Buy_No_Commitment_Reasons__c;
                    col.Buy_Commitments__c = t.Buy_Commitments__c;
                    col.Comments__c = t.Description;
                    col.Consignors_Pitched__c = t.Institutional_Sellers_Pitched__c;
                    col.Customer_Type__c = t.Customert_Type__c;
                    //PPM 104790 (Remove below two fields and update with Activity Detail fields )
                    //col.Pride_Activity_Type__c = t.Pride_Activity_Type__c;
                    //col.Pride_Classification__c = t.Pride_Classification__c;
                    col.Activity_Type1__c = objActivityDetails.Activity_Type1__c;
                    //col.Activity_Type2__c = objActivityDetails.Activity_Type2__c;
                
                    
                    
                    col.Sale_Type__c = t.ADESA_Sale_Type__c;
                    col.Subject__c = t.Subject;
                    col.Task_Date_Time__c = t.CreatedDate;
                    col.Task_ID__c = t.Id;
                    col.sale_event_date__c = t.Sale_Event_Date__c;
                    if(t.WhoId != null)
                    {
                        String contactPrefix = Schema.SObjectType.Contact.getKeyPrefix();
                        String taskWhoId = t.WhoId;
                        //System.debug('who: ' + t.WhoId + ' prefix: ' + contactPrefix + ' eval: ' + taskWhoId.startsWith(contactPrefix) + ' id: ' + t.id );
                        if(taskWhoId.startsWith(contactPrefix))
                        {
                            col.Contact__c = t.WhoId;
                        }
                        else
                        {
                            col.Lead__c = t.WhoId;
                        }
                    }
                    callOutcomeLogToInsert.add(col);
                    mapTaskId_To_CalOutcomeLog.put(col.Task_ID__c,col);
                                        
                }
            }               
        }    
    
    }  
    //System.debug('>>> callOutcomeLogToInsert: '+callOutcomeLogToInsert);
    Database.insert(callOutcomeLogToInsert);    
    
    for(Call_Outcome_Log__c col: callOutcomeLogToInsert)
    {
        Activity_Detail__c  objActivityDetails = mapTaskId_To_AD.get(col.Task_ID__c);
        if(objActivityDetails!=null)
        {
            /*
            //System.debug('>>>Before set link ');            
            String CurrentUrlNode;      
            String HostURL = System.URL.getSalesforceBaseUrl().getHost().remove('https://' ).remove('http://' );
            // String HostURL = 'c.cs23.visual.force.com';                       
            //System.Debug('>>> HostURL :'+HostURL );                        
            Integer parts = HostURL.countMatches('.');                        
            //System.Debug('>>> countMatches:'+parts);
            // changed for check URL node dynamically e.g. na19, c.na19 
            if(parts== 2)
            {                        
                CurrentUrlNode = HostURL.substring(0,HostURL .indexOf('.',0));
            }else{        
                
                CurrentUrlNode = HostURL.substring(HostURL.indexOf('.',0)+1,HostURL.indexOf('.',2));
            }
            //System.Debug('>>> CurrentUrlNode :'+CurrentUrlNode );
            
            
            objActivityDetails.Call_Outcome_Log_1_Link__c = 'https://' +CurrentUrlNode +'.salesforce.com/' + col.id;
            */
            String HostURL = URL.getSalesforceBaseUrl().toExternalForm();
            objActivityDetails.Call_Outcome_Log_1_Link__c = HostURL + '/' + col.id;
            
            ListActivityDetailsToUpdate.Add(objActivityDetails);
        }
    }
    
    //System.debug('>>> ListActivityDetailsToUpdate'+ListActivityDetailsToUpdate);
    Database.update(ListActivityDetailsToUpdate);
    System.debug('>>> Trigger TaskAfterInsertUpdate End');
}
}