/**
  * Apex Class: ArticleTaggingControllerTest
  * Description: Test class for ArticleTaggingController
  * Created By: Ashish Sharma (Appirio Off)
  * Created Date: September 11th, 2013.
*/
@isTest
private class ArticleTaggingControllerTest {
    static Intranet_Content__c article1;
    
    static testMethod void myUnitTest() {
        
        createData();
        Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(article1);
        ArticleTaggingController controller = new ArticleTaggingController(stdController);
        controller.getListOfArticleTags();
        ArticleTaggingController.WrapperClass wrap = ArticleTaggingController.fetchListOfTags();
        //Assert test for listOfTags
        System.assertNotEquals(null, wrap);
        
        Map<String, Id> tagMap = ArticleTaggingController.mapOfTagNameAndId;
        //Assert test for tagMap
        System.assertNotEquals(null, tagMap);
        
        ArticleTaggingController.addTags('Test Tag', article1.Id);
        //Assert test for Intranet_Content_Tags__c
        System.assertNotEquals(null, [SELECT ID FROM Intranet_Content_Tags__c 
                                      WHERE Intranet_Content__c =: article1.Id]);
    }
    
    static testMethod void nonAdminUserTest() {
    	
      List<Profile> profileList = [select id from Profile where Name='Intranet User' limit 1];
	    Id profileId;
	    User usr;
	    if(profileList.get(0) != null)
	    {
	        profileId = profileList.get(0).Id;    
	    }
	    
	    usr= new User();
	    usr.Email              = 'test'+ Integer.valueOf(Math.random()) +'@virginamerica.com';
	    usr.Username           = 'test' + Integer.valueOf(Math.random()) + '@testuser1.com';
	    usr.LastName           = 'test' ;
	    usr.Alias              = 'test' ;
	    usr.ProfileId          = profileId ;
	    usr.LanguageLocaleKey  = 'en_US';
	    usr.LocaleSidKey       = 'en_US';
	    usr.TimeZoneSidKey     = 'America/Chicago';
	    usr.EmailEncodingKey   = 'UTF-8';
	    insert usr;
	    
      createData();
      
      Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(article1);
	    ArticleTaggingController controller = new ArticleTaggingController(stdController);
	    controller.getListOfArticleTags();
	    system.runAs(usr) {
        ArticleTaggingController.WrapperClass wrap = ArticleTaggingController.fetchListOfTags();
	      //Assert test for listOfTags
        System.assertNotEquals(null, wrap);
	    }
	    
	    
	    
	    Map<String, Id> tagMap = ArticleTaggingController.mapOfTagNameAndId;
	    //Assert test for tagMap
	    System.assertNotEquals(null, tagMap);
	    
	    ArticleTaggingController.addTags('Test Tag', article1.Id);
	    //Assert test for Intranet_Content_Tags__c
	    System.assertNotEquals(null, [SELECT ID FROM Intranet_Content_Tags__c 
	                                  WHERE Intranet_Content__c =: article1.Id]);
      
    }
    
    static void createData() {
        String recordTypeId = Schema.SObjectType.Intranet_Content__c.getRecordTypeInfosByName().get('Intranet Article').getRecordTypeId();
        //Insert new Intranet_Article__c records
        article1 = new Intranet_Content__c();
        article1.Type__c = 'Global Alert';
        article1.Start_Date__c = Datetime.now();
        article1.End_Date__c = Datetime.now().addDays(5);
        //article1.Pages__c = 'Brand';
        article1.RecordTypeId = recordTypeId;
        insert article1;
        
        Tags__c testTag = new Tags__c();
        testTag.Tag__c = 'Test Tag';
        insert testTag;
        
        Intranet_Content_Tags__c contentTag = new Intranet_Content_Tags__c();
        contentTag.Intranet_Content__c = article1.Id;
        contentTag.Tags__c = testTag.Id;
        insert contentTag;
    }
}