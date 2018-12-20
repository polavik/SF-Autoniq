// 
// (c) 2016 Appirio, Inc.
//
// Apex REST service to return values in Intranet Content
//
// 10 Oct 2016     Chris Binovi      
//
@RestResource(urlMapping='/ApexRestIntranetContent/*') 
global with sharing class ApexRestIntranetContent { 
    @HttpGet
    global static List<IntranetContent> doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response; 
 
		EdgeForceIntranetNewsGridController conObj = new EdgeForceIntranetNewsGridController();  
        
        List<EdgeForceIntranetContentController.ContentVersionWrapper> intranetList = conObj.bannerList;
      
        
   		//Build image array
        List<Id> attachmentIdList = new List<Id>();
		for(EdgeForceIntranetContentController.ContentVersionWrapper intranetObj: intranetList  ) {
			if(intranetObj.content.Attachments != NULL) {
				List<Attachment> attachmentList = intranetObj.content.Attachments;
				if (attachmentList.size() > 0 ) { 
					attachmentIdList.add(attachmentList[0].Id);
				}	
			}		
		}

	 	//Get Attachments
        map<Id, Attachment> attachmentMap = new map<Id, Attachment>([SELECT Id, Body, Name, ContentType FROM Attachment WHERE Id IN :attachmentIdList]);
		
		

		//Populate IntranetContent
		List<IntranetContent> returnList = new List<IntranetContent>();
		for(EdgeForceIntranetContentController.ContentVersionWrapper intranetObj: intranetList  ) {
			IntranetContent returnIntranetContentRec = new IntranetContent();
			returnIntranetContentRec.name =  intranetObj.contentVersionforDisplay.Name;
			returnIntranetContentRec.title =  intranetObj.contentVersionforDisplay.Title__c;
			returnIntranetContentRec.description =  intranetObj.contentVersionforDisplay.Summary__c;
			returnIntranetContentRec.header =  intranetObj.contentVersionforDisplay.Header__c;
			returnIntranetContentRec.target =  intranetObj.content.Target__c;
			returnIntranetContentRec.targetURL =   intranetObj.contentVersionforDisplay.URL__c;
			returnIntranetContentRec.frameHeight =  intranetObj.content.Frame_Height__c;
			
			List<Attachment> attachmentList = intranetObj.content.Attachments;
			if (attachmentList.size() > 0 ) { 
				if (attachmentMap.containsKey(attachmentList[0].Id))  {
					returnIntranetContentRec.imageName = attachmentMap.get(attachmentList[0].Id).Name;
					returnIntranetContentRec.imageBlob = EncodingUtil.base64Encode(attachmentMap.get(attachmentList[0].Id).Body);
					returnIntranetContentRec.contentType = attachmentMap.get(attachmentList[0].Id).ContentType;
				}
			}
			returnList.add(returnIntranetContentRec);
		} 
		
        return returnList; 
    }
    

	global class IntranetContent {
		String url;
		String name;
		String title;
		String description;
		String target;
		String targetURL;
		String header;
		Decimal frameHeight;
		String imageBlob;
		String imageName;
		String contentType;		
	}    

}