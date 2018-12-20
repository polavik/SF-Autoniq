@isTest
private class TestSandboxRefreshHelperHubUrlCleanup {
	
	private static String FULL_URL = 'https://kar.my.salesforce.com/apex/KAR_Home';
	private static String REFERENCE_URL = '/apex/KAR_Home';

	@testSetup static void setupData() {
		// Setup Custom Setting Data
		Hub_Sandbox_Refresh_Settings__c cs = new Hub_Sandbox_Refresh_Settings__c(Name = 'IntranetContentVersion',
																				 Batch_Query__c = 'SELECT Id, URL__c FROM Intranet_Content_Version__c WHERE URL__c != \'\'',
																				 Field_to_Update__c = 'URL__c');
		insert cs;

		// Create Content Records
		List<Intranet_Content__c> contents = new List<Intranet_Content__c>();
		for(Integer i = 0; i < 199; i++)
		{
			Intranet_Content__c content = IntranetTestUtility.createIntranetContent('Team Page RT', 'Content', 'Test Frame ' + i, false);
			contents.add(content);
		}

		// Create 1 record that will fail a validation rule preventing successful DML
		Intranet_Content__c frameContent = IntranetTestUtility.createIntranetContent('Intranet Article', 'Content', 'Test Frame', false);
		frameContent.Target__c = 'Frame';
		frameContent.Frame_Height__c = 20;
		contents.add(frameContent);

		insert contents;

		// Create Content Versions
		List<Intranet_Content_Version__c> versions = new List<Intranet_Content_Version__c>();
		for(Intranet_Content__c ic : contents)
		{
			Intranet_Content_Version__c version = IntranetTestUtility.createContentVersion(ic.Id, false);
			version.URL__c = FULL_URL;
			versions.add(version);
		}
		
		insert versions;
	}

	@isTest static void TestBatchProcess() {
		
		Test.startTest();
		// Execute batch and verify results
		SandboxRefreshHelperUtil_Sync.CleanHubUrls();
		Test.stopTest();

		for(Intranet_Content_Version__c icv : [SELECT Id, URL__c, Intranet_Content__r.Target__c FROM Intranet_Content_Version__c])
		{
			if(icv.Intranet_Content__r.Target__c != 'Frame')
			{
				System.assertEquals(REFERENCE_URL, icv.URL__c, 'The batch job did not clean the URL as expected');
			}
			else
			{
				System.assertEquals(FULL_URL, icv.URL__c, 'Validation rule should have prevented this URL from being modified.');
			}
		}

	}
	
	@isTest static void TestBatchException() {
		
		// Modifiy the custom setting and set the field value to a invalid field.  This should cause an exception
		Hub_Sandbox_Refresh_Settings__c cs = [SELECT Id, Batch_Query__c, Field_to_Update__c FROM Hub_Sandbox_Refresh_Settings__c LIMIT 1];
		cs.Field_to_Update__c = 'InvalidField';
		update cs;

		Test.startTest();
		// Execute batch and verify results
		SandboxRefreshHelperUtil_Sync.CleanHubUrls();
		Test.stopTest();

		for(Intranet_Content_Version__c icv : [SELECT Id, URL__c, Intranet_Content__r.Target__c FROM Intranet_Content_Version__c])
		{
			System.assertEquals(FULL_URL, icv.URL__c, 'An exception in the batch job should have prevented the field from updating.');		
		}
	}
	
}