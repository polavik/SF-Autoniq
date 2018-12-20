/**
  * Apex Class: KAR_FooterControllerTest
  * Description: Test class for KAR_FooterController
  * Created By: Matt Salpietro
  * Created Date: 11 Feb, 2016
*/
@isTest
public class KAR_FooterControllerTest {
    static testmethod void FooterComponentControllerTest(){
        Intranet_Content__c parentLink1 = IntranetTestUtility.createIntranetContent('Intranet Link', 'Footer Link', 'Parent Link 1', false);
        parentLink1.Sequence__c = '1';
        parentLink1.URL__c = '#';
        parentLink1.Status__c = 'Published';
        insert parentLink1;

        List<Intranet_Content__c> childLinks = new List<Intranet_Content__c>();
        Intranet_Content__c childLink1 = IntranetTestUtility.createIntranetContent('Intranet Link', 'Footer Link', 'Child Link 1', false);
        childLink1.Sequence__c = '1';
        childLink1.URL__c = '#';
        childLink1.Status__c = 'Published';
        childLink1.Parent__c = parentLink1.Id;
        childLinks.add(childLink1);

        Intranet_Content__c childLink2 = IntranetTestUtility.createIntranetContent('Intranet Link', 'Footer Link', 'Child Link 2', false);
        childLink2.Sequence__c = '2';
        childLink2.URL__c = '#';
        childLink2.Status__c = 'Published';
        childLink2.Parent__c = parentLink1.Id;
        childLinks.add(childLink2);

        insert childLinks;
        
        childLinks.add(parentLink1);
        List<Intranet_Content_Version__c> linkVersions = new List<Intranet_Content_Version__c>();
        for(Intranet_Content__c link : childLinks){
            Intranet_Content_Version__c icv = IntranetTestUtility.createContentVersion(link.Id, false);
            icv.URL__c = '#';
        	linkVersions.add(icv);
        }
        insert linkVersions;
        
        KAR_FooterController conObj = new KAR_FooterController();
        system.assertEquals(3,conObj.idToWrapperFooterMap.size());
        for(List<EdgeForceIntranetContentController.ContentVersionWrapper> linkList : conObj.parentIdtoChildFooterMap.values()){
        	system.assertEquals(2,linkList.size());
        }
    }
}