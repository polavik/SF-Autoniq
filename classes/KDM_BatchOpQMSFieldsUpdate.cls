global class KDM_BatchOpQMSFieldsUpdate implements Database.Batchable<SObject>, Database.Stateful {
       
    global final String query;
    global string Summary;
    global boolean SendBatchCompleteNotification;
    global string ToEmail;
    global Integer CounterProcessRecords;
    global Integer CounterSuccessUpdateRecords;
    
    // Constructor  
    public KDM_BatchOpQMSFieldsUpdate(String strSOQLWhereClause, boolean blnSendBatchCompleteNotification, string strToEmail)  
    {
      query = 'SELECT Id,Op_RecordType_NAME__c,Op_Account_ATC_ORG_ID__c,Op_Account_Manager_USERNAME__c,Op_CC_Rep_USERNAME__c FROM Quality_Measurement_System__c where Is_Migrated_Record__c=true '+strSOQLWhereClause;  
      
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
           List<Quality_Measurement_System__c> List_QMS = (List<Quality_Measurement_System__c>) scope;           
           System.debug('>>> List_QMS.size()'+List_QMS.size());           
           if(List_QMS.size() == 0)
           {
                return;
           }           
           Set<String> List_Op_Account_ATC_ORG_ID = new Set<String>();
           Set<String> List_Op_Account_Manager_USERNAME = new Set<String>();
           Set<String> List_Op_CC_Rep_USERNAME = new Set<String>();
           Set<String> List_Op_RecordType_NAME = new Set<String>();
            
           //2. Make List 
           for(Quality_Measurement_System__c obj: List_QMS)
           {
                // For Account
                if(obj.Op_Account_ATC_Org_ID__c!=null && obj.Op_Account_ATC_Org_ID__c!='')
                {   
                    List_Op_Account_ATC_ORG_ID.Add(obj.Op_Account_ATC_Org_ID__c);   
                }
                // For User Account_Manager
                if(obj.Op_Account_Manager_USERNAME__c!=null && obj.Op_Account_Manager_USERNAME__c!='')
                {
                    List_Op_Account_Manager_USERNAME.Add(obj.Op_Account_Manager_USERNAME__c);
                }                 
                // For User CC_Rep
                if(obj.Op_CC_Rep_USERNAME__c!=null && obj.Op_CC_Rep_USERNAME__c!='')
                {
                    List_Op_CC_Rep_USERNAME.Add(obj.Op_CC_Rep_USERNAME__c);
                }
                // For Record Type 
                if(obj.Op_RecordType_NAME__c!=null && obj.Op_RecordType_NAME__c!='')
                {
                    List_Op_RecordType_NAME.Add(obj.Op_RecordType_NAME__c);
                }
                       
           }
           
            // 3. Get Record of Object for that value  
            List<Adesa_com_Detail__c> ListAdesaDetail_For_Account = new List<Adesa_com_Detail__c>();
            if(List_Op_Account_ATC_ORG_ID.size()>0)
            {
                ListAdesaDetail_For_Account = [SELECT Id, ATC_Organization_ID__c, Account__c FROM Adesa_com_Detail__c WHERE ATC_Organization_ID__c IN : List_Op_Account_ATC_ORG_ID];
            }
            
            Map<String,String>  mapATC_OrgId_To_KARAccountId = new Map<String, String>();
            Map<String,String>  mapATC_OrgId_To_KARAdesaId = new Map<String, String>();
            
            if(ListAdesaDetail_For_Account.size()>0)
            {
                for(Adesa_com_Detail__c objAdesaDetail :ListAdesaDetail_For_Account)
                {
                    mapATC_OrgId_To_KARAccountId.put(objAdesaDetail.ATC_Organization_ID__c,objAdesaDetail.Account__c);
                    mapATC_OrgId_To_KARAdesaId.put(objAdesaDetail.ATC_Organization_ID__c,objAdesaDetail.Id);
                }
            }
            
            // for Username map 
            List<Property__c>  ListProperty = [select Property_Id__c, Property_Value__c from Property__c where Property_Id__c ='username.patch' LIMIT 1];   
           
            Set<String> List_UserName_for_SOQL = new Set<String>();
            if(ListProperty.size()>0)
            {               
                String UsernamePatch = '';
                UsernamePatch = ListProperty[0].Property_Value__c;                
                for(String strUsername: List_Op_Account_Manager_USERNAME){
                    strUsername = strUsername.Replace('@',UsernamePatch);                    
                    List_UserName_for_SOQL.Add(strUsername);
                }    
                for(String strUsername: List_Op_CC_Rep_USERNAME){
                    strUsername = strUsername.Replace('@',UsernamePatch);                    
                    List_UserName_for_SOQL.Add(strUsername);
                }               
            }else{            
                for(String strUsername: List_Op_Account_Manager_USERNAME){                                    
                    List_UserName_for_SOQL.Add(strUsername);
                }  
                for(String strUsername: List_Op_CC_Rep_USERNAME){                                    
                    List_UserName_for_SOQL.Add(strUsername);
                }
            }  
            
            
            List_UserName_for_SOQL.Add(Utils.getMigratedCaseDefaultOwnerUserName('migrated.case.default.owner.username'));            
            List<User> ListKARUser = [SELECT UserName, Id FROM User where UserName IN :List_UserName_for_SOQL];  
             
            
            Map<String,String>  mapKARUserNameToId = new Map<String, String>();
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
                     }
                    mapKARUserNameToId.put(strUsername,obj.Id);
                }
                
            }else{
            
                for(User obj: ListKARUser){
                    mapKARUserNameToId.put(obj.Username,obj.Id);
                }
            } 
           
            String strDefaultOwnerId = mapKARUserNameToId.get(Utils.getMigratedCaseDefaultOwnerUserName('migrated.case.default.owner.username'));
            
            // FOr Record Type  
            Map<String,String>  mapOp_RTName_To_KAR_RTId = new Map<String, String>(); 
            List<RecordType> ListKARTaskRecordType = new List<RecordType>();
            if(List_Op_RecordType_NAME.size()>0)
            {
                ListKARTaskRecordType = [SELECT Name, Id, DeveloperName FROM RecordType WHERE SobjectType='Quality_Measurement_System__c' AND Name IN :List_Op_RecordType_NAME ];              
            }
            for(RecordType r: ListKARTaskRecordType){         
                mapOp_RTName_To_KAR_RTId.put(r.Name,r.Id);
            }
            
            //4. Set field 
            string strUserId ='';
            for(Quality_Measurement_System__c obj: List_QMS)
            {
                //For Account                 
                if(obj.Op_Account_ATC_Org_ID__c!=null && obj.Op_Account_ATC_Org_ID__c!='')
                {
                     string strAccountId = mapATC_OrgId_To_KARAccountId.get(obj.Op_Account_ATC_Org_ID__c);                                             
                     if(strAccountId!=null && strAccountId!='')
                     {
                         obj.AccountName__c = strAccountId; 
                         
                     }   
                    string strAdesaId = mapATC_OrgId_To_KARAdesaId.get(obj.Op_Account_ATC_Org_ID__c);                                             
                     if(strAdesaId!=null && strAdesaId!='')
                     {
                         obj.ADESA_com_Detail__c = strAdesaId;  
                     } 
                 }
                 
                // For User                  
                if(obj.Op_Account_Manager_USERNAME__c!=null && obj.Op_Account_Manager_USERNAME__c!='')
                {
                    strUserId = mapKARUserNameToId.get(obj.Op_Account_Manager_USERNAME__c);
                    if(strUserId!=null && strUserId!=''){
                        obj.amname__c = strUserId;
                    }
                    else
                    {
                        if(strDefaultOwnerId!=null && strDefaultOwnerId!='')
                        {
                            obj.amname__c = strDefaultOwnerId;
                        }
                    }
                    strUserId='';
                }
                // For User  CC_Rep
                if(obj.Op_CC_Rep_USERNAME__c!=null && obj.Op_CC_Rep_USERNAME__c!='')
                {
                    strUserId = mapKARUserNameToId.get(obj.Op_CC_Rep_USERNAME__c);
                    if(strUserId!=null && strUserId!=''){
                        obj.CC_Rep_Name__c = strUserId;
                    }
                    else
                    {
                        if(strDefaultOwnerId!=null && strDefaultOwnerId!='')
                        {
                            obj.CC_Rep_Name__c = strDefaultOwnerId;
                        }
                    }
                    strUserId='';
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
                CounterProcessRecords+=1;               
            }
            
             //Update ListActivityDetailsToUpdate;
            Database.SaveResult[] srList = Database.update(List_QMS, false);
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
            mail.setSubject('Finished processing KDM_BatchOpQMSFieldsUpdate.'); 
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
            if(!Test.isRunningTest() && !Sandbox.isSandbox())
            { 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
        
    }
   
}


//KDM_BatchOpQMSFieldsUpdate objKDM_BatchOpQMSFieldsUpdate = new KDM_BatchOpQMSFieldsUpdate('and Op_Load__c=1',true,'djpatel@openlane.com');
//Database.executeBatch(objKDM_BatchOpQMSFieldsUpdate);