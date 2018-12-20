/**
* Apex Class: KAR_CollapsibleController
* Description: This class is used to fetch collapsible content
* Created By: Matt Salpietro
* Created Date: 6th February 1016
* LastModifiedBy : 
* LastModifiedDate : 
* RelatedTo :
*/
public with sharing class KAR_CollapsibleController {
	DateTime todayDate = DateTime.now();
	public String currentPageName {get;set;} {currentPageName = 'Home';}
	public List<EdgeForceIntranetContentController.ContentVersionWrapper> contentList {get;set;} 
    public boolean pageTypeFAQ {get; set;}
	private String RECORDTYPE_COLLAPSIBLE_CONTENT = 'Intranet Collapsible Content';
    private String pageName;

   public String jctest {get; set;}

	public KAR_CollapsibleController() {
		contentList = getAllContent();
		System.debug('KCC2 count' + contentList.size());
		for(EdgeForceIntranetContentController.ContentVersionWrapper x : contentList) {
			System.debug('KCC2-contructor:TMS ' + x.contentVersionforDisplay.Team_Mission_Statement__c);
			System.debug('KCC2-contructor:DSC ' + x.contentVersionforDisplay.Description__c);
		}
		   
	}

	/*
	*Method to process all details
	*author Debadyuti Sil
	*/
	public List<EdgeForceIntranetContentController.ContentVersionWrapper> getAllContent(){
		List<EdgeForceIntranetContentController.ContentVersionWrapper> tempListofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
		List<EdgeForceIntranetContentController.ContentVersionWrapper> listofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
		
  	    try{pageName = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('name'), 'UTF-8');}
		catch(Exception e){pageName = 'Home';}
		
		pageTypeFAQ = true;
		if(pageName.compareTo('Home') == 0) pageTypeFAQ = false;
		
		// AND Content_Bucket__r.Name=\'' + pageName + '\''
		String queryString =  'SELECT Name, URL__c, Target__c, (SELECT Tags__r.Tag__c FROM Intranet_Content_Tags__r), Content_Bucket__r.Name FROM Intranet_Content__c WHERE Start_Date__c <= :todayDate AND End_Date__c >= :todayDate AND RecordType.Name = \''+ RECORDTYPE_COLLAPSIBLE_CONTENT+ '\'';
		EdgeForceIntranetContentController contentController = new EdgeForceIntranetContentController();
		tempListofLocalContentVersionWrapper = contentController.processContentAndVersion(queryString);
		System.debug('KCC1 count=' + tempListofLocalContentVersionWrapper.size());
		for(EdgeForceIntranetContentController.ContentVersionWrapper x : tempListofLocalContentVersionWrapper) {
			System.debug('KCC1-contructor:TMS ' + x.contentVersionforDisplay.Team_Mission_Statement__c);
			System.debug('KCC1-contructor:DSC ' + x.contentVersionforDisplay.Description__c);
		}		
		jctest = queryString + 'yields ' + tempListofLocalContentVersionWrapper.size() + ' rows.';
	 	for(Intranet_Content__c content : [SELECT Id, Name, Description__c FROM Intranet_Content__c
											WHERE Start_Date__c <= :todayDate
											   AND End_Date__c >= :todayDate
                                               AND Status__c = 'Published'
                                               AND REcordType.Name = : RECORDTYPE_COLLAPSIBLE_CONTENT
											ORDER BY Sequence__c]){
			for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempListofLocalContentVersionWrapper)   {
				if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(content.Id).substring(0,15)){
					listofLocalContentVersionWrapper.add(wrapper);
				}
			}   
		}                                   
		return listofLocalContentVersionWrapper;  
	}  
}