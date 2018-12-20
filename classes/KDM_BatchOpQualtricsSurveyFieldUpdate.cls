global class KDM_BatchOpQualtricsSurveyFieldUpdate implements Database.Batchable<SObject>, Database.Stateful {
       
    global final String query;
    global string Summary;
    global boolean SendBatchCompleteNotification;
    global string ToEmail;
    global Integer Counter;
    
    // Constructor  
    public KDM_BatchOpQualtricsSurveyFieldUpdate(String strSOQLWhereClause, boolean blnSendBatchCompleteNotification, string strToEmail)  
    {
      query = 'SELECT Id,Op_Contact_LOGIN_ID__c,Op_RecordType_NAME__c FROM Qualtrics_Survey__c '+strSOQLWhereClause;  
      
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
           List<Qualtrics_Survey__c> List_QualtricsSurvey = (List<Qualtrics_Survey__c>) scope;           
           System.debug('>>> List_QualtricsSurvey.size()'+List_QualtricsSurvey.size());           
           if(List_QualtricsSurvey.size() == 0)
           {
                return;
           }           
           
           Set<String> ListContactLoginId = new Set<String>();
           Set<String> List_Op_RecordType_NAME = new Set<String>();
           
            
           //2. Make List 
           for(Qualtrics_Survey__c obj: List_QualtricsSurvey)
           {
                // For Contact
                if(obj.Op_Contact_LOGIN_ID__c!=null && obj.Op_Contact_LOGIN_ID__c!='')
                {   
                    ListContactLoginId.Add(obj.Op_Contact_LOGIN_ID__c);   
                }
               
                // For EecordType
                if(obj.Op_RecordType_NAME__c!=null && obj.Op_RecordType_NAME__c!='')
                {
                    List_Op_RecordType_NAME.Add(obj.Op_RecordType_NAME__c);
                }      
           }
           
           Map<String,String>  mapKARContactLoginIdToId = new Map<String, String>();
           Map<String,String>  mapOp_RTName_To_KAR_RTId = new Map<String, String>(); 
           
           // FOr Contact 
            List<Contact> ListKARContact = new List<Contact>();
            if(ListContactLoginId.size()>0)
            {
                ListKARContact = [SELECT Login_Id__c, Id FROM Contact WHERE Login_Id__c IN :ListContactLoginId];            
            }
            for(Contact c: ListKARContact){         
                mapKARContactLoginIdToId.put(c.Login_Id__c,c.Id);
            }
            
           // FOr Record Type  
            List<RecordType> ListKAR_QS_RecordType = new List<RecordType>();
            if(List_Op_RecordType_NAME.size()>0)
            {
                ListKAR_QS_RecordType = [SELECT Name, Id, DeveloperName FROM RecordType WHERE SobjectType='Qualtrics_Survey__c' AND Name IN :List_Op_RecordType_NAME ];              
            }
            for(RecordType r: ListKAR_QS_RecordType){         
                mapOp_RTName_To_KAR_RTId.put(r.Name,r.Id);
            }
            
            
            
            //4. Set field 
            string strUserId ='';
            for(Qualtrics_Survey__c obj: List_QualtricsSurvey)
            {
                
                // Set Record Type
                string strRecordTypeId = mapOp_RTName_To_KAR_RTId.get(obj.Op_RecordType_NAME__c);
                if(strRecordTypeId!=null && strRecordTypeId!='')
                {
                    obj.RecordTypeId = strRecordTypeId;                            
                }   
                //FOr Contact 
                if(obj.Op_Contact_LOGIN_ID__c!=null && obj.Op_Contact_LOGIN_ID__c!='')
                {
                    string strContactId = mapKARContactLoginIdToId.get(obj.Op_Contact_LOGIN_ID__c);
                    if(strContactId!=null && strContactId!='')
                    {
                        obj.Contact__c = strContactId;                                                       
                    }                     
                 }
            }
            
            //Update Records;
            Database.SaveResult[] srList = Database.update(List_QualtricsSurvey, false);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {                      
                        System.debug('>>> Error in Update QualtricsSurvey : '+err.getStatusCode() + ': ' + err.getMessage());                        
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
            mail.setSubject('Finished process of KDM_BatchOpQualtricsSurveyFieldUpdate.'); 
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


//KDM_BatchOpQualtricsSurveyFieldUpdate objKDM_BatchOpQualtricsSurveyFieldUpdate = new KDM_BatchOpQualtricsSurveyFieldUpdate('WHERE Op_Load__c=1',true,'dipesh.patel@openlane.com');
//Database.executeBatch(objKDM_BatchOpQualtricsSurveyFieldUpdate);