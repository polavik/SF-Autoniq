global class UpdateNPSSurveySentFlag implements Database.Batchable<SObject>, Database.Stateful,Schedulable{

    global Integer counter = 0;
    global Set<String> ListFLSUpdate = new Set<String>();
	
	
	 
	
    global void execute(SchedulableContext sc) {
        UpdateNPSSurveySentFlag proc = new UpdateNPSSurveySentFlag();
        Database.executeBatch(proc);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator([select id, Last_Updated_by_Purchase_Id__c from PurchaseTypeContact__c where (Last_Updated_by_Purchase_Id__c != null OR Last_Updated_by_Purchase_Id__c != '') AND Last_Survey_Date__c =: system.today()]);
    } 
     
    global void execute(Database.BatchableContext bc, List<SObject> scope)
    {
		Boolean blnFLSOverride = Utils.GetFLS();	
        List<PurchaseTypeContact__c> pList = (List<PurchaseTypeContact__c>) scope;		
		
		List<String> pIdList = new List<String>();
		for(PurchaseTypeContact__c p:pList){                       
			pIdList.add(p.Last_Updated_by_Purchase_Id__c);
		}

		List<Purchase__c> pListUpdate =[select Id, NPS_Survey_Sent__c from Purchase__c where Id in: pIdList];
		List<Purchase__c> purchasesUpdate = new List<Purchase__c>();

		for(Purchase__c p: pListUpdate){
			 //Story B-44003 : FLS UPDATE ACCESS CHECK
			 if (Schema.sObjectType.Purchase__c.fields.NPS_Survey_Sent__c.isUpdateable() || blnFLSOverride)
			 {						 
				p.NPS_Survey_Sent__c = true;
			 }
			 else
			 {						
				ListFLSUpdate.add(Schema.sObjectType.Purchase__c.getName()+'.'+Schema.sObjectType.Purchase__c.fields.NPS_Survey_Sent__c.getName());
			 }
			purchasesUpdate.add(p);
			counter++; 
		}
		if(ListFLSUpdate.size() == 0 )
		{
			if(purchasesUpdate.size() > 0){
				try{
					Database.update(purchasesUpdate,false);
				}catch(DmlException e){
					System.debug('An unexpected error has occurred: ' + e.getMessage());
				}
			}
		}
		
    }
    
    global void finish(Database.BatchableContext bc) 
    {       
		//Story B-44003 : FLS UPDATE ACCESS CHECK
		if(ListFLSUpdate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_UPDATE','CLASS:UpdateNPSSurveySentFlag', ListFLSUpdate);
		}
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'rli@openlane.com'});
        mail.setSubject('NPS Survey Job Completed');
        String body = 'There are total of ' + counter + ' NPS Surveys had been sent out.';        
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }  
}