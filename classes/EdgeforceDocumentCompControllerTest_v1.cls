/*
*@author  : Debadyuti Sil
*@purpose : Test Class for EdgeForceDocumentComponent
*/
@isTest
public class EdgeforceDocumentCompControllerTest_v1{
    @isTest(seealldata=true)
    static   void processAllDocumenResourcesTest(){
         test.startTest();
        
                 
                ContentWorkSpace cwMaster = [Select Id from ContentWorkSpace Limit 1]; //where Name like '%Teva Master'];
                ContentWorkspace lib = [Select c.Id,c.Name From ContentWorkspace c where c.ID !=:cwMaster.id Limit 1]; //(Name like '%Teva Master') limit 1];
                
               ContentVersion libdoc = new ContentVersion();
                Blob beforeblob = Blob.valueOf('Testing base 64 encode');
                libdoc.VersionData = beforeblob;
                libdoc.Title = 'title1';
                libdoc.PathOnClient = 'xyz';
                //libdoc.FirstPublishLocationId = cwMaster.id;
               // libdoc.Start_Date__c = System.now();
                //libdoc.Team__c = lib.name;
                //libdoc.Team_Category__c = 'Hotel discount';
                //libdoc.End_Date__c = System.now().addMinutes(60);
                insert libdoc;
                system.assert(libdoc.id <> null);
                     
                
                ContentDocument contentdocmain = [Select id,LatestPublishedVersionId from ContentDocument where LatestPublishedVersionId =: libdoc.id];
                
                
                
                //Insert new Intranet_Article__c records
                Intranet_Content__c article1 = new Intranet_Content__c();
                article1.Name = 'Test Team Page';
                article1.Template__c = 'Team';
                article1.Sequence__c = '1';
                article1.Start_Date__c = Datetime.now();
                article1.End_Date__c = Datetime.now().addDays(5);
                //article1.Pages__c = 'Brand';
                insert article1;
                
                system.assert(article1.id <> null);
                
                Intranet_Content_Version__c intraContVer1 = new Intranet_Content_Version__c();
                intraContVer1.Intranet_Content__c = article1.Id;
                intraContVer1.Language__c = 'English';
                insert intraContVer1;
                
                system.assert(intraContVer1.id <> null);
                
                 //Insert new doc records[ATTACHMENT]
                Intranet_Content__c doc1 = new Intranet_Content__c();
                doc1.Name = 'Test Doc';
                doc1.Resources_Categories__c = 'Template';
                doc1.Template__c = 'Team';
                doc1.Sequence__c = '1';     
                doc1.Document_Location__c = 'Attachment';
                doc1.Start_Date__c = Datetime.now();
                doc1.End_Date__c = Datetime.now().addDays(5);
                //article1.Pages__c = 'Brand';
                insert doc1;
                
               system.assert(doc1.id <> null);
                
                Intranet_Content_Version__c docContVer1 = new Intranet_Content_Version__c();
                docContVer1.Intranet_Content__c = doc1.Id;
                docContVer1.Language__c = 'English';
                insert docContVer1;
                
                system.assert(docContVer1.id <> null);
        
        
           
                 //Insert new Intranet_Article__c records[URL]
                Intranet_Content__c doc2 = new Intranet_Content__c();
                doc2.Name = 'Test Doc2';
                doc2.Resources_Categories__c = 'Template';
                doc2.Template__c = 'Team';
                doc2.Sequence__c = '2';
                doc2.URL__c = 'http://www.cloudspokes.com';
                doc2.Start_Date__c = Datetime.now();
                doc2.End_Date__c = Datetime.now().addDays(5);
                insert doc2;
                
                system.assert(doc2.id <> null);
                
                Intranet_Content_Version__c docContVer2 = new Intranet_Content_Version__c();
                docContVer2.Intranet_Content__c = doc2.Id;
                docContVer2.Language__c = 'English';
                insert docContVer2;
                
               system.assert(docContVer2.id <> null);
               
                 Intranet_Content__c doc3 = new Intranet_Content__c();
                doc3.Name = 'Test Doc3';
                doc3.Resources_Categories__c = 'Templare';
                doc3.Template__c = 'Team';
                doc3.Document_Location__c = 'Chatter';
                doc3.Sequence__c = '3';
                doc3.Start_Date__c = Datetime.now();
                doc3.End_Date__c = Datetime.now().addDays(5);
                insert doc3;
                
               
                
                
                system.assert(doc3.id <> null);
        
        
                FeedItem contentFI = new FeedItem();
                contentFI.Type = 'ContentPost';
                contentFI.ParentId =doc3.id;
                contentFI.RelatedRecordId = contentdocmain.LatestPublishedVersionId;
                //contentFI.title = 'Content Post';
                contentFI.Body = 'Body of content post';
                insert contentFI;
                 system.assert(contentFI.id <> null);
                Intranet_Content_Version__c docContVer3 = new Intranet_Content_Version__c();
                docContVer3.Intranet_Content__c = doc3.Id;
                docContVer3.Language__c = 'English';
                insert docContVer3;
                
               system.assert(docContVer3.id <> null);
               

         
                Tags__c testTag = new Tags__c();
                testTag.Tag__c = 'Test Team Page';
                insert testTag;
                
                system.assert(testTag.id <> null);  
              
                Intranet_Content_Tags__c testContentTag = new Intranet_Content_Tags__c();
                testContentTag.Intranet_Content__c  = doc1.Id;
                testContentTag.Tags__c = testTag.Id;
                insert testContentTag ;
        
                Intranet_Content_Tags__c testContentTag2 = new Intranet_Content_Tags__c();
                testContentTag2.Intranet_Content__c  = doc2.Id;
                testContentTag2.Tags__c = testTag.Id;
                insert testContentTag2 ;
        
                  Intranet_Content_Tags__c testContentTag3 = new Intranet_Content_Tags__c();
                testContentTag3.Intranet_Content__c  = doc3.Id;
                testContentTag3.Tags__c = testTag.Id;
                insert testContentTag3 ;
   
                system.assert(testContentTag.id <> null);  
                system.assert(testContentTag2.id <> null); 
                  
               // Attachment testarticle = TestUtil.createAttachment(true, doc1.Id);
               // TestUtil.createIntranetConfig(true, 'Allowed Test Preview Formats', 'PDF,GIF');
                
                //Set IntranetContent as current page
                PageReference pageRef = Page.EF_Team;
                Test.setCurrentPage(pageRef);  
                pageRef.getParameters().put('name','Test Team Page');    
                pageRef.getParameters().put('tabName','Teams');
               
                EdgeforceDocumentCompController testcontroller = new EdgeforceDocumentCompController();  
                testcontroller.processAllDocumenResources();
        
                pageRef.getParameters().put('DocumentIdParam',doc3.id);                 
                testcontroller.processDocument();
        
                pageRef.getParameters().put('DocumentIdParam',doc1.id);                 
                testcontroller.processDocument();
        
        
                test.stopTest();
            }
        }