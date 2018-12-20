global class KDM_BatchOpOppDealerProfileFieldsUpdt implements Database.Batchable<SObject>, Database.Stateful {
       
    global final String query;
    global string Summary;
    global boolean SendBatchCompleteNotification;
    global string ToEmail;
    global Integer CounterProcessRecords;
    global Integer CounterSuccessUpdateRecords;
    
    // Constructor  
    public KDM_BatchOpOppDealerProfileFieldsUpdt(String strSOQLWhereClause, boolean blnSendBatchCompleteNotification, string strToEmail)  
    {
      query = 'SELECT Id,Op_Account_ATC_ORG_ID__c,Op_Dealer_Profile_SF_ID__c  FROM Opportunity_Dealer_Profile__c where Is_Migrated_Record__c=true '+strSOQLWhereClause;  
      
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
           List<Opportunity_Dealer_Profile__c> List_ODP = (List<Opportunity_Dealer_Profile__c>) scope;           
           System.debug('>>> List_ODP.size()'+List_ODP.size());           
           if(List_ODP.size() == 0)
           {
                return;
           }           
           Set<String> List_Op_Account_ATC_ORG_ID = new Set<String>();
           Set<String> List_Op_Dealer_Profile_SF_ID = new Set<String>();
            
           //2. Make List 
           for(Opportunity_Dealer_Profile__c obj: List_ODP)
           {
                // For Account
                if(obj.Op_Account_ATC_Org_ID__c!=null && obj.Op_Account_ATC_Org_ID__c!='')
                {   
                    List_Op_Account_ATC_ORG_ID.Add(obj.Op_Account_ATC_Org_ID__c);   
                }
                
                // For Dealer_Profile_SF_ID 
                if(obj.Op_Dealer_Profile_SF_ID__c!=null && obj.Op_Dealer_Profile_SF_ID__c!='')
                {
                    List_Op_Dealer_Profile_SF_ID.Add(obj.Op_Dealer_Profile_SF_ID__c);
                }
                       
           }
           
            // 3. Get Record of Object for that value  
            List<Adesa_com_Detail__c> ListAdesaDetail_For_Account = new List<Adesa_com_Detail__c>();
            if(List_Op_Account_ATC_ORG_ID.size()>0)
            {
                ListAdesaDetail_For_Account = [SELECT Id, ATC_Organization_ID__c, Account__c FROM Adesa_com_Detail__c WHERE ATC_Organization_ID__c IN : List_Op_Account_ATC_ORG_ID];
            }
            
            Map<String,String>  mapATC_OrgId_To_KARAccountId = new Map<String, String>();
            
            
            if(ListAdesaDetail_For_Account.size()>0)
            {
                for(Adesa_com_Detail__c objAdesaDetail :ListAdesaDetail_For_Account)
                {
                    mapATC_OrgId_To_KARAccountId.put(objAdesaDetail.ATC_Organization_ID__c,objAdesaDetail.Account__c);
                    
                }
            }
            
            // for Username map 
            
            
            // FOr  
            Map<String,String>  mapOp_DPId_To_KAR_DPId = new Map<String, String>(); 
            List<Survey__c> ListKARDP = new List<Survey__c>();
            if(List_Op_Dealer_Profile_SF_ID.size()>0)
            {
                ListKARDP = [SELECT Id, Op_Dealer_Profile_SF_ID__c FROM Survey__c WHERE Op_Dealer_Profile_SF_ID__c IN :List_Op_Dealer_Profile_SF_ID ];              
            }
            for(Survey__c r: ListKARDP){         
                mapOp_DPId_To_KAR_DPId.put(r.Op_Dealer_Profile_SF_ID__c,r.Id);
            }
            
            //4. Set field 
            string strUserId ='';
            for(Opportunity_Dealer_Profile__c obj: List_ODP)
            {
                //For Account                 
                if(obj.Op_Account_ATC_Org_ID__c!=null && obj.Op_Account_ATC_Org_ID__c!='')
                {
                     string strAccountId = mapATC_OrgId_To_KARAccountId.get(obj.Op_Account_ATC_Org_ID__c);                                             
                     if(strAccountId!=null && strAccountId!='')
                     {
                         obj.Account__c = strAccountId; 
                         
                     }   
                    
                 }
                
                // Set  
                if(obj.Op_Dealer_Profile_SF_ID__c!=null && obj.Op_Dealer_Profile_SF_ID__c!='')
                {
                    string strOp_Dealer_Profile_SF_ID = mapOp_DPId_To_KAR_DPId.get(obj.Op_Dealer_Profile_SF_ID__c);
                    if(strOp_Dealer_Profile_SF_ID!=null && strOp_Dealer_Profile_SF_ID!='')
                    {
                        obj.Dealer_Profile__c = strOp_Dealer_Profile_SF_ID;
                    }
                }
                CounterProcessRecords+=1;               
            }
            
             //Update ListActivityDetailsToUpdate;
            Database.SaveResult[] srList = Database.update(List_ODP, false);
            for (Database.SaveResult sr : srList) {
                CounterSuccessUpdateRecords+=1;
                if (!sr.isSuccess()){
                    CounterSuccessUpdateRecords-=1;
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {                      
                        System.debug('>>> Error in Update Opp Dealer Profile : '+err.getStatusCode() + ': ' + err.getMessage());                        
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
            mail.setSubject('Finished processing KDM_BatchOpOppDealerProfileFieldsUpdt.'); 
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


//KDM_BatchOpOppDealerProfileFieldsUpdt objKDM_BatchOpOppDealerProfileFieldsUpdt = new KDM_BatchOpOppDealerProfileFieldsUpdt('',true,'dipesh.patel@openlane.com');
//Database.executeBatch(objKDM_BatchOpOppDealerProfileFieldsUpdt);