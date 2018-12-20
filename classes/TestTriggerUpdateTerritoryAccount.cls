@isTest
private class TestTriggerUpdateTerritoryAccount{
    @isTest static void testUpdateBranchContactUs(){ 

        Account acct = new Account(Name='Test0',BillingPostalCode = '54321',BillingCountry = 'USA'); //FIXME,RecordTypeId = '01260000000Dl5v');
        insert acct;

        //Territory__c zip = new Territory__c(Zipcode__c = '54321');
        //insert zip;

        //FIX ME zip.DST_Outside_Sales_Rep__r.FirstName = 'testing';
        //upsert zip;
    }
    
}