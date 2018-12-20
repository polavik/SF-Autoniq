global class KDM_BatchOpDealerProfileFieldsUpdate implements Database.Batchable<SObject>, Database.Stateful {
       
    global final String query;
    global string Summary;
    global boolean SendBatchCompleteNotification;
    global string ToEmail;
    global Integer CounterProcessRecords;
    global Integer CounterSuccessUpdateRecords;
    
    // Constructor  
    public KDM_BatchOpDealerProfileFieldsUpdate(String strSOQLWhereClause, boolean blnSendBatchCompleteNotification, string strToEmail)  
    {
      query = 'SELECT Id,Op_RecordType_NAME__c,Op_Account_ATC_ORG_ID__c,Op_Contact_LOGIN_ID__c,Op_Dealer_Profile_SF_ID__c,Op_DP_5a_Make_ID__c,Op_DP_5b_Model_ID__c,Op_DP_5d_Make_ID__c,Op_DP_5e_Model_ID__c,Op_DP_5g_Make_ID__c,Op_DP_5h_Model_ID__c,Op_DP_9a_Make_ID__c,Op_DP_9b_Model_ID__c,Op_DP_9d_Make_ID__c,Op_DP_9e_Model_ID__c,Op_DP_9g_Make_ID__c,Op_DP_9h_Model_ID__c FROM Survey__c '+strSOQLWhereClause;  
      Summary='';
      ToEmail = strToEmail;
      CounterProcessRecords=0;
      CounterSuccessUpdateRecords=0;
      SendBatchCompleteNotification = blnSendBatchCompleteNotification;
      System.debug('>>> query'+query);
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) 
    {
        try{
           //1. Get List of 200 Records
           List<Survey__c> List_DP = (List<Survey__c>) scope;           
           System.debug('>>> List_DP.size()'+List_DP.size());           
           if(List_DP.size() == 0)
           {
                return;
           }           
           Set<String> List_Op_Account_ATC_ORG_ID = new Set<String>();           
           Set<String> List_Op_RecordType_NAME = new Set<String>();
           Set<String> ListContactLoginId = new Set<String>();
           


           //1
           Set<String> List_Op_DP_5a_Make_ID = new Set<String>();
           Set<String> List_Op_DP_5b_Model_ID = new Set<String>();

           //2
           Set<String> List_Op_DP_5d_Make_ID = new Set<String>();
           Set<String> List_Op_DP_5e_Model_ID = new Set<String>();
            
            //3
           Set<String> List_Op_DP_5g_Make_ID = new Set<String>();
           Set<String> List_Op_DP_5h_Model_ID = new Set<String>();
           
           //4
           Set<String> List_Op_DP_9a_Make_ID = new Set<String>();
           Set<String> List_Op_DP_9b_Make_ID = new Set<String>();
           
           //5
           Set<String> List_Op_DP_9d_Make_ID = new Set<String>();
           Set<String> List_Op_DP_9e_Model_ID = new Set<String>();
           
           //6
           Set<String> List_Op_DP_9g_Make_ID = new Set<String>();
           Set<String> List_Op_DP_9h_Model_ID = new Set<String>();
           

           
           //2. Make List 
           for(Survey__c obj: List_DP)
           {
                // For Account
                if(obj.Op_Account_ATC_Org_ID__c!=null && obj.Op_Account_ATC_Org_ID__c!='')
                {   
                    List_Op_Account_ATC_ORG_ID.Add(obj.Op_Account_ATC_Org_ID__c);   
                }
                
                // For Record Type 
                if(obj.Op_RecordType_NAME__c!=null && obj.Op_RecordType_NAME__c!='')
                {
                    List_Op_RecordType_NAME.Add(obj.Op_RecordType_NAME__c);
                }
                
                // For Contact
                if(obj.Op_Contact_LOGIN_ID__c!=null && obj.Op_Contact_LOGIN_ID__c!='')
                {   
                    ListContactLoginId.Add(obj.Op_Contact_LOGIN_ID__c);   
                }
                
                 // For 1
                if(obj.Op_DP_5a_Make_ID__c!=null && obj.Op_DP_5a_Make_ID__c!='')
                {   
                    List_Op_DP_5a_Make_ID.Add(obj.Op_DP_5a_Make_ID__c);   
                }
                 if(obj.Op_DP_5b_Model_ID__c!=null && obj.Op_DP_5b_Model_ID__c!='')
                {   
                    List_Op_DP_5b_Model_ID.Add(obj.Op_DP_5b_Model_ID__c);   
                }
                
                
                 // For 2
                if(obj.Op_DP_5d_Make_ID__c!=null && obj.Op_DP_5d_Make_ID__c!='')
                {   
                    List_Op_DP_5d_Make_ID.Add(obj.Op_DP_5d_Make_ID__c);   
                }
                 if(obj.Op_DP_5e_Model_ID__c!=null && obj.Op_DP_5e_Model_ID__c!='')
                {   
                    List_Op_DP_5e_Model_ID.Add(obj.Op_DP_5e_Model_ID__c);   
                }
                
                 // For 3
                if(obj.Op_DP_5g_Make_ID__c!=null && obj.Op_DP_5g_Make_ID__c!='')
                {   
                    List_Op_DP_5g_Make_ID.Add(obj.Op_DP_5g_Make_ID__c);   
                }
                 if(obj.Op_DP_5h_Model_ID__c!=null && obj.Op_DP_5h_Model_ID__c!='')
                {   
                    List_Op_DP_5h_Model_ID.Add(obj.Op_DP_5h_Model_ID__c);   
                }
                
                 // For 4
                if(obj.Op_DP_9a_Make_ID__c!=null && obj.Op_DP_9a_Make_ID__c!='')
                {   
                    List_Op_DP_9a_Make_ID.Add(obj.Op_DP_9a_Make_ID__c);   
                }
                 if(obj.Op_DP_9b_Model_ID__c!=null && obj.Op_DP_9b_Model_ID__c!='')
                {   
                    List_Op_DP_9b_Make_ID.Add(obj.Op_DP_9b_Model_ID__c);   
                }
                
                 // For 5
                if(obj.Op_DP_9d_Make_ID__c!=null && obj.Op_DP_9d_Make_ID__c!='')
                {   
                    List_Op_DP_9d_Make_ID.Add(obj.Op_DP_9d_Make_ID__c);   
                }
                 if(obj.Op_DP_9e_Model_ID__c!=null && obj.Op_DP_9e_Model_ID__c!='')
                {   
                    List_Op_DP_9e_Model_ID.Add(obj.Op_DP_9e_Model_ID__c);   
                }
                
                 // For 6
                if(obj.Op_DP_9g_Make_ID__c!=null && obj.Op_DP_9g_Make_ID__c!='')
                {   
                    List_Op_DP_9g_Make_ID.Add(obj.Op_DP_9g_Make_ID__c);   
                }
                 if(obj.Op_DP_9h_Model_ID__c!=null && obj.Op_DP_9h_Model_ID__c!='')
                {   
                    List_Op_DP_9h_Model_ID.Add(obj.Op_DP_9h_Model_ID__c);   
                }               
           }
           
            // 3. Get Record of Object for that value  
            List<Adesa_com_Detail__c> ListAdesaDetail_For_Account = new List<Adesa_com_Detail__c>();
            if(List_Op_Account_ATC_ORG_ID.size()>0)
            {
                ListAdesaDetail_For_Account = [SELECT Id, ATC_Organization_ID__c, Account__c FROM Adesa_com_Detail__c WHERE ATC_Organization_ID__c IN : List_Op_Account_ATC_ORG_ID];
            }
            
            Map<String,String>  mapATC_OrgId_To_KARAccountId = new Map<String, String>();            
            
            if(ListAdesaDetail_For_Account.size()>0)
            {
                for(Adesa_com_Detail__c objAdesaDetail :ListAdesaDetail_For_Account)
                {
                    mapATC_OrgId_To_KARAccountId.put(objAdesaDetail.ATC_Organization_ID__c,objAdesaDetail.Account__c);                    
                }
            }
            
            // FOr Record Type  
            Map<String,String>  mapOp_RTName_To_KAR_RTId = new Map<String, String>(); 
            List<RecordType> ListKARTaskRecordType = new List<RecordType>();
            if(List_Op_RecordType_NAME.size()>0)
            {
                ListKARTaskRecordType = [SELECT Name, Id, DeveloperName FROM RecordType WHERE SobjectType='Survey__c' AND Name IN :List_Op_RecordType_NAME ];              
            }
            for(RecordType r: ListKARTaskRecordType){         
                mapOp_RTName_To_KAR_RTId.put(r.Name,r.Id);
            }
            
             // FOr Contact 
              Map<String,String>  mapKARContactLoginIdToId = new Map<String, String>();
            List<Contact> ListKARContact = new List<Contact>();
            if(ListContactLoginId.size()>0)
            {
                ListKARContact = [SELECT Login_Id__c, Id FROM Contact WHERE Login_Id__c IN :ListContactLoginId];            
            }
            for(Contact c: ListKARContact){         
                mapKARContactLoginIdToId.put(c.Login_Id__c,c.Id);
            }
            
            // For Vehicle Make 
            Map<String,String>  mapMakeID_To_Id = new Map<String, String>(); 
            List<Vehicle_Make__c> ListKARVehicle_Make = new List<Vehicle_Make__c>();
            if(List_Op_RecordType_NAME.size()>0)
            {
                ListKARVehicle_Make = [SELECT Make_ID__c, Id  FROM Vehicle_Make__c];              
            }
            for(Vehicle_Make__c vm: ListKARVehicle_Make){         
                mapMakeID_To_Id.put(String.valueOf(vm.Make_ID__c),vm.Id);
            }
            
            // For Vehicle Model 
            Map<String,String>  mapModelID_To_Id = new Map<String, String>(); 
            List<Vehicle_Model__c> ListKARVehicle_Model = new List<Vehicle_Model__c>();
            if(List_Op_RecordType_NAME.size()>0)
            {
                ListKARVehicle_Model = [SELECT Model_ID__c, Id  FROM Vehicle_Model__c];              
            }
            for(Vehicle_Model__c vm: ListKARVehicle_Model){         
                mapModelID_To_Id.put(String.valueOf(vm.Model_ID__c),vm.Id);
            }
            
            //4. Set field 
            string strUserId ='';
            for(Survey__c obj: List_DP)
            {
                //For Account                 
                if(obj.Op_Account_ATC_Org_ID__c!=null && obj.Op_Account_ATC_Org_ID__c!='')
                {
                     string strAccountId = mapATC_OrgId_To_KARAccountId.get(obj.Op_Account_ATC_Org_ID__c);                                             
                     if(strAccountId!=null && strAccountId!='')
                     {
                         obj.Account__c = strAccountId; 
                         
                     }   
                    
                 }
                // Set Record Type 
                if(obj.Op_RecordType_NAME__c!=null && obj.Op_RecordType_NAME__c!='')
                {
                    string strRecordTypeId = mapOp_RTName_To_KAR_RTId.get(obj.Op_RecordType_NAME__c);
                    if(strRecordTypeId!=null && strRecordTypeId!='')
                    {
                        obj.RecordTypeId = strRecordTypeId;
                    }
                }
                
                 //FOr Contact 
                if(obj.Op_Contact_LOGIN_ID__c!=null && obj.Op_Contact_LOGIN_ID__c!='')
                {
                    string strContactId = mapKARContactLoginIdToId.get(obj.Op_Contact_LOGIN_ID__c);
                    if(strContactId!=null && strContactId!='')
                    {
                        obj.Contact__c = strContactId;                                                       
                    }                     
                 }
                 
                // Set 1
                if(obj.Op_DP_5a_Make_ID__c!=null && obj.Op_DP_5a_Make_ID__c!='')
                {
                    string strId = mapMakeID_To_Id.get(obj.Op_DP_5a_Make_ID__c);
                    if(strId!=null && strId!='')
                    {
                        obj.DP_5a__c = strId;
                    }
                }
                if(obj.Op_DP_5b_Model_ID__c!=null && obj.Op_DP_5b_Model_ID__c!='')
                {
                    string strId = mapModelID_To_Id.get(obj.Op_DP_5b_Model_ID__c);
                    if(strId!=null && strId!='')
                    {
                        obj.DP_5b__c = strId;
                    }
                }
                
                // Set 2
                if(obj.Op_DP_5d_Make_ID__c!=null && obj.Op_DP_5d_Make_ID__c!='')
                {
                    string strId = mapMakeID_To_Id.get(obj.Op_DP_5d_Make_ID__c);
                    if(strId!=null && strId!='')
                    {
                        obj.DP_5d__c = strId;
                    }
                }
                if(obj.Op_DP_5e_Model_ID__c!=null && obj.Op_DP_5e_Model_ID__c!='')
                {
                    string strId = mapModelID_To_Id.get(obj.Op_DP_5e_Model_ID__c);
                    if(strId!=null && strId!='')
                    {
                        obj.DP_5e__c = strId;
                    }
                }
                
                // Set 3
                if(obj.Op_DP_5g_Make_ID__c!=null && obj.Op_DP_5g_Make_ID__c!='')
                {
                    string strId = mapMakeID_To_Id.get(obj.Op_DP_5g_Make_ID__c);
                    if(strId!=null && strId!='')
                    {
                        obj.DP_5g__c = strId;
                    }
                }
                if(obj.Op_DP_5h_Model_ID__c!=null && obj.Op_DP_5h_Model_ID__c!='')
                {
                    string strId = mapModelID_To_Id.get(obj.Op_DP_5h_Model_ID__c);
                    if(strId!=null && strId!='')
                    {
                        obj.DP_5h__c = strId;
                    }
                }
                
                // Set 4
                if(obj.Op_DP_9a_Make_ID__c!=null && obj.Op_DP_9a_Make_ID__c!='')
                {
                    string strId = mapMakeID_To_Id.get(obj.Op_DP_9a_Make_ID__c);
                    if(strId!=null && strId!='')
                    {
                        obj.DP_9a__c = strId;
                    }
                }
                if(obj.Op_DP_9b_Model_ID__c!=null && obj.Op_DP_9b_Model_ID__c!='')
                {
                    string strId = mapModelID_To_Id.get(obj.Op_DP_9b_Model_ID__c);
                    if(strId!=null && strId!='')
                    {
                        obj.DP_9b__c = strId;
                    }
                }
                
                // Set 5
                if(obj.Op_DP_9d_Make_ID__c!=null && obj.Op_DP_9d_Make_ID__c!='')
                {
                    string strId = mapMakeID_To_Id.get(obj.Op_DP_9d_Make_ID__c);
                    if(strId!=null && strId!='')
                    {
                        obj.DP_9d__c = strId;
                    }
                }
                if(obj.Op_DP_9e_Model_ID__c!=null && obj.Op_DP_9e_Model_ID__c!='')
                {
                    string strId = mapModelID_To_Id.get(obj.Op_DP_9e_Model_ID__c);
                    if(strId!=null && strId!='')
                    {
                        obj.DP_9e__c = strId;
                    }
                }
                
                // Set 6
                if(obj.Op_DP_9g_Make_ID__c!=null && obj.Op_DP_9g_Make_ID__c!='')
                {
                    string strId = mapMakeID_To_Id.get(obj.Op_DP_9g_Make_ID__c);
                    if(strId!=null && strId!='')
                    {
                        obj.DP_9g__c = strId;
                    }
                }
                if(obj.Op_DP_9h_Model_ID__c!=null && obj.Op_DP_9h_Model_ID__c!='')
                {
                    string strId = mapModelID_To_Id.get(obj.Op_DP_9h_Model_ID__c);
                    if(strId!=null && strId!='')
                    {
                        obj.DP_9h__c = strId;
                    }
                }
                
                CounterProcessRecords+=1;               
            }
            
             //Update ListActivityDetailsToUpdate;
            Database.SaveResult[] srList = Database.update(List_DP, false);
            for (Database.SaveResult sr : srList) {
                CounterSuccessUpdateRecords+=1;
                if (!sr.isSuccess()){
                    CounterSuccessUpdateRecords-=1;
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {                      
                        System.debug('>>> Error in Update Territory : '+err.getStatusCode() + ': ' + err.getMessage());                        
                    }
                }
            }
          
            
        }
        catch (Exception e)
        {
            System.debug('>>>> Error:'+e);
            Summary+='Error Detail : '+e.getmessage()+'<br/><br/>';
        }
        
    }
    
    global void finish(Database.BatchableContext bc) 
    {
        if(SendBatchCompleteNotification)
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            String[] toAddresses = new String[] {ToEmail}; 
            mail.setToAddresses(toAddresses);           
            mail.setSenderDisplayName('Salesforce Support - Batch Complete Notification');
            mail.setSubject('Finished processing KDM_BatchOpDealerProfileFieldsUpdate.'); 
            mail.setBccSender(false);
            mail.setUseSignature(false);
            Summary+='<br/><br/> Organization Id: ' + Userinfo.getOrganizationId();
            Summary+='<br/><br/> Organization Name: ' + Userinfo.getOrganizationName() +' ('+ URL.getSalesforceBaseUrl().getHost().substring(0,URL.getSalesforceBaseUrl().getHost().indexOf('.',0)).toUpperCase() +')';
            
            Summary+='<br/> ---------------------------- ';
            Summary+='<br/><br/>   Processed Records: ' + String.valueOf(CounterProcessRecords);
            Summary+='<br/>   Success Update Records: ' + String.valueOf(CounterSuccessUpdateRecords);
            Summary+='<br/>>> Fail to Update Records: ' + String.valueOf(CounterProcessRecords - CounterSuccessUpdateRecords);
            Summary+='<br/> ---------------------------- ';
            mail.sethtmlBody(Summary);
            if(!Test.isRunningTest())
            { 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
        
    }
   
}


//KDM_BatchOpDealerProfileFieldsUpdate objKDM_BatchOpDealerProfileFieldsUpdate = new KDM_BatchOpDealerProfileFieldsUpdate('where Op_Dealer_Profile_SF_ID__c!=\'\' ',true,'dipesh.patel@openlane.com');
//Database.executeBatch(objKDM_BatchOpDealerProfileFieldsUpdate);