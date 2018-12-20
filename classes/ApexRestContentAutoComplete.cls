// 
// (c) 2016 Appirio, Inc.
//
// Apex REST service to return Content Document Title names & Intranet Content based on query string provided.
//
// 11 Oct 2016     Chris Binovi      
//
@RestResource(urlMapping='/ApexRestContentAutoComplete/*') 
global with sharing class ApexRestContentAutoComplete { 
    @HttpGet
    global static List<String> doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response; 
        String queryValueStr = '%' + RestContext.request.params.get('queryValue') + '%';
         
        
        List<String> resultsString = new List<String>();
        
        //Search Content
        List<ContentDocument> contentDocumentList = [SELECT Id, CreatedDate, CreatedById, 
        					LastModifiedById, LastModifiedDate, LatestPublishedVersionId, OwnerId, PublishStatus, SystemModstamp, Title 
        					FROM ContentDocument WHERE Title LIKE :queryValueStr ORDER BY LastModifiedDate DESC LIMIT 15];
        					
        for (ContentDocument contentDocumentRec: contentDocumentList){
        	resultsString.add(contentDocumentRec.Title);
        }
		
		
		//Search Intranet Content
        List<Intranet_Content__c> intranetContentList = [SELECT Name FROM Intranet_Content__c 
        					WHERE Name LIKE :queryValueStr ORDER BY LastModifiedDate DESC LIMIT 15];
        					
        for (Intranet_Content__c intranetContentRec: intranetContentList){
        	resultsString.add(intranetContentRec.Name);
        }		
		
        return resultsString;
    }

}