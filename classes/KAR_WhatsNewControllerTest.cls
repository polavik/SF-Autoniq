/**
  * Apex Class: KAR_WhatsNewControllerTest
  * Description: Test class for KAR_WhatsNewController
  * Created By: Matt Salpietro
  * Created Date: 11 Feb, 2016
*/
@isTest
public class KAR_WhatsNewControllerTest {
    static testmethod void WhatsNewComponentControllerTest(){
        Intranet_Content__c article1 = IntranetTestUtility.createIntranetContent('What\'s New Banner', null, 'Test Banner', false);
        article1.Status__c = 'Published';
        insert article1;
        
        Intranet_Content_Version__c intraContVer1 = IntranetTestUtility.createContentVersion(article1.Id, true);

        Tags__c tag = IntranetTestUtility.createTag('Home', true);
        IntranetTestUtility.createContentTag(article1.Id, tag.Id, true);

        KAR_WhatsNewController conObj = new KAR_WhatsNewController();
        system.assertNotEquals(conObj.banners.size(),0);
    }
}