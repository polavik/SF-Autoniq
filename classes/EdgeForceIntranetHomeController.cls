/*******************************************************************
* Author        :  Harshit Jain 
* Name          :  IntranetHomeController
* Date          :  December 13,2012
* Description   :  Controller for IntranetHome                  
*******************************************************************/
public with sharing class EdgeForceIntranetHomeController {
  DateTime todayDate = DateTime.now();
  private static String CONFIG_CHATTER_FEED_REC_NAME = 'Config - Chatter Group';
  private static String RECORDTYPE_FEATURED_USER = 'Home Page Featured Employee';

  //String hold page name selected by current user on Intranet. 
  public String pageName {get;set;}
  public String feedId {get;set;}
  public String feedType {get;set;}

  public String chatterGroupName {get;set;}
  public String chatterGroupId {get;set;}
  public String recgFeedId {get;set;}
  public String feedName {get;set;}        
  public String RECOGNITION_FEED {get;set;}       
  public String ANNOUNCEMENT_FEED {get;set;}
  public List<Intranet_Content__c> featuredUsers {get;set;}        

  public String publisherString {get;set;}
  public String entityIdString {get;set;}
  public String filterString {get;set;}

  public Integer whatsUpChatterCount{get; set;}

  public boolean isMobile {get; set;}

  public EdgeForceIntranetHomeController(){
    //Default selected page would be home page
    pageName = 'Home';
    //Populate selected page name.
    //Based on selected page name other information will be populated on intranet page like Banners,Articles,Links etc.
    if(ApexPages.currentPage().getParameters().get('tabName') != null){
      pageName = ApexPages.currentPage().getParameters().get('tabName');
    }
    // check for mobile.
    if(null == ApexPages.currentPage().getParameters().get('hideHeaders') || '' == ApexPages.currentPage().getParameters().get('hideHeaders')) isMobile=false;
    else isMobile=true;
    
    
    RECOGNITION_FEED = 'Recognition';
    ANNOUNCEMENT_FEED = 'Announcements';
    getChatterGroupName();
    initRecognitionIds();
    setFeeds();
    getFeaturedUsers();
    whatsUpChatterCount=wuChatterCount();
  }

  private void getChatterGroupName(){
    for(Intranet_Content__c aIntranetContent : [SELECT Id, Recognition_Text__c, Value__c, Name
                                                FROM Intranet_Content__c 
                                                WHERE Name = :CONFIG_CHATTER_FEED_REC_NAME LIMIT 1]){
      if(!String.isEmpty(aIntranetContent.Value__c)){
        chatterGroupName = aIntranetContent.Value__c;
      }
    }
    initChatterGroupId();
  }

  private void initRecognitionIds(){
    for(Topic aTopic : [SELECT Id, Name FROM Topic WHERE Name = :RECOGNITION_FEED LIMIT 1]){
      recgFeedId = aTopic.Id;
    }
  }

  private void initChatterGroupId(){
    for(CollaborationGroup aCollaborationGroup : [SELECT Id,Name
                                                  FROM CollaborationGroup 
                                                  WHERE CollaborationType = 'Public'
                                                  AND Name = :chatterGroupName]){
      chatterGroupId = aCollaborationGroup.Id;
    }
  }

  public PageReference setFeeds(){
    // For page onload
    if(feedName == RECOGNITION_FEED || feedName == null){
      feedId = recgFeedId;
      feedType = null;
    }else if(feedName == ANNOUNCEMENT_FEED) {
      feedId = chatterGroupId;
      feedType = 'AdvancedTextPost';
    }
    return null;
  }

  public void getFeaturedUsers(){
    featuredUsers = new List<Intranet_Content__c>();
    for(Intranet_Content__c content : [SELECT Featured_User__r.FirstName, Featured_User__r.LastName, Featured_User__r.Id, URL__c, Target__c
                                       , Featured_User__r.SmallPhotoUrl, (SELECT Id, Name FROM Attachments LIMIT 1)
                                       FROM Intranet_Content__c
                                       WHERE Start_Date__c <= :todayDate
                                       AND End_Date__c >= :todayDate
                                       AND RecordType.Name = :RECORDTYPE_FEATURED_USER 
                                       ORDER BY Sequence__c
                                       LIMIT 5]){
      featuredUsers.add(content);
    }                                    
  }

public Integer wuChatterCount(){  
	List<CollaborationGroup> wugroup = [SELECT ID FROM CollaborationGroup where Name='What\'s Up?'];
    if(wugroup.size() > 0){
        Date yesterday=Date.today().addDays(-1);
        List<CollaborationGroupFeed> x = [SELECT ID, ParentId, createdDate FROM CollaborationGroupFeed where ParentId=:wugroup[0].Id and CreatedDate>:yesterday ];
        return x.size();
    }
    return 0;
}
// ConnectApi.FeedElementPage fep = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(Network.getNetworkId(), ConnectApi.FeedType.News, 'me');
// SELECT iD, ParentId, createdDate FROM CollaborationGroupFeed 
// SELECT ID FROM CollaborationGroup where Name='What\'s Up?'
  
}