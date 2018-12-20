global class BatchAuctionDetailFieldsRelationUpdate implements Database.Batchable<SObject>, Database.Stateful {
       
    global final String query;
    public String strError ='' ;
    global string Summary;
     global boolean SendBatchCompleteNotification;
    global string ToEmail;
     // Constructor  
    public BatchAuctionDetailFieldsRelationUpdate(String strSOQLWhereClause, boolean blnSendBatchCompleteNotification, string strToEmail)  
    {  
      Summary=''; 
      query = 'SELECT ID,Op_Account_ATC_ORG_ID__c,Op_Auction_ATC_ORG_ID__c,Op_Inside_Sales_Queue_USERNAME__c,Op_Inside_Sales_Rep_USERNAME__c,Op_Outside_Sales_Rep_USERNAME__c FROM Auction_Detail__c WHERE Is_Migrated_Record__c = true '+strSOQLWhereClause;  
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
            List<Auction_Detail__c> ListAuctionDetail = (List<Auction_Detail__c>) scope;
            if(ListAuctionDetail.size() == 0)
            {
                 return;
            }
           
            //2. Get List of Values to be search from another object 
            Set<String> List_Op_Account_ATC_ORG_ID = new Set<String>();
            Set<String> List_Op_Auction_ATC_ORG_ID = new Set<String>();
            Set<String> List_Op_Inside_Sales_Queue_USERNAME = new Set<String>();
            Set<String> List_Op_Inside_Sales_Rep_USERNAME = new Set<String>();
            Set<String> List_Op_Outside_Sales_Rep_USERNAME = new Set<String>();     
            
            for(Auction_Detail__c objAD: ListAuctionDetail)
            {
                List_Op_Account_ATC_ORG_ID.Add(objAD.Op_Account_ATC_ORG_ID__c);
                List_Op_Auction_ATC_ORG_ID.Add(objAD.Op_Auction_ATC_ORG_ID__c);  
                List_Op_Inside_Sales_Queue_USERNAME.Add(objAD.Op_Inside_Sales_Queue_USERNAME__c);  
                List_Op_Outside_Sales_Rep_USERNAME.Add(objAD.Op_Inside_Sales_Rep_USERNAME__c);  
                List_Op_Inside_Sales_Rep_USERNAME.Add(objAD.Op_Outside_Sales_Rep_USERNAME__c);              
            }
            
            // 3. Get Record of Object for that value  
            List<Adesa_com_Detail__c> ListAdesaDetail_For_Account = new List<Adesa_com_Detail__c>();
            if(List_Op_Account_ATC_ORG_ID.size()>0)
            {
                ListAdesaDetail_For_Account = [SELECT Id, ATC_Organization_ID__c, Account__c FROM Adesa_com_Detail__c WHERE ATC_Organization_ID__c IN : List_Op_Account_ATC_ORG_ID];
            }
            
            List<Adesa_com_Detail__c> ListAdesaDetail_For_Auction = new List<Adesa_com_Detail__c>();
            if(List_Op_Auction_ATC_ORG_ID.size()>0)
            {
                ListAdesaDetail_For_Auction = [SELECT Id, ATC_Organization_ID__c, Account__c FROM Adesa_com_Detail__c WHERE ATC_Organization_ID__c IN : List_Op_Auction_ATC_ORG_ID];
            }
            
            List<User> ListUser = new List<User>();
            if(List_Op_Inside_Sales_Queue_USERNAME.size()>0 || List_Op_Outside_Sales_Rep_USERNAME.size()>0 || List_Op_Inside_Sales_Rep_USERNAME.size()>0  )
            {
                ListUser = [SELECT Id, UserName FROM User WHERE IsPortalEnabled= false];
            }
            
            
            
            // 4. Make Map of value -> related required id 
            Map<String,String>  mapATC_OrgId_To_KARAccountId = new Map<String, String>();
            if(ListAdesaDetail_For_Account.size()>0)
            {
                for(Adesa_com_Detail__c objAdesaDetail :ListAdesaDetail_For_Account)
                {
                    mapATC_OrgId_To_KARAccountId.put(objAdesaDetail.ATC_Organization_ID__c,objAdesaDetail.Account__c);
                }
            }           
            
            if(ListAdesaDetail_For_Auction.size()>0)
            {
                for(Adesa_com_Detail__c objAdesaDetail :ListAdesaDetail_For_Auction)
                {
                    mapATC_OrgId_To_KARAccountId.put(objAdesaDetail.ATC_Organization_ID__c,objAdesaDetail.Account__c);
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
            
            
            
            // 5. Update 200 Record List with Map 
            for(Auction_Detail__c objAD: ListAuctionDetail){
                //1
                if (mapATC_OrgId_To_KARAccountId.get(objAD.Op_Account_ATC_ORG_ID__c)!=null)
                {
                    objAD.Account__c = mapATC_OrgId_To_KARAccountId.get(objAD.Op_Account_ATC_ORG_ID__c);
                }
                //2
                if (mapATC_OrgId_To_KARAccountId.get(objAD.Op_Auction_ATC_ORG_ID__c)!=null)
                {
                    objAD.Auction__c = mapATC_OrgId_To_KARAccountId.get(objAD.Op_Auction_ATC_ORG_ID__c);
                }
                //3
                if (mapUserName_To_KARUserId.get(objAD.Op_Inside_Sales_Queue_USERNAME__c)!=null)
                {
                    objAD.Inside_Sales_Queue__c = mapUserName_To_KARUserId.get(objAD.Op_Inside_Sales_Queue_USERNAME__c);
                }
                //4
                if (mapUserName_To_KARUserId.get(objAD.Op_Inside_Sales_Rep_USERNAME__c)!=null)
                {
                    objAD.Inside_Sales_Rep__c = mapUserName_To_KARUserId.get(objAD.Op_Inside_Sales_Rep_USERNAME__c);
                }
                //5
                if (mapUserName_To_KARUserId.get(objAD.Op_Outside_Sales_Rep_USERNAME__c)!=null)
                {
                    objAD.Outside_Sales_Rep__c = mapUserName_To_KARUserId.get(objAD.Op_Outside_Sales_Rep_USERNAME__c);
                }
            }
            
            // 6. Update 
            Update ListAuctionDetail;
            
            
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
            String[] toAddresses = new String[] {'djpatel@openlane.com'}; 
            String Org = UserInfo.getOrganizationName();
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('Salesforce Support - Batch Complete Notification');
            mail.setSubject('Finished processing BatchAuctionDetailFieldsRelationUpdate in '+Org); 
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


//BatchAuctionDetailFieldsRelationUpdate objBatchAuctionDetailFieldsRelationUpdate = new BatchAuctionDetailFieldsRelationUpdate(' and CreatedDate >2014-12-13T00:00:00Z',true,'Dipesh.patel@openlane.com');
//Database.executeBatch(objBatchAuctionDetailFieldsRelationUpdate);