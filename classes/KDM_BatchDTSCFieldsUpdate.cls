global class KDM_BatchDTSCFieldsUpdate implements Database.Batchable<SObject>, Database.Stateful {
       
    global final String query;
    global string Summary;
    global boolean SendBatchCompleteNotification;
    global string ToEmail;
    global Integer CounterProcessRecords;
    global Integer CounterSuccessUpdateRecords;
    
    // Constructor  
    public KDM_BatchDTSCFieldsUpdate(String strSOQLWhereClause, boolean blnSendBatchCompleteNotification, string strToEmail)  
    {
      query = 'SELECT Id,Op_DC_Sales_Rep_Username__c FROM Daily_Transactional_DC_Rep_Stats__c '+strSOQLWhereClause;  
      
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
           List<Daily_Transactional_DC_Rep_Stats__c> List_DTDC = (List<Daily_Transactional_DC_Rep_Stats__c>) scope;           
           System.debug('>>> List_DTDC.size()'+List_DTDC.size());           
           if(List_DTDC.size() == 0)
           {
                return;
           }           
                     
           Set<String> List_Op_DC_Sales_Rep_USERNAME = new Set<String>();
                       
           //2. Make List 
           for(Daily_Transactional_DC_Rep_Stats__c obj: List_DTDC)
           {
                          
                // For User 
                if(obj.Op_DC_Sales_Rep_Username__c!=null && obj.Op_DC_Sales_Rep_Username__c!='')
                {
                    List_Op_DC_Sales_Rep_USERNAME.Add(obj.Op_DC_Sales_Rep_Username__c);
                }
                       
           }
           
            // for Username map 
            List<Property__c>  ListProperty = [select Property_Id__c, Property_Value__c from Property__c where Property_Id__c ='username.patch' LIMIT 1];   
           
            //new
            List<Property__c>  ListProperty2 = [select Property_Id__c, Property_Value__c from Property__c where Property_Id__c ='sandbox.suffix' LIMIT 1]; 
           
            Set<String> List_UserName_for_SOQL = new Set<String>();
            if(ListProperty.size()>0)
            {               
                String UsernamePatch = '';
                UsernamePatch = ListProperty[0].Property_Value__c;
                for(String strUsername: List_Op_DC_Sales_Rep_USERNAME){
                    strUsername = strUsername.Replace('@',UsernamePatch); 
                    //new 
                    if(ListProperty2.size()>0 && ListProperty2[0].Property_Value__c!='')
                    {
                        strUsername=strUsername+ListProperty2[0].Property_Value__c;
                    }                   
                    List_UserName_for_SOQL.Add(strUsername);
                }               
            }else{            
                  
                for(String strUsername: List_Op_DC_Sales_Rep_USERNAME){                                    
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
           
            String strDefaultOwnerId = mapKARUserNameToId.get(Utils.getMigratedCaseDefaultOwnerUserName('migrated.case.default.owner.username'));
            
            //4. Set field 
            string strUserId ='';
            for(Daily_Transactional_DC_Rep_Stats__c obj: List_DTDC)
            {
                
                // For User  
                if(obj.Op_DC_Sales_Rep_Username__c!=null && obj.Op_DC_Sales_Rep_Username__c!='')
                {
                    strUserId = mapKARUserNameToId.get(obj.Op_DC_Sales_Rep_Username__c);
                    if(strUserId!=null && strUserId!=''){
                        obj.DC_Sales_Rep__c = strUserId;
                    }
                    else
                    {
                        if(strDefaultOwnerId!=null && strDefaultOwnerId!='')
                        {
                            obj.DC_Sales_Rep__c = strDefaultOwnerId;
                        }
                    }
                    strUserId='';
                }
                CounterProcessRecords+=1;               
            }
            
             //Update ListActivityDetailsToUpdate;
            Database.SaveResult[] srList = Database.Update(List_DTDC, false);
            for (Database.SaveResult sr : srList) {
                CounterSuccessUpdateRecords+=1;
                if (!sr.isSuccess()){
                    CounterSuccessUpdateRecords-=1;
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {                      
                        System.debug('>>> Error in Update : '+err.getStatusCode() + ': ' + err.getMessage());                        
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
            mail.setSubject('Finished processing KDM_BatchDTSCFieldsUpdate.'); 
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


//KDM_BatchDTSCFieldsUpdate objKDM_BatchDTSCFieldsUpdate = new KDM_BatchDTSCFieldsUpdate('where Op_Load__c=1',true,'dipesh.patel@openlane.com');
//Database.executeBatch(objKDM_BatchDTSCFieldsUpdate);