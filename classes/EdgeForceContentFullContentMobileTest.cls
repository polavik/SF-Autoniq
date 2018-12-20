// (c) 2015 Appirio, Inc.
//
// 04 August, 2015    Prakarsh Jain		Test Class for EdgeForceContentFullConController
//
@isTest
public class EdgeForceContentFullContentMobileTest {
    static testMethod void EdgeForceContentFullContentMobile(){
        User sysAdmin = IntranetTestUtility.createUser(1, true);
        system.runAs(sysAdmin){
            Intranet_Content__c intraContent = new Intranet_Content__c();
            intraContent = IntranetTestUtility.createIntranetContent('Intranet Article', 'News', 'View Org Charts in Workday', true);

            Intranet_Content_Version__c intraVersion = new Intranet_Content_Version__c();
       		intraVersion = IntranetTestUtility.createContentVersion(intraContent.Id, true);

			Test.startTest();
			String queryString =  'SELECT URL__c, Frame_Height__c, Target__c, (SELECT Id, Name FROM Attachments LIMIT 1) FROM Intranet_Content__c  ORDER BY Sequence__c';
			EdgeForceContentFullContentMobile contentController = new EdgeForceContentFullContentMobile();
      		contentController.categoryType = 'Content';
      		List<EdgeForceIntranetContentController.ContentVersionWrapper> tempListofLocalContentVersionWrapper = contentController.processContentAndVersion(queryString); 
      		
      		system.assertEquals(1, tempListofLocalContentVersionWrapper.size());
        	Test.stopTest();
             
        }
    }
}