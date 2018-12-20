global class KDM_BatchMigratedTaskFieldsUpdate implements Database.Batchable<SObject> , Database.Stateful{
       
    global final String query;  
    global string Summary;
    global boolean HideDummyDataToOwner; 
    global boolean SendBatchCompleteNotification;
    global string ToEmail;
    
    public KDM_BatchMigratedTaskFieldsUpdate(String CreatedDateStart,String CreatedDateEnd, boolean blnHideDummyDataToOwner , boolean blnSendBatchCompleteNotification, string strToEmail)  
    {      
      query = 'SELECT Is_OwnerId_Applied__c,Is_RecordType_Applied__c,Is_WhoId_Applied__c,Is_WhatId_Applied__c, Op_Task_SF_ID__c,Op_Account_ATC_ORG_ID__c,Op_Contact_LOGIN_ID__c,Op_Case_SF_Id__c,Op_Owner_TYPE__c,Op_Owner_USERNAME__c,Op_RecordTypeId__c,Op_RecordType_NAME__c,Op_WhatId__c,Op_WhatType__c,Op_WhoId__c,Op_WhoType__c FROM Activity_Detail__c WHERE Op_Task_SF_ID__c!= \'\' AND Is_Migration_Details_Applied_to_Task__c=false and (Op_CreatedDate__c >= '+CreatedDateStart+' AND Op_CreatedDate__c < '+CreatedDateEnd+')';
      Summary='';
      HideDummyDataToOwner = blnHideDummyDataToOwner;
       ToEmail = strToEmail;
      SendBatchCompleteNotification = blnSendBatchCompleteNotification;
      System.debug('>> Constructor HideDummyDataToOwner:'+HideDummyDataToOwner);
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) 
    {
        System.debug('>> Inside HideDummyDataToOwner:'+HideDummyDataToOwner);
        try{
           //1. Get List of 200 Records
           List<Activity_Detail__c> ListActivityDetails = (List<Activity_Detail__c>) scope;
           if(ListActivityDetails.size() == 0)
           {
                return;
           }
            
            //2. Make List 
            // WhoId --> Contact , Lead             
            Set<String> ListContactLoginId = new Set<String>();
            Set<String> List_Op_Account_ATC_ORG_ID = new Set<String>();
            Set<String> List_Op_Owner_USERNAME = new Set<String>();
            Set<String> List_Op_Case_Id = new Set<String>();
            Set<String> ListOpTaskIds = new Set<String>();
            Set<String> List_Op_RecordType_NAME = new Set<String>();
            Map<String,Activity_Detail__c>  map_Op_Task_SF_ID_To_ActivityDetail = new Map<String, Activity_Detail__c>();
            
            // Generate List 
            for(Activity_Detail__c ObjActivityDetail: ListActivityDetails){
                // FOr Contact 
                if(ObjActivityDetail.Op_Contact_LOGIN_ID__c!=null && ObjActivityDetail.Op_Contact_LOGIN_ID__c!='')
                {
                    ListContactLoginId.Add(ObjActivityDetail.Op_Contact_LOGIN_ID__c);
                }
                // FOr Lead  
                
                // For Account
                if(ObjActivityDetail.Op_Account_ATC_ORG_ID__c!=null && ObjActivityDetail.Op_Account_ATC_ORG_ID__c!='')
                {
                    List_Op_Account_ATC_ORG_ID.Add(ObjActivityDetail.Op_Account_ATC_ORG_ID__c);
                }                
                // For Case 
                if(ObjActivityDetail.Op_Case_SF_Id__c!=null && ObjActivityDetail.Op_Case_SF_Id__c!='')
                {
                    List_Op_Case_Id.Add(ObjActivityDetail.Op_Case_SF_Id__c);
                }
                // For Record Type 
                if(ObjActivityDetail.Op_RecordType_NAME__c!=null && ObjActivityDetail.Op_RecordType_NAME__c!='')
                {
                    List_Op_RecordType_NAME.Add(ObjActivityDetail.Op_RecordType_NAME__c);
                }
                // For User
                if(ObjActivityDetail.Op_Owner_USERNAME__c!=null && ObjActivityDetail.Op_Owner_USERNAME__c!='')
                {
                    List_Op_Owner_USERNAME.Add(ObjActivityDetail.Op_Owner_USERNAME__c);
                }
                // For OpTaskId 
                if(ObjActivityDetail.Op_Task_SF_ID__c!=null && ObjActivityDetail.Op_Task_SF_ID__c!='')
                {
                    ListOpTaskIds.Add(ObjActivityDetail.Op_Task_SF_ID__c);
                    map_Op_Task_SF_ID_To_ActivityDetail.put(ObjActivityDetail.Op_Task_SF_ID__c,ObjActivityDetail);
                }               
            }
            
            //2. Make Map
            Map<String,String>  mapKARUserNameToId = new Map<String, String>();
            Map<String,String>  mapKARContactLoginIdToId = new Map<String, String>();
            Map<String,String>  mapATC_OrgId_To_KARAccountId = new Map<String, String>();
            Map<String,String>  mapATC_OrgId_To_KARAdesaId = new Map<String, String>();
            Map<String,String>  mapOpenlaneCaseIdToKARCaseId = new Map<String, String>(); 
            Map<String,String>  mapOp_RTName_To_KAR_RTId = new Map<String, String>(); 
            Map<String,String>  mapOpenlaneTaskIdToKARTaskId = new Map<String, String>(); 
            
            // For Task 
            List<Task> ListKARTask = new List<Task>();
            if(ListOpTaskIds.size()>0)
            {
                ListKARTask = [SELECT Id,Openlane_Task_SF_ID__c FROM Task WHERE Openlane_Task_SF_ID__c IN :ListOpTaskIds];
            }
            for(Task objTask: ListKARTask){
                mapOpenlaneTaskIdToKARTaskId.put(objTask.Openlane_Task_SF_ID__c,objTask.Id);             
            } 
            
            if(ListKARTask.size()==0)
            {
                return;
            }
            
            // New Changes for Username 
            List<Property__c>  ListProperty = [select Property_Id__c, Property_Value__c from Property__c where Property_Id__c ='username.patch' LIMIT 1];   
            
            //new
            List<Property__c>  ListProperty2 = [select Property_Id__c, Property_Value__c from Property__c where Property_Id__c ='sandbox.suffix' LIMIT 1];   
           
           
            Set<String> List_UserName_for_SOQL = new Set<String>();
            if(ListProperty.size()>0)
            {               
                String UsernamePatch = '';
                UsernamePatch = ListProperty[0].Property_Value__c;                
                for(String strUsername: List_Op_Owner_USERNAME){
                    strUsername = strUsername.Replace('@',UsernamePatch);   
                    //new 
                     
                    if(ListProperty2.size()>0 && ListProperty2[0].Property_Value__c!='')
                    {
                        strUsername=strUsername+ListProperty2[0].Property_Value__c;
                    }                   
                    List_UserName_for_SOQL.Add(strUsername);
                }                
            }else{            
                for(String strUsername: List_Op_Owner_USERNAME){                                    
                    List_UserName_for_SOQL.Add(strUsername);
                }  
            }  
            
            // For OwerId 
            List_UserName_for_SOQL.Add(Utils.getMigratedCaseDefaultOwnerUserName('migrated.case.default.owner.username'));            
            List<User> ListKARUser = [SELECT UserName, Id FROM User where UserName IN :List_UserName_for_SOQL];  
            
            //==
            if(ListProperty.size()>0)
            {    
                String UsernamePatch = '';
                UsernamePatch = ListProperty[0].Property_Value__c;
                String strDefaultOwnerUserName = Utils.getMigratedCaseDefaultOwnerUserName('migrated.case.default.owner.username');
                for(User obj: ListKARUser){
                    String strUsername = obj.Username;
                    if(!strUsername.EqualsIgnorecase(strDefaultOwnerUserName))
                     {
                        strUsername = strUsername.Replace(UsernamePatch,'@');
                        //new 
                        if(ListProperty2.size()>0 && ListProperty2[0].Property_Value__c!='')
                        { 
                            strUsername = strUsername.Replace(ListProperty2[0].Property_Value__c,'');
                        }
                     }
                    mapKARUserNameToId.put(strUsername,obj.Id);
                }
                
            }else{
            
                for(User obj: ListKARUser){
                    mapKARUserNameToId.put(obj.Username,obj.Id);
                }
            } 
            //==
            // New Changes for Username End 
            
            //for(User obj: ListKARUser){
            //    mapKARUserNameToId.put(obj.Username,obj.Id);
            //}           
            String strDefaultOwnerId = mapKARUserNameToId.get(Utils.getMigratedCaseDefaultOwnerUserName('migrated.case.default.owner.username'));
            System.debug('>>>strDefaultOwnerId: '+strDefaultOwnerId);
            System.debug('>>>mapKARUserNameToId: '+mapKARUserNameToId);
            
            
            // FOr Contact 
            List<Contact> ListKARContact = new List<Contact>();
            if(ListContactLoginId.size()>0)
            {
                ListKARContact = [SELECT Login_Id__c, Id FROM Contact WHERE Login_Id__c IN :ListContactLoginId];            
            }
            for(Contact c: ListKARContact){         
                mapKARContactLoginIdToId.put(c.Login_Id__c,c.Id);
            }
            
            System.debug('>>>mapKARContactLoginIdToId: '+mapKARContactLoginIdToId);
            
            // FOr Lead
            String strDefaultLeadId = Utils.getMigratedTaskDefaultLeadId('migrated.case.default.lead.id');            
            // FOr Account / Adesa  
            List<Adesa_com_Detail__c> ListAdesaDetail_For_Account = new List<Adesa_com_Detail__c>();
            if(List_Op_Account_ATC_ORG_ID.size()>0)
            {
                ListAdesaDetail_For_Account = [SELECT Id, ATC_Organization_ID__c, Account__c FROM Adesa_com_Detail__c WHERE ATC_Organization_ID__c IN : List_Op_Account_ATC_ORG_ID];
            }
            if(ListAdesaDetail_For_Account.size()>0)
            {
                for(Adesa_com_Detail__c objAdesaDetail :ListAdesaDetail_For_Account)
                {
                    mapATC_OrgId_To_KARAccountId.put(objAdesaDetail.ATC_Organization_ID__c,objAdesaDetail.Account__c);
                    mapATC_OrgId_To_KARAdesaId.put(objAdesaDetail.ATC_Organization_ID__c,objAdesaDetail.Id);
                }
            }
            System.debug('>>>mapATC_OrgId_To_KARAdesaId: '+mapATC_OrgId_To_KARAdesaId);
            
            //For Case 
            List<Temp_Openlane_KAR_Case_Mapper__c> ListOpenlaneCasesMapper = new List<Temp_Openlane_KAR_Case_Mapper__c>();
            if(List_Op_Case_Id.size()>0)
            {
                ListOpenlaneCasesMapper = [SELECT Migrated_Openlane_Case_Original_id__c,Migrated_Openlane_Case_KAR_id__c,ID FROM Temp_Openlane_KAR_Case_Mapper__c WHERE Migrated_Openlane_Case_Original_id__c IN :List_Op_Case_Id];
            }
            for(Temp_Openlane_KAR_Case_Mapper__c oc: ListOpenlaneCasesMapper){
                mapOpenlaneCaseIdToKARCaseId.put(oc.Migrated_Openlane_Case_Original_id__c,oc.Migrated_Openlane_Case_KAR_id__c);             
            }   
            System.debug('>>>mapOpenlaneCaseIdToKARCaseId: '+mapOpenlaneCaseIdToKARCaseId);
            
            // FOr Record Type  
            List<RecordType> ListKARTaskRecordType = new List<RecordType>();
            if(List_Op_RecordType_NAME.size()>0)
            {
                ListKARTaskRecordType = [SELECT Name, Id, DeveloperName FROM RecordType WHERE SobjectType='Task' AND Name IN :List_Op_RecordType_NAME ];              
            }
            for(RecordType r: ListKARTaskRecordType){         
                mapOp_RTName_To_KAR_RTId.put(r.Name,r.Id);
            }
            System.debug('>>>mapOp_RTName_To_KAR_RTId: '+mapOp_RTName_To_KAR_RTId);
            
            
            
            
            // Set All KAR Id 
            List<Activity_Detail__c> ListActivityDetailsToUpdate = new  List<Activity_Detail__c>();         
            for(Task ObjTask: ListKARTask){
            
                boolean IsWhoIdSet = false;
                boolean IsWhatIdSet = false;
                boolean IsRecordTypeSet = false;
                
               Activity_Detail__c objActivity_Detail = map_Op_Task_SF_ID_To_ActivityDetail.get(ObjTask.Openlane_Task_SF_ID__c);
               if(objActivity_Detail!=null)
               {
                    // Set Contact / Lead (may have / May not)
                    if(!objActivity_Detail.Is_WhoId_Applied__c)
                    {
                        if(objActivity_Detail.Op_WhoId__c!=null &&  objActivity_Detail.Op_WhoId__c!='')
                        {
                            if(objActivity_Detail.Op_WhoType__c.equalsIgnoreCase('CONTACT'))
                            {
                                string strWhoId = mapKARContactLoginIdToId.get(objActivity_Detail.Op_Contact_LOGIN_ID__c);
                                if(strWhoId!=null && strWhoId!='')
                                {
                                    ObjTask.whoid = strWhoId;                               
                                    objActivity_Detail.Is_WhoId_Applied__c = true;
                                }
                            }
                            else if(objActivity_Detail.Op_WhoType__c.equalsIgnoreCase('LEAD'))
                            {
                                ObjTask.whoid = strDefaultLeadId;                           
                                objActivity_Detail.Is_WhoId_Applied__c = true;
                            }                       
                        }
                        else
                        {                       
                            objActivity_Detail.Is_WhoId_Applied__c = true;
                        }
                    }
                    
                    
                    // Set Related to Account/Case  (may have / May not)
                    if(!objActivity_Detail.Is_WhatId_Applied__c)
                    {
                        if(objActivity_Detail.Op_WhatId__c!=null &&  objActivity_Detail.Op_WhatId__c!='')
                        {
                            if(objActivity_Detail.Op_WhatType__c.equalsIgnoreCase('ACCOUNT'))
                            {
                                //string strWhatId = mapATC_OrgId_To_KARAccountId.get(objActivity_Detail.Op_Account_ATC_ORG_ID__c);
                                string strWhatId = mapATC_OrgId_To_KARAdesaId.get(objActivity_Detail.Op_Account_ATC_ORG_ID__c);                                             
                                if(strWhatId!=null && strWhatId!='')
                                {
                                    ObjTask.whatid = strWhatId;
                                    objActivity_Detail.Is_WhatId_Applied__c = true;
                                    
                                }
                                
                            }
                            else if(objActivity_Detail.Op_WhatType__c.equalsIgnoreCase('CASE'))
                            {
                                string strWhatId = mapOpenlaneCaseIdToKARCaseId.get(objActivity_Detail.Op_Case_SF_Id__c);
                                if(strWhatId!=null && strWhatId!='')
                                {
                                    ObjTask.whatid = strWhatId;
                                    objActivity_Detail.Is_WhatId_Applied__c = true;
                                    
                                }                           
                            }
                        }
                        else
                        {
                            objActivity_Detail.Is_WhatId_Applied__c = true;
                            
                        }
                    }
                    
                    // Set Record Type 
                    if(!objActivity_Detail.Is_RecordType_Applied__c)
                    {
                        string strRecordTypeId = mapOp_RTName_To_KAR_RTId.get(objActivity_Detail.Op_RecordType_NAME__c);
                        if(strRecordTypeId!=null && strRecordTypeId!='')
                        {
                            ObjTask.RecordTypeId = strRecordTypeId;
                            objActivity_Detail.Is_RecordType_Applied__c = true;
                        }
                    }
                    
                    
                    if(HideDummyDataToOwner = false) // show owner dummy data also
                    {
                        // Set Owner (must have)                    
                        if(objActivity_Detail.Op_Owner_TYPE__c.equalsIgnoreCase('USER'))
                        {
                            string strOwnerId = mapKARUserNameToId.get(objActivity_Detail.Op_Owner_USERNAME__c);
                            if(strOwnerId!=null && strOwnerId!='')
                            {
                                ObjTask.ownerid = strOwnerId;
                                objActivity_Detail.Is_OwnerId_Applied__c = true;
                            }
                        }
                        else
                        {
                            if(strDefaultOwnerId!=null && strDefaultOwnerId!='')
                            {
                                ObjTask.ownerid = strDefaultOwnerId;
                                objActivity_Detail.Is_OwnerId_Applied__c = true;
                            }
                        }
                    }
                    else 
                    {
                        if (objActivity_Detail.Is_WhoId_Applied__c && objActivity_Detail.Is_WhatId_Applied__c && objActivity_Detail.Is_RecordType_Applied__c) // If each and every field set properly then set owner, so owner can see only valid task 
                        {
                            // Set Owner (must have)                    
                            if(objActivity_Detail.Op_Owner_TYPE__c.equalsIgnoreCase('USER'))
                            {
                                string strOwnerId = mapKARUserNameToId.get(objActivity_Detail.Op_Owner_USERNAME__c);
                                if(strOwnerId!=null && strOwnerId!='')
                                {
                                    ObjTask.ownerid = strOwnerId;
                                    objActivity_Detail.Is_OwnerId_Applied__c = true;
                                }
                            }
                            else
                            {
                                if(strDefaultOwnerId!=null && strDefaultOwnerId!='')
                                {
                                    ObjTask.ownerid = strDefaultOwnerId;
                                    objActivity_Detail.Is_OwnerId_Applied__c = true;
                                }
                            }
                        }
                    }
                    
                    if(objActivity_Detail.Is_OwnerId_Applied__c && objActivity_Detail.Is_RecordType_Applied__c && objActivity_Detail.Is_WhatId_Applied__c && objActivity_Detail.Is_WhoId_Applied__c)
                    {
                        objActivity_Detail.Is_Migration_Details_Applied_to_Task__c = true;
                    }
                    ListActivityDetailsToUpdate.Add(objActivity_Detail);
                    System.debug('>>> objActivity_Detail'+objActivity_Detail);
               }
            }
            //Update ListKARTask;
            Database.SaveResult[] srList1 = Database.update(ListKARTask, false);
            for (Database.SaveResult sr : srList1) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {                      
                        System.debug('>>> Error in Update ListKARTask: '+err.getStatusCode() + ': ' + err.getMessage());                        
                    }
                }
            }
            
            
            //Update ListActivityDetailsToUpdate;
            Database.SaveResult[] srList2 = Database.update(ListActivityDetailsToUpdate, false);
            for (Database.SaveResult sr : srList2) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {                      
                        System.debug('>>> Error in Update ListActivityDetailsToUpdate: '+err.getStatusCode() + ': ' + err.getMessage());                        
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
            mail.setSubject('Finished processing KDM_BatchMigratedTaskFieldsUpdate.'); 
            mail.setBccSender(false);
            mail.setUseSignature(false);              
            mail.sethtmlBody(Summary);    
            if(!Test.isRunningTest())
            {    
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
       } 
    }
   
}


//2011-08-23T21:57:52.000Z (First Records CreatedDate)
//2015-01-13T00:00:00Z (First time Exported Date)
// First time Run Batch (process only task upto 12-dec-2014 created date 
//KDM_BatchMigratedTaskFieldsUpdate objKDM_BatchMigratedTaskFieldsUpdate = new KDM_BatchMigratedTaskFieldsUpdate('2011-08-23T00:00:00Z','2014-12-13T00:00:00Z',true);
//Database.executeBatch(objKDM_BatchMigratedTaskFieldsUpdate);
//Second Time in kar.test 
//KDM_BatchMigratedTaskFieldsUpdate objKDM_BatchMigratedTaskFieldsUpdate = new KDM_BatchMigratedTaskFieldsUpdate('2014-12-12T00:00:00Z','2015-10-30T00:00:00Z',true,true,'Dipesh.patel@openlane.com');
//Database.executeBatch(objKDM_BatchMigratedTaskFieldsUpdate);