//
// (c) 2016, Appirio Inc.
//
// Test Call for ApexRestIntranetContent 
//
// 24 OCT 2016     Chris Binovi
//
@isTest(seeAllData = false)
private class ApexRestIntranetContentTest {


	static testMethod void testRestService() {
 
        createTestData();
        Test.startTest();
        RestRequest request = new RestRequest(); 
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;
        request.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/' + 'ApexRestIntranetContent';     
        request.httpMethod = 'GET';
          
        list<ApexRestIntranetContent.IntranetContent> results = ApexRestIntranetContent.doGet();            
        
	    system.assertEquals(1, results.size());
        Test.stopTest();

	}
	
	static void createTestData() {
        Intranet_Content__c banner = IntranetTestUtility.createIntranetContent('Intranet Banner', null, 'Banner 1', false);
        banner.Sequence__c = '1';
        banner.Status__c = 'Published';
        insert banner;
        
        IntranetTestUtility.createContentVersion(banner.Id, true);
        Tags__c homeTag = IntranetTestUtility.createTag('Home', true);
        IntranetTestUtility.createContentTag(banner.Id, homeTag.Id, true);
        
        //Attach attachments to Intranet Links records
        IntranetTestUtility.createAttachment(true, banner.Id);

	}
}