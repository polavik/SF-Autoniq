@isTest
private class TestCaseEscalationSharing {
    
    static testMethod void doTest() {
        
        Account a = new Account(Name='someAccount');
        insert a;
        
        Contact con = new Contact(AccountId=a.Id, Login_Name__c='testPortalUtils', LastName='Lorge', Email='glorge@openlane.com', Active__c = true);
        insert con;
        
        //User myuser = new User(FirstName='Scott',LastName='LastName');
        //insert myuser;
        
        User u = [SELECT Id FROM User where isActive=True LIMIT 1];
        
        Seller_Permission__c sp = new Seller_Permission__c(Account__c = a.Id, User__c = u.Id);
        insert sp;
        Purchase__c p = new Purchase__c(Name = 'JNKCV54E33M212906', ATC_Seller__c=a.Id, Vehicle_ID__c = '-1234567',Source_ID__c = '-1234567', Handles_Payment__c = 'Y', Actual_Pickup__c = Date.today(), Transport_Type__c = 2, Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Closed - Grounding Dealer');
        insert p;
        
        Case c = new Case(VIN__c = p.Id, Seller__c=a.Id, Type = 'Arbitration', Description='PSI FAILED:Description', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', Inspection_Company_Responsibility__c='Yes');
        insert c;
        
        CaseEscalationSharing.createAndShareEscalations(new Case[] {c});
         CaseEscalationSharing.resetCaseSharing(new Case[] {c});
        
        
        
    }
    
    
}