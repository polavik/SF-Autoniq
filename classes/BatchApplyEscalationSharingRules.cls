Global class BatchApplyEscalationSharingRules implements Database.Batchable<SObject>,Database.Stateful, Schedulable{
    
    global integer sharingRulesCounter = 0;
    public String email = 'eric.hulen@openlane.com';
    public String query = 'select Migrated_Openlane_Case_KAR_id__c, Sharing_Rules_Applied__c from Temp_Openlane_KAR_Case_Mapper__c WHERE Migrated_Openlane_Case_KAR_id__c != null AND Escalation_Sharing_Applied__c = FALSE';
       
    global void execute(SchedulableContext sc) 
    {
        BatchApplyEscalationSharingRules proc = new BatchApplyEscalationSharingRules ();
        Database.executeBatch(proc, 1);//This process can only do 50 at a time with SQL limits.
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
            cid.Escalation_Sharing_Applied__c = true;
        }
        
        List<Case_Escalation__c> caseEscalationList = new List<Case_Escalation__c>();
        Set<Id> caseEscalationIdSet = new Set<Id>();
        List<Id> caseEscalationIdList = new List<Id>();
        
        
        
        caseEscalationList =
        [SELECT Id FROM Case_Escalation__c where Case__r.Id in :caseIdList];
        
        for(Case_Escalation__c ce : caseEscalationList)
        {
            caseEscalationIdSet.add(ce.Id);
        }
        
        if(!caseEscalationIdSet.isEmpty())
        {
            caseEscalationIdList.addAll(caseEscalationIdSet);//removes duplicates
        }
        
        if(!caseEscalationIdList.isEmpty())
        {
        
            List<Case_Escalation__c> escalations = [select id, Seller__c, Case__r.id, Case__r.Seller__c from Case_Escalation__c where id in :caseEscalationIdList];
            Map<ID, List<ID>> escalationIdUserIdMap = CaseEscalationSharing.getSellerPermissions(escalations);
            CaseEscalationSharing.shareCaseEscalations(escalationIdUserIdMap);
            
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