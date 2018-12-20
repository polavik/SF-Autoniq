public with sharing class AFCDealerRetentionOppExtension {
    public Opportunity opp{get;set;}
    public List<Contact> accountContactList{get;set;}
    public Task rtLogACall{get;set;}
    private Id rtId; // 4n1LogACall Record Type Id
    private Map<Id,String> contactMap;
	
    public AFCDealerRetentionOppExtension(ApexPages.StandardController stdController) {
        contactMap = new Map<Id,String>();		
        this.opp = [select id, name, AccountId, StageName, CloseDate, AFC_Branch__c, AFC_Region__c from Opportunity where id = :stdController.getId()];
        accountContactList = [select id, firstname, lastname from Contact where AccountId = :opp.accountId];
        for(Contact c : accountContactList){
            contactMap.put(c.id,c.firstName+' '+c.lastName);
        }

        RecordType rt = [Select Id From RecordType  Where SobjectType = 'Task' and DeveloperName = 'X4n1_Log_a_Call'];
        rtId = rt.Id;

        Set<String> subjectOptions = new Set<String>{'Phone Call','Email','Dealership Visit','Branch Visit','Auction Visit','No Action-PLN','No Action-Performance History'};
        for(Task t : [select id, OwnerId, subject, Who_I_spoke_with__c, Next_Step__c, Results_of_Call__c, Details_of_Call__c, whoid from Task where whatid = :opp.id and subject in :subjectOptions and RecordTypeId = :rtId limit 1]){
            rtLogACall = t;
        }
    }

    public void beginOpportunity(){
		
		//Story B-44003 : FLS UPDATE ACCESS CHECK
		Set<String> ListFLSUpdate = new Set<String>();
		Boolean blnFLSOverride = Utils.GetFLS();
		if (Schema.sObjectType.Opportunity.fields.stageName.isUpdateable() && Schema.sObjectType.Opportunity.fields.stageName.isCreateable() || blnFLSOverride)
		{						 
			opp.stageName = 'Working';
		}
		else
		{						
			ListFLSUpdate.add(Schema.sObjectType.Opportunity.getName()+'.'+Schema.sObjectType.Opportunity.fields.stageName.getName());
		}
		if(ListFLSUpdate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_UPDATE','CLASS:AFCDealerRetentionOppExtension', ListFLSUpdate);			
		}
		else
		{
			update opp;
		}
    }

    public void updateOpportunity(){
        updateLogACall(ApexPages.currentPage().getParameters().get('updateData'));
        upsert rtLogACall;
    }

    public void closeOpportunity(){
        updateLogACall(ApexPages.currentPage().getParameters().get('updateData'));
        upsert rtLogACall;
		//Story B-44003 : FLS UPDATE ACCESS CHECK
		Set<String> ListFLSUpdate = new Set<String>();
		Boolean blnFLSOverride ;
		if(Test.isRunningTest())
		{
			blnFLSOverride = true;
		}   
		else
		{
			blnFLSOverride = !(FLS_Enforce_Switch__c.getInstance().Enforce_FLS__c); 
		}
		System.debug('>>>>blnFLSOverride:'+blnFLSOverride);
		if (Schema.sObjectType.Opportunity.fields.stageName.isUpdateable() && Schema.sObjectType.Opportunity.fields.stagename.isCreateable() || blnFLSOverride)
		{
			opp.stagename = 'Completed';
		}
		else
		{						
			ListFLSUpdate.add(Schema.sObjectType.Opportunity.getName()+'.'+Schema.sObjectType.Opportunity.fields.stageName.getName());
		}      
		
		if(ListFLSUpdate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_UPDATE','CLASS:AFCDealerRetentionOppExtension', ListFLSUpdate);			
		}
		else
		{
			update opp;
		}
    }

    private void updateLogACall(String jsonData){
        UpdateProxy p = (UpdateProxy)JSON.deserialize(jsonData, UpdateProxy.class);
        if(rtLogACall == null){
            rtLogACall = new Task(RecordTypeId = rtId);
        }
		Set<String> ListFLSUpdate = new Set<String>();		
		Set<String> ListFLSCreate = new Set<String>();		
		Boolean blnFLSOverride ;
		if(Test.isRunningTest())
		{
			blnFLSOverride = true;
		}   
		else
		{
			blnFLSOverride = !(FLS_Enforce_Switch__c.getInstance().Enforce_FLS__c); 
		}
		System.debug('>>>>blnFLSOverride:'+blnFLSOverride);
		if (Schema.sObjectType.Task.fields.WhatId.isUpdateable() && Schema.sObjectType.Task.fields.WhatId.isCreateable() || blnFLSOverride)
		{
			rtLogACall.WhatId = opp.Id;			
		}
		else
		{						
			ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.WhatId.getName());
			ListFLSCreate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.WhatId.getName());
		}
		
		if (Schema.sObjectType.Task.fields.Subject.isUpdateable() && Schema.sObjectType.Task.fields.Subject.isCreateable() || blnFLSOverride)
		{			
			rtLogACall.Subject = p.method;
		}
		else
		{						
			ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.Subject.getName());
			ListFLSCreate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.Subject.getName());
		}
		
		if (Schema.sObjectType.Task.fields.Who_I_spoke_with__c.isUpdateable() && Schema.sObjectType.Task.fields.Who_I_spoke_with__c.isCreateable() || blnFLSOverride)
		{			
			rtLogACall.Who_I_spoke_with__c = contactMap.get(p.who);
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.Who_I_spoke_with__c.getName());
			ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.Who_I_spoke_with__c.getName());
		}
		
		if (Schema.sObjectType.Task.fields.WhoId.isUpdateable() && Schema.sObjectType.Task.fields.WhoId.isCreateable() || blnFLSOverride)
		{			
			rtLogACall.WhoId = p.who;
		}
		else
		{						
			ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.WhoId.getName());
			ListFLSCreate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.WhoId.getName());
		}
		
		if (Schema.sObjectType.Task.fields.Details_of_Call__c.isUpdateable() && Schema.sObjectType.Task.fields.Details_of_Call__c.isCreateable() || blnFLSOverride)
		{			
			rtLogACall.Details_of_Call__c = (p.details != '')?p.results+' - '+p.details : p.results;
		}
		else
		{						
			ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.Details_of_Call__c.getName());
			ListFLSCreate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.Details_of_Call__c.getName());
		}
		
		if (Schema.sObjectType.Task.fields.Results_of_Call__c.isUpdateable() && Schema.sObjectType.Task.fields.Results_of_Call__c.isCreateable() || blnFLSOverride)
		{			
			rtLogACall.Results_of_Call__c = p.notes;
		}
		else
		{						
			ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.Results_of_Call__c.getName());
			ListFLSCreate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.Results_of_Call__c.getName());
		}
		
		if (Schema.sObjectType.Task.fields.Next_Step__c.isUpdateable() && Schema.sObjectType.Task.fields.Next_Step__c.isCreateable() || blnFLSOverride)
		{			
			rtLogACall.Next_Step__c = p.nextsteps;
		}
		else
		{						
			ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.Next_Step__c.getName());
			ListFLSCreate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.Next_Step__c.getName());
		}
		
		if (Schema.sObjectType.Task.fields.AFC_Branch__c.isUpdateable() && Schema.sObjectType.Task.fields.AFC_Branch__c.isCreateable() || blnFLSOverride)
		{			
			rtLogACall.AFC_Branch__c = opp.AFC_Branch__c;
		}
		else
		{						
			ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.AFC_Branch__c.getName());
			ListFLSCreate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.AFC_Branch__c.getName());
		}
		
		if (Schema.sObjectType.Task.fields.Status.isUpdateable() && Schema.sObjectType.Task.fields.Status.isCreateable() || blnFLSOverride)
		{			
			rtLogACall.Status = 'Completed';
		}
		else
		{						
			ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.Status.getName());
			ListFLSCreate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.Status.getName());
		}
		if (Schema.sObjectType.Task.fields.ActivityDate.isUpdateable() && Schema.sObjectType.Task.fields.ActivityDate.isCreateable() || blnFLSOverride)
		{			
			rtLogACall.ActivityDate = System.today();
		}
		else
		{						
			ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.ActivityDate.getName());
			ListFLSCreate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.ActivityDate.getName());
		}
		if (Schema.sObjectType.Task.fields.ownerId.isUpdateable() && Schema.sObjectType.Task.fields.ownerId.isCreateable() || blnFLSOverride)
		{			
			rtLogACall.ownerId = UserInfo.getUserId();
		}
		else
		{						
			ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.ownerId.getName());
			ListFLSCreate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.ownerId.getName());
		}
		
		if(ListFLSUpdate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_UPDATE','CLASS:AFCDealerRetentionOppExtension', ListFLSUpdate);
		}
		if(ListFLSCreate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_CREATE','CLASS:AFCDealerRetentionOppExtension', ListFLSCreate);
		}
    }

    private class UpdateProxy{
        public String method;
        public String results;
        public String details;
        public String nextsteps;
        public String who;
        public String notes;
    }
}