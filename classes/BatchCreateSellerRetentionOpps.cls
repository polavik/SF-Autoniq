global class BatchCreateSellerRetentionOpps implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    
    global String saveResults = '';
    global String deleteResults = '';
	global Set<String> ListFLSCreate = new Set<String>();
    private String sellerRecordTypeId = Utils.getRecordTypeId('Opportunity', 'Retention-Seller');
    
    
    public String query = 'select id, name, vehicle_id__c,' + 
                                  'Seller_ADESA_com_Detail__r.atc_organization_id__c,' + 
                                  'Seller_Account__r.name,' +
                                  'Seller_Account__r.ownerId,' +
                                  'Buyer_ADESA_com_Detail__r.atc_organization_id__c,' +
                                  'Buyer_Account__r.name,' +
                                  'Buyer_Account__r.ownerId ' +
                            'from Asset__c ' +
                           'where First_Date_in_Auction__c <= Last_N_days:120'+
                             'and Car_Group__r.Car_Group_Type__c = 2' +
                             'and Seller_Account__r.Owner.IsActive != False';


    global void execute(SchedulableContext sc) 
    {
       BatchCreateSellerRetentionOpps retention = new BatchCreateSellerRetentionOpps();
       Database.executeBatch(retention);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) 
    {
		Boolean blnFLSOverride = Utils.GetFLS();
        System.debug('####### inside execute');
        List<Asset__c> vehicles = (List<Asset__c>) scope;
        System.debug('##### size ' + vehicles.size());
        Set<String> sellerOrgs = new Set<String>();
        for(Asset__c v: vehicles){
           sellerOrgs.add(v.Seller_ADESA_com_Detail__r.atc_organization_id__c);
        }
       

         List<Opportunity> existingOpps = [select id, retention_type__c, ADESA_com_Detail__r.atc_organization_id__c
                                            from opportunity 
                                           where recordTypeId = :sellerRecordTypeId 
                                             and stageName = 'Open'
                                             and ADESA_com_Detail__r.atc_organization_id__c in :sellerOrgs];
        List<Opportunity> oppToAdd = new List<Opportunity>();                                     
        Map<String, Opportunity> oppRef = new Map<String, Opportunity>();
        
        for(Opportunity eo: existingOpps){
           oppRef.put(eo.ADESA_com_Detail__r.atc_organization_id__c, eo);
        }
        
        for(Asset__c v: vehicles ){
             String sellerOrg = v.Seller_ADESA_com_Detail__r.atc_organization_id__c;
             Opportunity o;
             if(oppRef.get(sellerOrg) == null){
                o = new Opportunity();
				//Story B-44003 : FLS CREATE ACCESS CHECK
				if (Schema.sObjectType.Opportunity.fields.name.isCreateable() || blnFLSOverride)
				{
					o.name = v.seller_account__r.name + ' Retention - Seller';
				}
				else
				{						
					ListFLSCreate.add(Schema.sObjectType.Opportunity.getName()+'.'+Schema.sObjectType.Opportunity.fields.name.getName());
				}
				if (Schema.sObjectType.Opportunity.fields.stageName.isCreateable() || blnFLSOverride)
				{
					o.stageName = 'Open';
				}
				else
				{						
					ListFLSCreate.add(Schema.sObjectType.Opportunity.getName()+'.'+Schema.sObjectType.Opportunity.fields.stageName.getName());
				}
				if (Schema.sObjectType.Opportunity.fields.recordTypeId.isCreateable() || blnFLSOverride)
				{
					o.recordTypeId = sellerRecordTypeId;
				}
				else
				{						
					ListFLSCreate.add(Schema.sObjectType.Opportunity.getName()+'.'+Schema.sObjectType.Opportunity.fields.recordTypeId.getName());
				}
				if (Schema.sObjectType.Opportunity.fields.closeDate.isCreateable() || blnFLSOverride)
				{
					o.closeDate = System.today();
				}
				else
				{						
					ListFLSCreate.add(Schema.sObjectType.Opportunity.getName()+'.'+Schema.sObjectType.Opportunity.fields.closeDate.getName());
				}
                Account sellerAcct = new Account();
                Adesa_com_Detail__c sellerAdesa_com_detail = new Adesa_com_Detail__c();
                sellerAdesa_com_detail.atc_organization_id__c = sellerOrg;
                sellerAcct.Id =sellerAdesa_com_detail.Account__r.Id;
                
				if (Schema.sObjectType.Opportunity.fields.accountid.isCreateable() || blnFLSOverride)
				{
					o.account = sellerAcct;
				}
				else
				{						
					ListFLSCreate.add(Schema.sObjectType.Opportunity.getName()+'.'+Schema.sObjectType.Opportunity.fields.accountid.getName());
				}
				if (Schema.sObjectType.Opportunity.fields.retention_type__c.isCreateable() || blnFLSOverride)
				{
					o.retention_type__c = 'Listing';
				}
				else
				{						
					ListFLSCreate.add(Schema.sObjectType.Opportunity.getName()+'.'+Schema.sObjectType.Opportunity.fields.retention_type__c.getName());
				}
        
                Id oid = v.Seller_Account__r.ownerId;
				if (Schema.sObjectType.Opportunity.fields.ownerId.isCreateable() || blnFLSOverride)
				{
					o.ownerId = oid;
				}
				else
				{						
					ListFLSCreate.add(Schema.sObjectType.Opportunity.getName()+'.'+Schema.sObjectType.Opportunity.fields.ownerId.getName());
				}
               
                oppToAdd.add(o);
                oppRef.put(sellerOrg, o);
              
             }
             
             
        }
        if(ListFLSCreate.size()==0)
		{	if(!Test.isRunningTest())
            { 		
				insert oppToAdd;
            }
		}
        
  
    }
    
    global void finish(Database.BatchableContext bc) 
    {
		if(ListFLSCreate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_CREATE','CLASS:BatchCreateSellerRetentionOpps', ListFLSCreate);
		}
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        String[] toAddresses = new String[] {'Salesforcebatchnotifications@openlane.com'}; 
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('salesforceemails@openlane.com');
        mail.setSenderDisplayName('Salesforce Support');
        mail.setSubject('Finished running BatchCreateBuyerRetentionOpps job.'); 
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setPlainTextBody('');
        
        if(!Test.isRunningTest())
        {        
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }         
    }
    
  

    
}