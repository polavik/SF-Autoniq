/**
  * Apex Class: EFIMeetTheTeamCompController
  * Description: This class is used to show the team emebers in each team.
  * Created By: Jim Cook
  * Created Date: 8-25-2016
  * LastModifiedBy : Jim Cook
  * LastModifiedDate : 8-25-2016
  */
  
public with sharing class EFIAboutUsCompController {
    
  DateTime todayDate = DateTime.now();
  DateTime startDate = system.Now();
  DateTime endDate = system.Now();

  public List<EdgeForceIntranetContentController.ContentVersionWrapper> aboutUsList {get;set;}
  public String typeValue;
  public String pageName;
  public String queryS {get; set;}
  public String fileId {get; set;}
  public Integer resSize {get; set;}

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
  
  public EFIAboutUsCompController(){
    try{pageName = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('name'), 'UTF-8');}
     catch(Exception e){pageName='Home';}
    
     aboutUsList = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
     aboutUsList = getAllAboutUsDetails();
  }

/* *****************************************************************
method: getAllAboutUsDetails
purpose: fetches appropriate data from the Intrnet_Content__c object.
******************************************************************** */
  public List<EdgeForceIntranetContentController.ContentVersionWrapper> getAllAboutUsDetails(){
    List<EdgeForceIntranetContentController.ContentVersionWrapper> tempList = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
    List<EdgeForceIntranetContentController.ContentVersionWrapper> finalList = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
   String queryString = 'SELECT Id, URL__c, Start_Date__c, Name, End_Date__c, Description__c, CreatedDate, Type__c, Category__c, Page_Type__c, Parent__c,  ' + 
                               'Team_Mission_STatement__c, Address_Street__c, Address_City__c, Address_State__c, Address_ZIP__c, Address_Country__c, Email__c, Phone__c, ' +
                               '(SELECT Id,Name FROM Attachments LIMIT 1), ' + 
                               '(SELECT Tags__r.Tag__c FROM Intranet_Content_Tags__r) ' + 
                         'FROM Intranet_Content__c ' + 
                         'WHERE RecordType.Name =\'About Us RT\'' +  
                          ' AND parent__r.Name = \'' + pageName +  
                          '\' ORDER BY Sequence__c ASC NULLS LAST, Start_Date__c DESC';

    EdgeForceIntranetContentController contentController = new EdgeForceIntranetContentController();
    
    // Run query through Version control code, and get 'versioned' result.
    tempList = contentController.processContentAndVersionMenu(queryString);
    System.debug('JCTEST4 tempList.size()=' + tempList.size());
    resSize = tempList.size();

    // Now get the non-versioned result for comparison.
    for(Intranet_Content__c content : [SELECT Id, Logo_File_Name__c, Page_Type__c
                                         FROM    Intranet_Content__c
                                         WHERE   RecordType.Name ='About Us RT'  
                                         AND parent__r.Name = :pageName   
                                         ORDER BY Sequence__c ASC NULLS LAST, Start_Date__c DESC]){
       for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempList){
          if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(content.Id).substring(0,15))
             finalList.add(wrapper);
            
          else continue;
      
          //Added for Brand Logo by Niza Khunger(T-534544)
          if(content.Page_Type__c=='Brand'){
            fileId='';
            for(Attachment att : wrapper.content.Attachments){
               if(att.name != null && att.Name.equalsIgnoreCase(content.Logo_File_Name__c)){
                  fileId = att.Id;
               }
            }
          }
        }
    }

    if(null == finalList || finalList.size() < 1 )
         finalList.add(new EdgeForceIntranetContentController.ContentVersionWrapper());
    System.debug('***** AboutUs.queryString ' + queryString); 
    System.debug('***** AboutUs.tempList.size ' + tempList.size());     
    System.debug('***** AboutUs.finalList.size ' + finalList.size()); 

    for(EdgeForceIntranetContentController.ContentVersionWrapper abc : tempList)
       System.debug('TEMPLIST DESC ' + abc.content.Description__c);

    for(EdgeForceIntranetContentController.ContentVersionWrapper def : finalList)
       System.debug('FINALLIST DESC ' + def.content.Description__c);

    return finalList;
  }
}