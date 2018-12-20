/**
* Apex Class: IntranetResourcesComponentController
* Description: This class is used to get Intranet chatter information. (T-97451) 
* Created By: Dheeraj Kumar (Appirio Off)
* Created Date: 26th Nov 2012.
*/
public with sharing class EdgeForceIntranetResourcesCompController {
  public Map<String,List<ContentVersion>> libraries {get;set;}
  public static final String NAME_PRAM = 'name';
  public User currentUser {get;set;}
  public String selectedLib {get;set;}
  public String resourceIdInController {get;set;}
  public ContentVersion versionDataforUI {get;set;}
  public Map<String,ContentVersion> mapofversionIdandVersion;
  public Boolean contentFlag {get;set;}
  public Map<String,Map<String,List<ContentVersion>>> langLibraries {get;set;}
  public String selectedLang {get;set;}
  public String jsonMap {get;set;}
  public boolean isMobile {get; set;}

  /*
  * Default Constructor: this will fetch the library contents that will
  * be used in pages which use resource component.
  */
  public EdgeForceIntranetResourcesCompController() {
  	// Are we in mobile?
  	if(null == ApexPages.currentPage().getParameters().get('hideHeaders') || '' == ApexPages.currentPage().getParameters().get('hideHeaders')) isMobile=false;
  	else isMobile=true;
  	
    contentFlag = false;
    // Fetch current user   
    for(User u :[SELECT Id, UserPermissionsSFContentUser, LanguageLocaleKey
                 FROM User
                 WHERE Id  = :UserInfo.getUserId()]){
      currentUser = u;               
    }
    selectedLang = 'English';
    for(Intranet_Content__c ic : [SELECT Name, Value__c
                                  FROM Intranet_Content__c
                                  WHERE RecordType.Name = 'Config - Language']){
      if(ic.Name == currentUser.LanguageLocaleKey){
        selectedLang = ic.Value__c;
      }
    }
    // Return if current user has no permission for access of contents
    if(currentUser.UserPermissionsSFContentUser == false){return;}

    Set<Id> contentDocIds = new Set<Id>();
    mapofversionIdandVersion = new Map<String,ContentVersion>();
    langLibraries = new Map<String,Map<String,List<ContentVersion>>>();

System.debug('JCTESTRESOURCE0 selectedLib = ' + selectedLib );
    selectedLib = String.isBlank(selectedLib) ? ApexPages.currentPage().getParameters().get(NAME_PRAM) : selectedLib;
System.debug('JCTESTRESOURCE1 selectedLib = ' + selectedLib );
    // Fetch library contents
    for(ContentVersion content : [SELECT OwnerId, ContentUrl, Title ,IsLatest, ContentDocument.ParentId, TagCsv,
                                  ContentDocumentId, Id, Team_Category__c, FileType, Language_Custom__c
                                  FROM ContentVersion 
                                  WHERE IsLatest = true
                                  AND Team__c INCLUDES (:selectedLib)  
                                  ORDER BY Team_Category__c DESC, Sequence__c ASC]){
      // Map documents by Team Category and Language
      Map<String,List<ContentVersion>> libraries;        
      if(content.Team_Category__c != null && content.Language_Custom__c != null){
        mapofversionIdandVersion.put(content.Id,content);
        if(langLibraries.containsKey(content.Language_Custom__c)){
          libraries = langLibraries.get(content.Language_Custom__c);
        } else {
          libraries = new Map<String,List<ContentVersion>>();
        }

        if(libraries.containsKey(content.Team_Category__c)){
          libraries.get(content.Team_Category__c).add(content);
        } else {
          List<ContentVersion> conVersions = new List<ContentVersion>();
          conVersions.add(content);
          libraries.put(content.Team_Category__c,conVersions);
        }
        langLibraries.put(content.Language_Custom__c,libraries);
      }      
    }
    jsonMap = JSON.serialize(langLibraries);

    if(langLibraries.size()>0){
      selectedLang = langLibraries.containsKey(selectedLang) ? selectedLang : new List<String>(langLibraries.keySet())[0];
      contentFlag = true;
    }
  }

  public PageReference setLang(){
    return null;
  }

  public void processContent(){
    String contentId = '';
    if(apexpages.currentPage().getParameters().get('resourceIdParam') <> null){
      contentId = apexpages.currentPage().getParameters().get('resourceIdParam');
    }
    versionDataforUI = new ContentVersion();
    if(mapofversionIdandVersion.containsKey(contentId)){
      versionDataforUI = mapofversionIdandVersion.get(contentId);
    }
  }

}