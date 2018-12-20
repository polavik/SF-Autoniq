@isTest
private class SellerPortalConfigHelperTest {
	
	@isTest static void Method_1() {
		
		List<Seller_Portal_Config__c> listCustObj = new List<Seller_Portal_Config__c>();
		listCustObj = TestUtility.createSellerPortalConfig();


		Test.startTest();
		SellerPortalConfigHelper.getSellerPortalConfig(null, null);	
		Account acc = [Select Id From Account where Name = 'Account1' limit 1];	
		SellerPortalConfigHelper.getSellerPortalConfig(null, 'AudiDirect');	
		SellerPortalConfigHelper.getSellerPortalConfig(acc.Id, 'AudiDirect');	
		Test.stopTest();

	}




}