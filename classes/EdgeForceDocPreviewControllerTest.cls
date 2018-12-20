@isTest(SeeAllData=False)
public class EdgeForceDocPreviewControllerTest {
    public static TestMethod void docPreviewControllerTest(){   
         
         List<ContentDocument> documents=EdgeForceDocPreviewControllerTest.createData();                       
                     
         ApexPages.currentPage().getParameters().put('hideHeaders', 'test');       
         EdgeForceDocPreviewController docPreview = new EdgeForceDocPreviewController();
         docPreview.resourceIdInController = documents.get(0).Id;
         docPreview.processContent();       
   
         System.assert(docPreview.baseURL != null);
  
        
        
                  
          
        
    }
    public TestMethod static List<ContentDocument> createData()
    {
        Intranet_content__c intraCon = new Intranet_content__c();
    	intraCon.Name = 'Allowed Preview Formats';
    	intraCon.Value__c='Test';
        intraCon.RecordTypeId = Schema.SObjectType.Intranet_Content__C.getRecordTypeInfosByName().get('Config - Portal').getRecordTypeId();
        insert intraCon;
        
         ContentVersion contentVersion_1 = new ContentVersion(
      	 Title = 'Penguins',
     	 PathOnClient = 'Penguins.jpg',
      	 VersionData = Blob.valueOf('Test Content'),
         IsMajorVersion = true
   		 );
    	 insert contentVersion_1;
        
         ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
   		 List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
       	 System.debug('content document'+ documents);    
         return documents;

    }
  
   
    
   
    
    

}