/**
  * Apex Class: EdgeForceIntranetChtFileSearchControllerTest
  * Description: Test class for EdgeForceIntranetChtFileSearchController
  * Created By: Ashish Sharma (Appirio Off)
  * Created Date: November 16th, 2013.
*/
@isTest
private class EdgeforceChtFileSearchControllerTest {

  static testMethod void testChatterFileSearch() {
    
    //create ContentVersion instance
    Blob beforeblob = Blob.valueOf('Testing base 64 encode');
    ContentVersion doc1 = new ContentVersion();
    doc1.VersionData = beforeblob;
    doc1.Title = 'title1';
    doc1.PathOnClient = 'xyz';
    insert doc1;

    //Check the content inserted
    System.assert(doc1.Id != null);
    
    ApexPages.currentPage().getParameters().put('searchInput', 'title1');
    EdgeForceIntranetChtFileSearchController controller = new EdgeForceIntranetChtFileSearchController();
    controller.processfileSearch();
    controller.clear();
    controller.processfilesSearchMore();
    
    System.assert(controller.listoffiles <> null);
  }
  
}