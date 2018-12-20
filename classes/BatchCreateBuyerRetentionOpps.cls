global class BatchCreateBuyerRetentionOpps implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    
    global String saveResults = '';
    global String deleteResults = '';
    private String buyerRecordTypeId = Utils.getRecordTypeId('Opportunity', 'Retention-Buyer');
    
    
    public String query = 'select id, name, vehicle_id__c,' + 
                                  'ATC_Seller_Adesa_com_Detail__r.atc_organization_id__c,' + 
                                  'ATC_Seller__r.name,' +
                                  'ATC_Seller__r.ownerId,' +
                                  'ATC_Buyer_Adesa_com_Detail__r.atc_organization_id__c,' +
                                  'ATC_Buyer__r.name,' +
                                  'ATC_Buyer__r.ownerId, ' +
                                  'ATC_Buyer__c, ' + //BSu added on Aug. 17, 2014 per discussion with RWang
                                  'sale_class__c ' +
                            'from purchase__c ' +
                           'where ATC_Sale_Date__c >= Last_N_days:120'+
                             'and sale_class__c in (\'Open D2D\', \'Open Non-Grounding Dealer\', ' +
                                                   '\'Closed D2D\', \'Closed - Non-Grounding Dealer\', ' +
                                                   //BSu updated on Aug. 17, 2014 per discussion with RWang
                                                   //'\'Closed - Grounding Dealer\')';
                                                   '\'Closed - Grounding Dealer\') and ATC_Buyer__c != null';


    global void execute(SchedulableContext sc) 
    {
       BatchCreateBuyerRetentionOpps retention = new BatchCreateBuyerRetentionOpps();
       Database.executeBatch(retention);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) 
    {
        System.debug('####### inside execute');
        List<Purchase__c> purchases = (List<Purchase__c>) scope;
        System.debug('##### size ' + purchases.size());
        Set<String> buyerOrgs = new Set<String>();
        for(Purchase__c p: purchases){
           buyerOrgs.add(p.ATC_Buyer_Adesa_com_Detail__r.atc_organization_id__c);
        }
        
        List<Opportunity> existingOpps = [select id, retention_type__c, ADESA_com_Detail__r.atc_organization_id__c 
                                            from opportunity 
                                           where recordTypeId = :buyerRecordTypeId 
                                             and stageName = 'Open'
                                             and  ADESA_com_Detail__r.atc_organization_id__c in :buyerOrgs];

        Map<String, Opportunity> oppRef = new Map<String, Opportunity>();
        for(Opportunity eo: existingOpps){
           oppRef.put(eo.ADESA_com_Detail__r.atc_organization_id__c, eo);
        }
        for(Purchase__c p: purchases){
             String buyerOrg = p.ATC_Buyer_Adesa_com_Detail__r.atc_organization_id__c;
             Opportunity o;
             if(oppRef.get(buyerOrg) == null){
                o = new Opportunity();
                o.name = p.atc_buyer__r.name + ' Retention - Buyer';
                o.stageName = 'Open';
                o.recordTypeId = buyerRecordTypeId;
                o.closeDate = System.today();

                //BSu updated on Aug. 17, 2014 per discussion with RWang
                //Account buyerAcct = new Account();
                Adesa_com_Detail__c buyerAdesa_com_detail = new Adesa_com_Detail__c();
                buyerAdesa_com_detail.atc_organization_id__c = buyerOrg;
                
                //buyerAcct.atc_organization_id__c = buyerOrg;
                //buyerAcct.Id = buyerAdesa_com_detail.Account__r.Id;

                //BSu updated on Aug. 17, 2014 per discussion with RWang
                //o.account = buyerAcct;
                o.accountid = p.ATC_Buyer__c;
           
        
               Id oid = p.ATC_Buyer__r.ownerId;
               o.ownerId = oid;
               
             }else{
               o = oppRef.get(buyerOrg);
             }
      /*       if(p.sale_class__c.equals('Open D2D') ||
                p.sale_class__c.equals('Open Non-Grounding Dealer')){
                o.retention_type__c = 'Open Auction';
             }else if(p.sale_class__c.equals('Closed D2D') ||
                      p.sale_class__c.equals('Closed - Non-Grounding Dealer')){
                if(o.retention_type__c == null || !o.retention_type__c.equals('Open Auction')){
                    o.retention_type__c = 'Closed Non Grounded';
                }
             }else{
                if(o.retention_type__c == null || !(o.retention_type__c.equals('Open Auction') || 
                   o.retention_type__c.equals('Closed Non Grounded'))){
                    o.retention_type__c = 'Closed Grounded';
                }
             } */
             
             if(p.sale_class__c.equals('Closed - Grounding Dealer') && o.retention_type__c == null){
                 o.retention_type__c = 'Closed Grounded';
             }
             if((p.sale_class__c.equals('Closed D2D') ||
                      p.sale_class__c.equals('Closed - Non-Grounding Dealer')) && 
                (o.retention_type__c == null || o.retention_type__c.equals('Closed Grounded'))){
                 o.retention_type__c = 'Closed Non Grounded';
             }
             if(p.sale_class__c.equals('Open D2D') ||
                p.sale_class__c.equals('Open Non-Grounding Dealer')){
                o.retention_type__c = 'Open Auction';
             }
             oppRef.put(buyerOrg, o);

        }
        
      upsert oppRef.values();
        
  
    }
    
    global void finish(Database.BatchableContext bc) 
    {
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