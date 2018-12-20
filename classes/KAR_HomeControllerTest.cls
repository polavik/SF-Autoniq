/**
  * Apex Class: KAR_HomeControllerTest
  * Description: Test class for KAR_HomeController
  * Created By: Matt Salpietro
  * Created Date: 1 Feb, 2016
*/
@isTest
private class KAR_HomeControllerTest {
    
    private static testmethod void homeControllerTest(){
        //Set IntranetHome as current page
        PageReference pageRef = Page.KAR_Home;
        Test.setCurrentPage(pageRef);
        
        //Pass parameteres to current page
        ApexPages.currentPage().getParameters().put('tabName', 'test');
        KAR_HomeController conObj = new KAR_HomeController();
        
        //assert controller's property 'pageName' value has been changed
        system.assertEquals(conObj.pageName,'test');
    }

}