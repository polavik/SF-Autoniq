trigger ActivityDetailBeforeUpdate on Activity_Detail__c (before update) { //(after insert, after update) {
   
    System.debug('>>> Trigger ActivityDetailAfterInsertUpdate Started');
    
    List<Call_Outcome_Log__c> callOutcomeLogToInsert= new List<Call_Outcome_Log__c>();
    List<Task> ListTask = new List<Task>();
    List<Id> AD_Ids = new List<Id>();
    Map<String,Task>  mapADId_To_TaskObj = new Map<String, Task>();
    
    List<Activity_Detail__c > ListActivityDetailsToUpdate= new List<Activity_Detail__c>();
    Map<String,Call_Outcome_Log__c>  mapTaskId_To_CalOutcomeLog = new Map<String, Call_Outcome_Log__c>();
    Map<String,Activity_Detail__c>  mapTaskId_To_AD = new Map<String, Activity_Detail__c>();
    //get all AD ids 
    // retrieve all task where parent is this AD Ids 
    // make map that contains ADId_To_TaskObj
            
    for(Activity_Detail__c objAD: Trigger.new)
    {
    
    //System.debug('>>> objAD.Sale_Event_Date_2__c: '+objAD.Sale_Event_Date_2__c);
    //System.debug('>>> objAD.Call_Outcome_Log_2_Link__c : '+objAD.Call_Outcome_Log_2_Link__c );

        if(objAD.Sale_Event_Date_2__c!= null && objAD.Call_Outcome_Log_2_Link__c == null)
        {
            AD_Ids.Add(objAD.Id);            
            
        }
    }
    if(AD_Ids.size()<1)
    {
        System.debug('>>>No AD_Ids found ..exiting..');
        return;
    }
    
    ListTask = [SELECT Id,Activity_Detail__c,Subject,CreatedDate,WhoId,OwnerId,AccountId,Description,Customert_Type__c from Task WHERE Activity_Detail__c in :AD_Ids];
    
    if(ListTask.size()<1)
    {
        System.debug('>>>No ListTask found ..exiting..');
        return;
    }   
    
    for(Task t: ListTask)
    {
        mapADId_To_TaskObj.put(t.Activity_Detail__c,t);
    }
    
    //System.debug('>>>mapADId_To_TaskObj: '+mapADId_To_TaskObj);
        
    for(Activity_Detail__c objAD: Trigger.new)
    {             
        if(objAD.Sale_Event_Date_2__c!= null && objAD.Call_Outcome_Log_2_Link__c == null)
        {
            Task t = mapADId_To_TaskObj.get(objAD.Id);
            if(t!=null)
            {
                mapTaskId_To_AD.put(t.id,objAD);
                
                Call_Outcome_Log__c col = new Call_Outcome_Log__c();
                col.OwnerId = t.OwnerId;
                col.Account__c = t.AccountId;
                col.Auction__c = objAD.sharedresourceauction__c;
                col.Buy_No_Commitment_Reasons__c = objAD.Buy_No_Commitment_Reasons_2__c;
                col.Buy_Commitments__c = objAD.Buy_Commitments_2__c;
                col.Comments__c = t.Description;
                col.Consignors_Pitched__c = objAD.Consignors_Pitched_2__c;
                col.Customer_Type__c = t.Customert_Type__c;
                
                //col.Pride_Activity_Type__c = t.Pride_Activity_Type__c;
                //col.Pride_Classification__c = t.Pride_Classification__c;
                //PPM 104790 (Remove above two fields and use below two fields )
                col.Activity_Type1__c = objAD.Activity_Type2__c;
                //col.Activity_Type2__c = objAD.Activity_Type2__c;
                
                col.Sale_Type__c = objAD.ADESA_Sale_Type_2__c;
                col.Subject__c = t.Subject;
                col.Task_Date_Time__c = t.CreatedDate;
                col.Task_ID__c = t.Id;
                col.sale_event_date__c = objAD.Sale_Event_Date_2__c;
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
                
            }
        }
    }
    
    //System.debug('>>>callOutcomeLogToInsert: '+callOutcomeLogToInsert);
    
    Database.insert(callOutcomeLogToInsert);
    //Database.update(tasksToUpdate); 
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
            
            
            objActivityDetails.Call_Outcome_Log_2_Link__c = 'https://' +CurrentUrlNode +'.salesforce.com/' + col.id;
			*/
			String HostURL = URL.getSalesforceBaseUrl().toExternalForm();
            objActivityDetails.Call_Outcome_Log_2_Link__c =  HostURL + '/' + col.id;
			
            //ListActivityDetailsToUpdate.Add(objActivityDetails);
        }
    }
System.debug('>>> Trigger ActivityDetailAfterInsertUpdate End');
}