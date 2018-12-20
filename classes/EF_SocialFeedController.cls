public with sharing class EF_SocialFeedController {
  
  private static final String RT_SOCIAL_FEED = 'Home Page Social Feed';
  
  public List<Intranet_Content__c> lstSocialFeed{get;set;}
  public List<Intranet_Content__c> lstSocialLink{get;set;}

  public Map<String,ContWrapper> mapSocialLink{get;set;}

  //public Map<String,String> mapAccts{get;set;}
  
  public EF_SocialFeedController() {
    lstSocialFeed = new List<Intranet_Content__c>();
    lstSocialLink = new List<Intranet_Content__c>();
    mapSocialLink = new Map<String,ContWrapper>();

    for(Intranet_Content__c intraCont : [SELECT Id, Name, Value__c, Sequence__c, Type__c, Site__c, Access_Token__c
                                         FROM Intranet_Content__c
                                         WHERE RecordType.Name = :RT_SOCIAL_FEED
                                         AND Type__c = 'Social Feed Config'
                                         ORDER by Sequence__c ASC]) {
      lstSocialFeed.add(intraCont);
      mapSocialLink.put(intraCont.Site__c,new ContWrapper());
    }

    for(Intranet_Content__c intraCont : [SELECT Id, Name, Value__c, Sequence__c, Type__c, Site__c
                                         FROM Intranet_Content__c
                                         WHERE RecordType.Name = :RT_SOCIAL_FEED
                                         AND Type__c = 'Social Feed Link'
                                         ORDER by Sequence__c ASC]) {
      mapSocialLink.get(intraCont.Site__c).theList.add(intraCont);
    }

  }

  public class ContWrapper {
    public List<Intranet_Content__c> theList { get; set; }
    public ContWrapper() {
      theList = new List<Intranet_Content__c>();
    }
    public Integer size {get {return theList.size();}}
  }

}