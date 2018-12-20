/**
  * Apex Class: IntranetNewsFeedComponentControllerTest
  * Description: test class for IntranetNewsFeedComponentController
  * Created By: Dipika Gupta (Appirio Off)
  * Created Date: 17 Dec,2012
*/
@isTest(seeAllData=true)
private class EdgeForceIntranetNewsFeedCompContTest {
    
    private static testmethod void NewsFeedComponentControllerTest(){
        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Intranet_Content__c' and DeveloperName = 'Config_Portal'];
        Intranet_content__c  IC = new Intranet_content__c (Name =userinfo.getLanguage(),value__c = 'English',recordTypeId = RecType.id);
        insert IC;
        Intranet_Content__c intranetConfing = new Intranet_Content__c(Name='Banner_Rotating_Speed', Value__c = '20000', recordtypeid = RecType.id ); 
        insert intranetConfing ;
        String recordTypeId = Schema.SObjectType.Intranet_Content__c.getRecordTypeInfosByName().get('Intranet Article').getRecordTypeId();
        
        //Insert new Intranet_Article__c records
        Intranet_Content__c article1 = new Intranet_Content__c();
        article1.Type__c = 'News';
        article1.Start_Date__c = Datetime.now();
        article1.End_Date__c = Datetime.now().addDays(5);
        //article1.Pages__c = 'Brand';
        article1.RecordTypeId = recordTypeId;
        Intranet_Content__c article2 = new Intranet_Content__c();
        article2.Type__c = 'News';
        article2.Start_Date__c = Datetime.now();
        article2.End_Date__c = Datetime.now().addDays(5);
        //article2.Pages__c = 'Brand';
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
        
        EdgeForceIntranetNewsFeedCompController conObj = new EdgeForceIntranetNewsFeedCompController();
        //set PageIds according to which Intranet_Article__c records have to be retrieved
        conObj.pageId = 'Brand';
        
        //Assert newsFeed list has some data
        system.assertNotEquals(conObj.newsList.size(),null);
        system.assertEquals(conObj.banner_Roating_Speed,20000);
    }
}