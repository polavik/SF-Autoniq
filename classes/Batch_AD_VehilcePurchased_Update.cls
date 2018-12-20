global class Batch_AD_VehilcePurchased_Update implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
       
    global final String query;
    public String strError ='' ;
    global string Summary;
    
     // Constructor  
    public Batch_AD_VehilcePurchased_Update()  
    {  
      Summary=''; 
      query = 'SELECT id, ADESA_Auction_Detail__r.source_id__c,name,Source_Id__c FROM Vehicles_Purchased_ADESA_Auction__c WHERE ADESA_Auction_Detail__r.MigrationFlag__c =1 and Is_Migrated_Under_New_SourceId__c!=1';  
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query); 
    }
    
    global void execute(SchedulableContext sc) 
    {
        Batch_AD_VehilcePurchased_Update proc = new Batch_AD_VehilcePurchased_Update(); 
        Database.executeBatch(proc);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) 
    {
        try{
            //1. Get List of 200 Records
            List<Vehicles_Purchased_ADESA_Auction__c> ListVehilcePurchased= (List<Vehicles_Purchased_ADESA_Auction__c>) scope;          
            
            if(ListVehilcePurchased.size() == 0)
            {
                 return;
            }
           Map<String,String>  mapId_to_NewSourceId = new Map<String, String>();      
                        
            for(Vehicles_Purchased_ADESA_Auction__c obj: ListVehilcePurchased)
            {
                String repNewSourceId = obj.ADESA_Auction_Detail__r.source_id__c+obj.name.substring(obj.name.lastIndexOf('-'));
                mapId_to_NewSourceId.put(obj.id,repNewSourceId )  ;                     
                        
            }
             for(Vehicles_Purchased_ADESA_Auction__c objVehiclePurchased: ListVehilcePurchased)
             {
                if (mapId_to_NewSourceId.get(objVehiclePurchased.id)!=null)
                {
                    objVehiclePurchased.Source_Id__c = mapId_to_NewSourceId.get(objVehiclePurchased.id);
                    objVehiclePurchased.name = mapId_to_NewSourceId.get(objVehiclePurchased.id);
                    objVehiclePurchased.Is_Migrated_Under_New_SourceId__c =1;
                }
             
             }
          List<Database.SaveResult> result = Database.update(ListVehilcePurchased, false); 
          for(Database.SaveResult saveResult : result) {            
                 if (!saveResult.isSuccess()){                       
                     System.debug('>>>>>saveResult error : '+saveResult.getErrors());
                 }
            
            }  
           // Update ListVehilcePurchased;
            
            
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
        mail.setSubject('Finished processing Batch_VehilcePurchased_Update in '+Org+' Organization'); 
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.sethtmlBody(Summary);
        //if(!Test.isRunningTest())
        //{ 
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        //}
        
    }
   
}


//Batch_AD_VehilcePurchased_Update objBatch_AD_VehilcePurchased_Update = new Batch_AD_VehilcePurchased_Update();
//Database.executeBatch(objBatch_AD_VehilcePurchased_Update);