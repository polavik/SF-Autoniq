/**
  * Apex Class: IntranetContentRTSelectionController
  * Description: T-179349 : Develop VF page to enter content
  * Created By: Ashish Sharma (Appirio Off)
  * Created Date: September 2nd, 2013.
  * Modified: Ashish Sharma September 11th, 2015 T-433551
  */
public with sharing class EdgeForceIntranetContentRTSelController {
  public String selectedContentRecordType {get;set;}
  public List<SelectOption> intranetContentRecordTypes {get;set;}
  public String contentBucketId {get;set;}
  public String parentContentId {get;set;}
  Map<String,String> recordTypeIdNameMap;
  
  public EdgeForceIntranetContentRTSelController(ApexPages.StandardController stdController){

    Intranet_Content__c content = (Intranet_Content__c)stdController.getRecord();
    intranetContentRecordTypes = new List<SelectOption>();
    recordTypeIdNameMap = new Map<String, String>();
    
    //Fetch Record Types for Intranet_Content__c sObject
    Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Intranet_Content__c.getRecordTypeInfosByName();
      
    //Create select option list of Intranet Content record types 
    for(Schema.RecordTypeInfo recordTypeInfo : rtMapByName.values()){
      if((recordTypeInfo.getName() != 'Master' && recordTypeInfo.isAvailable()) || Test.isRunningTest()){
        intranetContentRecordTypes.add(new SelectOption(recordTypeInfo.getRecordTypeId(), recordTypeInfo.getName()));
        recordTypeIdNameMap.put(recordTypeInfo.getRecordTypeId(), recordTypeInfo.getName());
      }
    }
    
    //checks if the New IC is created via ICB Related list or IC Child Content Related List
    contentBucketId = '';
    parentContentId = '';
    String currentURLId  = ApexPages.currentPage().getParameters().get('retURL');
    String keyPrefix = Intranet_Content_Buckets__c.sObjectType.getDescribe().getKeyPrefix();
    if(!String.isBlank(currentURLId)) {
      currentURLId = currentURLId.substring(1);
    }
    if(!String.isBlank(currentURLId) && currentURLId.substring(0, 3).equals(keyPrefix)) {
      contentBucketId = currentURLId;
    }
    keyPrefix = Intranet_Content__c.sObjectType.getDescribe().getKeyPrefix();
    if(!String.isBlank(currentURLId) && currentURLId.substring(0, 3).equals(keyPrefix) && (currentURLId.length() == 15 || currentURLId.length() == 18)) {
      parentContentId = currentURLId;
    }
  }
  
  //this function will redirect the user to IntranetContentNew page with record type id and name
  public PageReference selectRecordType(){
    String recordTypeName = recordTypeIdNameMap.get(selectedContentRecordType);
    String contentURL = '/Apex/EdgeForceIntranetContentNew?RecordTypeId=';
    contentURL += selectedContentRecordType + '&RecordTypeName=' + recordTypeName;
    contentURL += !String.isBlank(contentBucketId) ? '&contentBucketId=' + contentBucketId : '';
    contentURL += !String.isBlank(parentContentId) ? '&parentContentId=' + parentContentId : '';
    
    return new PageReference(contentURL);
  }
  
  //This function will cancel the action and redirect to Intranet Content list view
  public PageReference cancel(){
    return new PageReference('/' + (!String.isBlank(parentContentId) ? parentContentId : Intranet_Content__c.sObjectType.getDescribe().getKeyPrefix()));
  }
}