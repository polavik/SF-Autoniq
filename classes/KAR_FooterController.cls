/**
  * Apex Class: KAR_FooterController
  * Description: Controller for KAR Footer Controller
  * Created By: Matt Salpietro
  * Created Date: February 8th, 2016
  
  * Modified By     : Lovish Goyal(JDC)
  * Modified Date   : 13 April, 2016
  * Description     : Added Frame_Height__c field to the query
*/
public with sharing class KAR_FooterController {
  public static final String FOOTER_LINK = 'Footer Link';
  DateTime todayDate = DateTime.now();
  
  public transient Map<Id,List<EdgeForceIntranetContentController.ContentVersionWrapper>> parentIdtoChildFooterMap{get;set;}
  public transient Map<Id,EdgeForceIntranetContentController.ContentVersionWrapper> idToWrapperFooterMap{get;set;}
    
  /*
  * Default Constructor, this will initialize the intranet list and fetch
  * intranet link lists.
  */
  public KAR_FooterController() {
    parentIdtoChildFooterMap = new Map<Id,List<EdgeForceIntranetContentController.ContentVersionWrapper>>();
    idToWrapperFooterMap = new Map<Id,EdgeForceIntranetContentController.ContentVersionWrapper>();

    for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : getAllLinksDetails()){
      if(wrapper.content.Parent__c == null && !parentIdtoChildFooterMap.containsKey(wrapper.content.id)) {
        parentIdtoChildFooterMap.put(wrapper.content.id, new List<EdgeForceIntranetContentController.ContentVersionWrapper>());
      }
      if(wrapper.content.Parent__c != null) {
        if(!parentIdtoChildFooterMap.containsKey(wrapper.content.Parent__c)) {
          parentIdtoChildFooterMap.put(wrapper.content.Parent__c, new List<EdgeForceIntranetContentController.ContentVersionWrapper>());
        }
        parentIdtoChildFooterMap.get(wrapper.content.Parent__c).add(wrapper);
      }
      idToWrapperFooterMap.put(wrapper.content.id, wrapper);
    }

    for(Id parentId : parentIdtoChildFooterMap.keySet()){
      if(!idToWrapperFooterMap.containsKey(parentId) || parentIdtoChildFooterMap.get(parentId).size() == 0){
        parentIdtoChildFooterMap.remove(parentId);
      }
    }
  }

  /*
  *Method to process all details
  *author Debadyuti Sil
  */
  public List<EdgeForceIntranetContentController.ContentVersionWrapper> getAllLinksDetails(){
    List<EdgeForceIntranetContentController.ContentVersionWrapper> tempListofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
    List<EdgeForceIntranetContentController.ContentVersionWrapper> listofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
    String queryString =  'SELECT URL__c, Target__c, Frame_Height__c, Parent__c FROM Intranet_Content__c WHERE Start_Date__c <= :todayDate AND End_Date__c >= :todayDate AND Type__c = \'Footer Link\' AND RecordType.Name = \''+EdgeForceIntranetContentController.RECORDTYPE_INTERNET_LINK+'\' AND Status__c = \'Published\' ORDER BY Sequence__c ASC';
    EdgeForceIntranetContentController contentController = new EdgeForceIntranetContentController();
    contentController.categoryType = 'Content';
    tempListofLocalContentVersionWrapper = contentController.processContentAndVersion(queryString);
    for(Intranet_Content__c content : [SELECT Id FROM Intranet_Content__c
                                       WHERE Type__c = 'Footer Link'
                                       AND RecordType.Name = :EdgeForceIntranetContentController.RECORDTYPE_INTERNET_LINK
                                       AND Status__c = 'Published'
                                       AND Start_Date__c <= :todayDate
                                       AND End_Date__c >= :todayDate
                                       ORDER BY Sequence__c ASC]){
      for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempListofLocalContentVersionWrapper){
        if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(content.Id).substring(0,15)){
          listofLocalContentVersionWrapper.add(wrapper);
        }
      }
    }
    return listofLocalContentVersionWrapper;
  }

}