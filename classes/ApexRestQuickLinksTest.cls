//
// (c) 2016, Appirio Inc.
//
// Test Call for ApexRestIntranetContent 
//
// 24 OCT 2016     Chris Binovi
//
@isTest(seeAllData = false)
private class  ApexRestQuickLinksTest {


	static testMethod void testRestService() {
 
        createTestData();
        Test.startTest();
        RestRequest request = new RestRequest(); 
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;
        request.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/' + 'ApexRestQuickLinks';     
        request.httpMethod = 'GET';
          
        list<ApexRestQuickLinks.ReturnQuickLink> results = ApexRestQuickLinks.doGet();            
        
	    system.assertEquals(1, results.size());
        Test.stopTest();

	}
	
	static void createTestData() {
        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Intranet_Content__c' and DeveloperName = 'Config_Portal'];
        Intranet_content__c  IC = new Intranet_content__c (Name =userinfo.getLanguage(),value__c = 'English',recordTypeId = RecType.id);
        insert IC;
        
        String recordTypeId = Schema.SObjectType.Intranet_Content__c.getRecordTypeInfosByName().get('Intranet Link').getRecordTypeId();
        
        
        //Insert new Intranet_Article__c records
        Intranet_Content__c link = new Intranet_Content__c();
        link.Type__c = 'Quick Link';
        link.Status__c = 'Published';
        link.Start_Date__c = Datetime.now();
        link.End_Date__c = Datetime.now().addDays(5);
        link.RecordTypeId = recordTypeId;
        link.URL__c = 'www.google.com';
        insert link;
        
        Intranet_Content_Version__c intraContVer = new Intranet_Content_Version__c();
        intraContVer.Intranet_Content__c = link.Id;
        intraContVer.Language__c = 'English';
        intraContVer.URL__c = 'www.google.com';
        insert intraContVer;
        
        //Attach attachments to Intranet Links records
        IntranetTestUtility.createAttachment(true, link.ID);

	}
}