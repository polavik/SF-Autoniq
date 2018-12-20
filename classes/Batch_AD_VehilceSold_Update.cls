global class Batch_AD_VehilceSold_Update implements Database.Batchable<SObject>, Database.Stateful,Schedulable {
       
    global final String query;
    public String strError ='' ;
    global string Summary;
    
     // Constructor  
    public Batch_AD_VehilceSold_Update()  
    {  
      Summary=''; 
      query = 'SELECT id, ADESA_Auction_Detail__r.source_id__c,name,Source_Id__c FROM Vehicles_Sold_ADESA_Auction__c WHERE ADESA_Auction_Detail__r.MigrationFlag__c =1 and Is_Migrated_Under_New_SourceId__c!=1';  
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query); 
    }
    
    global void execute(SchedulableContext sc) 
    {
        Batch_AD_VehilceSold_Update proc = new Batch_AD_VehilceSold_Update(); 
        Database.executeBatch(proc);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) 
    {
        try{
            //1. Get List of 200 Records
            List<Vehicles_Sold_ADESA_Auction__c> ListVehilceSold= (List<Vehicles_Sold_ADESA_Auction__c>) scope;          
            
            if(ListVehilceSold.size() == 0)
            {
                 return;
            }
           Map<String,String>  mapId_to_NewSourceId = new Map<String, String>();      
                        
            for(Vehicles_Sold_ADESA_Auction__c obj: ListVehilceSold)
            {
                String repNewSourceId = obj.ADESA_Auction_Detail__r.source_id__c+obj.name.substring(obj.name.lastIndexOf('-'));
                mapId_to_NewSourceId.put(obj.id,repNewSourceId )  ;                     
                        
            }
             for(Vehicles_Sold_ADESA_Auction__c objVehicleSold: ListVehilceSold)
             {
                if (mapId_to_NewSourceId.get(objVehicleSold.id)!=null)
                {
                    objVehicleSold.Source_Id__c = mapId_to_NewSourceId.get(objVehicleSold.id);
                    objVehicleSold.name = mapId_to_NewSourceId.get(objVehicleSold.id);
                    objVehicleSold.Is_Migrated_Under_New_SourceId__c =1;
                }
             
             }
          List<Database.SaveResult> result = Database.update(ListVehilceSold, false); 
          for(Database.SaveResult saveResult : result) {            
                 if (!saveResult.isSuccess()){                       
                     System.debug('>>>>>saveResult error : '+saveResult.getErrors());
                 }
            
            }  
           // Update ListVehilceSold;
            
            
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
        mail.setSubject('Finished processing Batch_VehilceSold_Update in '+Org+' Organization'); 
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.sethtmlBody(Summary);
        //if(!Test.isRunningTest())
        //{ 
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        //}
        
    }
   
}


//Batch_AD_VehilceSold_Update objBatch_AD_VehilceSold_Update = new Batch_AD_VehilceSold_Update();
//Database.executeBatch(objBatch_AD_VehilceSold_Update);