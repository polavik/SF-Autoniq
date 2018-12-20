/**
  * Apex Class: IntranetRecentArticleControllerTest
  * Description: Test class for IntranetRecentArticleController
  * Created By: Ashish Sharma (Appirio Off)
  * Created Date: September 12th,2013
*/
@isTest
private class EdgeForceIntranetRecentArticleContTest {
    
    private static testmethod void testMethod1(){
        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Intranet_Content__c' and DeveloperName = 'Config_Portal'];
        Intranet_content__c  IC = new Intranet_content__c (Name =userinfo.getLanguage(),value__c = 'English',recordTypeId = RecType.id);
        insert IC;

        String recordTypeId = Schema.SObjectType.Intranet_Content__c.getRecordTypeInfosByName().get('Intranet Article').getRecordTypeId();
        //Insert new Intranet_Article__c records
        Intranet_Content__c article1 = new Intranet_Content__c();
        article1.Type__c = 'News';
        article1.Start_Date__c = Datetime.now();
        article1.End_Date__c = Datetime.now().addDays(5);
        //article1.Pages__c = 'Home';
        article1.RecordTypeId = recordTypeId;
        Intranet_Content__c article2 = new Intranet_Content__c();
        article2.Type__c = 'News';
        article2.Start_Date__c = Datetime.now();
        article2.End_Date__c = Datetime.now().addDays(5);
        //article2.Pages__c = 'Home';
        article2.RecordTypeId = recordTypeId;
        list<Intranet_Content__c> listArticle = new list<Intranet_Content__c>{article1,article2};
        insert listArticle;
        
        Intranet_Content_Version__c intraContVer1 = new Intranet_Content_Version__c();
        intraContVer1.Intranet_Content__c = article1.Id;
        intraContVer1.Language__c = 'English';
        
        Intranet_Content_Version__c intraContVer2 = new Intranet_Content_Version__c();
        intraContVer2.Intranet_Content__c = article2.Id;
        intraContVer2.Language__c = 'English';
        list<Intranet_Content_Version__c> listContentVer = new list<Intranet_Content_Version__c>{intraContVer1,intraContVer2};
        insert listContentVer;
        
        //set currentPage
        ApexPages.currentPage().getParameters().put('category', 'News');
        ApexPages.currentPage().getParameters().put('tabName', 'Home');
        Apexpages.currentPage().getParameters().put('id', article1.Id);
        
        EdgeForceIntranetRecentArticleController conObj = new EdgeForceIntranetRecentArticleController();
        
        //Assert newsFeed list has some data
        system.assertNotEquals(conObj.newsList, null);
    }
}