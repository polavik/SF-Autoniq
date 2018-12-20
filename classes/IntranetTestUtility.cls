//
// (c) 2013 Appirio, Inc.
//
// A Test Utility for Intranet Training controllers
//
// 24 Dec 2013     Sudhir Kr. Jagetiya       Original
//
@isTest
public without sharing class IntranetTestUtility {
    private static Id systemAdminProfileId;
    private static Map<String, Schema.SObjectType> sObjectMap;
    private static Schema.SObjectType previousObjectType;
    private static Schema.DescribeSObjectResult resSchema;
    private static final String RECORD_LANGUAGE_ENGLISH;
    private static final DateTime currentDateTime;
    
    static {
      RECORD_LANGUAGE_ENGLISH = 'English';
      currentDateTime = system.now();
      List<Profile> profileList = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
      if(profileList.size() > 0) {
        systemAdminProfileId = profileList.get(0).Id;
      }
    }
    
    private static Id getRecordTypeId(String objectName, String recordTypeName) {
      if(sObjectMap == null) {
        sObjectMap = Schema.getGlobalDescribe();
      }
      Schema.SObjectType objectType = sObjectMap.get(objectName) ; // getting Sobject Type
      if(previousObjectType != objectType) {
        previousObjectType = objectType;
        resSchema = objectType.getDescribe() ;
      }
      Map<String, Schema.RecordTypeInfo> recordTypeInfo = resSchema.getRecordTypeInfosByName(); //getting all Recordtype for the Sobject
      return recordTypeInfo.get(recordTypeName).getRecordTypeId(); //particular RecordId by  Name
    }
    
    //create CollaborationGroup
    public static CollaborationGroup createGroup(Boolean isInsert){
      CollaborationGroup collaborationGroup = new CollaborationGroup(Name='testGroup', CollaborationType = 'public');
      if(isInsert) {
        insert collaborationGroup;
      }
      return collaborationGroup;
    }

    //create CollaborationGroup with name
    public static CollaborationGroup createGroup(Boolean isInsert, String groupName){
      CollaborationGroup collaborationGroup = new CollaborationGroup(Name=groupName, CollaborationType = 'public');
      if(isInsert) {
        insert collaborationGroup;
      }
      return collaborationGroup;
    }

  
    //create Attachment
    public static Attachment createAttachment(Boolean isInsert, Id parentId){
      Blob articleData = Blob.valueof('TestData');
      Attachment article = new Attachment(Name='testAttachment', body = articleData, ParentId = parentId);

      if(isInsert) {
        insert article;
      }
      return article;
    }
  
    //This method will create Tags record
    //Created By : Ashish Sharma on 26th Dec, 2013
    public static Tags__c createTag(String tagName, Boolean isInsert){
      Tags__c testTag = new Tags__c();
      testTag.Tag__c = tagName;
      if(isInsert) {
        insert testTag;
      }
      return testTag;
    }
  
    //This method will create Intranet Content Tags record
    //Created By : Ashish Sharma on 26th Dec, 2013
    public static Intranet_Content_Tags__c createContentTag(String contentId, String tagId, Boolean isInsert){
      Intranet_Content_Tags__c testContentTag = new Intranet_Content_Tags__c();
      testContentTag.Intranet_Content__c  = contentId;
      testContentTag.Tags__c = tagId;
      if(isInsert) {
        insert testContentTag;
      }
      return testContentTag;
    }
  
    //This method will create Intranet Content record and will be used
    //generically for all record types
    //Created By : Ashish Sharma on 26th Dec, 2013
    public static Intranet_Content__c createIntranetContent(String recordType, String contentType, String name, Boolean isInsert){
      Intranet_Content__c content = new Intranet_Content__c();
      content.Name = name;
      content.RecordTypeId = getRecordTypeId('Intranet_Content__c', recordType);
      content.Type__c = contentType;
      content.Start_Date__c = currentDateTime;
      content.End_Date__c = currentDateTime.addDays(30);
      content.CurrencyISOCode = 'USD';
      if(isInsert){
        insert content;
      }
      return content;
    }

    //This method will create Intranet Content Bucket record
    public static Intranet_Content_Buckets__c createContentBucket(String name, String viewers, String admins, Boolean isInsert){
      Intranet_Content_Buckets__c bucket = new Intranet_Content_Buckets__c();
      bucket.Name = name;
      bucket.Viewers__c = viewers;
      bucket.Permission_Groups__c = admins;
      if(isInsert){
        insert bucket;
      }
      return bucket;
    }
  
    //This method will create Intranet Content Version record
    //Created By : Ashish Sharma on 26th Dec, 2013
    public static Intranet_Content_Version__c createContentVersion(String contentId, Boolean isInsert){
      Intranet_Content_Version__c intraContVer = new Intranet_Content_Version__c();
      intraContVer.Intranet_Content__c = contentId;
      intraContVer.Language__c = RECORD_LANGUAGE_ENGLISH;
      intraContVer.Name = 'Test Rec';
      intraContVer.CurrencyISOCode = 'USD';
      if(isInsert){
         insert intraContVer;
      }
      return intraContVer;
    }

    //Create intranet_Config__c custom setting
    public static Intranet_Content__c createIntranetConfig(Boolean isInsert , String name, String value){
      /*RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Intranet_Content__c' and DeveloperName = 'Config_Portal'];
      Intranet_Content__c intranetConfing = new Intranet_Content__c(Name=name, Value__c = value , recordtypeid = RecType.id );
      if(isInsert) {
        insert intranetConfing;
      }
      return intranetConfing;*/
      return createIntranetConfig(isInsert, name, value, 'Config - Portal');
    }

    // Overload to create other config record types
    public static Intranet_Content__c createIntranetConfig(Boolean isInsert , String name, String value, String recordType){      
      Intranet_Content__c intranetConfig = new Intranet_Content__c();
      intranetConfig.Name = name;
      intranetConfig.Value__c = value;
      intranetConfig.recordtypeid = getRecordTypeId('Intranet_Content__c', recordType);
      if(isInsert) {
        insert intranetConfig;
      }
      return intranetConfig;
    }
  
    public static User createUser(Integer randomNumber, boolean isInsert) {
      User user = new User();
      user.Email = 'test'+ randomNumber +'@adesa.com.marketingtest';
      user.Username = 'test' + randomNumber + '@adesa.com.marketingtest';
      user.LastName = 'test';
      user.FirstName = 'test';
      user.Alias = 'test';
      user.ProfileId = systemAdminProfileId;
      user.LanguageLocaleKey = 'en_US';
      user.LocaleSidKey = 'en_US';
      user.TimeZoneSidKey = 'America/Chicago';
      user.EmailEncodingKey = 'UTF-8';
      if(isInsert) {
        insert user;
      }
      return user ;
    }

    public static User createUser(Integer randomNumber, boolean isInsert, String userName) {
      User user = new User();
      user.Email = userName;
      user.Username = userName;
      user.LastName = 'test';
      user.FirstName = 'test';
      user.Alias = 'test';
      user.ProfileId = systemAdminProfileId;
      user.LanguageLocaleKey = 'en_US';
      user.LocaleSidKey = 'en_US';
      user.TimeZoneSidKey = 'America/Chicago';
      user.EmailEncodingKey = 'UTF-8';
      if(isInsert) {
        insert user;
      }
      return user ;
    }
  
    //create CollaborationGroup
    public static CollaborationGroupMember createGroupMember(String userId, String groupId, Boolean isInsert){
      CollaborationGroupMember collaborationGroupMember = new CollaborationGroupMember();
      collaborationGroupMember.memberId = userId;
      collaborationGroupMember.CollaborationGroupId = groupId;
      if(isInsert) {
        insert collaborationGroupMember;
      }
      return collaborationGroupMember;
    }

    // Create Public Group Member
    public static GroupMember createPublicGroupMember(String userId, String groupId, Boolean isInsert)
    {
        GroupMember gm = new GroupMember();
        gm.GroupId = groupId;
        gm.UserOrGroupId = userId;
        if(isInsert)
        {
            insert gm;
        }
        return gm;
    }

    public static User createUser(String profileId,Integer randomNumber, boolean isInsert, String userName) {
      User user = new User();
      user.Email = userName;
      user.Username = userName;
      user.LastName = 'test';
      user.FirstName = 'test';
      user.Alias = 'test';
      user.ProfileId = profileId;
      user.LanguageLocaleKey = 'en_US';
      user.LocaleSidKey = 'en_US';
      user.TimeZoneSidKey = 'America/Chicago';
      user.EmailEncodingKey = 'UTF-8';
      if(isInsert) {
        insert user;
      }
      return user ;
    }
}