/**
  * Apex Class: EdgeForceIntranetNewsGridController
  * Description: Controller for Home Page News Grid Component
  * Created By: Matt Salpietro (Appirio)
  * Created Date: February 5th 2016
*/
public with sharing class EdgeForceIntranetNewsGridController {
  DateTime todayDate = DateTime.now();
  public List<EdgeForceIntranetContentController.ContentVersionWrapper> bannerList {get;set;}
    
  public EdgeForceIntranetNewsGridController() {
    bannerList = getAllBannerDetails();
  }
    
  /*
   *Method to process all details
   *author Debadyuti Sil
  */
  public List<EdgeForceIntranetContentController.ContentVersionWrapper> getAllBannerDetails(){
    List<EdgeForceIntranetContentController.ContentVersionWrapper> tempListofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
    List<EdgeForceIntranetContentController.ContentVersionWrapper> listofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
    String queryString = 'SELECT Id, URL__c, Target__c, Category__c, Frame_Height__c, (SELECT Id FROM Attachments LIMIT 1), (SELECT Tags__r.Tag__c FROM Intranet_Content_Tags__r) FROM Intranet_Content__c WHERE Start_Date__c <= :todayDate and End_Date__c >= :todayDate AND RecordType.Name = \''+EdgeForceIntranetContentController.RECORDTYPE_INTERNET_BANNER+'\' AND Status__c = \'Published\' ORDER BY Sequence__c';

    EdgeForceIntranetContentController contentController = new EdgeForceIntranetContentController();
    tempListofLocalContentVersionWrapper = contentController.processContentAndVersion(queryString);
    String queryString1 = 'SELECT Id FROM Intranet_Content__c ' + 
    					  'WHERE recordType.Name =\'' + EdgeForceIntranetContentController.RECORDTYPE_TEAM_MEMBER + '\'' + 
                          'ORDER BY Sequence__c';
      
      system.debug('queryString1===' +queryString1);
      
    for(Intranet_Content__c content : [SELECT Id FROM Intranet_Content__c
                                       WHERE Start_Date__c <= :todayDate
                                       AND End_Date__c >= :todayDate
                                       AND Status__c = 'Published'
                                       AND RecordType.Name = :EdgeForceIntranetContentController.RECORDTYPE_INTERNET_BANNER
                                       ORDER BY Sequence__c]){
      for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempListofLocalContentVersionWrapper) {
        if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(content.Id).substring(0,15)){
          listofLocalContentVersionWrapper.add(wrapper);
        }
      }   
    }
    return listofLocalContentVersionWrapper;
  }
}