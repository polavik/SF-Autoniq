/**
  * Apex Class: EdgeForceIntranetNewsGridControllerTest
  * Description: Test class for EdgeForceIntranetNewsGridController
  * Created By: Matt Salpietro (Appirio)
  * Created Date: February 5th 2016
*/
@isTest
private class EdgeForceIntranetNewsGridControllerTest {
    
    private static testmethod void newsGridComponentControllerTest(){
        Intranet_Content__c banner = IntranetTestUtility.createIntranetContent('Intranet Banner', null, 'Banner 1', false);
        banner.Sequence__c = '1';
        banner.URL__c = '#';
        banner.Status__c = 'Published';
        insert banner;
        
        IntranetTestUtility.createContentVersion(banner.Id, true);
        Tags__c homeTag = IntranetTestUtility.createTag('Home', true);
        IntranetTestUtility.createContentTag(banner.Id, homeTag.Id, true);

        EdgeForceIntranetNewsGridController conObj = new EdgeForceIntranetNewsGridController();
        
        //Assert list has articles of Intranet Banner
        system.assertEquals(1, conObj.bannerList.size());
    }
}