global class KDM_BatchOpTerritoryFieldUpdate implements Database.Batchable<SObject>, Database.Stateful {
       
    global final String query;
    global string Summary;
    global boolean SendBatchCompleteNotification;
    global string ToEmail;
    global Integer Counter;
    
    // Constructor  
    public KDM_BatchOpTerritoryFieldUpdate(String strSOQLWhereClause, boolean blnSendBatchCompleteNotification, string strToEmail)  
    {
      query = 'SELECT Id,Op_Account_Owner_Username__c, Op_DST_Outside_Sales_Rep_Username__c, Op_Assinged_Auction_ATC_Org_Id__c, Op_D2D_Specialist_Username__c, Op_DOSS_Username__c, Op_ISS_Username__c, Op_Owner_Username__c FROM Territory__c '+strSOQLWhereClause;  
      
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
           List<Territory__c> List_Territory = (List<Territory__c>) scope;           
           System.debug('>>> List_Territory.size()'+List_Territory.size());           
           if(List_Territory.size() == 0)
           {
                return;
           }           
           Set<String> List_Op_Account_ATC_ORG_ID = new Set<String>();
           Set<String> List_Op_Owner_USERNAME = new Set<String>();
           
            
           //2. Make List 
           for(Territory__c obj: List_Territory)
           {
                // For Account
                if(obj.Op_Assinged_Auction_ATC_Org_Id__c!=null && obj.Op_Assinged_Auction_ATC_Org_Id__c!='')
                {   
                    List_Op_Account_ATC_ORG_ID.Add(obj.Op_Assinged_Auction_ATC_Org_Id__c);   
                }
               
                // For User
                if(obj.Op_Account_Owner_Username__c!=null && obj.Op_Account_Owner_Username__c!='')
                {
                    List_Op_Owner_USERNAME.Add(obj.Op_Account_Owner_Username__c);
                }               
                if(obj.Op_DST_Outside_Sales_Rep_Username__c!=null && obj.Op_DST_Outside_Sales_Rep_Username__c!='')
                {
                    List_Op_Owner_USERNAME.Add(obj.Op_DST_Outside_Sales_Rep_Username__c);
                }
                if(obj.Op_D2D_Specialist_Username__c!=null && obj.Op_D2D_Specialist_Username__c!='')
                {
                    List_Op_Owner_USERNAME.Add(obj.Op_D2D_Specialist_Username__c);
                }
                if(obj.Op_DOSS_Username__c!=null && obj.Op_DOSS_Username__c!='')
                {
                    List_Op_Owner_USERNAME.Add(obj.Op_DOSS_Username__c);
                }
                if(obj.Op_ISS_Username__c!=null && obj.Op_ISS_Username__c!='')
                {
                    List_Op_Owner_USERNAME.Add(obj.Op_ISS_Username__c);
                }
                if(obj.Op_Owner_Username__c!=null && obj.Op_Owner_Username__c!='')
                {
                    List_Op_Owner_USERNAME.Add(obj.Op_Owner_Username__c);
                }
                
                       
           }
           
            // 3. Get Record of Object for that value  
            List<Adesa_com_Detail__c> ListAdesaDetail_For_Account = new List<Adesa_com_Detail__c>();
            if(List_Op_Account_ATC_ORG_ID.size()>0)
            {
                ListAdesaDetail_For_Account = [SELECT Id, ATC_Organization_ID__c, Account__c FROM Adesa_com_Detail__c WHERE ATC_Organization_ID__c IN : List_Op_Account_ATC_ORG_ID];
            }
            
            Map<String,String>  mapATC_OrgId_To_KARAccountId = new Map<String, String>();
            //Map<String,String>  mapATC_OrgId_To_KARAdesaId = new Map<String, String>();
            
            if(ListAdesaDetail_For_Account.size()>0)
            {
                for(Adesa_com_Detail__c objAdesaDetail :ListAdesaDetail_For_Account)
                {
                    mapATC_OrgId_To_KARAccountId.put(objAdesaDetail.ATC_Organization_ID__c,objAdesaDetail.Account__c);
                    //mapATC_OrgId_To_KARAdesaId.put(objAdesaDetail.ATC_Organization_ID__c,objAdesaDetail.Id);
                }
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
           
            // New Changes for Username End 
          
            String strDefaultOwnerId = mapKARUserNameToId.get(Utils.getMigratedCaseDefaultOwnerUserName('migrated.case.default.owner.username'));
            //System.debug('>>>strDefaultOwnerId: '+strDefaultOwnerId);
            //System.debug('>>>mapKARUserNameToId: '+mapKARUserNameToId);
            
            
            //4. Set field 
            string strUserId ='';
            for(Territory__c obj: List_Territory)
            {
                //FOr Account 
                if(obj.Op_Assinged_Auction_ATC_Org_Id__c!=null && obj.Op_Assinged_Auction_ATC_Org_Id__c!='')
                {
                     string strAccountId = mapATC_OrgId_To_KARAccountId.get(obj.Op_Assinged_Auction_ATC_Org_Id__c);                                             
                     if(strAccountId!=null && strAccountId!='')
                     {
                         obj.Assinged_Auction__c = strAccountId;
                         
                     }
                     
                 }
                 
                // FOr User 
                //1
                if(obj.Op_Account_Owner_Username__c!=null && obj.Op_Account_Owner_Username__c!='')
                {
                    strUserId = mapKARUserNameToId.get(obj.Op_Account_Owner_Username__c);
                    if(strUserId!=null && strUserId!=''){
                        obj.Account_Owner__c = strUserId;
                    }else{
                        if(strDefaultOwnerId!=null && strDefaultOwnerId!=''){obj.Account_Owner__c = strDefaultOwnerId;}
                    }
                    strUserId='';
                }
                //2
                if(obj.Op_DST_Outside_Sales_Rep_Username__c!=null && obj.Op_DST_Outside_Sales_Rep_Username__c!='')
                {
                    strUserId = mapKARUserNameToId.get(obj.Op_DST_Outside_Sales_Rep_Username__c);
                    if(strUserId!=null && strUserId!=''){
                        obj.DST_Outside_Sales_Rep__c = strUserId;
                    }else{
                        if(strDefaultOwnerId!=null && strDefaultOwnerId!=''){obj.DST_Outside_Sales_Rep__c = strDefaultOwnerId;}
                    }
                    strUserId='';
                }
                //3
                if(obj.Op_D2D_Specialist_Username__c!=null && obj.Op_D2D_Specialist_Username__c!='')
                {
                    strUserId = mapKARUserNameToId.get(obj.Op_D2D_Specialist_Username__c);
                    if(strUserId!=null && strUserId!=''){
                        obj.D2D_Specialist__c = strUserId;
                    }else{
                        if(strDefaultOwnerId!=null && strDefaultOwnerId!=''){obj.D2D_Specialist__c = strDefaultOwnerId;}
                    }
                    strUserId='';
                }
                //4
                if(obj.Op_DOSS_Username__c!=null && obj.Op_DOSS_Username__c!='')
                {
                    strUserId = mapKARUserNameToId.get(obj.Op_DOSS_Username__c);
                    if(strUserId!=null && strUserId!=''){
                        obj.DOSS__c = strUserId;
                    }else{
                        if(strDefaultOwnerId!=null && strDefaultOwnerId!=''){obj.DOSS__c = strDefaultOwnerId;}
                    }
                    strUserId='';
                }
                //5
                if(obj.Op_ISS_Username__c!=null && obj.Op_ISS_Username__c!='')
                {
                    strUserId = mapKARUserNameToId.get(obj.Op_ISS_Username__c);
                    if(strUserId!=null && strUserId!=''){
                        obj.ISS__c = strUserId;
                    }else{
                        if(strDefaultOwnerId!=null && strDefaultOwnerId!=''){obj.ISS__c = strDefaultOwnerId;}
                    }
                    strUserId='';
                }
                //6 Owner 
                if(obj.Op_Owner_Username__c!=null && obj.Op_Owner_Username__c!='')
                {
                    strUserId = mapKARUserNameToId.get(obj.Op_Owner_Username__c);
                    if(strUserId!=null && strUserId!=''){
                        obj.ownerId = strUserId;
                    }else{
                        if(strDefaultOwnerId!=null && strDefaultOwnerId!=''){obj.ownerId = strDefaultOwnerId;}
                    }
                    strUserId='';
                }
                
                obj.Op_Record_Proccessed__c = true;
            }
            
             //Update ListActivityDetailsToUpdate;
            Database.SaveResult[] srList = Database.update(List_Territory, false);
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
            mail.setSubject('Finished processing KDM_BatchOpTerritoryFieldUpdate.'); 
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


//KDM_BatchOpTerritoryFieldUpdate objKDM_BatchOpTerritoryFieldUpdate = new KDM_BatchOpTerritoryFieldUpdate('WHERE Op_Record_Proccessed__c=false and  Op_Load__c=1',true,'dipesh.patel@openlane.com');
//Database.executeBatch(objKDM_BatchOpTerritoryFieldUpdate);