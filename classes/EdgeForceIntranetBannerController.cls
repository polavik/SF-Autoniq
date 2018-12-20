/**
  * Apex Class: IntranetBannerController
  * Description: This class is used to fetch the Banner records and used to build the Banner section dynamically
  *              (T-97451).
  * Created By: Dheeraj Kumar (Appirio Off)
  * Created Date: 26th Nov 2012.
  * LastModifiedBy : Harshit Jain
  * LastModifiedDate : December 12,2012
  * RelatedTo : Maintain banners list as per the selected current page. 
*/
public with sharing class EdgeForceIntranetBannerController {
    DateTime todayDate = DateTime.now();
    public List<EdgeForceIntranetContentController.ContentVersionWrapper> banners {get;set;} 
    public Integer banner_Roating_Speed {get;set;}
     
    public EdgeForceIntranetBannerController() {
      banner_Roating_Speed = 10000;
      //Retrieve Banner rotating speed
      for(Intranet_Content__c qLinks : [Select Name, value__c From Intranet_Content__c where Name = 'Banner_Rotating_Speed' AND recordType.Name = 'Config - Portal' ]) {
        banner_Roating_Speed = Integer.valueOf(qLinks.Value__c);                                
      }

      banners = getAllBannerDetails();
    }

    /*
     *Method to process all details
     *author Debadyuti Sil
    */
    public List<EdgeForceIntranetContentController.ContentVersionWrapper> getAllBannerDetails(){
      List<EdgeForceIntranetContentController.ContentVersionWrapper> tempListofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
      List<EdgeForceIntranetContentController.ContentVersionWrapper> listofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
      String queryString =  'Select URL__c, Name, Target__c, Position__c, Button_Location__c, Summary_Color__c, Header_Color__c, Frame_Height__c, (SELECT Id, Name  FROM Attachments limit 1), (Select Tags__r.Tag__c From Intranet_Content_Tags__r)  From Intranet_Content__c  WHERE  Start_Date__c <=: todayDate  AND  End_Date__c >=: todayDate AND RecordType.Name =\''+EdgeForceIntranetContentController.RECORDTYPE_INTERNET_BANNER+'\'order by Sequence__c';
      EdgeForceIntranetContentController contentController = new EdgeForceIntranetContentController();
      tempListofLocalContentVersionWrapper = contentController.processContentAndVersion(queryString);
        
      for(Intranet_Content__c content : [SELECT Id FROM Intranet_Content__c
                                         WHERE Start_Date__c <= :todayDate
                                         AND End_Date__c >= :todayDate
                                         AND Status__c = 'Published'
                                         AND recordType.Name =: EdgeForceIntranetContentController.RECORDTYPE_INTERNET_BANNER
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