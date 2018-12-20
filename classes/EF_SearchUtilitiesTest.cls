@isTest
private class EF_SearchUtilitiesTest {
	@isTest static void PrivateIntranetContentTestSmall() {
		List<Intranet_Content__c> banners = new List<Intranet_Content__c>();
        Intranet_Content__c banner = IntranetTestUtility.createIntranetContent('Intranet Banner', null, 'Banner 1', false);
        banner.Sequence__c = '1';
        banner.Status__c = 'Published';
        insert banner;
        banners.add(banner);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Intranet User']; 
        User u = new User(Alias = 'test99', Email='testuser99@adesa.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Chicago', UserName='testuser99@adesa.com.fake');
    	System.runAs(u) {
			Test.startTest();
			System.assertEquals(1, banners.size());
			EF_SearchUtilities.RemoveUnauthorizedFromList(banners);
			System.assertEquals(0, banners.size());
			Test.stopTest();
		}
	}
	@isTest static void PrivateIntranetContentTestLarge() {
		List<Intranet_Content__c> banners = new List<Intranet_Content__c>();
        for (Integer i = 1; i<=225; i++){
            Intranet_Content__c banner = IntranetTestUtility.createIntranetContent('Intranet Banner', null, 'Banner 1', false);
            banner.Sequence__c = '1';
            banner.Status__c = 'Published';            
	        banners.add(banner);
        }
        insert banners;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Intranet User']; 
        User u = new User(Alias = 'test99', Email='testuser99@adesa.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Chicago', UserName='testuser99@adesa.com.fake');
    	System.runAs(u) {
			Test.startTest();
			System.assertEquals(225, banners.size());
			EF_SearchUtilities.RemoveUnauthorizedFromList(banners);
			System.assertEquals(0, banners.size());
			Test.stopTest();
		}
	}    
}