global class KDM_BatchOpADESAComplianceFieldUpdate implements Database.Batchable<SObject>, Database.Stateful {
       
    global final String query;
    global string Summary;
    global boolean SendBatchCompleteNotification;
    global string ToEmail;
    global Integer Counter;
    
    // Constructor  
    public KDM_BatchOpADESAComplianceFieldUpdate(String strSOQLWhereClause, boolean blnSendBatchCompleteNotification, string strToEmail)  
    {
       query = 'SELECT  Id, ADESA_com_Detail__c,Account__c, Is_Account_Found__c, Op_Account_ATC_ORG_ID__c FROM ADESA_Compliance__c where Is_Migrated_Record__c=true '+strSOQLWhereClause;  
      
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
           List<ADESA_Compliance__c> List_ADESACompliance = (List<ADESA_Compliance__c>) scope;           
           System.debug('>>> List_ADESACompliance.size()'+List_ADESACompliance.size());           
           if(List_ADESACompliance.size() == 0)
           {
                return;
           }           
           Set<String> List_Op_Account_ATC_ORG_ID = new Set<String>();
            
           //2. Make List 
           for(ADESA_Compliance__c obj: List_ADESACompliance)
           {
                // For Account
                if(obj.Op_Account_ATC_Org_ID__c!=null && obj.Op_Account_ATC_Org_ID__c!='')
                {   
                    List_Op_Account_ATC_ORG_ID.Add(obj.Op_Account_ATC_Org_ID__c);   
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
            
            //4. Set field             
            for(ADESA_Compliance__c obj: List_ADESACompliance)
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
            }
            
             //Update List_ADESAComplianceToUpdate;
            Database.SaveResult[] srList = Database.update(List_ADESACompliance, false);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {                      
                        System.debug('>>> Error in Update ASESA Compliance Record : '+err.getStatusCode() + ': ' + err.getMessage());                        
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
            mail.setSubject('Finished processing BatchOpADESAComplianceFieldUpdate.'); 
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


//KDM_BatchOpADESAComplianceFieldUpdate objKDMFieldUpdate = new KDM_BatchOpADESAComplianceFieldUpdate('',true,'lily.wu@openlane.com');
//Database.executeBatch(objKDMFieldUpdate );