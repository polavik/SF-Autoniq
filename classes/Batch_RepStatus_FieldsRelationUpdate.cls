global class Batch_RepStatus_FieldsRelationUpdate implements Database.Batchable<SObject>, Database.Stateful {
       
    global final String query;
    public String strError ='' ;
    global string Summary;
    
     // Constructor  
    public Batch_RepStatus_FieldsRelationUpdate()  
    {  
      Summary=''; 
      query = 'SELECT ID,Op_Account_ATC_ORG_ID__c,Op_Auction_ATC_ORG_ID__c,Op_Contact_LOGIN_ID__c FROM Rep_Status_ADESA_Auction__c WHERE Is_Migrated_Record__c = true ';  
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) 
    {
        try{
            //1. Get List of 200 Records
            List<Rep_Status_ADESA_Auction__c> ListRepStatus = (List<Rep_Status_ADESA_Auction__c>) scope;
            if(ListRepStatus.size() == 0)
            {
                 return;
            }
           
            //2. Get List of Values to be search from another object 
            Set<String> List_Op_Account_ATC_ORG_ID = new Set<String>();
            Set<String> List_Op_Auction_ATC_ORG_ID = new Set<String>();
            Set<String> List_Contact_LOGIN_ID = new Set<String>();
            
            
            for(Rep_Status_ADESA_Auction__c objRepStatus: ListRepStatus)
            {
                if(objRepStatus.Op_Account_ATC_ORG_ID__c!=null && objRepStatus.Op_Account_ATC_ORG_ID__c!=''){  List_Op_Account_ATC_ORG_ID.Add(objRepStatus.Op_Account_ATC_ORG_ID__c);  }
                if(objRepStatus.Op_Auction_ATC_ORG_ID__c!=null && objRepStatus.Op_Auction_ATC_ORG_ID__c!=''){  List_Op_Auction_ATC_ORG_ID.Add(objRepStatus.Op_Auction_ATC_ORG_ID__c);  }
                if(objRepStatus.Op_Contact_LOGIN_ID__c !=null && objRepStatus.Op_Contact_LOGIN_ID__c!=''){    List_Contact_LOGIN_ID.Add(objRepStatus.Op_Contact_LOGIN_ID__c);  }
                        
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
            
            List<Contact> ListContact = new List<Contact>();
            if(List_Contact_LOGIN_ID.size()>0 )
            {
                ListContact = [SELECT Id, Login_ID__c FROM Contact WHERE Login_ID__c IN :List_Contact_LOGIN_ID];
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
            
            Map<String,String>  mapContactLoginId_To_KARContactId = new Map<String, String>();
            for(Contact objContact :ListContact)
            {
                mapContactLoginId_To_KARContactId.put(objContact.Login_ID__c,objContact.Id);
            }
            
            
            
            
            // 5. Update 200 Record List with Map 
            for(Rep_Status_ADESA_Auction__c objRepStatus: ListRepStatus){
                //1
                if (mapATC_OrgId_To_KARAccountId.get(objRepStatus.Op_Account_ATC_ORG_ID__c)!=null)
                {
                    objRepStatus.Account__c = mapATC_OrgId_To_KARAccountId.get(objRepStatus.Op_Account_ATC_ORG_ID__c);
                }
                //2
                if (mapATC_OrgId_To_KARAccountId.get(objRepStatus.Op_Auction_ATC_ORG_ID__c)!=null)
                {
                    objRepStatus.Auction__c = mapATC_OrgId_To_KARAccountId.get(objRepStatus.Op_Auction_ATC_ORG_ID__c);
                }
                //3
                if (mapContactLoginId_To_KARContactId.get(objRepStatus.Op_Contact_LOGIN_ID__c)!=null)
                {
                    objRepStatus.Contact__c = mapContactLoginId_To_KARContactId.get(objRepStatus.Op_Contact_LOGIN_ID__c);
                }
                
            }
            
            // 6. Update 
            Update ListRepStatus;
            
            
        }
        catch (Exception e)
        {
            System.debug('>>>> Error:'+e);
            Summary+='Error Detail : '+e.getmessage()+'<br/><br/>';
        }
        
    }
    
    global void finish(Database.BatchableContext bc) 
    {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        String[] toAddresses = new String[] {'djpatel@openlane.com'}; 
        String Org = UserInfo.getOrganizationName();
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Salesforce Support - Batch Complete Notification');
        mail.setSubject('Finished processing Batch_RepStatus_FieldsRelationUpdate in '+Org+' Organization'); 
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.sethtmlBody(Summary);
        //if(!Test.isRunningTest())
        //{ 
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        //}
        
    }
   
}


//Batch_RepStatus_FieldsRelationUpdate objBatch_RepStatus_FieldsRelationUpdate = new Batch_RepStatus_FieldsRelationUpdate();
//Database.executeBatch(objBatch_RepStatus_FieldsRelationUpdate);