/*
Author: Pike Pullen
Date: 10/30/2013
Description: Unit Test Coverage for assorted Classes
*/

@isTest
private class TestApplicationModel 
{
	static testMethod void runApplicationModel() 
    {
        Account accObj = new Account(Name='BROWARD MOTORSPORTS OF FT LAUDERDALE LLC', Corrected_P_City__c = 'city', Corrected_P_State__c = 'NY', Dealership_Federal_ID_GST_Number__c='98765432', Dealer_License_Number__c='12345678', Corrected_P_Street__c='1090 W SUNRISE BLVD'); 
        insert accObj;       
            
        User testUser = TestServices.createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = TestServices.createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);
        Opportunity opp = TestServices.createTestOpportunity('Test Opp', 'Closed Won', 'Indianapolis', true);
        Application__c appObj = TestServices.createTestApplication(opp.Id, 'Shull', false);
        appObj.Applications_Accounts__c = accObj.Id;
        insert appObj;           

        ApplicationModel Test = new ApplicationModel(appObj);      
        
        Application__c appObj2 = new Application__c(); 
        ApplicationModel Test2 = new ApplicationModel(appObj2); 
        
        System.assertNotEquals(null, Test);   
        System.assertNotEquals(null, Test2);         
    }
}