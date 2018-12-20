/**
  * Apex Class: IntranetBannerControllertest
  * Description: test class for IntranetBannerController
  * Created By: Dipika Gupta (Appirio Off)
  * Created Date: 17 Dec,2012
*/
@isTest(seeAllData=false)
private class EdgeForceIntranetBannerControllerTest {
    
  private static testmethod void bannerSectionTest(){
    RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Intranet_Content__c' and DeveloperName = 'Config_Portal'];
    Intranet_content__c  IC = new Intranet_content__c (Name =userinfo.getLanguage(),value__c = 'English',recordTypeId = RecType.id);
    insert IC;
    Intranet_Content__c intranetConfing = new Intranet_Content__c(Name='Banner_Rotating_Speed', Value__c = '20000', recordtypeid = RecType.id ); 
    insert intranetConfing ;

    Intranet_Content__c banner1 = IntranetTestUtility.createIntranetContent('Intranet Banner', null, 'Test Banner', false);
    banner1.Status__c = 'Published';
    insert banner1;
    
    Intranet_Content_Version__c intraContVer1 = IntranetTestUtility.createContentVersion(banner1.Id, true);

    Tags__c tag = IntranetTestUtility.createTag('Test1', true);
    IntranetTestUtility.createContentTag(banner1.Id, tag.Id, true);

    //Set IntranetHome as current page
    PageReference pageRef = Page.KAR_Team;
    Test.setCurrentPage(pageRef);
    
    //Pass parameteres to current page
    ApexPages.currentPage().getParameters().put('name', 'Test1');
    EdgeForceIntranetBannerController conObj = new EdgeForceIntranetBannerController();
    
    //assert valid banner list size
    system.assert(conObj.banners.size() > 0);
    system.assertEquals(conObj.banner_Roating_Speed,20000);
  }

}