/**
* Apex Class: KAR_WhatsNewController
* Description: This class is used to fetch What's New banners
* Created By: Matt Salpietro
* Created Date: 6th February 1016
* LastModifiedBy : 
* LastModifiedDate : 
* RelatedTo : Maintain banners list as per the selected current page.
*/
public with sharing class KAR_WhatsNewController {
	DateTime todayDate = DateTime.now();
	public String currentPageName {get; set;}{currentPageName = 'Home';}
	public List<EdgeForceIntranetContentController.ContentVersionWrapper> banners{get;set;} 
	public List<EdgeForceIntranetContentController.ContentVersionWrapper> banners1{get;set;} 
	private String RECORDTYPE_WHATS_NEW_BANNER = 'Whats_New_Banner';

	public KAR_WhatsNewController() {
		//Initialize all properties
		banners = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
		banners1 = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
		banners1 = getAllBannerDetails();

		for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : banners1){
			banners.add(wrapper);
		}
	}

	/*
	*Method to process all details
	*author Debadyuti Sil
	*/
	public List<EdgeForceIntranetContentController.ContentVersionWrapper> getAllBannerDetails(){
		List<EdgeForceIntranetContentController.ContentVersionWrapper> tempListofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
		List<EdgeForceIntranetContentController.ContentVersionWrapper> listofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
		//String queryString =  'SELECT URL__c, Target__c, Image_Overlay__c, (SELECT Id, Name FROM Attachments LIMIT 1), (SELECT Tags__r.Tag__c FROM Intranet_Content_Tags__r) FROM Intranet_Content__c WHERE Start_Date__c <= :todayDate AND End_Date__c >= :todayDate AND RecordType.DeveloperName = \''+RECORDTYPE_WHATS_NEW_BANNER+'\'';
		String queryString =  'SELECT URL__c, Target__c, Image_Overlay__c, (SELECT Id, Name FROM Attachments LIMIT 1), (SELECT Tags__r.Tag__c FROM Intranet_Content_Tags__r) FROM Intranet_Content__c WHERE Start_Date__c <= TODAY AND End_Date__c >= TODAY AND RecordType.DeveloperName = \''+RECORDTYPE_WHATS_NEW_BANNER+'\'';
        
        system.debug('queryString===' +queryString);
		EdgeForceIntranetContentController contentController = new EdgeForceIntranetContentController();
		tempListofLocalContentVersionWrapper = contentController.processContentAndVersion(queryString);
		system.debug('tempListofLocalContentVersionWrapper===' +tempListofLocalContentVersionWrapper);
        system.debug('qwerty=='+[SELECT Id FROM Intranet_Content__c
																			 WHERE Start_Date__c <= :todayDate
																			 AND End_Date__c >= :todayDate
                                       AND Status__c = 'Published'
																			 AND RecordType.DeveloperName = :RECORDTYPE_WHATS_NEW_BANNER
																			 LIMIT 1]);
        
		for(Intranet_Content__c content : [SELECT Id FROM Intranet_Content__c
																			 WHERE Start_Date__c <= :todayDate
																			 AND End_Date__c >= :todayDate
                                       AND Status__c = 'Published'
																			 AND RecordType.DeveloperName = :RECORDTYPE_WHATS_NEW_BANNER
																			 LIMIT 1]){
			for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempListofLocalContentVersionWrapper)   {
				if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(content.Id).substring(0,15)){
					listofLocalContentVersionWrapper.add(wrapper);
				}
			}   
		}                                    
		return listofLocalContentVersionWrapper;
	}
}