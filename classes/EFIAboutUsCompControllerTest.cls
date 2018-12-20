/**
  * Apex Class: EFIAboutUsCompControllerTest
  * Description: Test class for EFIAboutUsCompController
  * Created By: Matt Salpietro
  * Created Date: Sept. 8, 2016
*/
@isTest
public with sharing class EFIAboutUsCompControllerTest {
  static testmethod void aboutUsControllerTest(){
  	Intranet_Content_Buckets__c bucket = IntranetTestUtility.createContentBucket(
  		'TestTeam', 'All Intranet Users', 'All Intranet Users', true
  	);

    Intranet_Content__c team1 = IntranetTestUtility.createIntranetContent(
    	'Team Page RT',
    	null,
    	'TestTeam',
    	false
    );
    team1.Status__c = 'Published';
    team1.Content_Bucket__c = bucket.Id;
    insert team1;

    Intranet_Content_Version__c intraContVer1 = IntranetTestUtility.createContentVersion(team1.Id, true);

    Tags__c tag = IntranetTestUtility.createTag('TestTeam', true);
    IntranetTestUtility.createContentTag(team1.Id, tag.Id, true);

    Intranet_Content__c aboutUs = IntranetTestUtility.createIntranetContent(
    	EdgeForceIntranetContentController.RECORDTYPE_ABOUT_US,
    	null,
    	'About Us',
    	false);
    aboutUs.Status__c = 'Published';
    aboutUs.Content_Bucket__c = bucket.Id;
    insert aboutUs;

    Intranet_Content_Version__c aboutUsVer = IntranetTestUtility.createContentVersion(aboutUs.Id, true);
    IntranetTestUtility.createContentTag(aboutUs.Id, tag.Id, true);

		PageReference pageRef = Page.KAR_Team;
		Test.setCurrentPage(pageRef);  
		pageRef.getParameters().put('name','TestTeam');  


	    ApexPages.currentPage().getParameters().put('category','category-test');

    EFIAboutUsCompController controller = new EFIAboutUsCompController();
    system.assertNotEquals(controller.pageId,null);
    system.assertNotEquals(controller.aboutUsList.size(),0);
  }
  
    static testmethod void myUnitTest1(){
    	
    	Test.startTest();
    	
  		PageReference pageRef = Page.KAR_Team;
		Test.setCurrentPage(pageRef);  
		pageRef.getParameters().put('name','');  

	    ApexPages.currentPage().getParameters().put('name',null);
  
	    EFIAboutUsCompController controller = new EFIAboutUsCompController();
	    controller.queryS = 'SELECT Id  from Intranet_Content__c limit 5';
	    controller.pageIdForContent = 'test---pageIdForContent'; 
	    
	    ApexPages.currentPage().getParameters().put('category',null);
	    
	    system.debug('-----controller.queryS =' +  controller.queryS);
	    system.debug('-----controller.fileId =' +  controller.fileId);
	  
	    system.debug('-----controller.pageIdForContent =' +  controller.pageIdForContent);
	    system.debug('-----controller.fileId =' +  controller.fileId);
  		
  		Test.stopTest();
    }
  
  
}