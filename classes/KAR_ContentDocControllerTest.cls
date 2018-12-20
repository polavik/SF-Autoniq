@isTest
private class KAR_ContentDocControllerTest {
	

	public static String restResourceUri = '/services/apexrest/ContentDoc/';

	@testSetup
	static void createTestData()
	{
		// Create all Content Verions needed for test
		List<ContentVersion> cvs = new List<ContentVersion>();
		List<String> contTypes = new List<String>{'pdf', 'mp4', 'jpg', 'docx', 'xlsx', 'svg', 'png', '404'};		

		for(Integer i = 0; i < contTypes.size(); i++)
		{
			ContentVersion cv = new ContentVersion();
			cv.Title = 'Test Files with Extension ' + contTypes.get(i);
			cv.PathOnClient = 'FileName.' + contTypes.get(i);
			cv.VersionData = Blob.valueOf('somefakedata');
			cvs.add(cv);
		}
		insert cvs;
	}

	@isTest
	static void testForPdf() {

		ContentVersion cv = [SELECT Id FROM ContentVersion WHERE FileExtension = 'pdf' LIMIT 1];
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = restResourceUri + cv.Id;  
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		KAR_ContentDocController.getBlob();

		System.assertNotEquals(404, res.statusCode);
		System.assertEquals('application/pdf', res.headers.get('Content-Type'));
		System.assert(res.responseBody != null);		
	}
	
	@isTest
	static void testForMp4() {
		
		ContentVersion cv = [SELECT Id FROM ContentVersion WHERE FileExtension = 'mp4' LIMIT 1];
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = restResourceUri + cv.Id; 
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		KAR_ContentDocController.getBlob();

		System.assertNotEquals(404, res.statusCode);
		System.assertEquals('video/mp4', res.headers.get('Content-Type'));
		System.assert(res.responseBody != null);
	}
	
	@isTest
	static void testForJpg() {
		
		ContentVersion cv = [SELECT Id FROM ContentVersion WHERE FileExtension = 'jpg' LIMIT 1];
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = restResourceUri + cv.Id;  
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		KAR_ContentDocController.getBlob();

		System.assertNotEquals(404, res.statusCode);
		System.assertEquals('image/jpeg', res.headers.get('Content-Type'));
		System.assert(res.responseBody != null);
	}

	@isTest
	static void testForDocx() {
		
		ContentVersion cv = [SELECT Id FROM ContentVersion WHERE FileExtension = 'docx' LIMIT 1];
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = restResourceUri + cv.Id;  
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		KAR_ContentDocController.getBlob();

		System.assertNotEquals(404, res.statusCode);
		System.assertEquals('application/vnd.openxmlformats-officedocument.wordprocessingml.document', res.headers.get('Content-Type'));
		System.assert(res.responseBody != null);
	}

	@isTest
	static void testForXlsx() {
		
		ContentVersion cv = [SELECT Id FROM ContentVersion WHERE FileExtension = 'xlsx' LIMIT 1];
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = restResourceUri + cv.Id; 
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		KAR_ContentDocController.getBlob();

		System.assertNotEquals(404, res.statusCode);
		System.assertEquals('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', res.headers.get('Content-Type'));
		System.assert(res.responseBody != null);
	}

	@isTest
	static void testForSvg() {
		
		ContentVersion cv = [SELECT Id FROM ContentVersion WHERE FileExtension = 'svg' LIMIT 1];
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = restResourceUri + cv.Id;  
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		KAR_ContentDocController.getBlob();

		System.assertNotEquals(404, res.statusCode);
		System.assertEquals('image/svg+xml', res.headers.get('Content-Type'));
		System.assert(res.responseBody != null);
	}

	@isTest
	static void testForPng() {
		
		ContentVersion cv = [SELECT Id FROM ContentVersion WHERE FileExtension = 'png' LIMIT 1];
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = restResourceUri + cv.Id;  
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		KAR_ContentDocController.getBlob();

		System.assertNotEquals(404, res.statusCode);
		System.assertEquals('image/png', res.headers.get('Content-Type'));
		System.assert(res.responseBody != null);
	}

	@isTest
	static void testFor404() {
		
		ContentVersion cv = [SELECT Id FROM ContentVersion WHERE FileExtension = '404' LIMIT 1];
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = restResourceUri + cv.Id;  
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		KAR_ContentDocController.getBlob();

		System.assertEquals(404, res.statusCode);
	}
}