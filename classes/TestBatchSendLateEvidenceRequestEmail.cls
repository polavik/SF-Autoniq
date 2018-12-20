@isTest
private class TestBatchSendLateEvidenceRequestEmail{

    public static testMethod void testBatch() {
        Account a = new Account(
        Name = 'TEST ACCOUNT'
        );
        insert a;
    
        Contact cont = new Contact(
        FirstName='TEST',
        LastName='CONTACT'
        );
        insert cont;
    
        Purchase__c p = new Purchase__c(
        Name = 'JNKCV54E33M212906', 
        Vehicle_Id__c = '12345',
        Source_Id__c = '12345',
        Private_Label__c = 'OPENLANE.ca Open Auction',
        ATC_Buyer_Contact__r = cont,      
        ATC_Sale_Date__c = system.today()
        );  
        insert p;
    
        Case c = new Case(
        VIN__c = p.Id,
        AccountId = a.Id,
        Description='PSI FAILED:Description',
        Type = 'Customer Service Inquiry',
        Reason='VEHICLE UNAVAILABLE',
        Claim_Resolution__c='Void',
        Resolution_Subtype__c='Seller',
        Inspection_Company_Responsibility__c='Yes'
        );
        insert c;
        
        c.Status = 'Evidence Requested';
        
        update c;
        
        Evidence_Request__c er = new Evidence_Request__c(
        Case__c = c.id,
        Evidence_Received__c = false,
        Evidence_Req_Date__c = Date.today() - 7
        );
        insert er;
    
         Test.StartTest();
         BatchSendLateEvidenceRequestEmail eremail = new BatchSendLateEvidenceRequestEmail();
         eremail.query = 
            'SELECT Id, CaseNumber, Status ' + 
            'FROM Case ' +
            'WHERE Status = \'Evidence Requested\' ';
         ID batchprocessid = Database.executeBatch(eremail);
         Test.StopTest();  
    }
}