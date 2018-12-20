global class KDM_BatchOpVehRelReqFieldsUpdate implements Database.Batchable<SObject>, Database.Stateful {
       
    global final String query;
    public String strError ='' ;
    global string Summary;
     global boolean SendBatchCompleteNotification;
    global string ToEmail;
     // Constructor  
    public KDM_BatchOpVehRelReqFieldsUpdate(String strSOQLWhereClause, boolean blnSendBatchCompleteNotification, string strToEmail)  
    {  
      Summary=''; 
      query = 'SELECT ID,Op_Purchase_Source_Id__c,Purchase__c,Is_Purchase_Found__c, Requesting_Manager__c,Requesting_Rep__c,Op_Requesting_Manager_USERNAME__c, Op_Requesting_Rep_USERNAME__c FROM Vehicle_Release_Request__c WHERE Is_Migrated_Record__c = true '+strSOQLWhereClause;  
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
            List<Vehicle_Release_Request__c> ListVehRelReq = (List<Vehicle_Release_Request__c>) scope;
            if(ListVehRelReq.size() == 0)
            {
                 return;
            }
            System.debug('>>>> 666666:');
            //2. Get List of Values to be search from another object 
            
            Set<String> List_Op_Purchase_Source_Id = new Set<String>();
            Set<String> List_Op_Requesting_Manager_USERNAME = new Set<String>();
            Set<String> List_Op_Requesting_Rep_USERNAME = new Set<String>();    
            
            for(Vehicle_Release_Request__c objVRR: ListVehRelReq )
            {               
                if(objVRR.Op_Purchase_Source_Id__c!=null && objVRR.Op_Purchase_Source_Id__c!='')
                {
                    List_Op_Purchase_Source_Id.Add(objVRR.Op_Purchase_Source_Id__c);  
                }
                List_Op_Requesting_Manager_USERNAME.Add(objVRR.Op_Requesting_Manager_USERNAME__c);  
                List_Op_Requesting_Rep_USERNAME.Add(objVRR.Op_Requesting_Rep_USERNAME__c);  
                          
            }
            
            // 3. Get Record of Object for that value  
            List<Purchase__c> ListPurchase_For_VRR = new List<Purchase__c>();
            if( List_Op_Purchase_Source_Id.size()>0)
            {
                ListPurchase_For_VRR = [SELECT Id,Source_Id__c FROM Purchase__c WHERE Source_Id__c IN : List_Op_Purchase_Source_Id];
            }
            
            
            List<User> ListUser = new List<User>();
            if(List_Op_Requesting_Manager_USERNAME.size()>0 || List_Op_Requesting_Rep_USERNAME.size()>0   )
            {
                ListUser = [SELECT Id, UserName FROM User WHERE IsPortalEnabled= false];
            }
            
            
            // 4. Make Map of value -> related required id 
            Map<String,String>  mapOL_VehId_To_KARPurchseId = new Map<String, String>();
            if(ListPurchase_For_VRR.size()>0)
            {
                for(Purchase__c objPurchase :ListPurchase_For_VRR)
                {
                    mapOL_VehId_To_KARPurchseId.put(objPurchase.Source_Id__c,objPurchase.id);
                }
            }          
            

            Map<String,String>  mapUserName_To_KARUserId = new Map<String, String>();
            //for(User objUser :ListUser)
            //{
            //    mapUserName_To_KARUserId.put(objUser.UserName,objUser.Id);
            //}
            //
                List<Property__c>  ListProperty = [select Property_Id__c, Property_Value__c from Property__c where Property_Id__c ='username.patch' LIMIT 1];   
                String UsernamePatch = '';
                
                 //new
                List<Property__c>  ListProperty2 = [select Property_Id__c, Property_Value__c from Property__c where Property_Id__c ='sandbox.suffix' LIMIT 1];   
           
           
                if(ListProperty.size()>0)
                {               
                    UsernamePatch = ListProperty[0].Property_Value__c;
                    for(User obj: ListUser){
                        String strUsername = obj.Username;
                        strUsername = strUsername.Replace(UsernamePatch,'@');
                        //new 
                        if(ListProperty2.size()>0 && ListProperty2[0].Property_Value__c!='')
                        { 
                            strUsername = strUsername.Replace(ListProperty2[0].Property_Value__c,'');
                        }
                        mapUserName_To_KARUserId.put(strUsername,obj.Id);
                    }
                    
                }else{
                
                    for(User obj: ListUser){
                        mapUserName_To_KARUserId.put(obj.Username,obj.Id);
                    }
                }   
            //
            
            
            //4. Set field  
             
            
            for(Vehicle_Release_Request__c objVRR: ListVehRelReq ){
                
                //For Purchase 
                if(objVRR.Is_Purchase_Found__c == false)
                {
                    if(objVRR.Op_Purchase_Source_Id__c!=null && objVRR.Op_Purchase_Source_Id__c!='')
                    {
                         string strPurchaseId = mapOL_VehId_To_KARPurchseId.get(objVRR.Op_Purchase_Source_Id__c);                                             
                         if(strPurchaseId!=null && strPurchaseId!='')
                         {
                             objVRR.Purchase__c = strPurchaseId; 
                             objVRR.Is_Purchase_Found__c = true;
                         }
                     }
                     else
                     {
                         objVRR.Is_Purchase_Found__c = true;
                     }
                }  
                 
                //2
                if (mapUserName_To_KARUserId.get(objVRR.Op_Requesting_Manager_USERNAME__c)!=null)
                {
                    objVRR.Requesting_Manager__c = mapUserName_To_KARUserId.get(objVRR.Op_Requesting_Manager_USERNAME__c);
                }
                //3
                if (mapUserName_To_KARUserId.get(objVRR.Op_Requesting_Rep_USERNAME__c)!=null)
                {
                    objVRR.Requesting_Rep__c = mapUserName_To_KARUserId.get(objVRR.Op_Requesting_Rep_USERNAME__c);
                }

            }
            
            // 6. Update 
            Update ListVehRelReq ;
            
            
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
            String[] toAddresses = new String[] {'lily.wu@openlane.com'}; 
            String Org = UserInfo.getOrganizationName();
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('Salesforce Support - Batch Complete Notification');
            mail.setSubject('Finished processing KDM_BatchOpVehRelReqFieldsUpdate in '+Org); 
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


//KDM_BatchOpVehRelReqFieldsUpdate objBatch = new KDM_BatchOpVehRelReqFieldsUpdate('',true,'lily.wu@openlane.com');
//Database.executeBatch(objBatch );