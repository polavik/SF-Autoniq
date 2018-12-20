//
// (c) 2016, Appirio Inc.
//
// Test Call for ApexRestContentAutoComplete 
//
// 24 OCT 2016     Chris Binovi
//
@isTest(seeAllData = false)
private class ApexRestContentAutoCompleteTest {


	static testMethod void testRestService() {
 
        createTestData();
        Test.startTest();
        RestRequest request = new RestRequest(); 
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;
        request.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/' + 'ApexRestContentAutoComplete';  
        request.addParameter('queryValue', 'Tes');       
        request.httpMethod = 'GET';
          
        list<String> results = ApexRestContentAutoComplete.doGet();            
        
	    system.assertEquals(2, results.size());
        Test.stopTest();

	}
	static void createTestData() {
		Intranet_Content__c intranetConentRec1 = new Intranet_Content__c();
		intranetConentRec1.Name = 'Test1';
		insert  intranetConentRec1;
		
		Intranet_Content__c intranetConentRec2 = new Intranet_Content__c();
		intranetConentRec1.Name = 'Test2';
		insert  intranetConentRec2;

		ContentVersion cv = new ContentVersion(title='Test', contentUrl='http:///www.foor.bar');
		insert cv;
		ContentVersion cvRes = [select id, ContentDocument.id, ContentDocument.title 
		                         from ContentVersion where id= :cv.id];
		ContentDocument cd = cv.ContentDocument;
				
	}
}