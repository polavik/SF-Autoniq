// (c) 2015 Appirio, Inc.
//
// 04 August, 2015    Prakarsh Jain		Test Class for EdgeForceVideoGalleryController
//
@isTest
public class EdgeForceVideoGalleryControllerTest {
    static testMethod void testEdgeForceVideoGalleryController(){
        User usr = IntranetTestUtility.createUser(1, true);
        system.runAs(usr){
            ApexPages.currentPage().getParameters().put('uid', usr.Id);
            EdgeForceVideoGalleryController edForceVideo = new EdgeForceVideoGalleryController();
            edForceVideo.goToNextPage();
            edForceVideo.goToPreviousPage();
            List<SelectOption> lstSelect = edForceVideo.listOfOrderingFields;
            Integer count = edForceVideo.userVideoCount;
            List<SelectOption> lstPageSize = edForceVideo.listOfPageSizes;
            ApexPages.currentPage().getParameters().put('uid', null);
            EdgeForceVideoGalleryController edForceVideo1 = new EdgeForceVideoGalleryController();
        }
    }
}