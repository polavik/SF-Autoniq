@isTest
private class TestDealerRegistrationRequest {

    static testMethod void dealerRegistrationRequestTrigger() {
        Account a = new Account(Name = 'WILLIAM LEHMAN MITSUBISHI', Master_Index__c = '1234567' );
        insert a;
        
        Adesa_com_Detail__c b = new Adesa_com_Detail__c(Name = 'WILLIAM LEHMAN MITSUBISHI', ATC_Organization_ID__c = '686868', Account__c = a.Id );
        insert b;
        
        Dealer_Registration_Request__c drr = new Dealer_Registration_Request__c(name = 'WILLIAM LEHMAN MITSUBISHI',ADESA_com_Detail__c = b.Id, Organization_Id__c='686868', Country_Id__c  = '2', Registration_Form_Id__c='abc123');
        insert drr;
        
        drr.Country_Id__c = '1';
        update drr;
        List<Dealer_Registration_Request__c> drrs = [Select id, ADESA_com_Detail__r.Id from dealer_registration_request__c where Registration_Form_Id__c='abc123'];
        
       System.assertEquals(drrs.size(), 1);
       //System.assertEquals(drrs.get(0).account__c, a.id);
       System.assertEquals(drrs.get(0).ADESA_com_Detail__c, b.id);
       
       
    }
}