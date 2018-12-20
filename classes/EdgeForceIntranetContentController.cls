/**
  * Apex Class: IntranetContentController
  * Description: This class is used to display Content
  * Created By: Virendra (Appirio Off)
  * Created Date: 23rd Nov 2012.
  * Updated Date : December 6, 2012
  * Related To : T-102188 - Add standard chatter component to IntranetArticle
  * LastUpdatedBy : Harshit Jain
  * LastUpdatedDate : December 11, 2012
  * Related To : Used this class to show IntranetArticle data on IntranetContent Page.
  ******************************************************************************************
  *Modified by   : Sil
  *Modified date : 10-March-2014
  *purpose       : Content was not displaying based on tag specific as tag code was commented.
  *changeid      : c001
   ******************************************************************************************
  * ModifiedBy : Vipul Jain
  * ModifiedDate : July 07,2015
  * RelatedTo : Getting News on Content Template.
  *******************************************************************************************
  * Methods
  * - processContentAndVersion
  * - processContentAndVersionMenu
  * - processContentAndVersionforDetailpage
  * 
  * Inner classes
  *  - ContentVersionWrapper
  * 
  */
global class EdgeForceIntranetContentController {
  DateTime todayDate = DateTime.now();
  public List<Attachment> galleryAttachmentList {get;set;}
  public String categoryType {get;set;}
  public String tabName {get;set;}
  public boolean renderAttachment {get;set;}
  public String lang {get;set;}

  public ContentVersionWrapper cmsPage {get;set;}
  public ContentVersionWrapper articleDetail {get;set;}

  public String contentIdinParameter {get;set;}
  public String pageName {get;set;}
  public String groupName {get;set;}
  public boolean isMobile {get; set;}
  public boolean isService {get; set;}

// These values hold the record types names and are used in various SOQL statements.
  public static String RECORDTYPE_INTERNET_BANNER   = 'Intranet Banner';
  public static String RECORDTYPE_INTERNET_ARTICLE  = 'Intranet Article';
  public static String RECORDTYPE_INTERNET_LINK     = 'Intranet Link';
  public static String RECORDTYPE_TEAM              = 'Team_Page_RT';
  public static String RECORDTYPE_TEAM_MEMBER       = 'Team Member RT';
  public static String RECORDTYPE_SUB_TEAM          = 'Sub Team RT';
  public static String RECORDTYPE_ABOUT_US          = 'About Us RT';
  
  private static final String BZ_UNIT_RT_NAME       = 'Business Unit Pages';
  private static final String CMS_PAGES_RT_NAME     = 'Intranet CMS Pages';


  public EdgeForceIntranetContentController(EdgeForceIntranetTeamController controller) {}

  /*
  * Default constructor create data based on category parameter of url
  * weather it is Intranet content or Intranet Articles.
  */
  public EdgeForceIntranetContentController() {
    isService = false;
    try{groupName = ApexPages.currentPage().getParameters().get('category');}
    catch(Exception e) {groupName = ' ';}
    try{
    	if(null != ApexPages.currentPage().getParameters().get('hideHeaders')) isMobile = true;
    	else isMobile = false;
    }catch(Exception e) { System.debug('EXCEPTION: ' + e.getMessage()); isService = true; isMobile = false;} //BJ 2-16-17 - Added isService to mimic the content for Mobile.

    renderAttachment = false;
    galleryAttachmentList = new list<Attachment>();
    tabName = 'Home';
    contentIdinParameter = '';


      try{tabName = ApexPages.currentPage().getParameters().get('tabName');}
      catch(Exception e){tabName=' ';}
//    if(ApexPages.currentPage().getParameters().get('tabName') != null && ApexPages.currentPage().getParameters().get('tabName') <> '') {
//      tabName = ApexPages.currentPage().getParameters().get('tabName');
//    }

      try{ lang = ApexPages.currentPage().getParameters().get('lang');}
      catch(Exception e){lang = ' ';}
//    if(ApexPages.currentPage().getParameters().get('lang') != null && ApexPages.currentPage().getParameters().get('lang') <> '') {
//      lang = ApexPages.currentPage().getParameters().get('lang');
//    }

    try{categoryType = ApexPages.currentPage().getParameters().get('category');}
    catch(Exception e){categoryType = ' ';}
    try{contentIdinParameter = ApexPages.currentPage().getParameters().get('Id');}
    catch(Exception e){contentIdInParameter=' ';}

     try{pageName = ApexPages.currentPage().getParameters().get('name');}
     catch(Exception e){pageName = 'Home';}
     if(null == pageName || pageName.length() < 1) pageName = 'Home';
         
    
    // It will prevent rendering attachments on IntranetContent page.
    if(contentIdinParameter != null && contentIdinParameter <>'' && categoryType <> null && categoryType <> '') {
      try{contentIdinParameter = ApexPages.currentPage().getParameters().get('Id');}
      catch(Exception e){contentIdinParameter = ' ';}
      processContentAndVersionforDetailpage(contentIdinParameter,categoryType);
    }
  }


  public void processContentAndVersionforDetailpage(String contentId,String categoryType) {
  	System.debug('JCTEST Top of processContentAndVersionforDetailpage');
    renderAttachment = false;
    List<ContentVersionWrapper> listofvontentversionWrapper = new  List<ContentVersionWrapper>();
    String queryString = '';
      if(isService){
          queryString = 'SELECT URL__c, Template__c, SystemModstamp, Target__c, Show_Chatter_Feed__c, Show_Attachment__c,'+
                         '(SELECT Id, Name FROM Attachments), (SELECT Tags__r.Tag__c FROM Intranet_Content_Tags__r WHERE Tags__r.Tag__c = \'Home\') '+
                         'FROM Intranet_Content__c';
      } else{
        queryString = 'SELECT URL__c, Template__c, SystemModstamp, Target__c, Show_Chatter_Feed__c, Show_Attachment__c,'+
                         '(SELECT Id, Name FROM Attachments), (SELECT Tags__r.Tag__c FROM Intranet_Content_Tags__r) '+
                         'FROM Intranet_Content__c WHERE Id =\''+contentId+'\'';
      }
      system.debug('==queryString=='+queryString);
      system.debug('==contentId=='+contentId);
      
    listofvontentversionWrapper = processContentAndVersion(queryString);
    if(listofvontentversionWrapper.size()>0){
      if(categoryType == 'News' || categoryType == 'Leadership Corner'
          || categoryType == 'Announcements & Newsletters' || categoryType == 'Global Alert'
          || categoryType == 'Training'){
        renderAttachment = true;
        articleDetail = listofvontentversionWrapper[0];
      }else if(categoryType == 'Content' ){
        renderAttachment = true;
        cmsPage = listofvontentversionWrapper[0];
      }
      if(listofvontentversionWrapper[0].content <> null && listofvontentversionWrapper[0].content.Attachments <> null && listofvontentversionWrapper[0].content.Attachments.size()>0){
        galleryAttachmentList.addall(listofvontentversionWrapper[0].content.Attachments);
      }
    }
  }

  /*
    Inner Class: COntentVersionWrapper
    purpose: This class holds one Intranet_Content__c record (content) and one Intranet_Content_Version__c (contentVersionforDisplay) record.
             The Intranet_Content_Version__c record should always be the correct, language-specific, child of the 
             Intranet_Content__c record. Enforcement of "correctness" is elsewhere in this file, EdgeforceIntranetCOntentController.
  */
  global Class ContentVersionWrapper{
    public Intranet_Content__c content {get;set;} {content = new Intranet_Content__c();}
    public Intranet_Content_Version__c contentVersionforDisplay {get;set;} {contentVersionforDisplay = new Intranet_Content_Version__c();}
    public Integer baseImageLocation     {get; set;}
    public String carouselImageLinkOpen  {get; set;}
    public String carouselImageLinkClose {get; set;}
    public String carouselInnerLink      {get; set;}
 
    public ContentVersionWrapper(Intranet_Content__c localContent, Intranet_Content_Version__c localContentVersionforDisplay){
      this.content = localContent ;
      this.contentVersionforDisplay = localContentVersionforDisplay;
    }
    
    public ContentVersionWrapper() {
      content = new Intranet_Content__c();
      contentVersionforDisplay = new Intranet_Content_Version__c();
      carouselImageLinkOpen  = '';
      carouselImageLinkClose = '';
      carouselInnerLink      = '';
      
    }
  }


  /**
    *Process Different type of Content and return list of appropriate content.
    * important local variables
    *
    * mapofContentIdAndContent - lists the content requested, indexed by ID.
    * mapofContentIdAndSetofVersionsIds - each entry contains a set of versions indexed to the content's Id.
    * setOfLanguages - a list of the languages we want to include.
    * listofContentandVersionWrapper - the final "wrapped" set containing the correct versions of your content. 
    *
    *
    *author Debadyuti Sil
  */
  public  List<ContentVersionWrapper> processContentAndVersion(String query){
    List<ContentVersionWrapper> listofContentandVersionWrapper = new List<ContentVersionWrapper>();
    Map<String,Intranet_Content__c> mapofContentIdAndContent = new Map<String,Intranet_Content__c>();
    Map<String,Set<String>> mapofContentIdAndSetofVersionsIds = new Map<String,Set<String>>();
    Map<String,Intranet_Content_Version__c> mapofVersionIdIdAndVersion = new Map<String,Intranet_Content_Version__c>();
    Set<String> setofContentVersions;
    String userLocalLanguage = '';
    String defaultLanguage = '';
    Set<String> setofLanguages = new Set<String>();

    // Build a set of languages that wil be used for rendering pages etc.
    if(String.isBlank(lang)){
      for(Intranet_content__c intranetConfig : [SELECT Name, Value__c, Language_Default__c
                                                FROM Intranet_content__c
                                                WHERE recordType.Name = 'Config - Language']){
                                                //AND Name = :userinfo.getLanguage()]){
        if(intranetConfig <> null && intranetConfig.value__c <> null){
          if(intranetConfig.Name == userInfo.getLanguage())
          {
              userLocalLanguage = intranetConfig.value__c;
              for(String language : userLocalLanguage.split(';')){
                language = language.toUpperCase();
                setofLanguages.add(language);
              }
          }
          else if(intranetConfig.Language_Default__c)
          {
              defaultLanguage = intranetConfig.Value__c;
          }
        }
      }
    } else {
      userLocalLanguage = lang;
      setofLanguages.add(lang.toUpperCase());
    }

    // Run the query that has been passed to this method and loop through 
    // the results, putting all "Content",  and any "non-content" that has 
    // a tag which matches the current page name, into mapOfContentIDandContent.
    // This map will be used to get the correct version in the next loop.
    for(Intranet_Content__c localContent :  Database.query(query)){
    	System.debug('KCC3 ' + categoryType + ' ' + localContent + ' ' + query);
       if(localContent <> null){
        if(categoryType != 'Content'){
            System.debug('localContent.Intranet_Content_Tags__r== ' + localContent.Intranet_Content_Tags__r + ' ' + query);
          for(Intranet_Content_Tags__c contTag: localContent.Intranet_Content_Tags__r){
            if(contTag.Tags__r.Tag__c == pageName){
              mapofContentIdAndContent.put(localContent.Id,localContent);
            }
          }
        }else{
          mapofContentIdAndContent.put(localContent.Id,localContent);
          System.debug('KCC6 srsly' + localCOntent.Id + ' ' + query);
        }
      }
    }
    system.debug('mapofContentIdAndContent.size=' + mapofContentIdAndContent.size() + ' ' + query);
    // Using  mapOfContentIDandContent as a filter, get all pertinent versions of content and
    // place them in mapofVersionIdIdAndVersion.
    for(Intranet_Content_Version__c localContentVersion : [SELECT isPublished__c, Video_Caption__c, Primary_Record__c, 
                                                           Team_Mission_Statement__c, Title__c, Summary__c,
                                                           Name, Language__c, Intranet_Content__c, Id, Header__c, Description__c, Button_Label__c,
                                                           Video_Type__c, Video_ID__c,Header_Color__c, Summary_Color__c, Button_Location__c, 
                                                           Position__c, Value__c, Image_Description__c, URL__c
                                                           FROM Intranet_Content_Version__c
                                                           WHERE Intranet_Content__c IN :mapofcontentIdAndContent.keySet()
                                                           ORDER BY Intranet_Content__c ]){
      System.debug('KCC4 ' + localContentVersion + ' ' + query);
      if(localContentVersion <> null){
        // Build mapofContentIdAndSetofVersionsIds.
        // This will hold all the versions for each piece of content we want. 
        // in the NEXT loop will use that to determine which version we actually want to show to the user.
        mapofVersionIdIdAndVersion.put(localContentVersion.Id,localContentVersion);
        if(mapofContentIdAndSetofVersionsIds.containsKey(localContentVersion.Intranet_Content__c)){
          // If there's already an entry in mapofContentIdAndSetofVersionsIds for this row from localContentVersion,
          // just add more version records to it.
          setofContentVersions = new Set<String>();
          setofContentVersions.addall(mapofContentIdAndSetofVersionsIds.get(localContentVersion.Intranet_Content__c));
          setofContentVersions.add(localContentVersion.Id);
          mapofContentIdAndSetofVersionsIds.put(localContentVersion.Intranet_Content__c,setofContentVersions);
        }else{
          // If there ISN'T already a row in mapofContentIdAndSetofVersionsIds, add one.
          Set<String> setofNewVersionIds = new Set<String>();
          setofNewVersionIds.add(localContentVersion.Id);
          mapofContentIdAndSetofVersionsIds.put(localContentVersion.Intranet_Content__c,setofNewVersionIds);
        }
      }
    }
    system.debug('mapofContentIdAndSetofVersionsIds==' +mapofContentIdAndSetofVersionsIds);
    system.debug('mapofContentIdAndContent1==' +mapofContentIdAndContent);
    if(null == mapofContentIdAndSetofVersionsIds.keySet())system.debug('Keyset was null!');
    else System.debug('Keyset=' + mapofContentIdAndSetofVersionsIds.keySet() + ' ' + query);
    if(mapofContentIdAndSetofVersionsIds.keySet() <> null){
      // If we found anything, loop through all the content items and determine which 
      // version we actually want to use.   
      for(String contentId : mapofContentIdAndContent.keySet()){
        Intranet_Content_Version__c contentVersiontoLoad = new Intranet_Content_Version__c();
        boolean isContentFound = false;
        String primaryVersionid = '';
        if(mapofContentIdAndSetofVersionsIds.containsKey(contentId)){
          for(String  versionId : mapofContentIdAndSetofVersionsIds.get(contentId)){
            if(mapofVersionIdIdAndVersion.get(versionId).Primary_Record__c
                && mapofVersionIdIdAndVersion.get(versionId).Language__c == defaultLanguage)
            {
                primaryVersionid = versionId;
            }
            //if local language available
            if(userLocalLanguage <> null && setofLanguages.size() > 0
                && mapofVersionIdIdAndVersion.get(versionId).Language__c <> null
                && setofLanguages.contains(mapofVersionIdIdAndVersion.get(versionId).Language__c.trim().toUpperCase())
                && mapofVersionIdIdAndVersion.get(versionId).isPublished__c == true){
              contentVersiontoLoad = mapofVersionIdIdAndVersion.get(versionId);
              isContentFound = true;
            }
          }

        }

        //go for primary version
        if(isContentFound == false && primaryVersionid <> ''){
          contentVersiontoLoad = mapofVersionIdIdAndVersion.get(primaryVersionid);
        }
        listofContentandVersionWrapper.add(new ContentVersionWrapper(mapofContentIdAndContent.get(contentId),contentVersiontoLoad));
      }
    }
    system.debug('KCC5 listofContentandVersionWrapper size' + listofContentandVersionWrapper.size() + ' on ' + query);
    return listofContentandVersionWrapper;
  }

  public  List<ContentVersionWrapper> processContentAndVersionMenu(String query){
  	System.debug('^^^^^ processContentAndVersionMenu-query=' + query);
    List<ContentVersionWrapper> listofContentandVersionWrapper = new List<ContentVersionWrapper>();
    Map<String,Intranet_Content__c> mapofContentIdAndContent = new Map<String,Intranet_Content__c>();
    Map<String,Set<String>> mapofContentIdAndSetofVersionsIds = new Map<String,Set<String>>();
    Map<String,Intranet_Content_Version__c> mapofVersionIdIdAndVersion = new Map<String,Intranet_Content_Version__c>();
    Set<String> setofContentVersions;
    String userLocalLanguage = '';
    String defaultLanguage = '';
    Set<String> setofLanguages = new Set<String>();

    //user local language from setting
    for(Intranet_content__c intranetConfig : [SELECT Name, Value__c, Language_Default__c
                                              FROM Intranet_content__c
                                              WHERE recordType.Name = 'Config - Language']){
                                              //AND Name = :userinfo.getLanguage()]){
      if(intranetConfig <> null && intranetConfig.value__c <> null){
          if(intranetConfig.Name == userInfo.getLanguage())
          {
              userLocalLanguage = intranetConfig.value__c;
              for(String language : userLocalLanguage.split(';')){
                language = language.toUpperCase();
                setofLanguages.add(language);
              }
          }
          else if(intranetConfig.Language_Default__c)
          {
              defaultLanguage = intranetConfig.Value__c;
          }
      }
    }

    // Using the incoming query, get all matching INtranet_Content__c records, and put them in a map.
    // Their IDs will be used to locate the appropriate version records.
    for(Intranet_Content__c localContent :  Database.query(query)){
      if(localContent <> null){
        mapofContentIdAndContent.put(localContent.Id,localContent);
      }
    }
    System.debug('JCTEST1 mapofContentIdAndContent.size()=' + mapofContentIdAndContent.size() );
    System.debug('JCTest query ' + query);
    // Using the keySet we just built, find the related VERSIONS for the content.
    for(Intranet_Content_Version__c localContentVersion : [SELECT isPublished__c, Video_Caption__c, Summary__c,  Primary_Record__c, 
                                                           Team_Mission_Statement__c, Title__c, 
                                                           Name, Language__c, Intranet_Content__c, Id, Header__c, Description__c, Button_Label__c,
                                                           Video_Type__c, Video_ID__c,Header_Color__c, Summary_Color__c, Button_Location__c, Position__c, URL__c
                                                           FROM Intranet_Content_Version__c
                                                           WHERE Intranet_Content__c IN :mapofcontentIdAndContent.keySet()
                                                           ORDER BY Intranet_Content__c ]){
      if(localContentVersion <> null){
        mapofVersionIdIdAndVersion.put(localContentVersion.Id,localContentVersion);
        if(mapofContentIdAndSetofVersionsIds.containsKey(localContentVersion.Intranet_Content__c)){
          setofContentVersions = new Set<String>();
          setofContentVersions.addall(mapofContentIdAndSetofVersionsIds.get(localContentVersion.Intranet_Content__c));
          setofContentVersions.add(localContentVersion.Id);
          mapofContentIdAndSetofVersionsIds.put(localContentVersion.Intranet_Content__c,setofContentVersions);
        }else{
          Set<String> setofNewVersionIds = new Set<String>();
          setofNewVersionIds.add(localContentVersion.Id);
          mapofContentIdAndSetofVersionsIds.put(localContentVersion.Intranet_Content__c,setofNewVersionIds);
        }
      }
    }
    System.debug('JCTEST2 mapofContentIdAndSetofVersionsIds.size()=' + mapofContentIdAndSetofVersionsIds.size() );
    if(mapofContentIdAndSetofVersionsIds.keySet() <> null){
      for(String contentId : mapofContentIdAndContent.keySet()){
        Intranet_Content_Version__c contentVersiontoLoad = new Intranet_Content_Version__c();
        Boolean isContentFound = false;
        String primaryVersionid = '';
        if(mapofContentIdAndSetofVersionsIds.containsKey(contentId)){
          for(String  versionId : mapofContentIdAndSetofVersionsIds.get(contentId)){
            if(mapofVersionIdIdAndVersion.get(versionId).Primary_Record__c
                && mapofVersionIdIdAndVersion.get(versionId).Language__c == defaultLanguage){
              primaryVersionid = versionId;
            }
            //if local language available
            if(userLocalLanguage <> null && setofLanguages.size() > 0
                && mapofVersionIdIdAndVersion.get(versionId).Language__c <> null
                && setofLanguages.contains(mapofVersionIdIdAndVersion.get(versionId).Language__c.trim().toUpperCase())
                && mapofVersionIdIdAndVersion.get(versionId).isPublished__c == true){
              contentVersiontoLoad = mapofVersionIdIdAndVersion.get(versionId);
              system.debug('@@@@@@ Menu Item: '+contentVersiontoLoad);
              isContentFound = true;
            }
          }
        }

        //go for primary version
        if(isContentFound == false && primaryVersionid <> ''){
          contentVersiontoLoad = mapofVersionIdIdAndVersion.get(primaryVersionid);
        }
        listofContentandVersionWrapper.add(new ContentVersionWrapper(mapofContentIdAndContent.get(contentId),contentVersiontoLoad));
      }
    }
    System.debug('JCTEST3 listofContentandVersionWrapper.size()=' + listofContentandVersionWrapper.size() );   
    return listofContentandVersionWrapper;
  }

}