global class KDM_BatchOpSellerPermissionFieldUpdate implements Database.Batchable<SObject>, Database.Stateful {
       
    global final String query;
    global string Summary;
    global boolean SendBatchCompleteNotification;
    global string ToEmail;
    global Integer Counter;
    
    // Constructor  
    public KDM_BatchOpSellerPermissionFieldUpdate(String strSOQLWhereClause, boolean blnSendBatchCompleteNotification, string strToEmail)  
    {
      query = 'SELECT Account__c, Id, User__c, ADESA_com_Detail__c, Is_Account_Found__c, Is_User_Found__c, Op_Account_ATC_Org_ID__c, Op_User_Username__c FROM Seller_Permission__c where Is_Migrated_Record__c=true '+strSOQLWhereClause;  
      
      Summary='';
      ToEmail = strToEmail;
      Counter=0;
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
           List<Seller_Permission__c> List_Seller_Permission = (List<Seller_Permission__c>) scope;           
           System.debug('>>> List_Seller_Permission.size()'+List_Seller_Permission.size());           
           if(List_Seller_Permission.size() == 0)
           {
                return;
           }           
           Set<String> List_Op_Account_ATC_ORG_ID = new Set<String>();
           Set<String> List_Op_User_USERNAME = new Set<String>();
           
            
           //2. Make List 
           for(Seller_Permission__c obj: List_Seller_Permission)
           {
                // For Account
                if(obj.Op_Account_ATC_Org_ID__c!=null && obj.Op_Account_ATC_Org_ID__c!='')
                {   
                    List_Op_Account_ATC_ORG_ID.Add(obj.Op_Account_ATC_Org_ID__c);   
                }
               
                // For User
                if(obj.Op_User_Username__c!=null && obj.Op_User_Username__c!='')
                {
                    List_Op_User_USERNAME.Add(obj.Op_User_Username__c);
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
            
            // New Changes for Username 
            List<Property__c>  ListProperty = [select Property_Id__c, Property_Value__c from Property__c where Property_Id__c ='username.patch' LIMIT 1];   
           
            Set<String> List_UserName_for_SOQL = new Set<String>();
            if(ListProperty.size()>0)
            {               
                String UsernamePatch = '';
                UsernamePatch = ListProperty[0].Property_Value__c;                
                for(String strUsername: List_Op_User_USERNAME){
                    strUsername = strUsername.Replace('@',UsernamePatch);                    
                    List_UserName_for_SOQL.Add(strUsername);
                }                
            }else{            
                for(String strUsername: List_Op_User_USERNAME){                                    
                    List_UserName_for_SOQL.Add(strUsername);
                }  
            }  
            
            // For OwerId 
            List_UserName_for_SOQL.Add(Utils.getMigratedCaseDefaultOwnerUserName('migrated.case.default.owner.username'));            
            List<User> ListKARUser = [SELECT UserName, Id FROM User where UserName IN :List_UserName_for_SOQL];  
             
            //==
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
           
            // New Changes for Username End 
          
            String strDefaultOwnerId = mapKARUserNameToId.get(Utils.getMigratedCaseDefaultOwnerUserName('migrated.case.default.owner.username'));
            //System.debug('>>>strDefaultOwnerId: '+strDefaultOwnerId);
            //System.debug('>>>mapKARUserNameToId: '+mapKARUserNameToId);
            
            
            //4. Set field 
            string strUserId ='';
            for(Seller_Permission__c obj: List_Seller_Permission)
            {
                //For Account 
                if(obj.Is_Account_Found__c == false)
                {
                    if(obj.Op_Account_ATC_Org_ID__c!=null && obj.Op_Account_ATC_Org_ID__c!='')
                    {
                         string strAccountId = mapATC_OrgId_To_KARAccountId.get(obj.Op_Account_ATC_Org_ID__c);                                             
                         if(strAccountId!=null && strAccountId!='')
                         {
                             obj.Account__c = strAccountId; 
                             obj.Is_Account_Found__c = true;
                         }   
                        string strAdesaId = mapATC_OrgId_To_KARAdesaId.get(obj.Op_Account_ATC_Org_ID__c);                                             
                         if(strAdesaId!=null && strAdesaId!='')
                         {
                             obj.ADESA_com_Detail__c = strAdesaId;     
                        
                         } 
                     }
                     else
                     {
                         obj.Is_Account_Found__c = true;
                     }
                }
                 
                // For User  
                if(obj.Is_User_Found__c == false)
                {
                    if(obj.Op_User_Username__c!=null && obj.Op_User_Username__c!='')
                    {
                        strUserId = mapKARUserNameToId.get(obj.Op_User_Username__c);
                        if(strUserId!=null && strUserId!=''){
                            obj.User__c = strUserId;
                            obj.Is_User_Found__c = true;
                        }
                        else
                        {
                            if(strDefaultOwnerId!=null && strDefaultOwnerId!='')
                            {
                                obj.User__c = strDefaultOwnerId;
                            }
                        }
                        strUserId='';
                    }
                    else
                    {
                        obj.Is_User_Found__c = true;
                    }
                }
               
            }
            
             //Update ListActivityDetailsToUpdate;
            Database.SaveResult[] srList = Database.update(List_Seller_Permission, false);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){
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
            mail.setSubject('Finished processing KDM_BatchOpSellerPermissionFieldUpdate.'); 
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.sethtmlBody(Summary);
            if(!Test.isRunningTest() && !Sandbox.isSandbox())
            { 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
        
    }
   
}


//KDM_BatchOpSellerPermissionFieldUpdate objKDM_BatchOpSellerPermissionFieldUpdate = new KDM_BatchOpSellerPermissionFieldUpdate('',true,'djpatel@openlane.com');
//Database.executeBatch(objKDM_BatchOpSellerPermissionFieldUpdate);