@isTest
                        
global class MockHttpGetExcelReport implements HttpCalloutMock {
   	@TestVisible static final Blob MOCK_BODY= Blob.valueOf('TestCallout');
   	@TestVisible static Integer statusCode=200;

    global HTTPResponse respond(HTTPRequest req) {
    	HttpResponse res = new HttpResponse();
        res.setBodyAsBlob(MOCK_BODY);
        res.setStatusCode(statusCode);

        return res;
    }
}