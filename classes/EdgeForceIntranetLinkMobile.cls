/**
  * Apex Class: IntranetLinkComponentController
  * Description: This class is used to fetch Intranet links and thier attachments (T-97451)
  * Created By: Dheeraj Kumar (Appirio Off)
  * Created Date: 23rd Nov 2012
  * LastModifiedBy : Harshit Jain
  * LastModifiedDate : December 12,2012
  * RelatedTo : Maintain IntranetList as per the selected current page.
*/
public with sharing class EdgeForceIntranetLinkMobile {
    DateTime todayDate = DateTime.now();
    public Integer no_Of_Link {get;set;}
    public List<EdgeForceIntranetContentController.ContentVersionWrapper> intranetList {get;set;}

    /*
    * Default Constructor, this will initialize the intranet list and fetch
    * intranet link lists.
    */
    public EdgeForceIntranetLinkMobile() {
      intranetList = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();

      //Initialise default with 6
      no_Of_Link = Integer.valueof(Label.No_of_Links);

      //Retrieve No of Links configured from the Custom setting by Sys Admin
      for(Intranet_content__c qLinks : [Select Name, value__c From Intranet_content__c where recordType.Name = 'Config - Portal' AND Name = 'NO_OF_LINKS']) {
        no_Of_Link = Integer.valueOf(qLinks.Value__c);
      }

      intranetList = getAllLinksDetails();
    }

    /*
     *Method to process all details
     *author Debadyuti Sil
    */
    public List<EdgeForceIntranetContentController.ContentVersionWrapper> getAllLinksDetails(){
      List<EdgeForceIntranetContentController.ContentVersionWrapper> tempListofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
      List<EdgeForceIntranetContentController.ContentVersionWrapper> listofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
      String queryString =  'SELECT URL__c, Frame_Height__c, Target__c, (SELECT Id, Name FROM Attachments LIMIT 1) FROM Intranet_Content__c WHERE Start_Date__c <= :todayDate AND End_Date__c >= :todayDate AND Type__c = \'Quick Link\' AND Status__c = \'Published\' AND RecordType.Name = \''+EdgeForceIntranetContentController.RECORDTYPE_INTERNET_LINK+'\' ORDER BY Sequence__c';
      EdgeForceContentFullContentMobile contentController = new EdgeForceContentFullContentMobile();
      contentController.categoryType = 'Content';
      tempListofLocalContentVersionWrapper = contentController.processContentAndVersion(queryString); 
      Integer recordCount = 0;
      for(Intranet_Content__c content : [SELECT Id FROM Intranet_Content__c
                                         WHERE Start_Date__c <= :todayDate
                                         AND End_Date__c >= :todayDate
                                         AND Type__c = 'Quick Link'
                                         AND recordType.Name =: EdgeForceIntranetContentController.RECORDTYPE_INTERNET_LINK
                                         ORDER BY Sequence__c]){
        for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempListofLocalContentVersionWrapper)   {
          if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(content.Id).substring(0,15)){
            listofLocalContentVersionWrapper.add(wrapper);
            recordCount= recordCount + 1;
          }
        }
        //check if number of records reached at max limit of records
        if(recordCount == no_Of_Link){
          break;
        }
      }
      return listofLocalContentVersionWrapper;
    }
}