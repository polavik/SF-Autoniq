/**
  * Apex Class: KAR_CollapsibleControllerTest
  * Description: Test class for KAR_CollapsibleController
  * Created By: Matt Salpietro
  * Created Date: 11 Feb, 2016
*/
@isTest
public class KAR_CollapsibleControllerTest {
  static testmethod void CollapsibleComponentControllerTest(){
    Intranet_Content__c article1 = IntranetTestUtility.createIntranetContent('Intranet Collapsible Content', null, 'Test Banner', false);
    article1.Status__c = 'Published';
    insert article1;
    
    Intranet_Content_Version__c intraContVer1 = IntranetTestUtility.createContentVersion(article1.Id, true);

    Tags__c tag = IntranetTestUtility.createTag('Home', true);
    IntranetTestUtility.createContentTag(article1.Id, tag.Id, true);

    KAR_CollapsibleController conObj = new KAR_CollapsibleController();
    system.assertNotEquals(conObj.contentList.size(),0);
  }
}