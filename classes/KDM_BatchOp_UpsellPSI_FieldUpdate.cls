global class KDM_BatchOp_UpsellPSI_FieldUpdate implements Database.Batchable<SObject>, Database.Stateful {
       
    global final String query;
    global string Summary;
    global boolean SendBatchCompleteNotification;
    global string ToEmail;
    global Integer Counter;
    
    // Constructor  
    public KDM_BatchOp_UpsellPSI_FieldUpdate(String strSOQLWhereClause, boolean blnSendBatchCompleteNotification, string strToEmail)  
    {
      query = 'SELECT  Id, Op_Account_ATC_ORG_ID__c,Op_Purchase_Source_Id__c,Is_Purchase_Found__c,Is_Account_Found__c  FROM Upsell_PSI__c where Is_Migrated_Record__c=true '+strSOQLWhereClause;  
      
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
           List<Upsell_PSI__c> List_Upsell_PSI = (List<Upsell_PSI__c>) scope;           
           System.debug('>>> List_Upsell_PSI.size()'+List_Upsell_PSI.size());           
           if(List_Upsell_PSI.size() == 0)
           {
                return;
           }           
           Set<String> List_Op_Account_ATC_ORG_ID = new Set<String>();
           Set<String> List_Op_Purchase_Source_ID = new Set<String>();
            
           //2. Make List 
           for(Upsell_PSI__c obj: List_Upsell_PSI)
           {
                // For Account
                if(obj.Op_Account_ATC_ORG_ID__c!=null && obj.Op_Account_ATC_ORG_ID__c!='')
                {   
                    List_Op_Account_ATC_ORG_ID.Add(obj.Op_Account_ATC_ORG_ID__c);   
                }
                
                // For purchase
                if(obj.Op_Purchase_Source_Id__c!=null && obj.Op_Purchase_Source_Id__c!='')
                {   
                    List_Op_Purchase_Source_ID.Add(obj.Op_Purchase_Source_Id__c);
                }                   
                       
           }
           
            // 3. Get Record of Object for that value  
            
            //Purchase
            List<Purchase__c> ListPurchase = new List<Purchase__c>();
            if(List_Op_Purchase_Source_ID.size()>0)
            {
                ListPurchase = [SELECT Id, Source_Id__c  FROM Purchase__c WHERE Source_Id__c IN : List_Op_Purchase_Source_ID];
            }
            
            Map<String,String>  mapSourceId_To_KARPurchaseId = new Map<String, String>();
            
            if(ListPurchase.size()>0)
            {
                for(Purchase__c objPurchase :ListPurchase)
                {
                    mapSourceId_To_KARPurchaseId.put(objPurchase.Source_Id__c,objPurchase.Id);
                    
                }
            }
            
            
            //Account 
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
            //4. Set field             
            for(Upsell_PSI__c obj: List_Upsell_PSI)
            {
                //For Purchase 
                if(obj.Is_Purchase_Found__c == false)
                {
                    if(obj.Op_Purchase_Source_Id__c!=null && obj.Op_Purchase_Source_Id__c!='')
                    {
                         string strPurchaseId = mapSourceId_To_KARPurchaseId.get(obj.Op_Purchase_Source_Id__c);                                             
                         if(strPurchaseId!=null && strPurchaseId!='')
                         {
                             obj.Purchase__c = strPurchaseId; 
                             obj.Is_Purchase_Found__c = true;
                         }
                     }
                     else
                     {
                         obj.Is_Purchase_Found__c = true;
                     }
                }    
                
                //For Account 
                if(obj.Is_Account_Found__c == false)
                {
                    if(obj.Op_Account_ATC_ORG_ID__c!=null && obj.Op_Account_ATC_ORG_ID__c!='')
                    {
                         string strAccountId = mapATC_OrgId_To_KARAccountId.get(obj.Op_Account_ATC_ORG_ID__c);                                             
                         if(strAccountId!=null && strAccountId!='')
                         {
                             obj.Processing_Auction__c = strAccountId; 
                             obj.Is_Account_Found__c = true;
                         }
                     }
                     else
                     {
                         obj.Is_Account_Found__c = true;
                     }
                }               
            }            
            //Update ListActivityDetailsToUpdate;
            Database.SaveResult[] srList = Database.update(List_Upsell_PSI, false);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {                      
                        System.debug('>>> Error in Update ISAP Record : '+err.getStatusCode() + ': ' + err.getMessage());                        
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
            mail.setSubject('Finished processing KDM_BatchOp_UpsellPSI_FieldUpdate.'); 
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


//KDM_BatchOp_UpsellPSI_FieldUpdate objKDM_BatchOp_UpsellPSI_FieldUpdate = new KDM_BatchOp_UpsellPSI_FieldUpdate('and Loaded__c=1',true,'dipesh.patel@openlane.com');
//Database.executeBatch(objKDM_BatchOp_UpsellPSI_FieldUpdate);