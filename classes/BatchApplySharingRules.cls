Global class BatchApplySharingRules implements Database.Batchable<SObject>,Database.Stateful, Schedulable{
    
    global integer sharingRulesCounter = 0;
    public String email = 'eric.hulen@openlane.com';
    public String query = 'select Migrated_Openlane_Case_KAR_id__c, Sharing_Rules_Applied__c from Temp_Openlane_KAR_Case_Mapper__c WHERE Migrated_Openlane_Case_KAR_id__c != null AND Sharing_Rules_Applied__c = FALSE';
       
    global void execute(SchedulableContext sc) 
    {
        BatchApplySharingRules proc = new BatchApplySharingRules();
        Database.executeBatch(proc, 50);//This process can only do 50 at a time with SQL limits.
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {      
        return Database.getQueryLocator(query); 
    } 
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) 
    {   
    
        List<ID> caseIDList = new List<ID>();
        List<Temp_Openlane_KAR_Case_Mapper__c> caseMapperList = (List<Temp_Openlane_KAR_Case_Mapper__c>) scope;
          
        for(Temp_Openlane_KAR_Case_Mapper__c cid: caseMapperList)
        {
            caseIDList.add(Id.valueOf(cid.Migrated_Openlane_Case_KAR_id__c));
            cid.Sharing_Rules_Applied__c = true;
        }
        
        List<Case> caseList = [select id, Seller__c from Case where id in: caseIDList];
        
        for(Case singleCase : caseList)
        {
            List<Case> singleCaseList = new List<Case>();
            singleCaseList.add(singleCase);
            CaseEscalationSharing.resetCaseSharing(singleCaseList);
        }
        
        update(scope);    
    }

    
    global void finish(Database.BatchableContext bc) 
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {email});
        mail.setSubject('BatchApplySharingRules  Job Completed');
        String body = 'There are total of ' + sharingRulesCounter + ' Sharing Rules applied.';
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}