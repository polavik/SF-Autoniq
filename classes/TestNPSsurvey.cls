@isTest class TestNPSsurvey {
    @isTest static void testScheduledBatchNPS() {
        final Id cronTriggerId;
 
        //for (CronTrigger cronTrigger : [SELECT Id FROM CronTrigger]) System.abortJob(cronTrigger.Id);
        
        // AsyncApexJob correctly follows SeeAllData=false as this count returns 0 even if existing Batch Job history in org.
        System.assertEquals(0, [SELECT COUNT()
                                FROM AsyncApexJob
                                WHERE ApexClassId IN (SELECT Id FROM ApexClass WHERE NamespacePrefix = null AND Name = 'TestNPSsurvey')]);
        Test.startTest();
        
        Contact c = new Contact(lastName='test', Email='test@test.com');
        insert c;        
        
        Account a = new Account(BillingCountry='UNITED STATES', name = 'ADESA CHARLOTTE', ATC_Organization_Id__c = '12345');
        insert a;
        Account a1 = new Account(BillingCountry='UNITED STATES', name = 'Test Account');
        insert a1;
        Account a2 = new Account(BillingCountry='UNITED STATES', name = 'ADESA ATLANTA', ATC_Organization_Id__c = '54321');
        insert a2;
        Auction_Detail__c auction = new Auction_Detail__c(Source_Id__c='1234-5678', Account__c = a1.Id, Auction__c = a.Id);
        insert auction;       
        Auction_Detail__c auction2 = new Auction_Detail__c(Source_Id__c='5678-1234', Account__c = a2.Id, Auction__c = a.Id);
        insert auction2;
        Rep_Status_ADESA_Auction__c rep = new Rep_Status_ADESA_Auction__c(ADESA_Auction_Detail__c=auction.Id, name='test', contact__c=c.Id, Auction__c=a.Id, Send_Qualtrics_Survey_Today__c=true, Send_Qualtrics_Survey_Outbound_Message__c=false);
        insert rep;        
        AuctionContact__c ac = [select Id, AuctionIdEmail__c from AuctionContact__c limit 1];
        ac.Last_Survey_Date__c = system.today() - 120;
        update ac;
        rep.Send_Qualtrics_Survey_Today__c = true;
        rep.Send_Qualtrics_Survey_Outbound_Message__c = false;
        rep.Last_Survey_Date__c=system.today();
        update rep;
        
        List<Purchase__c> purchsToInsert = new List<Purchase__c>();
        
        Purchase__c p2 = new Purchase__c(Source_id__c = 'NPS-12345', NPS_Survey_LiveBlock_DealerBlock_Onsite__c=true, ATC_Buyer_Contact__c=c.Id, Last_NPS_Survey_Date__c=system.today());
        //insert p2; Causing issues with too many SQL queries, so I'm combinging the two Purch inserts
        purchsToInsert.add(p2);
        
        Rep_Status_ADESA_Auction__c rep2 = new Rep_Status_ADESA_Auction__c(ADESA_Auction_Detail__c=auction2.Id, name='test2', contact__c=c.Id, Auction__c=a2.Id, Send_Qualtrics_Survey_Today__c=true, Send_Qualtrics_Survey_Outbound_Message__c=false);
        insert rep2;

        Purchase__c p1 = new Purchase__c(Source_id__c = 'NPS-23456', NPS_Survey_DealerBlock_Offsite__c=true, ATC_Buyer_Contact__c=c.Id, Last_NPS_Survey_Date__c=system.today());
        //insert p1;Causing issues with too many SQL queries, so I'm combinging the two Purch inserts
        purchsToInsert.add(p1);
        
        insert purchsToInsert;
        
        PurchaseTypeContact__c pc = [select Id, Email_Purchase_Type__c,Last_Survey_Date__c,email__c from PurchaseTypeContact__c where Email_Purchase_Type__c='test@test.com@1'];
        pc.Last_Survey_Date__c = system.today() - 120;
        update pc;
        p1.Last_NPS_Survey_Date__c = system.today();
        p1.NPS_Survey_Sent__c = false;
        update p1;      
                
        cronTriggerId = System.schedule('ScheduledJob', '0 0 * * * ?', new UpdateNPSSurveySentFlag());
        
        Test.stopTest();
        
    }
}