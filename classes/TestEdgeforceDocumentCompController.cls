/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestEdgeforceDocumentCompController {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test

         ApexPages.currentPage().getParameters().put('name','Test Tag02');
        
 		Tags__c testTag = new Tags__c( tag__c = 'Test Tag02');
 		insert testTag;
        
 		Tags__c testTag1 = new Tags__c( tag__c = 'Test Tag03');
        insert testTag1;

        
		Intranet_Content__c content = new Intranet_Content__c(
		      Name = 'Allowed Preview Formats',  RecordTypeId = '01213000001WHlDAAW',
			  Page_Type__c='Brand',  Type__c = 'contentType',
		      Start_Date__c = system.now(), End_Date__c = system.now().addDays(30),
		      Resources_Categories__c = 'Templates', URL__c =null,sequence__c ='3',
		      Document_Location__c = 'Attachment'
		      );
        insert content;
		Intranet_Content__c content1 = new Intranet_Content__c(
		      Name = 'Allowed Preview Formats',  RecordTypeId = '01213000001WHlDAAW',
			  Page_Type__c='Brand',  Type__c = 'contentType',
		      Start_Date__c = system.now(), End_Date__c = system.now().addDays(30),
		      Resources_Categories__c = 'Templates', URL__c ='testurl',sequence__c ='2',
		      Document_Location__c = 'Attachment'
		      );
        insert content1;
        apexpages.currentPage().getParameters().put('DocumentIdParam',content1.id);
       
        Intranet_Content_Tags__c ict = IntranetTestUtility.createContentTag(content.id, testTag.id,true);
        Intranet_Content_Tags__c ict1 = IntranetTestUtility.createContentTag(content1.id, testTag.id,true);
        
		Account acct = new Account(Name = 'Test Account');
		insert acct;
		Blob attachBody = Blob.valueOf('attachment body');
		Attachment attach = new Attachment(Name = 'TestAttachment', ParentId = content.Id, 
				Body = attachBody, ContentType= 'image/jpeg');
		insert attach;
		Attachment attach1 = new Attachment(Name = 'TestAttachment1', ParentId = content.Id, 
				Body = attachBody, ContentType= 'image/pjpeg');
		insert attach1;

                        
        EdgeforceDocumentCompController efc = new EdgeforceDocumentCompController();
        efc.processDocument();
        
        
    }
}