/**
  * Apex Class: EdgeForceIntranetHomeControllerTest
  * Description: test class for IntranetHomeController
  * Created By: Dipika Gupta (Appirio Off)
  * Created Date: 17 Dec,2012
*/
@isTest
private class EdgeForceIntranetHomeControllerTest {
    
    private static testmethod void homeControllerTest(){
        //Set IntranetHome as current page
        PageReference pageRef = Page.KAR_Home;
        Test.setCurrentPage(pageRef);
        
        //Pass parameteres to current page
        ApexPages.currentPage().getParameters().put('tabName', 'test');
        EdgeForceIntranetHomeController conObj = new EdgeForceIntranetHomeController();
        
        //assert controller's property 'pageName' value has been changed
        system.assertEquals(conObj.pageName,'test');
    }

}