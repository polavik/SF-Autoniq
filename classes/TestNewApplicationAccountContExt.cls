/*
Author: Pike Pullen
Date: 10/30/2013
Description: Unit Test Coverage for assorted Classes
*/

@isTest
private class TestNewApplicationAccountContExt 
{
	static testMethod void NewApplicationAccountContExt_nullParams_returnsNothing() 
    {
		Application_Account_Role__c aarObj = new Application_Account_Role__c();

        ApexPages.StandardController sObjectName = New ApexPages.StandardController(aarObj);
        NewApplicationAccountContExt naac = new NewApplicationAccountContExt(sObjectName);    
        naac.saveAccount();       
        Pagereference myPr = naac.saveAccount();
        system.assertEquals(null, myPr, 'Null page reference');
        system.assertEquals(1, Apexpages.getMessages().size(), 'page reference has messages');
        system.assert(Apexpages.getMessages()[0].getDetail().contains('Required fields are missing:') , 'Null page reference');
        system.assert(Apexpages.getMessages()[0].getDetail().contains('Application__c') , 'Null page reference');
        system.assert(Apexpages.getMessages()[0].getDetail().contains('Account__c') , 'Null page reference');
    }

    static testMethod void NewApplicationAccountContExt_existingRecord_returnsPageRef() 
    {
        Account tAcc = new Account(Name = 'Account_ApplicationAccountTriggerTest');
        insert tAcc;
        
        User testUser = TestServices.createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = TestServices.createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);
        Opportunity opp = TestServices.createTestOpportunity('Test Opp', 'Closed Won', 'Indianapolis', true);
        Application__c tApplication = TestServices.createTestApplication(opp.Id, 'Shull', true);
        
        Application_Account_Role__c aarObj= new Application_Account_Role__c(Name = 'App Account 1_ApplicationAccountTriggerTest', Account__c =tAcc.Id, Application__c = tApplication.Id, Primary__c = true);
        insert aarObj;

        ApexPages.StandardController sObjectName = New ApexPages.StandardController(aarObj);
        NewApplicationAccountContExt naac = new NewApplicationAccountContExt(sObjectName);    
        naac.saveAccount();       
        Pagereference myPr = naac.saveAccount();
        system.assertNotEquals(null, myPr, 'Page reference NOT null');
        system.assertEquals(0, Apexpages.getMessages().size(), 'page reference has NO messages');
    } 

        
}