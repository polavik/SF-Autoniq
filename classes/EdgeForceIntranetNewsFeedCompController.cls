/**
  * Apex Class: IntranetNewsFeedComponentController
  * Description: This class is used to show intranet news feeds
  * Created By: Dheeraj Kumar (Appirio Off)
  * Created Date: 
  * LastModifiedBy : Matt Salpietro (Appirio) - 11/3/16 - Removed where clause to filter on content bucket name
  */
public with sharing class EdgeForceIntranetNewsFeedCompController {
  DateTime todayDate = DateTime.now();
  DateTime startDate = system.Now();
  DateTime endDate = system.Now();

  public Integer banner_Roating_Speed {get;set;}
  public List<EdgeForceIntranetContentController.ContentVersionWrapper> newsList {get;set;}
  public String groupName {get; set;}
  public String parent {get; set;}
  public String pageName {get; set;}

  // page id, this will decide that for which page we are going to
  // show news feed and can be used to fetch news feed according to
  // page ids.
  public String pageId {get{
    if(ApexPages.currentPage().getParameters().get('name') != null) {
      return ApexPages.currentPage().getParameters().get('name');
    }else{
      return 'Home';
    }
  }set;}

  public String pageIdForContent {get{
      if(ApexPages.currentPage().getParameters().get('category') != null) {
          return ApexPages.currentPage().getParameters().get('category');
      }else{
          return 'Home';
      }
  }set;}
  
  public EdgeForceIntranetNewsFeedCompController(){
  	groupName = ApexPages.currentPage().getParameters().get('name');
    //Initialise default with 6 sec
    banner_Roating_Speed = 7000;
    //Retrieve Banner rotating speed configured from the Custom setting by Sys Admin
    for(Intranet_Content__c qLinks : [SELECT Name, Value__c FROM Intranet_Content__c WHERE Name = 'Banner_Rotating_Speed' AND RecordType.Name = 'Config - Portal']) {
      banner_Roating_Speed = Integer.valueOf(qLinks.Value__c);
    }
    newsList = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
    newsList = getAllArticleDetails();
  }

  public List<EdgeForceIntranetContentController.ContentVersionWrapper> getAllArticleDetails(){
  	try{parent = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('parent'), 'UTF-8');}
  	catch(Exception e){parent='none';}
  	try{pageName = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('name'), 'UTF-8');}
  	catch(Exception e){pageName='Home';}
    List<EdgeForceIntranetContentController.ContentVersionWrapper> tempListofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
    List<EdgeForceIntranetContentController.ContentVersionWrapper> listofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
    String queryString = 'SELECT Id, URL__c, Start_Date__c, Name, End_Date__c, CreatedDate, Type__c, Category__c, ' + 
                          '(SELECT Id FROM Attachments LIMIT 1), (SELECT Tags__r.Tag__c FROM Intranet_Content_Tags__r) ' + 
                          'FROM Intranet_Content__c WHERE Start_Date__c <= :todayDate AND End_Date__c >= :todayDate ' + 
                          //' AND Content_Bucket__r.Name = \'' + pageName + '\'' +
                          'AND Type__c = \'News\' AND RecordType.Name =\''+EdgeForceIntranetContentController.RECORDTYPE_INTERNET_ARTICLE+
                          '\' ORDER BY Sequence__c ASC NULLS LAST, Start_Date__c DESC'+(pageIdForContent.equals('Content') ? ' ':' ' );
    EdgeForceIntranetContentController contentController = new EdgeForceIntranetContentController();
    tempListofLocalContentVersionWrapper = contentController.processContentAndVersion(queryString);
    Integer articleCount = 1;
    for(Intranet_Content__c content : [SELECT Id FROM Intranet_Content__c
                                       WHERE Start_Date__c <= :todayDate
                                       AND End_Date__c >= :todayDate
                                       AND Type__c = 'News'
                                       AND recordType.Name =: EdgeForceIntranetContentController.RECORDTYPE_INTERNET_ARTICLE
                                       ORDER BY Sequence__c ASC NULLS LAST,
                                       Start_Date__c DESC]) {
      for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempListofLocalContentVersionWrapper)    {
        if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(content.Id).substring(0,15)){
          if(articleCount <= 5){
               listofLocalContentVersionWrapper.add(wrapper);
               articleCount++;
          } else {
            continue;
          }
        }
      }
    }
    return listofLocalContentVersionWrapper;
  }
}