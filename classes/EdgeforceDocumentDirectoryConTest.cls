/**
  * Apex Class: EdgeforceDocumentDirectoryConTest
  * Description: Test class for EdgeforceDocumentDirectoryController
  * Created By: Ashish Sharma (Appirio Off)
  * Created Date: February 5, 2016
*/
@isTest
public class EdgeforceDocumentDirectoryConTest{

    static testMethod void docDirectoryTest(){
        ContentVersion doc = new ContentVersion();
        Blob beforeblob = Blob.valueOf('Testing base 64 encode');
        doc.VersionData = beforeblob;
        doc.Title = 'title1';
        doc.PathOnClient = 'xyz';
        insert doc;
        
        Test.startTest();
            ApexPages.currentPage().getParameters().put('name', Label.All);
            EdgeforceDocumentDirectoryController docDirectory = new EdgeforceDocumentDirectoryController();
            docDirectory.libraryName = 'Test';
            docDirectory.fetchContents();
        Test.stopTest();
    }

}