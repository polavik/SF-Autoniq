/**
  * Apex Class: KAR_BusinessUnitComponentCtrlTest
  * Description: Test class for KAR_BusinessUnitComponentController
  * Created By: Matt Salpietro
  * Created Date: 11 Feb, 2016
*/
@isTest
public class KAR_BusinessUnitComponentCtrlTest {
    static testmethod void KAR_BusinessUnitComponentCtrlTest(){
    		List<Intranet_Content__c> buPages = new List<Intranet_Content__c>();

        Intranet_Content__c page1 = IntranetTestUtility.createIntranetContent('Business Unit Pages', null, 'Test BU Page 1', false);
        page1.Status__c = 'Published';
        page1.Template__c = 'Team';
        buPages.add(page1);

        Intranet_Content__c page2 = IntranetTestUtility.createIntranetContent('Business Unit Pages', null, 'Test BU Page 2', false);
        page2.Status__c = 'Published';
        page2.Template__c = 'Content';
        buPages.add(page2);

        Intranet_Content__c page3 = IntranetTestUtility.createIntranetContent('Business Unit Pages', null, 'Test BU Page 3', false);
        page3.Status__c = 'Published';
        page3.Template__c = 'Content Full';
        buPages.add(page3);

        insert buPages;
        
        List<Intranet_Content_Version__c> pageVersions = new List<Intranet_Content_Version__c>();
        for(Intranet_Content__c page : buPages){
        	pageVersions.add(IntranetTestUtility.createContentVersion(page.Id, false));
        }
        insert pageVersions;

        KAR_BusinessUnitComponentController conObj = new KAR_BusinessUnitComponentController();
        system.assertEquals(conObj.intranetList.size(),3);
    }
}