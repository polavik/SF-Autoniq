/**
  * Apex Class: IntranetNewsPageControllerTest
  * Description: Test class for IntranetNewsPageController
  * Created By: Ashish Sharma (JDC)
  * Created Date: 27 Dec,2013
*/
@isTest
private class EdgeforceIntranetNewsPageControllerTest {

    private static testmethod void newsPageControllerTest(){
        //Insert 'Intranet_Config__c' custom setting
        Intranet_Content__c config = IntranetTestUtility.createIntranetConfig(true, 'Banner_Rotating_Speed', '20000');

        //Insert new Intranet_Article__c records
        Intranet_Content__c article1 = IntranetTestUtility.createIntranetContent('Intranet Article', 'News', 'Test', false);
        article1.Status__c = 'Published';
        insert article1;
        Intranet_Content__c article2 =IntranetTestUtility.createIntranetContent('Intranet Article', 'News', 'Test 1', false);
        article2.Status__c = 'Published';
        insert article2;

        Intranet_Content_Version__c intraContVer1 = IntranetTestUtility.createContentVersion(article1.Id, true);

        Intranet_Content_Version__c intraContVer2 = IntranetTestUtility.createContentVersion(article2.Id, true);
    IntranetTestUtility.createAttachment(true, article1.Id);
    IntranetTestUtility.createAttachment(true, article2.Id);
        Tags__c testTag1 = IntranetTestUtility.createTag('Home', false);
        Tags__c testTag2 = IntranetTestUtility.createTag('HR', false);
        Tags__c testTag3 = IntranetTestUtility.createTag('Consumer', false);
        insert new List<Tags__c>{testTag1, testTag2, testTag3};

        Intranet_Content_Tags__c testContentTag1 = IntranetTestUtility.createContentTag(article1.Id, testTag1.Id, false);
        Intranet_Content_Tags__c testContentTag2 = IntranetTestUtility.createContentTag(article2.Id, testTag2.Id, false);
        Intranet_Content_Tags__c testContentTag3 = IntranetTestUtility.createContentTag(article1.Id, testTag3.Id, false);
                insert new List<Intranet_Content_Tags__c> {testContentTag1, testContentTag2, testContentTag3};
                
        EdgeforceIntranetNewsPageController conObj = new EdgeforceIntranetNewsPageController();
    conObj.addToDispalyList();
    System.assert(conObj.displayList <> null);
    
        ApexPages.currentPage().getParameters().put('nType', 'Home');
        conObj = new EdgeforceIntranetNewsPageController();
        conObj.offSet = 'Prev';
        conObj.addToDispalyList();
        
        ApexPages.currentPage().getParameters().put('nType', 'Home');
        conObj = new EdgeforceIntranetNewsPageController();
        conObj.offSet = 'Next';
        conObj.addToDispalyList();
    }
    
    
}