global class BatchCaseRelatedObjectUpdate implements Database.Batchable<SObject>, Database.Stateful {
       
    global final String query;
    global string Summary;
    // Constructor  
     global boolean SendBatchCompleteNotification;
    global string ToEmail;
    public BatchCaseRelatedObjectUpdate(String strSOQLWhereClause, boolean blnSendBatchCompleteNotification, string strToEmail)  
    {
      query = 'SELECT ID FROM case WHERE Is_Migrated_Openlane_Case__c = true '+strSOQLWhereClause;  
      Summary='';
      ToEmail = strToEmail;
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
           List<Case> ListKARCase = (List<Case>) scope;
           //System.debug('>>>> ListKARCase:'+ListKARCase);
           if(ListKARCase.size() == 0)
           {
                return;
           }
           
           //2. Get Ids of Case who migrated from openlane
            List<String> List_KAR_Case_Id = new List<String>();
            for(Case c: ListKARCase){
                List_KAR_Case_Id.Add(c.Id);         
            }
            //System.debug('>>>> List_KAR_Case_Id:'+List_KAR_Case_Id);
            
            //3. Get List of Openlane Case belongs to 200 records 
            List<Temp_Openlane_KAR_Case_Mapper__c> ListOpenlaneCasesMapper = [SELECT Migrated_Openlane_Case_Original_id__c,Migrated_Openlane_Case_KAR_id__c,ID FROM Temp_Openlane_KAR_Case_Mapper__c WHERE Migrated_Openlane_Case_KAR_id__c IN :List_KAR_Case_Id];
            
            
            // 4. Get List of Openlane_id to search in all object 
            
            List<Id> ListMigratedOpenlaneCaseId = new List<Id>();
            
            Map<String,String>  mapOpenlaneCaseIdToKARCaseId = new Map<String, String>(); 
            Map<String,String>  mapOpenlaneCaseNoToKARCaseId = new Map<String, String>(); 
             
            for(Temp_Openlane_KAR_Case_Mapper__c oc: ListOpenlaneCasesMapper){
            
                ListMigratedOpenlaneCaseId.Add(oc.Migrated_Openlane_Case_Original_id__c);
                mapOpenlaneCaseIdToKARCaseId.put(oc.Migrated_Openlane_Case_Original_id__c,oc.Migrated_Openlane_Case_KAR_id__c);
            }
            
            
            List<Temp_Case_Comment__c> ListTempCaseComment = [SELECT Id, CommentBody__c,IsPublished__c,ParentId__c  FROM Temp_Case_Comment__c WHERE Is_Applied__c=false and ParentId__c IN :ListMigratedOpenlaneCaseId];
            List<CaseComment> ListCaseComment = new List<CaseComment>();
           
           // New Changes 
           Map<String,CaseComment>  mapTempCaseCommentIdToKARCaseComment = new Map<String, CaseComment>();
           //
           
            for(Temp_Case_Comment__c tcc: ListTempCaseComment){
                CaseComment cc = new CaseComment();
                cc.ParentId = mapOpenlaneCaseIdToKARCaseId.get(tcc.ParentId__c);
                cc.IsPublished = tcc.IsPublished__c;
                cc.CommentBody = tcc.CommentBody__c;
                ListCaseComment.Add(cc);
                
                tcc.Is_Applied__c = true;
                
                // New Changes 
                mapTempCaseCommentIdToKARCaseComment.put(tcc.Id,cc);
                //
            }
            
            Insert ListCaseComment; 
            
            // New Changes 
            for(Temp_Case_Comment__c tcc: ListTempCaseComment){
                
                CaseComment objCC = mapTempCaseCommentIdToKARCaseComment.get(tcc.Id);
                if(objCC!=null)
                {
                    tcc.KAR_Case_Comment_SF_Id__c = objCC.Id;
                }
            
            }
            //
            
            Update ListTempCaseComment;
            
            //Case Task 
            //List<Task> ListTask = [SELECT Id,Migrated_Openlane_Case_Original_id__c  FROM Task WHERE Migrated_Openlane_Case_Original_id__c IN :ListMigratedOpenlaneCaseId];
            
            //for(Task objTask: ListTask){
            //    objTask.WhatId = mapOpenlaneCaseIdToKARCaseId.get(objTask.Migrated_Openlane_Case_Original_id__c);
            //}
            
            //Update ListTask;
            
            // New Changes 
            // Make User List 
            List<User> ListKARUser = new List<User>();
            ListKARUser = [SELECT UserName, Id FROM User WHERE IsPortalEnabled=false];   
            Map<String,String>  mapKARUserNameToId = new Map<String, String>();         
            
            List<Property__c>  ListProperty = [select Property_Id__c, Property_Value__c from Property__c where Property_Id__c ='username.patch' LIMIT 1];   
            String UsernamePatch = '';
            
            //new
            List<Property__c>  ListProperty2 = [select Property_Id__c, Property_Value__c from Property__c where Property_Id__c ='sandbox.suffix' LIMIT 1];   
           
            if(ListProperty.size()>0)
            {               
                UsernamePatch = ListProperty[0].Property_Value__c;
                for(User obj: ListKARUser){
                    String strUsername = obj.Username;
                    //strUsername = strUsername.Replace('@',UsernamePatch);
                    strUsername = strUsername.Replace(UsernamePatch,'@');
                    //new 
                    if(ListProperty2.size()>0 && ListProperty2[0].Property_Value__c!='')
                    { 
                        strUsername = strUsername.Replace(ListProperty2[0].Property_Value__c,'');
                    }
                    mapKARUserNameToId.put(strUsername,obj.Id);
                }
                
            }else{
            
                for(User obj: ListKARUser){
                    mapKARUserNameToId.put(obj.Username,obj.Id);
                }
            }           
            
            // Action Package
            
            List<Action_Package__c> ListActionPackage = [SELECT Id,Migrated_Openlane_Case_Original_id__c,Op_AP_RecordType_NAME__c,Op_AP_Seller_Contact_LOGIN_ID__c,Op_VP_Approver_2_USERNAME__c,Op_AP_Director_Approver_USERNAME__c,Op_AP_VP_Approver_USERNAME__c,Op_AP_Manager_Approver_USERNAME__c  FROM Action_Package__c WHERE Migrated_Openlane_Case_Original_id__c IN :ListMigratedOpenlaneCaseId];
            
            //Make Contact List             
            Set<String> List_SellerContactLoginID = new Set<String>();    
            Set<String> List_AP_RecordTypes = new Set<String>();
            for(Action_Package__c objAP: ListActionPackage){
            
                if(objAP.Op_AP_Seller_Contact_LOGIN_ID__c !=null && objAP.Op_AP_Seller_Contact_LOGIN_ID__c!=''){  List_SellerContactLoginID.Add(objAP.Op_AP_Seller_Contact_LOGIN_ID__c);   }
                if(objAP.Op_AP_RecordType_NAME__c !=null && objAP.Op_AP_RecordType_NAME__c!=''){  List_AP_RecordTypes.Add(objAP.Op_AP_RecordType_NAME__c);   }
            
            }
            
            List<Contact> ListKARSellerContact = new List<Contact>();
            if(List_SellerContactLoginID.size()>0)
            {
                ListKARSellerContact = [SELECT Login_ID__c, Id FROM Contact WHERE Login_ID__c IN :List_SellerContactLoginID ];// LIMIT 1 ]; //Change Here before go in production
            }
            Map<String,String>  mapKARSellerContactLoginIdToContactId = new Map<String, String>();
            for(Contact obj: ListKARSellerContact){
                mapKARSellerContactLoginIdToContactId.put(obj.Login_ID__c,obj.Id);
            }
            
            //Make Record Type List
             List<RecordType> ListKAR_AP_RecordType = new List<RecordType>();
            if(List_AP_RecordTypes.size()>0)
            {
                ListKAR_AP_RecordType = [SELECT Name, Id, DeveloperName FROM RecordType WHERE SobjectType='Action_Package__c' AND Name IN :List_AP_RecordTypes ];           
            }
            Map<String,String>  mapKARRecordTypeNameToId = new Map<String, String>();
            for(RecordType obj: ListKAR_AP_RecordType){
                mapKARRecordTypeNameToId.put(obj.Name,obj.Id);
            }
            //
            
            for(Action_Package__c objAP: ListActionPackage){
                objAP.Case__c = mapOpenlaneCaseIdToKARCaseId.get(objAP.Migrated_Openlane_Case_Original_id__c);
        
                // New Changes 
                //Set Record Type 
                if(objAP.Op_AP_RecordType_NAME__c!=null && objAP.Op_AP_RecordType_NAME__c!='')
                {
                    String strRecordTypeId = mapKARRecordTypeNameToId.get(objAP.Op_AP_RecordType_NAME__c);
                    if(strRecordTypeId!=null && strRecordTypeId!='')
                    {
                        objAP.RecordTypeId = strRecordTypeId;
                    }       
                }
                
                // Manager_Approver__c 
                if(objAP.Op_AP_Manager_Approver_USERNAME__c!=null && objAP.Op_AP_Manager_Approver_USERNAME__c!='')
                {
                    String strUserId = mapKARUserNameToId.get(objAP.Op_AP_Manager_Approver_USERNAME__c);
                    if(strUserId!=null && strUserId!='')
                    {
                        objAP.Manager_Approver__c = strUserId;
                    }       
                }
                //Director_Approver__c
                if(objAP.Op_AP_Director_Approver_USERNAME__c!=null && objAP.Op_AP_Director_Approver_USERNAME__c!='')
                {
                    String strUserId = mapKARUserNameToId.get(objAP.Op_AP_Director_Approver_USERNAME__c);
                    if(strUserId!=null && strUserId!='')
                    {
                        objAP.Director_Approver__c = strUserId;
                    }       
                }
                //VP_Approver__c
                if(objAP.Op_AP_VP_Approver_USERNAME__c!=null && objAP.Op_AP_VP_Approver_USERNAME__c!='')
                {
                    String strUserId = mapKARUserNameToId.get(objAP.Op_AP_VP_Approver_USERNAME__c);
                    if(strUserId!=null && strUserId!='')
                    {
                        objAP.VP_Approver__c = strUserId;
                    }       
                }
                
                //VP_Approver_2__c
                if(objAP.Op_VP_Approver_2_USERNAME__c!=null && objAP.Op_VP_Approver_2_USERNAME__c!='')
                {
                    String strUserId = mapKARUserNameToId.get(objAP.Op_VP_Approver_2_USERNAME__c);
                    if(strUserId!=null && strUserId!='')
                    {
                        objAP.VP_Approver_2__c = strUserId;
                    }       
                }
                
                //Seller_Contact__c Contact 
                if(objAP.Op_AP_Seller_Contact_LOGIN_ID__c!=null && objAP.Op_AP_Seller_Contact_LOGIN_ID__c!='')
                {
                    String strContactId = mapKARSellerContactLoginIdToContactId.get(objAP.Op_AP_Seller_Contact_LOGIN_ID__c);
                    if(strContactId!=null && strContactId!='')
                    {
                        objAP.Seller_Contact__c = strContactId;
                    }       
                }
                //
        
            }
            
            Update ListActionPackage;
            
            List<Evidence_Request__c> ListEvidenceRequest = [SELECT Id,Migrated_Openlane_Case_Original_id__c  FROM Evidence_Request__c WHERE Migrated_Openlane_Case_Original_id__c IN :ListMigratedOpenlaneCaseId];
            
            for(Evidence_Request__c objEvidenceRequest: ListEvidenceRequest){
                objEvidenceRequest.Case__c = mapOpenlaneCaseIdToKARCaseId.get(objEvidenceRequest.Migrated_Openlane_Case_Original_id__c);
            }
            
            Update ListEvidenceRequest;
            
            List<Case_Escalation__c> ListCaseEscalation = [SELECT Id,Migrated_Openlane_Case_Original_id__c,Op_Escalation_Approver_USERNAME__c,Op_Escalation_Assigned_To_USERNAME__c  FROM Case_Escalation__c WHERE Migrated_Openlane_Case_Original_id__c IN :ListMigratedOpenlaneCaseId];
           
            System.debug('ListCaseEscalation:'+ListCaseEscalation);
            
            /*
            List<User> ListKARUser = new List<User>();
            ListKARUser = [SELECT UserName, Id FROM User WHERE IsPortalEnabled=false];
            Map<String,String>  mapKARUserNameToId = new Map<String, String>();
            for(User obj: ListKARUser){
                mapKARUserNameToId.put(obj.Username,obj.Id);
            }
            */          
            
            
            for(Case_Escalation__c objCaseEscalation : ListCaseEscalation){
                objCaseEscalation.Case__c = mapOpenlaneCaseIdToKARCaseId.get(objCaseEscalation.Migrated_Openlane_Case_Original_id__c);
                // Approver__c 
                if(objCaseEscalation.Op_Escalation_Approver_USERNAME__c!=null && objCaseEscalation.Op_Escalation_Approver_USERNAME__c!='')
                {
                    String strUserId = mapKARUserNameToId.get(objCaseEscalation.Op_Escalation_Approver_USERNAME__c);
                    if(strUserId!=null && strUserId!='')
                    {
                        objCaseEscalation.Approver__c = strUserId;
                    }                   
                    
                }
                // Assigned_To__c
                if(objCaseEscalation.Op_Escalation_Assigned_To_USERNAME__c!=null && objCaseEscalation.Op_Escalation_Assigned_To_USERNAME__c!='')
                {
                    String strUserId = mapKARUserNameToId.get(objCaseEscalation.Op_Escalation_Assigned_To_USERNAME__c);
                    if(strUserId!=null && strUserId!='')
                    {
                        objCaseEscalation.Assigned_To__c = strUserId;
                    }                   
                    
                }               
            }           
            Update ListCaseEscalation;
            
            
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
            //mail.setReplyTo('salesforceemails@openlane.com');
            mail.setSenderDisplayName('Salesforce Support - Batch Complete Notification');
            mail.setSubject('Finished processing BatchCaseRelatedObjectUpdate.'); 
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


//BatchCaseRelatedObjectUpdate objBatchCaseRelatedObjectUpdate = new BatchCaseRelatedObjectUpdate(' and Load__c=2',true,'Dipesh.patel@openlane.com');
//Database.executeBatch(objBatchCaseRelatedObjectUpdate);