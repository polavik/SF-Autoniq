/*
*@author  : Debadyuti Sil
*@purpose : controller for EdgeForceDocumentComponent
*/
public class EdgeforceDocumentCompController {
    
    public String pageNameParam;
    public List<String> listofContentIds{get;set;}
    public List<Intranet_Content__c> listofResourceContents{get;set;}
    public Map<String,Attachment> mapofContentIdandAttachment {get;set;}
    public String documentInController{get;set;}
    public DocProperty currentDoc {get;set;}
    public Map<String,Intranet_Content__c> mapofContentIdandContent{get;set;}
    public Map<String,List<Intranet_Content__c>> mapofcategoryandContents{get;set;}
    public List<String> listofResourceCategories{get;set;}
    public Map<String,String> mapofcontentIdandChatterDoc{get;set;}
    public String allowedPreviewFormats{get; set;}
    public String currentICId{get;set;}
    public boolean contentFlag{get;set;}{contentFlag = false;}
    
    public Class DocProperty{
        public String docName{get;set;}
        public String docId{get;set;}
        public String docType{get;set;}
    }
    
    public EdgeforceDocumentCompController(){
        
        listofContentIds = new List<String>();
        listofResourceContents = new List<Intranet_Content__c>();
        mapofContentIdandAttachment = new Map<String,Attachment>();
        mapofContentIdandContent = new Map<String,Intranet_Content__c>();
        mapofcategoryandContents = new  Map<String,List<Intranet_Content__c>>();
        listofResourceCategories = new   List<String>();  
        mapofcontentIdandChatterDoc = new Map<String,String>();
        currentDoc = new DocProperty();
        
        if(ApexPages.currentPage().getParameters().get('name') <> null && ApexPages.currentPage().getParameters().get('name') <> ''){
         pageNameParam = ApexPages.currentPage().getParameters().get('name');
        }
        allowedPreviewFormats = '';
        for(Intranet_content__c config : [Select Name, value__c 
                                            From Intranet_content__c 
                                            where recordType.Name = 'Config - Portal'
                                                AND Name like 'Allowed Preview Formats']) {
        
            if(allowedPreviewFormats == ''){
                allowedPreviewFormats = config.Value__c;
            }
            else{
                allowedPreviewFormats += ',' + config.Value__c;
            }
        }
       try{
        
        processAllDocumenResources();
       }catch(exception e){
        
       }
    }
    
    
    public void processAllDocumenResources(){
    
        system.debug('**pageNameParam*'+pageNameParam);
        String tagId = '';
        //get tagId
        for(Tags__c tagData : [SELECT Id, OwnerId, IsDeleted, Name, Tag__c FROM Tags__c where tag__c =: pageNameParam]){
            tagId = tagData.Id;
        }
        system.debug('**tagId*'+tagId);
        //get all resources
        if(tagId <> null && tagId <> ''){
         for(Intranet_Content_Tags__c contentTag : [SELECT Id, Intranet_Content__c , Tags__c FROM Intranet_Content_Tags__c where Tags__c= :tagId]){         
           if(contentTag.Intranet_Content__c <> null){
              listofContentIds.add(contentTag.Intranet_Content__c);
           }
          }
          Set<String> setofContentIdshavingURLBlank = new  Set<String>();
          Set<String> setofallchattercontentIds = new   Set<String>();
          datetime currentTime = system.now();
          for(Intranet_Content__c contentData : [Select Id,Name,Document_Location__c,Sequence__c,URL__c,start_date__c,End_date__c,Resources_Categories__c from Intranet_Content__c  Where Id IN : listofContentIds and start_date__c <=: currentTime and End_date__c >=: currentTime order by Sequence__c ]){
            listofResourceContents.add(contentData);
            mapofContentIdandContent.put(contentData.Id,contentData);
            
                if(contentData.URL__c == null){
                  setofContentIdshavingURLBlank.add(contentData.Id);
                }
                if(contentData.Resources_Categories__c <> null){
                    if(mapofcategoryandContents.containskey(contentData.Resources_Categories__c)){
                        Set<Intranet_Content__c> allconset = new set<Intranet_Content__c>();
                         List<Intranet_Content__c> allconlist = new List<Intranet_Content__c>();
                        allconset.addall(mapofcategoryandContents.get(contentData.Resources_Categories__c));
                        allconset.add(contentData);
                        allconlist.addall(allconset);
                        mapofcategoryandContents.put(contentData.Resources_Categories__c,allconlist);
                    }else{
                        List<Intranet_Content__c> newConList = new List<Intranet_Content__c>();
                        newConList.add(contentData);
                        mapofcategoryandContents.put(contentData.Resources_Categories__c,newConList);
                    }
                }
            
            
            
            
          }
          
                if(mapofcategoryandContents <> null && mapofcategoryandContents.keyset() <> null && mapofcategoryandContents.keyset().size()>0){
                    contentFlag = true;
                }
                          
                Set<String> allresourceset = new Set<String>();
                allresourceset.addall(mapofcategoryandContents.keyset());
                listofResourceCategories.addall(allresourceset);
                for(String resourseName : listofResourceCategories){
                    List<Intranet_Content__c> listofsortedData = new     List<Intranet_Content__c>();
                    if(mapofcategoryandContents.get(resourseName) <> null && mapofcategoryandContents.get(resourseName).size()>1){
                       listofsortedData = sortBysequence(mapofcategoryandContents.get(resourseName));
                       mapofcategoryandContents.put(resourseName,listofsortedData);
                    }
                }
                
                
                
          system.debug('****mapofcategoryandContents***'+mapofcategoryandContents);
          
          //process  attached DocumentData        
          for(Attachment attachmentData : [SELECT Id,  ParentId, Name,ContentType 
                                           FROM Attachment
                                           Where ParentId  IN : setofContentIdshavingURLBlank]){
                                            
            mapofContentIdandAttachment.put(attachmentData.ParentId,attachmentData);
          }
          
          
    
        }
    }
    
    public void processDocument(){
        try{
        
            if(apexpages.currentPage().getParameters().get('DocumentIdParam') <> null){
                 currentICId = apexpages.currentPage().getParameters().get('DocumentIdParam') ;
                  currentDoc = new DocProperty();
                if(mapofContentIdandContent.get(currentICId).Document_Location__c == 'Attachment'){
                     currentDoc.docId = mapofContentIdandAttachment.get(currentICId).Id;
                     currentDoc.docName = mapofContentIdandContent.get(currentICId).Name;
                     if(mapofContentIdandAttachment.containskey(currentICId) && mapofContentIdandAttachment.get(currentICId).contentType <> null && mapofContentIdandAttachment.get(currentICId).contentType.split('/').size()>0){
                        currentDoc.docType =  mapofContentIdandAttachment.get(currentICId).contentType.touppercase();
                           SYSTEM.DEBUG('****** currentDoc.docType********'+ currentDoc.docType);
                     }
                }
                 else if(currentICId <> null && mapofContentIdandContent <> null && mapofContentIdandContent.containskey(currentICId) && mapofContentIdandContent.get(currentICId).Document_Location__c == 'Chatter'){
                     currentDoc.docName = mapofContentIdandContent.get(currentICId).Name;
                      String docId = '';
                      for(ContentDocumentLink docLink :[SELECT Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType 
                                               FROM ContentDocumentLink 
                                               where LinkedEntityId = : currentICId]){
                                                if(docLink <> null)
                                                docId  = docLink.ContentDocumentId;
                                                
                                               }
                         for(ContentDocument docData : [SELECT Id,  LatestPublishedVersionId FROM ContentDocument where id =: docId]){
                                    if(currentDoc <> null)
                                    currentDoc.docId =  docData.LatestPublishedVersionId;
                         }
                         for(ContentVersion versiondata : [SELECT Id,FileType FROM ContentVersion where id=: currentDoc.docId]){
                             currentDoc.docType = versiondata.FileType.trim().touppercase();
                         }
                                               
             
                       }
            }
        }catch(Exception e){
            
        }
        
        system.debug('***currentDoc*'+currentDoc);
    }
    
    public List<Intranet_Content__c> sortBysequence(List<Intranet_Content__c> listofmixedContent){
        Map<Integer,Intranet_Content__c> mapofSequenceandContent = new Map<Integer,Intranet_Content__c>();
        for(Intranet_Content__c mixcontent : listofmixedContent){
            mapofSequenceandContent.put(Integer.valueof(mixcontent.sequence__c),mixcontent);
            
        }
        List<Integer> sequenceList = new List<Integer>();
        sequenceList.addall(mapofSequenceandContent.keyset());
        sequenceList.sort();
        List<Intranet_Content__c> returnedList = new List<Intranet_Content__c>();
        for(Integer seq : sequenceList){
            returnedList.add(mapofSequenceandContent.get(seq));
        }
        return returnedList;
    } 

}