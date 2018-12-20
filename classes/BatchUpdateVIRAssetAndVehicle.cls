global class BatchUpdateVIRAssetAndVehicle implements Database.Batchable<SObject>, Database.Stateful {
       
    global final String query;
    global string Summary;
    global boolean SendBatchCompleteNotification;
    global string ToEmail;
    // Constructor  
    public BatchUpdateVIRAssetAndVehicle(String strCondition,boolean blnSendBatchCompleteNotification, string strToEmail)   
    {
      query = 'SELECT ID,vehicle_id__c FROM VIR__c ' +strCondition;  
      Summary='';
      System.debug('>>> query'+query);
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
           
           List<VIR__c> List_VIRs = (List<VIR__c>) scope;
           
           System.debug('>>> List_VIRs.size()'+List_VIRs.size());
           
           if(List_VIRs.size() == 0)
           {
                return;
           }          
           
            
            List<String> List_VIR_Vehicle_Id = new List<String>();
            Map<String,String>  mapVehicleIdToVIRSFID = new Map<String, String>(); 
            Map<String,String>  mapVehicleIdToAssetSFID = new Map<String, String>();
            for(VIR__c obj: List_VIRs){                 
                List_VIR_Vehicle_Id.Add(obj.vehicle_id__c);               
            }            
            
            System.debug('>>> List_VIR_Vehicle_Id'+List_VIR_Vehicle_Id);            
          
            
            List<Asset__c> List_Asset = [SELECT Id, source_id__c FROM asset__c WHERE source_id__c IN:List_VIR_Vehicle_Id];
            
            if(List_Asset.size()>0)
            {
                for(asset__c obj: List_Asset){ 
                mapVehicleIdToAssetSFID.put(obj.source_id__c,obj.ID);               
             }
            }
            
             for(VIR__c obj: List_VIRs){                 
                String assetId = mapVehicleIdToAssetSFID.get(obj.vehicle_id__c);
                System.debug('>>>> process vehicle_id :'+obj.vehicle_id__c);

                if (assetId!=null){
                    obj.asset__c= assetId;
                    obj.vehicle__c = assetId;
                }
                
            }  
            update List_VIRs;
            
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
            //mail.setReplyTo('salesforceemails@openlane.com');
            mail.setSenderDisplayName('Salesforce Support - Batch Complete Notification');
            mail.setSubject('Finished processing BatchUpdateVIRAssetAndVehicle.'); 
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


//BatchUpdateVIRAssetAndVehicle objBatchUpdateVIRAssetAndVehicle  = new BatchUpdateVIRAssetAndVehicle(' WHERE createddate>=2015-01-01T00:00:00Z   and  createddate< 2016-01-05T00:00:00Z ',true,'lily.wu@openlane.com');
//Database.executeBatch(objBatchUpdateVIRAssetAndVehicle ,1);