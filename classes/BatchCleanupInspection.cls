Global class BatchCleanupInspection implements Database.Batchable<SObject>,Database.Stateful, Schedulable{    
    global Integer intDeleteCounter = 0;      
    public Integer intDaysForInspection  = Integer.valueof([select date__c from Cleanup_Properties__c where name = 'Inspections_Purge_BeforeDays'].date__c); //12 month   
    global string Summary='';    
    global DateTime PurgeDateNotSaleVehicle = Date.today().addDays(intDaysForInspection*(-1));
    global String strPurgeDateAction  = string.valueOf(system.today() - intDaysForInspection) + 'T23:01:01Z';     
                        
    public String query = 'select id from Inspection__c where createddate<'+strPurgeDateAction+' and (Vehicle__r.System_Id__c!=\'3\' and Vehicle__r.System_Id__c!=\'4\')' ;
   
   global void execute(SchedulableContext sc) 
    {
        BatchCleanupInspection objProcess = new BatchCleanupInspection();
        Database.executeBatch(objProcess);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {      
        return Database.getQueryLocator(query); 
    } 
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) 
    {     
        try
        {
            List<Inspection__c> InspectionToProcess = (List<Inspection__c>) scope;    
            List<Inspection__c> InspectionToDelete = new List<Inspection__c>();            
            
            for(Inspection__c obj: InspectionToProcess){
                InspectionToDelete.add(obj);
                intDeleteCounter++;               
            }
            delete InspectionToDelete;
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
        mail.setToAddresses(new String[] {'rli@openlane.com'});
        mail.setSubject('Inspection Cleanup Job Completed');
        String body = 'There are total : ' + intDeleteCounter + ' Inspection have been deleted. <br/><br/> Error:'+Summary;
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}