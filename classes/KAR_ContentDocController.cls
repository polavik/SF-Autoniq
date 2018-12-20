@RestResource(urlMapping='/ContentDoc/*') 
global class KAR_ContentDocController { 
  @HttpGet global static void getBlob() { 
    RestRequest req = RestContext.request; 
    String Id= RestContext.request.requestURI.substring(RestContext.request.requestURI.lastIndexOf('/')+1);
    for(ContentVersion contentObj : [SELECT Title, ContentModifiedById,ContentDocumentId,FileExtension,FileType,ContentSize,ContentUrl,Id,VersionData,VersionNumber FROM ContentVersion where ContentDocumentId=:Id OR Id=:Id LIMIT 1]){
      System.debug(contentObj);
        RestResponse res = RestContext.response;
        res.addHeader('Title',contentObj.Title);
        res.addHeader('Content-Extension',contentObj.FileExtension); 
        if(contentObj.FileExtension == 'pdf'){            
          res.addHeader('Content-Type','application/pdf');
        }
        else if(contentObj.FileExtension == 'mp4'){
          res.addHeader('Content-Type','video/mp4'); 
        }
        else if(contentObj.FileExtension == 'jpg'){
          res.addHeader('Content-Type','image/jpeg'); 
        }
        else if(contentObj.FileExtension == 'docx'){
          res.addHeader('Content-Type','application/vnd.openxmlformats-officedocument.wordprocessingml.document');
        }
        else if(contentObj.FileExtension == 'xlsx'){
          res.addHeader('Content-Type','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        }
         else if(contentObj.FileExtension == 'svg'){
          res.addHeader('Content-Type','image/svg+xml');
        }
        else if(contentObj.FileExtension=='png'){
          res.addHeader('Content-Type','image/png');
        }
        else{
            res.statusCode = 404;
        }     
       res.responseBody = contentObj.VersionData; 
    }    
  } 
}