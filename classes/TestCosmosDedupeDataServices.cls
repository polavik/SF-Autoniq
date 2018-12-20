/*
Author: Pike Pullen
Date: 10/30/2013
Description: Unit Test Coverage for assorted Classes
*/

@isTest
private class TestCosmosDedupeDataServices 
{
    static testMethod void runCosmosDedupeDataServices() 
    {
        Account accObj = new Account(Name='BROWARD MOTORSPORTS OF FT LAUDERDALE LLC', Dealership_Federal_ID_GST_Number__c='98765432', Dealer_License_Number__c='12345678', Corrected_P_Street__c='1090 W SUNRISE BLVD', Corrected_P_City__c = 'city', Corrected_P_State__c = 'NY');
        	insert accObj;    
        Contact conObj = new Contact(FirstName='TestFirstName', LastName='TestLastName');
        	insert conObj;  
         
		Application_Account_Role__c[] aar = new Application_Account_Role__c[]{};
		aar.add(new Application_Account_Role__c(Account__r=accObj));
		aar.add(new Application_Account_Role__c(Account__r=accObj));
		
        Application_Contact_Role__c[] acr = new Application_Contact_Role__c[]{};
		acr.add(new Application_Contact_Role__c(Contact__r=conObj)); 
		acr.add(new Application_Contact_Role__c(Contact__r=conObj));  
            
        User testUser = TestServices.createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = TestServices.createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);
        Opportunity opp = TestServices.createTestOpportunity('Test Opp', 'Closed Won', 'Indianapolis', true);
        Application__c appObj = TestServices.createTestApplication(opp.Id, 'Shull', true);
        Application__c appObjNull = TestServices.createTestApplication(opp.Id, 'Shull', true);
			
		//models
		ApplicationModel appModel = new ApplicationModel(appObj);  
		appModel.accounts.addAll(aar);
		appModel.contacts.addAll(acr);
		System.assertEquals(appModel, appModel); 
		
		ApplicationModel appModelNull = new ApplicationModel(appObjNull);  
		System.assertEquals(appModelNull, appModelNull);  

        Map<Account, Cosmos_Dedupe_Data__c[]> Test = CosmosDedupeDataServices.findDupeCosmosAccountData(appModel);
        Map<Account, Cosmos_Dedupe_Data__c[]> Test2 = CosmosDedupeDataServices.findDupeCosmosAccountData(appModelNull);   
		Map<Contact, Cosmos_Dedupe_Data__c[]> Test3 = CosmosDedupeDataServices.findDupeCosmosContactData(appModel);    
		Map<Contact, Cosmos_Dedupe_Data__c[]> Test4 = CosmosDedupeDataServices.findDupeCosmosContactData(appModelNull);    
    }
}