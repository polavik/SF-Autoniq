Global class BatchCleanupVehicle implements Database.Batchable<SObject>,Database.Stateful,Schedulable{
    
    global Integer intDeleteNotSaleRecordCounter = 0;
    global Integer intDeleteSoldRecordCounter = 0;
    
    public Integer intDaysForNotSaleVehicle  = Integer.valueof([select date__c from Cleanup_Properties__c where name = 'Vehicles_NotSold_Purge_BeforeDays'].date__c); //24 month
    public Integer intDaysForSoldVehicle  = Integer.valueof([select date__c from Cleanup_Properties__c where name = 'Vehicles_Sold_Purge_BeforeDays'].date__c); //36 month
    global string Summary='';
    public String email = [select date__c from Cleanup_Properties__c where name = 'Email'].date__c; //email notification    
    //global DateTime PurgeDateNotSaleVehicle = Date.today().addDays(intDaysForNotSaleVehicle*(-1));
    global String strPurgeDateNotSaleVehicle  = string.valueOf(system.today() - intDaysForNotSaleVehicle) + 'T23:01:01Z';     
    global DateTime PurgeDateNotSaleVehicle = Date.today().addDays(intDaysForNotSaleVehicle*(-1));
    global DateTime PurgeDateSoldVehicle = Date.today().addDays(intDaysForSoldVehicle*(-1));
            
            
    public String query = 'select id,createddate,System_Id__c,(Select Id From Cases__r) from Asset__c where createddate<'+strPurgeDateNotSaleVehicle;    
    public String query2 = 'select id,createddate,System_Id__c,(Select Id From Cases__r) from Asset__c where CreatedDate >= 2012-05-01T00:00:00Z and  CreatedDate <2013-01-01T00:00:00Z  ';    
   global void execute(SchedulableContext sc) 
    {
        BatchCleanupVehicle objProcess = new BatchCleanupVehicle();
        Database.executeBatch(objProcess);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {      
        return Database.getQueryLocator(query); 
    } 
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) 
    { 
        try{
            
            List<Asset__c> VehiclesToProcess = (List<Asset__c>) scope;    
            List<Asset__c> VehiclesToDelete = new List<Asset__c>();   
            for(Asset__c obj: VehiclesToProcess){
                if(obj.System_Id__c != '3' && obj.System_Id__c != '4' ){
                    VehiclesToDelete.add(obj);
                    intDeleteNotSaleRecordCounter++;
                }else if(obj.createdDate < PurgeDateSoldVehicle ){              
                    if(obj.cases__r.size()==0){
                        VehiclesToDelete.add(obj);
                        intDeleteSoldRecordCounter++;
                    }
                    
                }
            
            }
            delete VehiclesToDelete;           
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
        mail.setToAddresses(new String[] {email});
        mail.setSubject('Vehicle Cleanup Job Completed');
        String body = 'There are total of NotSaleRecord ' + intDeleteNotSaleRecordCounter + ' Vehicles and total SoldRecord '+ intDeleteSoldRecordCounter +' have been deleted. <br/><br/>Error:'+Summary;
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}