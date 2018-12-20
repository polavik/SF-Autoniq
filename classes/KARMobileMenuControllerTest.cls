@isTest
private class KARMobileMenuControllerTest {
	
	@isTest 
	static void testMenuCreation() {
		
		IntranetTestDataBuilder.buildDefaultMenu();

		Test.startTest();

		KARMobileMenuController ctrl = new KARMobileMenuController();

		System.assert(!ctrl.finalMenuList.isEmpty(), 'The menu list was not populated by the controller.');

		Test.stopTest();
	}
	
}