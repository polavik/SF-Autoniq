/*
Author: Pike Pullen
Date: 10/30/2013
Description: Unit Test Coverage for assorted Classes
*/

@isTest
private class TestNewApplicationContactContExt 
{
	static testMethod void NewApplicationContactContExt_nullParams_returnsNothing() 
    {
        Application__c appObj = new Application__c();
		Application_Contact_Role__c acrObj =  new Application_Contact_Role__c();
		
		ApexPages.StandardController sObjectName = New ApexPages.StandardController(acrObj);
        NewApplicationContactContExt  naac = new NewApplicationContactContExt (sObjectName);    
        //naac.saveContact();       
        Pagereference myPr = naac.saveContact();
        
        system.assertEquals(null, myPr, 'Null page reference');
        system.assertEquals(1, Apexpages.getMessages().size(), 'page reference has messages');
        system.assertEquals('Relationship is required', Apexpages.getMessages()[0].getDetail() , 'Null page reference');    
    }

	static testMethod void NewApplicationContactContExt_nullContactApp_returnsNothing() 
    {
        Application__c appObj = new Application__c();
		Application_Contact_Role__c acrObj =  new Application_Contact_Role__c(Relationship__c='Owner');
		
		ApexPages.StandardController sObjectName = New ApexPages.StandardController(acrObj);
        NewApplicationContactContExt  naac = new NewApplicationContactContExt (sObjectName);    
        //naac.saveContact();       
        Pagereference myPr = naac.saveContact();
        
        system.assertEquals(null, myPr, 'Null page reference');
        system.assertEquals(1, Apexpages.getMessages().size(), 'page reference has messages');
        system.assert(Apexpages.getMessages()[0].getDetail().contains('Required fields are missing:') , 'Null page reference');    
        system.assert(Apexpages.getMessages()[0].getDetail().contains('Application__c') , 'Null page reference');    
        system.assert(Apexpages.getMessages()[0].getDetail().contains('Contact__c') , 'Null page reference');    
    }

	static testMethod void NewApplicationContactContExt_name_validParams_returnsNothing() 
    {
        User testUser = TestServices.createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = TestServices.createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);
        Opportunity opp = TestServices.createTestOpportunity('Test Opp', 'Closed Won', 'Indianapolis', true);
        Application__c appObj = TestServices.createTestApplication(opp.Id, 'Shull', true);
    	Contact conObj = new Contact(FirstName='TestFirstName', LastName='TestLastName', Previous_Account_Guarantor_Search__c='Positive');
    		insert conObj;
        Application_Contact_Role__c acrObj = new Application_Contact_Role__c(Application__c = appObj.Id, Contact__c=conObj.Id, Contract_Name__c = '', Show_on_Contract__c = 'name', Relationship__c = 'Owner'); 	
        
        ApexPages.StandardController sObjectName = New ApexPages.StandardController(acrObj);
        NewApplicationContactContExt naac = new NewApplicationContactContExt (sObjectName);  
        //naac.saveContact();      
        Pagereference myPr = naac.saveContact();
        system.assertNotEquals(null, myPr, 'non-null page reference');
        system.assertEquals(0, Apexpages.getMessages().size(), 'page reference has messages');
    }    
    
	static testMethod void NewApplicationContactContExt_nickname_validParams_returnsNothing() 
    {
        User testUser = TestServices.createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = TestServices.createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);
        Opportunity opp = TestServices.createTestOpportunity('Test Opp', 'Closed Won', 'Indianapolis', true);
        Application__c appObj = TestServices.createTestApplication(opp.Id, 'Shull', true);
    	Contact conObj = new Contact(FirstName='TestFirstName', LastName='TestLastName', Previous_Account_Guarantor_Search__c='Positive');
    		insert conObj;
        Application_Contact_Role__c acrObj = new Application_Contact_Role__c(Application__c = appObj.Id, Contact__c=conObj.Id, Contract_Name__c = '', Show_on_Contract__c = 'nickname', Relationship__c = 'Owner'); 	
        
        ApexPages.StandardController sObjectName = New ApexPages.StandardController(acrObj);
        NewApplicationContactContExt naac = new NewApplicationContactContExt (sObjectName);  
        //naac.saveContact();      
        Pagereference myPr = naac.saveContact();
        system.assertNotEquals(null, myPr, 'non-null page reference');
        system.assertEquals(0, Apexpages.getMessages().size(), 'page reference has messages');
    }        

	static testMethod void NewApplicationContactContExt_blank_validParams_returnsNothing() 
    {
        User testUser = TestServices.createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = TestServices.createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);
        Opportunity opp = TestServices.createTestOpportunity('Test Opp', 'Closed Won', 'Indianapolis', true);
        Application__c appObj = TestServices.createTestApplication(opp.Id, 'Shull', true);
    	Contact conObj = new Contact(FirstName='TestFirstName', LastName='TestLastName', Previous_Account_Guarantor_Search__c='Positive');
    		insert conObj;
        Application_Contact_Role__c acrObj = new Application_Contact_Role__c(Application__c = appObj.Id, Contact__c=conObj.Id, Contract_Name__c = '', Show_on_Contract__c = '', Relationship__c = 'Owner'); 	
        
        ApexPages.StandardController sObjectName = New ApexPages.StandardController(acrObj);
        NewApplicationContactContExt naac = new NewApplicationContactContExt (sObjectName);  
        //naac.saveContact();      
        Pagereference myPr = naac.saveContact();
        system.assertNotEquals(null, myPr, 'non-null page reference');
        system.assertEquals(0, Apexpages.getMessages().size(), 'page reference has messages');
    }         
}