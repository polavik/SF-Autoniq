global class KDM_BatchMigrated_LCT_FieldsUpdate implements Database.Batchable<SObject> , Database.Stateful{
       
    global final String query;  
    global string Summary;
    
    global boolean SendBatchCompleteNotification;
    global string ToEmail;
    
    public KDM_BatchMigrated_LCT_FieldsUpdate(String strSOQLWhereClause, boolean blnSendBatchCompleteNotification, string strToEmail)  
    {      
      query = 'SELECT ID,OL_Account_ATC_ORG_ID__c,OL_Contact_Login_ID__c,OL_Owner_Username__c FROM LiveChatTranscript ';
      Summary='';
      ToEmail = strToEmail;
      SendBatchCompleteNotification = blnSendBatchCompleteNotification;
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) 
    {
        
        try{
           //1. Get List of 200 Records
           List<LiveChatTranscript> ListLiveChatTranscript = (List<LiveChatTranscript>) scope;
           if(ListLiveChatTranscript.size() == 0)
           {
                return;
           }      
           
            //2. Make List                      
            Set<String> ListContactLoginId = new Set<String>();
            Set<String> List_Op_Account_ATC_ORG_ID = new Set<String>();
            Set<String> List_Op_Owner_USERNAME = new Set<String>();
           
            // Generate List 
            for(LiveChatTranscript ObjLiveChatTranscript: ListLiveChatTranscript){
                // For Contact 
                if(ObjLiveChatTranscript.OL_Contact_Login_ID__c!=null && ObjLiveChatTranscript.OL_Contact_Login_ID__c!='')
                {
                    ListContactLoginId.Add(ObjLiveChatTranscript.OL_Contact_Login_ID__c);
                }
                
                // For Account
                if(ObjLiveChatTranscript.OL_Account_ATC_ORG_ID__c!=null && ObjLiveChatTranscript.OL_Account_ATC_ORG_ID__c!='')
                {
                    List_Op_Account_ATC_ORG_ID.Add(ObjLiveChatTranscript.OL_Account_ATC_ORG_ID__c);
                }
                
                // For User
                if(ObjLiveChatTranscript.OL_Owner_Username__c!=null && ObjLiveChatTranscript.OL_Owner_Username__c!='')
                {
                    List_Op_Owner_USERNAME.Add(ObjLiveChatTranscript.OL_Owner_Username__c);
                }                           
            }
            
            //2. Make Map
            Map<String,String>  mapKARUserNameToId = new Map<String, String>();
            Map<String,String>  mapKARContactLoginIdToId = new Map<String, String>();
            Map<String,String>  mapATC_OrgId_To_KARAccountId = new Map<String, String>();
            Map<String,String>  mapATC_OrgId_To_KARAdesaId = new Map<String, String>();
            
            
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
            System.debug('>>>mapATC_OrgId_To_KARAccountId: '+mapATC_OrgId_To_KARAccountId);
            
            
            // Set All KAR Id 
                    
            for(LiveChatTranscript ObjLiveChatTranscript: ListLiveChatTranscript){
                
               //FOr Contact 
                if(ObjLiveChatTranscript.OL_Contact_Login_ID__c!=null && ObjLiveChatTranscript.OL_Contact_Login_ID__c!='')
                {
                    string strContactId = mapKARContactLoginIdToId.get(ObjLiveChatTranscript.OL_Contact_Login_ID__c);
                    if(strContactId!=null && strContactId!='')
                    {
                        ObjLiveChatTranscript.ContactId = strContactId;                                                       
                    }                     
                }   
                // Set Account
                if(ObjLiveChatTranscript.OL_Account_ATC_ORG_ID__c!=null &&  ObjLiveChatTranscript.OL_Account_ATC_ORG_ID__c!='')
                {
                    string strAccId = mapATC_OrgId_To_KARAccountId.get(ObjLiveChatTranscript.OL_Account_ATC_ORG_ID__c);                                             
                    if(strAccId!=null && strAccId!='')
                    {
                        ObjLiveChatTranscript.AccountId = strAccId;                                   
                    }
                }
                string strOwnerId = mapKARUserNameToId.get(ObjLiveChatTranscript.OL_Owner_Username__c);
                if(strOwnerId!=null && strOwnerId!='')
                {
                    ObjLiveChatTranscript.ownerid = strOwnerId;                                
                }
                            
                
                System.debug('>>> ObjLiveChatTranscript'+ObjLiveChatTranscript);
               
            }
            //Update ListLiveChatTranscript;
            Database.SaveResult[] srList1 = Database.update(ListLiveChatTranscript, false);
            for (Database.SaveResult sr : srList1) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {                      
                        System.debug('>>> Error in Update ListLiveChatTranscript: '+err.getStatusCode() + ': ' + err.getMessage());                        
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
            mail.setSubject('Finished processing KDM_BatchMigrated_LCT_FieldsUpdate.'); 
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



//KDM_BatchMigrated_LCT_FieldsUpdate objKDM_BatchMigrated_LCT_FieldsUpdate = new KDM_BatchMigrated_LCT_FieldsUpdate('WHERE OL_LC_Trascript_SF_ID__c!=\'\' ',true,'Dipesh.patel@openlane.com');
//Database.executeBatch(objKDM_BatchMigrated_LCT_FieldsUpdate);