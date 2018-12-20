/**
  * Apex Class: EFIMeetTheSubTeamCompController
  * Description: This class is used to show the team emebers in each sub-team.
  * Created By: Jim Cook
  * Created Date: 8-25-2016
  * LastModifiedBy : Jim Cook
  * LastModifiedDate : 8-25-2016
  */
  
public with sharing class EFIMeetTheSubTeamCompController {

  DateTime todayDate = DateTime.now();
  DateTime startDate = system.Now();
  DateTime endDate = system.Now();

  public List<EdgeForceIntranetContentController.ContentVersionWrapper> teamList {get;set;}
  public Integer teamSize {get;set;}
  public Boolean showGreen {get; set;}
  public String typeValue;
  public String pageName;
  public String parentPage;

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
  
  public EFIMeetTheSubTeamCompController(){
    try{pageName = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('name'), 'UTF-8');}catch(Exception e){pageName = 'Home';}
    try{parentPage = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('parent'), 'UTF-8');}catch(Exception e){parentPage = '';}
    
     teamList = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
     teamList = getAllTeamMemberDetails();
     teamSize = teamList.size();
  }

public List<EdgeForceIntranetContentController.ContentVersionWrapper> getAllTeamMemberDetails(){
  
      String pageName;
      try{pageName = ApexPages.currentPage().getParameters().get('name');}
      catch(Exception e){}
      if(null == pageName) pageName = 'Home';

      List<String> resultFields = new List<String>();
      resultFields.add('Email__c');
      resultFields.add('Name');
      resultFields.add('Title__c');
      resultFields.add('Description__c');
      resultFields.add('Target_URL__c');
                              
      List<String> tags = new List<String>();
      tags.add(pageName);
      String rtName = EdgeForceIntranetContentController.RECORDTYPE_TEAM_MEMBER;
      return TagUtilities.getVersionedContentByTags(resultFields, tags,  rtName);
  }

}