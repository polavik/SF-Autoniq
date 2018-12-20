global class Batch_AD_RepStatus_Update implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
       
    global final String query;
    public String strError ='' ;
    global string Summary;
    
     // Constructor  
    public Batch_AD_RepStatus_Update()  
    {  
      Summary=''; 
      query = 'SELECT id, ADESA_Auction_Detail__r.source_id__c,name,Source_Id__c FROM Rep_Status_ADESA_Auction__c WHERE ADESA_Auction_Detail__r.MigrationFlag__c =1 and Is_Migrated_Under_New_SourceId__c!=1';  
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query); 
    }
    
     global void execute(SchedulableContext sc) 
    {
        Batch_AD_RepStatus_Update proc = new Batch_AD_RepStatus_Update(); 
        Database.executeBatch(proc);
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
           Map<String,String>  mapId_to_NewSourceId = new Map<String, String>();      
                        
            for(Rep_Status_ADESA_Auction__c obj: ListRepStatus)
            {
                String repNewSourceId = obj.ADESA_Auction_Detail__r.source_id__c+obj.name.substring(obj.name.lastIndexOf('-'));
                mapId_to_NewSourceId.put(obj.id,repNewSourceId )  ;                     
                        
            }
             for(Rep_Status_ADESA_Auction__c objRepStatus: ListRepStatus)
             {
                if (mapId_to_NewSourceId.get(objRepStatus.id)!=null)
                {
                    objRepStatus.Source_Id__c = mapId_to_NewSourceId.get(objRepStatus.id);
                    objRepStatus.name = mapId_to_NewSourceId.get(objRepStatus.id);
                    objRepStatus.Is_Migrated_Under_New_SourceId__c =1;
                }
             
             }
             
          List<Database.SaveResult> result = Database.update(ListRepStatus, false); 
          for(Database.SaveResult saveResult : result) {            
                 if (!saveResult.isSuccess()){                       
                     System.debug('>>>>>saveResult error : '+saveResult.getErrors());
                 }
            
            }  
           // Update ListRepStatus ;
            
            
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
        String[] toAddresses = new String[] {'lily.wu@openlane.com'}; 
        String Org = UserInfo.getOrganizationName();
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Salesforce Support - Batch Complete Notification');
        mail.setSubject('Finished processing Batch_RepStatus_Update in '+Org+' Organization'); 
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.sethtmlBody(Summary);
        //if(!Test.isRunningTest())
        //{ 
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        //}
        
    }
   
}


//Batch_AD_RepStatus_Update objBatch_AD_RepStatus_Update = new Batch_AD_RepStatus_Update();
//Database.executeBatch(objBatch_AD_RepStatus_Update);