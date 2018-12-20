@isTest
private class EdgeForceContentFullCntntCntrTest {
	
	@testSetup
	static void createTestData()
	{
		User runAsUser = IntranetTestUtility.createUser(1, true, 'TestRunAsUser@adesa.com.testing');
        system.runAs(runAsUser){
            
            IntranetTestDataBuilder db = new IntranetTestDataBuilder().withTeamPage(false, true, false);
			db.build();
		}
	}

	@isTest
	static void testUrlParameters() {
		
		Intranet_Content__c teamPage = [SELECT Id FROM Intranet_Content__c WHERE Name = 'Test Team Page' LIMIT 1];
				
		Test.setCurrentPage(Page.KAR_Team);
		ApexPages.currentPage().getParameters().put('name' , 'testGroup');
		EdgeForceIntranetContentFullController intranetCon = new EdgeForceIntranetContentFullController();

		ApexPages.currentPage().getParameters().put('name', 'Test Team Page');
		ApexPages.currentPage().getParameters().put('tabName', 'Teams');
		ApexPages.currentPage().getParameters().put('id', teamPage.Id);

		Test.startTest();

		EdgeForceContentFullContentController fullConCtrl = new EdgeForceContentFullContentController(intranetCon);

		// Verify controller saw URL parameters
		System.assert(String.isNotBlank(fullConCtrl.tabName) && fullConCtrl.tabName != 'Home', 'tabName URL Parameter was not set');
		System.assert(String.isNotBlank(fullConCtrl.pageName) && fullConCtrl.pageName != 'Home', 'pageName URL Parameter was not set');

		Test.stopTest();
	}
	
}