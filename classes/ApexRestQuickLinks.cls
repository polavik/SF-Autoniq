// 
// (c) 2016 Appirio, Inc.
//
// Apex REST service to return values for Quick Links
//
// 10 Oct 2016     Chris Binovi      
//
@RestResource(urlMapping='/ApexRestQuickLinks/*') 
global with sharing class ApexRestQuickLinks { 
    @HttpGet
    global static List<ReturnQuickLink> doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response; 
 
		EdgeForceIntranetLinkComponentController conObj = new EdgeForceIntranetLinkComponentController(); 
        
        List<EdgeForceIntranetContentController.ContentVersionWrapper> intranetList = conObj.intranetList;
      
        
        //Build image array
        List<Id> attachmentIdList = new List<Id>();
		for(EdgeForceIntranetContentController.ContentVersionWrapper intranetObj: intranetList  ) {
			List<Attachment> attachmentList = intranetObj.content.Attachments;
			if (attachmentList.size() > 0 ) { 
				attachmentIdList.add(attachmentList[0].Id);
			}			
		}

		//Get Attachments
        map<Id, Attachment> attachmentMap = new map<Id, Attachment>([SELECT Id, Body, Name, ContentType FROM Attachment WHERE Id IN :attachmentIdList]);
		
		

		//Populate ReturnQuickLink
		List<ReturnQuickLink> returnList = new List<ReturnQuickLink>();
		for(EdgeForceIntranetContentController.ContentVersionWrapper intranetObj: intranetList  ) {
			ReturnQuickLink returnQuickLinkRec = new ReturnQuickLink();
			returnQuickLinkRec.title =  intranetObj.contentVersionforDisplay.Name;
			returnQuickLinkRec.frameHeight = intranetObj.content.Frame_Height__c;
			returnQuickLinkRec.url = intranetObj.contentVersionforDisplay.URL__c; 
			System.debug('intranetObj.contentVersionforDisplay::' + intranetObj.contentVersionforDisplay);
			List<Attachment> attachmentList = intranetObj.content.Attachments;
			if (attachmentList.size() > 0 ) { 
				returnQuickLinkRec.imageName = attachmentList[0].Name;
				if (attachmentMap.containsKey(attachmentList[0].Id))  {
					returnQuickLinkRec.imageBlob = EncodingUtil.base64Encode(attachmentMap.get(attachmentList[0].Id).Body);
					returnQuickLinkRec.contentType = attachmentMap.get(attachmentList[0].Id).ContentType;
				}
			}
			returnList.add(returnQuickLinkRec);
		}
		
        return returnList; 
    }
    
	global class ReturnQuickLink {
		String title;
		String url;
		Decimal frameHeight;
		String imageName;
		String imageBlob;
		String contentType;

	}    

}