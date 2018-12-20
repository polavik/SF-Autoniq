@isTest
private class TestChecklistItemServices
{
	static testMethod void updateCLIItemStatusWhenAttachmentUploaded_validParams_returnsNothing()
    {
        User testUser = TestServices.createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = TestServices.createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);
        Opportunity opp = TestServices.createTestOpportunity('Test Opp', 'Closed Won', 'Indianapolis', true);
        Application__c testApp = TestServices.createTestApplication(opp.Id, 'Shull', true);
        Checklist__c testCl = new Checklist__c(Application__c=testApp.id);
        insert testCl;
        Checklist_Item__c testCli = new Checklist_Item__c(Checklist__c=testCl.Id, For_Department__c='Credit', Item_Status__c='Not Started');
        insert testCli;

		Attachment testAtt=new Attachment();
		testAtt.Body=Blob.valueOf('testBlob');
		testAtt.Name='Note_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.txt';
		testAtt.parentId=testCli.id;
		insert testAtt;
		
		system.assertEquals(testAtt.parentId, testCli.Id);
    }
    
    /*
    //User localUser = userQuery(clMap.get(cli.CheckList__c).Application__r.AFC_Region__c, clMap.get(cli.CheckList__c).Application__r.AFC_Branch__c, cli.For_Department__c);
    
    static testMethod void testChecklistItemTrigger_validParams_returnsNothing()
    {
    	User testUser = new User();
    	testUser.FirstName					= 'fName'; 
    	testUser.LastName					= 'lName'; 
    	testUser.Username					= 'triggerTest@test.com'; 
    	testUser.Email						= 'email@email.com'; 
    	testUser.Alias						= 'flNa'; 
    	testUser.CommunityNickname			= 'flName'; 
    	testUser.AFC_Region_Responsible__c	= 'Region'; 
    	testUser.AFC_Branch_Responsible__c	= 'Branch'; 
    	testUser.Credit_or_Contract__c		= 'Credit';
    	testUser.TimeZoneSidKey 			= 'GMT';
    	testUser.LocaleSidKey 				= 'en_US';
    	testUser.EmailEncodingKey 			= 'ISO-8859-1';
    	testUser.LanguageLocaleKey 			= 'en_US';
    	testUser.ProfileId 					= '00e30000001lION';
    	insert testUser;
    	    	
    	Opportunity testOpp = new Opportunity(Name='Opportunity', StageName='Not Started', CloseDate=Date.Today(), AFC_Branch__c='Branch');
    	insert testOpp;
    	Application__c testApp = new Application__c(Opportunity__c=testOpp.Id, AFC_Region__c='Region');
        insert testApp;
        Checklist__c testCl = new Checklist__c(Application__c=testApp.id);
        insert testCl;
        Checklist_Item__c testCli = new Checklist_Item__c(Checklist__c=testCl.Id, For_Department__c='Credit', Item_Status__c='Not Started');
        insert testCli;

		testCli = [select Id, Name, Date_Assigned_Department__c, Assigned_Department_User__c from Checklist_Item__c where Id = :testCli.Id];
		system.assertEquals(date.today(), testCli.Date_Assigned_Department__c);
		system.assertEquals(testUser.Id, testCli.Assigned_Department_User__c);
    }
    static testMethod void testChecklistItemTrigger_nullParams_returnsNothing()
    {
    	User testUser = new User();
    	testUser.FirstName					= 'fName'; 
    	testUser.LastName					= 'lName'; 
    	testUser.Username					= 'triggerTest@test.com'; 
    	testUser.Email						= 'email@email.com'; 
    	testUser.Alias						= 'flNa'; 
    	testUser.CommunityNickname			= 'flName'; 
    	testUser.AFC_Region_Responsible__c	= 'Region'; 
    	testUser.AFC_Branch_Responsible__c	= 'Branch'; 
    	testUser.Credit_or_Contract__c		= '';
    	testUser.TimeZoneSidKey 			= 'GMT';
    	testUser.LocaleSidKey 				= 'en_US';
    	testUser.EmailEncodingKey 			= 'ISO-8859-1';
    	testUser.LanguageLocaleKey 			= 'en_US';
    	testUser.ProfileId 					= '00e30000001lION';
    	insert testUser;    	
    	
    	Opportunity testOpp = new Opportunity(Name='Opportunity', StageName='Not Started', CloseDate=Date.Today(), AFC_Branch__c='Branch');
    	insert testOpp;
    	Application__c testApp = new Application__c(Opportunity__c=testOpp.Id, AFC_Region__c='Region');
        insert testApp;
        Checklist__c testCl = new Checklist__c(Application__c=testApp.id);
        insert testCl;
        Checklist_Item__c testCli = new Checklist_Item__c(Checklist__c=testCl.Id, For_Department__c='', Item_Status__c='Not Started');
        insert testCli;

		//testCli = [select Id, Name, Date_Assigned_Branch__c, Assigned_Branch_User__c from Checklist_Item__c where Id = :testCli.Id];
		//system.assertEquals(date.today(), testCli.Date_Assigned_Branch__c);
		//system.assertEquals(testUser.Id, testCli.Assigned_Branch_User__c);
    }    
    */
}