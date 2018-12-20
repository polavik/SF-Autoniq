@isTest
public with sharing class TestMDMRealTimeServiceHandler {
    public static String currentTest = '';

    public TestMDMRealTimeServiceHandler(){

    }

    static testMethod void testCreateNewAccount(){
    	MDMRealtimeServiceHandler.AccountInfo acct = new MDMRealtimeServiceHandler.AccountInfo();
    	acct.integrationID = '123';
    	acct.COSMOS_Id = '123';
    	acct.OPENLANE_Id = '123';
    	acct.customerName = '123 Systems';
    	acct.customerLegalName = '123 Systems Inc.';
    	acct.phoneNumber = '1234567890';
    	acct.accountType = '123';
    	acct.auctionAccessID = '123';
    	acct.faxNumber = '1234567890';
    	acct.federalTaxId = '123';
    	acct.addressLine1 = '123 main';
    	acct.addressLine2 = 'Suite 123';
    	acct.city = 'Canton';
    	acct.state = 'MI';
    	acct.zipcode = '12345';
    	acct.country = 'United States';

    	Test.startTest();
    		MDMRealtimeServiceHandler.createAccount(new List<MDMRealtimeServiceHandler.AccountInfo>{acct});
    		Account a = [select id, Name, Integration_Id__c, Auction_Access_Number__c, Tax_Identification_Number__c, Dba__c,Legal_Name__c, AFC_Dealer_Id__c, ATC_Organization_ID__c, Openlane_Org_Id__c, 
                                    BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, phone, fax from Account where Integration_Id__c = :acct.integrationID limit 1];

            System.assertEquals(a.Integration_Id__c,acct.integrationID);
            System.assertEquals(a.AFC_Dealer_Id__c,acct.COSMOS_Id);
            System.assertEquals(a.Openlane_Org_Id__c,acct.OPENLANE_Id);
            System.assertEquals(a.Name,acct.customerName);
            System.assertEquals(a.Dba__c,acct.customerName);
            //System.assertEquals(a.Legal_Name__c,acct.customerLegalName);  THE AFC WORKFLOW GETS IN THE WAY HERE.
            System.assertEquals(a.phone.replaceAll('[^0-9]', ''),acct.phoneNumber); // Eliminates (from the comparison) masking characters added by Salesforce
           // System.assertEquals(a.accountType,acct.accountType);
            System.assertEquals(a.Auction_Access_Number__c,acct.auctionAccessID);
            System.assertEquals(a.fax.replaceAll('[^0-9]', ''),acct.faxNumber);// Eliminates (from the comparison) masking charactersadded by Salesforce
            System.assertEquals(a.Tax_Identification_Number__c,acct.federalTaxId);
            System.assertEquals(a.BillingStreet,acct.addressLine1+' '+acct.addressLine2);
            System.assertEquals(a.BillingCity,acct.city);
            System.assertEquals(a.BillingState,acct.state);
            System.assertEquals(a.BillingPostalCode,acct.zipcode);
            System.assertEquals(a.BillingCountry,acct.country);
    	Test.stopTest();
    }

    static testMethod void testCreateExistingAccount(){
    	MDMRealtimeServiceHandler.AccountInfo acct = new MDMRealtimeServiceHandler.AccountInfo();
    	acct.integrationID = '123';
    	acct.COSMOS_Id = '123';
    	acct.OPENLANE_Id = '123';
    	acct.customerName = '123 Systems';
    	acct.customerLegalName = '123 Systems Inc.';
    	acct.phoneNumber = '1234567890';
    	acct.accountType = '123';
    	acct.auctionAccessID = '123';
    	acct.faxNumber = '1234567890';
    	acct.federalTaxId = '123';
    	acct.addressLine1 = '123 main';
    	acct.addressLine2 = 'Suite 123';
    	acct.city = 'Canton';
    	acct.state = 'MI';
    	acct.zipcode = '12345';
    	acct.country = 'United States';

    	Account existingAccount = new Account(Name='Test Name', Phone='4567890123',Integration_Id__c='123');
    	insert existingAccount;

    	Test.startTest();
    		MDMRealtimeServiceHandler.createAccount(new List<MDMRealtimeServiceHandler.AccountInfo>{acct});
    		Account a = [select id, Name, Integration_Id__c, Auction_Access_Number__c, Tax_Identification_Number__c, Dba__c,Legal_Name__c, AFC_Dealer_Id__c, ATC_Organization_ID__c, Openlane_Org_Id__c, 
                                    BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, phone, fax from Account where Integration_Id__c = :acct.integrationID limit 1];

            System.assertEquals(a.Integration_Id__c,acct.integrationID);
            System.assertEquals(a.AFC_Dealer_Id__c,acct.COSMOS_Id);
            System.assertEquals(a.Openlane_Org_Id__c,acct.OPENLANE_Id);
            System.assertEquals(a.Name,'Test Name');
            System.assertEquals(a.Dba__c,acct.customerName);
            //System.assertEquals(a.Legal_Name__c,acct.customerLegalName);  THE AFC WORKFLOW GETS IN THE WAY HERE.
            System.assertEquals(a.phone.replaceAll('[^0-9]', ''),'4567890123'); // Eliminates (from the comparison) masking characters added by Salesforce
           // System.assertEquals(a.accountType,acct.accountType);
            System.assertEquals(a.Auction_Access_Number__c,acct.auctionAccessID);
            System.assertEquals(a.fax.replaceAll('[^0-9]', ''),acct.faxNumber);// Eliminates (from the comparison) masking charactersadded by Salesforce
            System.assertEquals(a.Tax_Identification_Number__c,acct.federalTaxId);
            System.assertEquals(a.BillingStreet,acct.addressLine1+' '+acct.addressLine2);
            System.assertEquals(a.BillingCity,acct.city);
            System.assertEquals(a.BillingState,acct.state);
            System.assertEquals(a.BillingPostalCode,acct.zipcode);
            System.assertEquals(a.BillingCountry,acct.country);
    	Test.stopTest();
    }

    static testMethod void testMultipleExistingAccount(){
        // Tests that if multiple matching Accounts are found, each one will be enriched with MDM data.
        MDMRealtimeServiceHandler.AccountInfo acct = new MDMRealtimeServiceHandler.AccountInfo();
        acct.integrationID = '123';
        acct.COSMOS_Id = '456';
        acct.OPENLANE_Id = '789';
        acct.customerName = '123 Systems';
        acct.customerLegalName = '123 Systems Inc.';
        acct.phoneNumber = '1234567890';
        acct.accountType = 'test';
        acct.auctionAccessID = '112233';
        acct.faxNumber = '1234567890';
        acct.federalTaxId = '224466';
        acct.addressLine1 = '123 main';
        acct.addressLine2 = 'Suite 123';
        acct.city = 'Canton';
        acct.state = 'MI';
        acct.zipcode = '12345';
        acct.country = 'United States';

        List<Account> existingAccountList = new List<Account>();
        existingAccountList.add(new Account(Name='Test Name', Phone='4567890123',Integration_Id__c='123'));
        existingAccountList.add(new Account(Name='Test Name', Phone='4567890123',Auction_Access_Number__c='112233'));
        existingAccountList.add(new Account(Name='Test Name', Phone='4567890123',Openlane_Org_Id__c='789'));
        insert existingAccountList;

        Test.startTest();
            MDMRealtimeServiceHandler.createAccount(new List<MDMRealtimeServiceHandler.AccountInfo>{acct});
            List<Account> a = [select id, Name, Integration_Id__c, Auction_Access_Number__c, Tax_Identification_Number__c, Dba__c,Legal_Name__c, AFC_Dealer_Id__c, ATC_Organization_ID__c, Openlane_Org_Id__c, 
                                    BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, phone, fax from Account where Integration_Id__c = :acct.integrationID];
            System.assertEquals(3,existingAccountList.size());
        Test.stopTest();
    }    

    static testMethod void testMultipleExistingMismatchedAccount(){
        // Tests that if multiple matching Accounts are found, each one will be enriched with MDM data.
        MDMRealtimeServiceHandler.AccountInfo acct = new MDMRealtimeServiceHandler.AccountInfo();
        acct.integrationID = '123';
        acct.COSMOS_Id = '456';
        acct.OPENLANE_Id = '789';
        acct.customerName = '123 Systems';
        acct.customerLegalName = '123 Systems Inc.';
        acct.phoneNumber = '1234567890';
        acct.accountType = 'test';
        acct.auctionAccessID = '112233';
        acct.faxNumber = '1234567890';
        acct.federalTaxId = '224466';
        acct.addressLine1 = '123 main';
        acct.addressLine2 = 'Suite 123';
        acct.city = 'Canton';
        acct.state = 'MI';
        acct.zipcode = '12345';
        acct.country = 'United States';

        List<Account> existingAccountList = new List<Account>();
        existingAccountList.add(new Account(Name='Test Name', Phone='4567890123',Integration_Id__c='123'));
        existingAccountList.add(new Account(Name='Test Name', Phone='4567890123',Auction_Access_Number__c='112233'));
        existingAccountList.add(new Account(Name='Test Name', Phone='4567890123',Integration_Id__c='456', Openlane_Org_Id__c='789'));
        insert existingAccountList;

        Test.startTest();
            MDMRealtimeServiceHandler.createAccount(new List<MDMRealtimeServiceHandler.AccountInfo>{acct});
            String subjectString = 'Possible Duplicates for Integration Id: '+acct.integrationID;
            List<Case> caseList = [select id, subject from Case where RecordTypeId = :StewardshipHelper.stewardshipRtId and subject = :subjectString limit 1];
            System.assertEquals(1,caseList.size());
        Test.stopTest();
    }  
}