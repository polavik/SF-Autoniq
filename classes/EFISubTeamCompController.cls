/**
  * Apex Class: EFIMeetTheTeamCompController
  * Description: This class is used to show the sub teams.
  * Created By: Jim Cook
  * Created Date: 8-25-2016
  * LastModifiedBy : Jim Cook
  * LastModifiedDate : 8-29-2016
  */
  
public with sharing class EFISubTeamCompController {

  DateTime todayDate = DateTime.now();
  DateTime startDate = system.Now();
  DateTime endDate = system.Now();

  public Integer banner_Roating_Speed {get;set;}
  public List<EdgeForceIntranetContentController.ContentVersionWrapper> subTeamList {get;set;}
  public Integer subTeamSize {get;set;}
  public String pageName {get;set;}
  public String qS {get; set;}
  
  // pageID will decide which page(s) will
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
  
/*
Constructor.
*/  
  
  public EFISubTeamCompController(){
    pageName = ApexPages.currentPage().getParameters().get('name');
    if(null == pageName) pageName = 'Home';

    subTeamList = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();  
    subTeamList = getAllSubTeamDetails();
    subTeamSize = subTeamList.size();    
  }

  public List<EdgeForceIntranetContentController.ContentVersionWrapper> getAllSubTeamDetails(){
     // Versioning
     List<EdgeForceIntranetContentController.ContentVersionWrapper> tempList  = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
     List<EdgeForceIntranetContentController.ContentVersionWrapper> finalList = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();

     qS = 'SELECT Id, Name,  Title__c, Description__c, Content_Bucket__c, Target_URL__c, URL__c, ' +
                  '(SELECT Id FROM Attachments LIMIT 1) ' +
                  'FROM    Intranet_Content__c ' +
                  'WHERE   Content_Bucket__r.Name=\''+ ApexPages.currentPage().getParameters().get('name') + '\' ' + 
                  'AND     recordType.Name = \'' + EdgeForceIntranetContentController.RECORDTYPE_SUB_TEAM + '\' ' +
                  'ORDER BY Sequence__c ASC NULLS LAST, Start_Date__c DESC';
                  
        EdgeForceIntranetContentController contentController = new EdgeForceIntranetContentController();
        tempList = contentController.processContentAndVersionMenu(qS);

        for(Intranet_Content__c content : [SELECT Id 
                                               FROM Intranet_Content__c
                                               WHERE Content_Bucket__r.Name = :pageName
                                               AND RecordType.Name = :EdgeForceIntranetContentController.RECORDTYPE_SUB_TEAM  
                                               ORDER BY Sequence__c ASC NULLS LAST, Start_Date__c DESC
                                              ])
        {        
           for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempList) {
             if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(content.Id).substring(0,15)){
                finalList.add(wrapper);
             }
           }
        }

System.debug('*** JC query string=' + qS);
System.debug('*** pageName=' + pageName);
System.debug('*** tempList.size=' + tempList.size());
System.debug('*** finalList.size=' + finalList.size());

    return finalList;
  }
}