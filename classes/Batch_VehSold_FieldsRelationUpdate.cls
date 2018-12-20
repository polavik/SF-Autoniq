global class Batch_VehSold_FieldsRelationUpdate implements Database.Batchable<SObject>, Database.Stateful {
       
    global final String query;
    public String strError ='' ;
    global string Summary;
    
     // Constructor  
    public Batch_VehSold_FieldsRelationUpdate()  
    {  
      Summary=''; 
      query = 'SELECT ID,Op_Account_ATC_ORG_ID__c,Op_Auction_Site_ATC_ORG_ID__c FROM Vehicles_Sold_ADESA_Auction__c WHERE Is_Migrated_Record__c = true ';  
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) 
    {
        try{
            //1. Get List of 200 Records
            List<Vehicles_Sold_ADESA_Auction__c> ListVehiclesSold = (List<Vehicles_Sold_ADESA_Auction__c>) scope;
            if(ListVehiclesSold.size() == 0)
            {
                 return;
            }
           
            //2. Get List of Values to be search from another object 
            Set<String> List_Op_Account_ATC_ORG_ID = new Set<String>();
            Set<String> List_Op_Auction_Site_ATC_ORG_ID = new Set<String>();
            
            
            
            for(Vehicles_Sold_ADESA_Auction__c obj: ListVehiclesSold)
            {
                if(obj.Op_Account_ATC_ORG_ID__c!=null && obj.Op_Account_ATC_ORG_ID__c!=''){   List_Op_Account_ATC_ORG_ID.Add(obj.Op_Account_ATC_ORG_ID__c);   }
                if(obj.Op_Auction_Site_ATC_ORG_ID__c!=null && obj.Op_Auction_Site_ATC_ORG_ID__c!=''){  List_Op_Auction_Site_ATC_ORG_ID.Add(obj.Op_Auction_Site_ATC_ORG_ID__c);  }
                
                        
            }
            
            // 3. Get Record of Object for that value  
            List<Adesa_com_Detail__c> ListAdesaDetail_For_Account = new List<Adesa_com_Detail__c>();
            if(List_Op_Account_ATC_ORG_ID.size()>0)
            {
                ListAdesaDetail_For_Account = [SELECT Id, ATC_Organization_ID__c, Account__c FROM Adesa_com_Detail__c WHERE ATC_Organization_ID__c IN : List_Op_Account_ATC_ORG_ID];
            }
            
            List<Adesa_com_Detail__c> ListAdesaDetail_For_Auction = new List<Adesa_com_Detail__c>();
            if(List_Op_Auction_Site_ATC_ORG_ID.size()>0)
            {
                ListAdesaDetail_For_Auction = [SELECT Id, ATC_Organization_ID__c, Account__c FROM Adesa_com_Detail__c WHERE ATC_Organization_ID__c IN : List_Op_Auction_Site_ATC_ORG_ID];
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
            
            
            
            // 5. Update 200 Record List with Map 
            for(Vehicles_Sold_ADESA_Auction__c obj: ListVehiclesSold){
                //1
                if (mapATC_OrgId_To_KARAccountId.get(obj.Op_Account_ATC_ORG_ID__c)!=null)
                {
                    obj.Account__c = mapATC_OrgId_To_KARAccountId.get(obj.Op_Account_ATC_ORG_ID__c);
                }
                //2
                if (mapATC_OrgId_To_KARAccountId.get(obj.Op_Auction_Site_ATC_ORG_ID__c)!=null)
                {
                    obj.Auction_Site__c = mapATC_OrgId_To_KARAccountId.get(obj.Op_Auction_Site_ATC_ORG_ID__c);
                }
                                
            }
            
            // 6. Update 
            Update ListVehiclesSold;
            
            
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
        mail.setSubject('Finished processing Batch_VehSold_FieldsRelationUpdate in '+Org+' Organization'); 
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.sethtmlBody(Summary);
        //if(!Test.isRunningTest())
        //{ 
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        //}
        
    }
   
}


//Batch_VehSold_FieldsRelationUpdate objBatch_VehSold_FieldsRelationUpdate = new Batch_VehSold_FieldsRelationUpdate();
//Database.executeBatch(objBatch_VehSold_FieldsRelationUpdate);