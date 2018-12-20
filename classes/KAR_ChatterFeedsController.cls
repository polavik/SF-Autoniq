/**
  * Apex Class: KAR_ChatterFeedsController
  * Description: Controller for KAR_ChatterFeeds component. Displays chatter feeds in tabbed view within Edgeforce.
  * Created By: Matt Salpietro
  * Created Date: Jan 30 2016
  * LastModifiedBy : 
  * LastModifiedDate : 
  * RelatedTo : Maintain IntranetList as per the selected current page.
  */
public with sharing class KAR_ChatterFeedsController {
	private static String RECORDTYPE_CHATTER_FEED = 'Chatter Feed';

	//public FeedWrap currentFeed {get;set;}
  public Map<String,FeedWrap> feedMap {get;set;}
  public String feedName {get;set;}
  public boolean isMobile {get; set;}


	public KAR_ChatterFeedsController() {
  	   // Are we in mobile?
  	   if(null == ApexPages.currentPage().getParameters().get('hideHeaders') || '' == ApexPages.currentPage().getParameters().get('hideHeaders')) isMobile=false;
  	   else isMobile=true;
  			
		// Set feed map if first load
		if(feedMap == null){
			feedMap = new Map<String,FeedWrap>();
			Set<String> groups = new Set<String>();
			Set<String> topics = new Set<String>();
			Set<String> users = new Set<String>();

			// Get all Chatter Feed Intranet Content records and sort by entity type
			for(EdgeForceIntranetContentController.ContentVersionWrapper cw : getAllFeeds()){
				String val = cw.contentVersionforDisplay.Value__c != null ? cw.contentVersionforDisplay.Value__c : cw.content.Value__c;
				if(val.startsWith('@')){ // Users
					users.add(val.substring(1));
				}else if(val.startsWith('#')){ // Topics
					topics.add(val.substring(1));
				}else{ // Groups
					groups.add(val);
				}
				feedMap.put(val,new feedWrap(cw.contentVersionforDisplay.Name,val,cw.content.Type__c));
			}

			// Get IDs for entities
			for(CollaborationGroup cg : [SELECT Id, Name FROM CollaborationGroup WHERE Name IN :groups]){
				feedMap.get(cg.Name).feedId = cg.Id;
			}
			for(User u : [SELECT Id, Name FROM User WHERE Name IN :users]){
				feedMap.get('@'+u.Name).feedId = u.Id;
			}
			for(Topic t : [SELECT Id, Name FROM Topic WHERE Name IN :topics]){
				feedMap.get('#'+t.Name).feedId = t.Id;
			}
			// Remove if no Id fount for entity
			for(String fw : feedMap.keySet()){
				if(feedMap.get(fw).feedId == null){
					feedMap.remove(fw);
				}
			}
			// Set first feed in map
			if(feedMap.size()>0){
				feedName = feedMap.values()[0].feedName;
			}
		}
	}

	public PageReference setFeeds(){
    return null;
  }

  // Get all Chatter Feed Intranet Content records that are Published Status and tagged with current page
	public List<EdgeForceIntranetContentController.ContentVersionWrapper> getAllFeeds(){
		List<EdgeForceIntranetContentController.ContentVersionWrapper> tempListofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
		List<EdgeForceIntranetContentController.ContentVersionWrapper> listofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
	  String queryString = 'SELECT Id, Value__c, Type__c, (Select Tags__r.Tag__c From Intranet_Content_Tags__r) FROM Intranet_Content__c WHERE RecordType.Name = \''+RECORDTYPE_CHATTER_FEED+'\' ORDER BY Sequence__c';
	  EdgeForceIntranetContentController contentController = new EdgeForceIntranetContentController();
	  tempListofLocalContentVersionWrapper = contentController.processContentAndVersion(queryString);
	  for(Intranet_Content__c content : [SELECT Id FROM Intranet_Content__c
																	  	 WHERE Status__c = 'Published'
																	  	 AND RecordType.Name = :RECORDTYPE_CHATTER_FEED
																	  	 ORDER BY Sequence__c]){
	  	for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempListofLocalContentVersionWrapper)    {
	  		if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(content.Id).substring(0,15)){
	  			listofLocalContentVersionWrapper.add(wrapper);
	  		}
	  	}
	  }
	  return listofLocalContentVersionWrapper;
	}

	// Feed wrapper
	public class feedWrap{
		public String feedName {get;set;}
		public String feedId {get;set;}
		public String feedType {get;set;}
		public String feedTitle {get;set;}

		public feedWrap(String fTitle, String fName, String fType){
			feedName = fName;
			feedType = fType;
			feedTitle = fTitle;
		}
	}

}