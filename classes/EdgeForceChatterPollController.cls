public without sharing class EdgeForceChatterPollController {
	private static final String POLL_FEED = 'Home Page Poll Feed';
	private static final String POLL_POST_STR = 'PollPost';
	private static final String FALSE_STR = 'false';
    private static final String RT_CONFIG_PORTAL = 'Intranet Poll';
    private static final String PUBLIC_STR = 'public';

	public String entityIdString {get;set;}
	private String publisherString;
	private String filterString;
	private String groupName;
	public String currentPageName {get; set;}{currentPageName = 'Home';}
	
	public CollaborationGroupFeed pollPost {get;set;}
	public Map<Id,PollChoice> pollChoices {get;set;}
	public Boolean voted {get;set;}
	public Integer totalCount {get;set;}
	public String selectedChoice {get;set;}
	public String errorMsg {get;set;}
    
    public EdgeForceChatterPollController() {
    	getGroupName();
    	if(groupName != null){
    		if(loadData()){
		    	voted = [SELECT Id FROM FeedPollVote
						 			 WHERE FeedItemId = :pollPost.Id
						 			 AND CreatedById = :UserInfo.getUserId()].size() > 0;
					if(voted){
						loadVotes();
					}
				}
			} else {
				errorMsg = 'No Poll configuration found.';
			}
    }

    public PageReference submit() {
    	try{
    		ConnectApi.ChatterFeeds.voteOnFeedElementPoll(null,pollPost.Id,selectedChoice);
    		voted = true;
    	} catch (Exception ex) {

    	}
    	loadData();
    	loadVotes();
    	return null;
    }

    private Boolean loadData(){
	    entityIdString = '';
	    pollChoices = new Map<Id,PollChoice>();
    	totalCount = 0;
	    
	    for(CollaborationGroup chatterGrp : [SELECT Id, Name 
	                                         FROM CollaborationGroup 
	                                         WHERE CollaborationType = :PUBLIC_STR
	                                         AND Name = :groupName]) {
	    	entityIdString = chatterGrp.Id;
			}

    	for(CollaborationGroupFeed gf : [SELECT Id, Body
				    					 FROM CollaborationGroupFeed
									     WHERE ParentId = :entityIdString
									     AND Type = :POLL_POST_STR
									     ORDER BY CreatedDate DESC LIMIT 1]){
    		pollPost = gf;
    	}
    	if(pollPost == null){
    		errorMsg = 'No poll found for group';
    		return false;
    	}

			for(FeedPollChoice pc : [SELECT Id, ChoiceBody, Position
						   			 FROM FeedPollChoice
						   			 WHERE FeedItemId = :pollPost.Id
						   			 ORDER BY Position ASC]){
				pollChoices.put(pc.Id, new PollChoice(pc));
			}
			return true;
    }

    private void loadVotes(){
    	for(AggregateResult ar : [SELECT COUNT(Id) voteCount, ChoiceId, FeedItemId
								  FROM FeedPollVote
								  WHERE FeedItemId = :pollPost.Id
								  GROUP BY ChoiceId, FeedItemId]){
				pollChoices.get((Id)ar.get('ChoiceId')).voteCount = (Integer)ar.get('voteCount');
				totalCount += (Integer)ar.get('voteCount');
			}
    }

	public class PollChoice {
		public String choiceText {get;set;}
		public String choiceId {get;set;}
		public Integer voteCount {get;set;}

		public PollChoice(FeedPollChoice pc) {
			voteCount = 0;
			choiceText = pc.ChoiceBody;
			choiceId = pc.Id;
		}
	}

	/*
    *Method to get Group Name for current page
  */
  public void getGroupName(){
      List<EdgeForceIntranetContentController.ContentVersionWrapper> tempListofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
      List<EdgeForceIntranetContentController.ContentVersionWrapper> listofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
      String queryString = 'SELECT Value__c, (Select Tags__r.Tag__c FROM Intranet_Content_Tags__r) FROM Intranet_Content__c WHERE RecordType.Name =\''+RT_CONFIG_PORTAL+'\'';
      EdgeForceIntranetContentController contentController = new EdgeForceIntranetContentController();
      tempListofLocalContentVersionWrapper = contentController.processContentAndVersion(queryString);
      
      for(Intranet_Content__c content : [SELECT Id FROM Intranet_Content__c
                                         WHERE RecordType.Name = :RT_CONFIG_PORTAL]){
          for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempListofLocalContentVersionWrapper)    {
              if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(content.Id).substring(0,15)){
                  groupName = wrapper.content.Value__c;
              }
          }   
      }                                                                       
  }
    
}