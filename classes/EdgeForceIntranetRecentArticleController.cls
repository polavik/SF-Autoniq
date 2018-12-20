/**
  * Apex Class: IntranetRecentArticleController
  * Description: This class is used to display Recent Articles
  * Created By: Ashish Sharma (Appirio Off)
  * Created Date: September 12, 2013
  */

public with sharing class EdgeForceIntranetRecentArticleController {
  DateTime todayDate = DateTime.now();
  public String tabName {
    get{
      if(ApexPages.currentPage().getParameters().get('tabName') != null && ApexPages.currentPage().getParameters().get('tabName') <> '') {
        return ApexPages.currentPage().getParameters().get('tabName');
      }
      return '';
    }
  }

  public String categoryType {
    get{
      return ApexPages.currentPage().getParameters().get('category');
    }
  }

  public String pageId {get{
      if(ApexPages.currentPage().getParameters().get('name') != null) {
      return ApexPages.currentPage().getParameters().get('name');
    }else{
      return 'Home';
    }
    }
     set;}

  // page id, this will decide that for which page we are going to
  // show news feed and can be used to fetch news feed according to
  // page ids.

  public List<EdgeForceIntranetContentController.ContentVersionWrapper> newsList {
    get {
      String currentArticleId = Apexpages.currentPage().getParameters().get('id');
      return getAllArticleDetails(currentArticleId, tabName, categoryType);
    }
 }

  /*
   *Method to process all details
  */
  public List<EdgeForceIntranetContentController.ContentVersionWrapper> getAllArticleDetails(String currentArticleId, String tabName, String categoryType){

    List<EdgeForceIntranetContentController.ContentVersionWrapper> tempListofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
    List<EdgeForceIntranetContentController.ContentVersionWrapper> listofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
 	String queryString = 'SELECT Id, URL__c, Start_Date__c, Name, End_Date__c,CreatedDate,Type__c,(SELECT Id  FROM Attachments LIMIT 1),(Select Tags__r.Tag__c From Intranet_Content_Tags__r) FROM Intranet_Content__c Where Start_Date__c <=: todayDate and End_Date__c >=: todayDate and Id != \'' + currentArticleId + '\' and Type__c = \'News\' and recordType.Name =\''+EdgeForceIntranetContentController.RECORDTYPE_INTERNET_ARTICLE+'\' order by Start_Date__c DESC LIMIT 20';
  	system.debug('%%%%%%%%%%%%%%%%%'+queryString);
  	EdgeForceIntranetContentController contentController = new EdgeForceIntranetContentController();
    tempListofLocalContentVersionWrapper = contentController.processContentAndVersion(queryString);
    system.debug('@@@@@@@@@@@@@@@@@@@'+tempListofLocalContentVersionWrapper);
    for(Intranet_Content__c content : [SELECT Id FROM Intranet_Content__c
                                     Where Start_Date__c <=: todayDate
                                     AND End_Date__c >=: todayDate
                                     AND Id !=: currentArticleId
                                     AND Type__c = 'News'
                                     AND recordType.Name =: EdgeForceIntranetContentController.RECORDTYPE_INTERNET_ARTICLE
                                      order by Start_Date__c DESC LIMIT 20]){
       for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempListofLocalContentVersionWrapper)  {
         if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(content.Id).substring(0,15)){
           listofLocalContentVersionWrapper.add(wrapper);
         }
       }
    }
    system.debug('^^^^^^^^^^^^^^^^^^^^^^'+listofLocalContentVersionWrapper);
  return listofLocalContentVersionWrapper;

  }
}