global class VEROrphanManager implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    
    global String saveResults = '';
    global String deleteResults = '';
  global Set<String> ListFLSUpdate = new Set<String>();
  
    public String query =  
        'SELECT Vehicle_ID__c, Purchase__c, CreatedDate ' + 
        'FROM Vehicle_Exception_Report__c ' + 
        'WHERE Purchase__c = NULL ';


    global void execute(SchedulableContext sc) 
    {
        VEROrphanManager orphanManager = new VEROrphanManager();
        Database.executeBatch(orphanManager);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query); 
    } 
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) 
    {
        Boolean blnFLSOverride = Utils.GetFLS();

        List<Vehicle_Exception_Report__c> vers = (List<Vehicle_Exception_Report__c>) scope;
        
        // Extract a list of Vehicle IDs from "scope"
        List<String> vehicleIdsToMatch = new List<String>();
        for (Vehicle_Exception_Report__c ver : vers) 
        {
            vehicleIdsToMatch.add(ver.Vehicle_ID__c);
        }
        
        // Find vehicle id matches within the Purchase__c object
        List<Purchase__c> purchases = 
            [SELECT Vehicle_ID__c, Id FROM Purchase__c WHERE Vehicle_ID__c IN :vehicleIdsToMatch];
            
        Map<String, ID> vehicleIdPurchaseIdMap = new Map<String, ID>();
        for (Purchase__c purchase : purchases) 
        {
            vehicleIdPurchaseIdMap.put(purchase.Vehicle_ID__c, purchase.Id);
        }
        
        // VERs that are matched to Purchases to be updated with new Purchase__c reference
        // VERs over 30 days old with no match should be deleted
        List<Vehicle_Exception_Report__c> versToUpdate = new List<Vehicle_Exception_Report__c>();
        List<Vehicle_Exception_Report__c> versToDelete = new List<Vehicle_Exception_Report__c>();
    Set<String> ListFLSUpdate = new Set<String>();
    
        for (Vehicle_Exception_Report__c ver : vers) 
        {
            ID match = vehicleIdPurchaseIdMap.get(ver.Vehicle_ID__c);
            if (match != null) 
            {
        //Story B-44003 : FLS UPDATE ACCESS CHECK
        if (Schema.sObjectType.Vehicle_Exception_Report__c.fields.Purchase__c.isUpdateable() || blnFLSOverride)
        {             
          ver.Purchase__c = match;
        }
        else
        {            
          ListFLSUpdate.add(Schema.sObjectType.Vehicle_Exception_Report__c.getName()+'.'+Schema.sObjectType.Vehicle_Exception_Report__c.fields.Purchase__c.getName());
        }
                versToUpdate.add(ver);
            }
            else
            {
                if (ver.CreatedDate.date().daysBetween(Date.today()) > 30) 
                {
                    versToDelete.add(ver);
                }               
            }
        }
        
    if(ListFLSUpdate.size() == 0 )
    {
      Database.SaveResult[] srs = Database.update(versToUpdate, false);
      for (Database.SaveResult sr : srs) {
        saveResults = saveResults + sr + '\n';
      }
      
      Database.DeleteResult[] drs = Database.delete(versToDelete, false);
      for (Database.DeleteResult dr : drs) {
        deleteResults = deleteResults + dr + '\n';
      }
    }
    }
    
    global void finish(Database.BatchableContext bc) 
    {
    if(ListFLSUpdate.size()>0)
    {
      Utils.SendEmailforFLS('FLS_UPDATE','CLASS:VEROrphanManager', ListFLSUpdate);
    }
    else
    {    
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      mail.setToAddresses(new String[] {'sshehzad@openlane.com'});
      mail.setSubject('VER Reattachment Completed');
      
      String body = 'Reattach Results:\n' + saveResults + '\n\nDelete Results:\n' + deleteResults;
        
      mail.setPlainTextBody(body);
      
        if(!Test.isRunningTest())
        {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }       
    }
    }
    
}