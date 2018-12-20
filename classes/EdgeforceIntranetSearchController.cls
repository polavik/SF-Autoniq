/* Sherlock Salesforce Gloabl Search Utility Controller
Description: Sherlock is a Salesforce search replacment utility that can perform full text searches against any searchable object, including
             searching the content of uploaded content documents and chatter posts. The interface is provided via a jQuery plugin on a visualforce page.
Author: Daniel Llewellyn/Kenji776 (@Kenji776)
Date: 12/05/2012
Modified By : Ashish Sharma on 9th October, 2014 Ref : T-325088
Modified By : Sidhant Agarwal 21st November, 2014    : T-335839
Modified By : Ashish Sharma on 18th December, 2014 Ref : I-143411
Modified By : Joe Castro (Appirio) on 27-MAR-2017: add check to removed unauthorized object access
*/

global class EdgeforceIntranetSearchController {
    //wrapper object to standardize search results. The search program expects to receivea list of these. 
    //all the data found from the original sObject is included as well in the objectData property
    global class searchResult {
      String thumbnail = '';
      String title = '';
      String description = '';
      String link = '';
      Integer size = 0;
      String type = '';
      Id recordId;
      SObject objectData;
      String startDate = '';
      Set<String> tags = new Set<String>();
      String fileType = '';
    }

    global static Map<String,ContentVersion> mapofversionIdandVersion;
    global ContentVersion versionDataforUI {get;set;}
    global static String resourceIdInController {get;set;}
    global static String tabName {get;set;}
    global static Map<String,String> parentTabMap {get;set;}
    global static final Integer categoryLimit {get;set;}
    global static final Integer paginationLimit {get; set;}
    private static final String IntranetArticleKeyPrefix {get;set;}
    static Map<String,String> contentNameTitleMap;
    static Map<String,String> parentTabNameMap;
    static Map<SObject,Intranet_Content__c> versionContentMap = new Map<SObject,Intranet_Content__c>();

    static {
      //Initialize final varibles to decide search configuration
      for(Intranet_content__c searchConfig : [SELECT Name, Value__c
                                              FROM Intranet_content__c
                                              WHERE RecordType.Name = 'Config - Portal']){
        if(searchConfig.Name == 'Search Limit') {
          categoryLimit = Integer.valueOf(searchConfig.value__c);
        }
        if(searchConfig.Name == 'Search Pagination') {
          paginationLimit = Integer.valueOf(searchConfig.value__c);
        }           
      }
      IntranetArticleKeyPrefix = Schema.getGlobalDescribe().get('Intranet_Content_Version__c').getDescribe().getKeyPrefix();
    }
    
    @RemoteAction
    global static Map<String,List<searchResult>> globalSearch(String searchTerm, Boolean isMobile, List<String> objectList, 
        List<String> tagList, List<String> fileTypeList, Map<String,String> objectLabels, Integer typeLimit, List<String> langList){

      Map<Id,Set<String>> feedItemMap = new Map<Id,Set<String>>();

      Set<String> fileTypes = new Set<String>();
      if(fileTypeList.size() > 0){
        fileTypes = new Set<String>(fileTypeList);
      }
      Set<String> languageFilterSet = new Set<String>();
      system.debug('langList: '+ langList);
      if(langList.size() > 0) {
        languageFilterSet = new Set<String>(langList);
      }
      system.debug('languageFilterSet:: '+languageFilterSet);
      Set<String> objectTypes = new Set<String>();
      if(objectList.size() > 0){
        objectTypes = new Set<String>(objectList);
      }

      //map to hold the results. The results will have the objectLabels or names (if no label for that object type is provided) and a list of search results for it.
      Map<string,list<searchResult>> results = new  Map<string,list<searchResult>>();
      Map<String, Boolean> isIncludedInSearchMap = new Map<String,Boolean>();
      mapofversionIdandVersion = new Map<String,ContentVersion>();
      parentTabMap = new Map<String,String>();

      try{ 
        //string to hold the SOSL querystring.
        String customObjectQuery = '';

        // Custom setting that decide wheather object included in search or not.
        objectLabels = new Map<string,string>();
        for(Intranet_Content__c searchConfig : [SELECT Name, Object_Name__c, Display_In_Search__c
                                                FROM Intranet_Content__c
                                                WHERE RecordType.Name = 'Config - Search']){
          if(objectTypes.isEmpty() || (!objectTypes.isEmpty() && objectTypes.contains(searchConfig.Object_Name__c))){
            isIncludedInSearchMap.put(searchConfig.Object_Name__c, searchConfig.Display_In_Search__c);
            objectLabels.put(searchConfig.Object_Name__c, searchConfig.Name);
          }
        }

        for(String obj : isIncludedInSearchMap.keySet()){
          if(obj == 'Intranet_Content_Version__c' && isIncludedInSearchMap.get(obj)) {
            customObjectQuery += 'Intranet_Content_Version__c' +'(Name, Id, Language__c, Intranet_Content__c, Summary__c WHERE isPublished__c = true ';
            if(!languageFilterSet.isEmpty()) {
                customObjectQuery+= ' AND Language__c IN :languageFilterSet';
            }
            customObjectQuery += ' ORDER BY LastModifiedDate DESC LIMIT '+typeLimit+'),';
          }else if(obj == 'FeedItem' && isIncludedInSearchMap.get(obj)) {
            customObjectQuery += obj+'(Id, Title, Body, InsertedBy.Name, InsertedById, CreatedDate, ParentId ORDER BY CreatedDate DESC LIMIT '+typeLimit+'),';
          }else if(obj == 'ContentVersion' && isIncludedInSearchMap.get(obj)) {
            customObjectQuery += obj+'(ContentDocumentId, Language_Custom__c, ContentSize, ContentUrl, Description, IsLatest, PublishStatus, TagCsv, Title, FileType, Id ';
            if(!fileTypes.isEmpty() || !languageFilterSet.isEmpty()) {
              customObjectQuery += ' WHERE ';
            }
            if(!fileTypes.isEmpty()) {
              customObjectQuery+= 'FileType IN :fileTypes ';
              if(!languageFilterSet.isEmpty()) {
                customObjectQuery += ' AND ';
              }
            }
            system.debug('languageFilterSet in query:: '+languageFilterSet);
            if(!languageFilterSet.isEmpty()) {
                customObjectQuery+= ' Language_Custom__c IN :languageFilterSet ';
            }
            customObjectQuery += 'ORDER BY RatingCount DESC LIMIT '+typeLimit+'),';
          }
        }

        //append the last of the information we need to our querystring, including stuff for finding documents, feed items and users.
        String objectsQuery = 'FIND \''+searchTerm+'\' IN ALL FIELDS RETURNING '+customObjectQuery.subString(0, customObjectQuery.length()-1) + ' WITH SNIPPET (target_length=120)';
        system.debug('SOSL:: ' + objectsQuery);
        //find all objects where the name matches the search term.
        List<List<SObject>> tempSearchList = search.query(objectsQuery);

        // Edit by Joe Castro (Appirio) 27-MAR-2017 to remove unauthorized records from search results
		EF_SearchUtilities.RemoveUnauthorizedFromLists(tempSearchList);

        String objType = '';
        String objLabel = '';
        
        List<List<SObject>> searchList = new List<List<SObject>>();
        List<SObject> sobjList;
        Set<Id> contentIdSet;
        Boolean isContent;
        Map<Id,Map<String,Intranet_Content_Version__c>> mapContContVersion = new Map<Id,Map<String,Intranet_Content_Version__c>>();
        for(List<SObject> thisObjList : tempSearchList){
          sobjList= new List<SObject>();
          contentIdSet = new Set<Id>();
          isContent = false;

          for(SObject thisObj : thisObjList){
            if(string.valueOf(thisObj.getsObjectType()) == 'Intranet_Content_Version__c'){
              isContent = true;
              if(!mapContContVersion.containsKey((string)thisObj.get('Intranet_Content__c'))) {
                mapContContVersion.put((string)thisObj.get('Intranet_Content__c'), new Map<String,Intranet_Content_Version__c>());
              }
              mapContContVersion.get((string)thisObj.get('Intranet_Content__c')).put((String)thisobj.get('Language__c'),(Intranet_Content_Version__c)thisObj);
            }else{
              if(string.valueOf(thisObj.getsObjectType()) == 'FeedItem'){
                feedItemMap.put((Id)thisObj.get('Id'),null);
              }
              sobjList.add(thisObj);
            }
          }
          searchList.add(sobjList);
        }
        Map<Id, Intranet_Content__c> contentMap = new Map<Id, Intranet_Content__c>([SELECT Id, Status__c, RecordType.Name
                                                                                    FROM Intranet_Content__c
                                                                                    WHERE Id IN :mapContContVersion.keySet()]);
        

        Map<String,String> langMap = new Map<String,String>();
        langMap.put('en_US','English');
        langMap.put('fr_CA','French Canadian');
        for(String contentId : mapContContVersion.keyset()){
          sobjList = new List<sObject>();
          Intranet_Content_Version__c icv;
          if(mapContContVersion.get(contentId).containsKey(langMap.get(UserInfo.getLanguage()))){
            icv = mapContContVersion.get(contentId).get(langMap.get(UserInfo.getLanguage()));
          } else if (mapContContVersion.get(contentId).containsKey('English')){
            icv = mapContContVersion.get(contentId).get('English');
          }
          //for(Intranet_Content_Version__c icv : mapContContVersion.get(contentId)){
            if(icv != null && contentMap.get(contentId).Status__c == 'Published'){                
                sobjList.add(icv);                  
            }               
          //}
          searchList.add(sobjList);
        }
            
        Map<SObject,Id> versionContentIdMap = new Map<SObject,Id>();
        for(List<SObject> thisObjList : searchList){
          for(SObject sobj : thisObjList){
            if(sobj != null && string.valueOf(sobj.getsObjectType()) == 'Intranet_Content_Version__c'){
              versionContentIdMap.put(sobj, (id)sobj.get('Intranet_Content__c'));
            }
          }
        }

        if(objectsQuery.contains('Intranet_Content_Version__c')) {
          //Populate child parent relationship map if Intranet_Article__c object included in search
          contentNameTitleMap = new map<String, String>();
          parentTabNameMap =  new map<String, String>();
          for(Intranet_Content__c CMSPage : [SELECT Id, Parent__c,URL__c, Parent__r.Name, Skip_Menu_Link__c, 
                                             Name, Template__c, Sequence__c, Target__c, RecordType.Name 
                                             FROM Intranet_Content__c
                                             WHERE Status__c = 'Published' 
                                             AND RecordType.Name = 'Intranet Article'
                                             AND Type__c = 'News'
                                             ORDER BY Parent__c, Sequence__c]) {
            parentTabNameMap.put(CMSPage.Name, CMSPage.Parent__r.Name);
            for(SObject innerSobj : versionContentIdMap.keySet()){
              if(versionContentIdMap.get(innerSobj) == CMSPage.Id){
                contentNameTitleMap.put(CMSPage.Name, (string)innerSobj.get('name')); 
              }
            }
          }
          for(String childName : parentTabNameMap.keySet()){
            parentTabMap.put(contentNameTitleMap.get(childName), 
            parentTabNameMap.get(childName));
          }  
        }

        SObject primaryVersion;
        for(Intranet_Content__c sobj : [SELECT Id, URL__c, Type__c, CreatedById, CreatedDate,
                                        Start_Date__c, Template__c, Skip_Menu_Link__c, RecordType.Name 
                                        FROM Intranet_Content__c
                                        WHERE ((Start_Date__c <= :dateTime.now() AND 
                                          End_Date__c >= :dateTime.now()) OR
                                          Status__c = 'Published') 
                                        AND RecordType.Name = 'Intranet Article'
                                        AND Type__c = 'News'
                                        AND ID IN :versionContentIdMap.values() 
                                        ORDER BY Start_Date__c]){
          for(SObject innerSobj : versionContentIdMap.keySet()){
            if(versionContentIdMap.get(innerSobj) == sobj.Id){
              versionContentMap.put(innerSobj, sobj);
            }
          }
        }

        Set<ID> searchObjectIds = new Set<ID>();
        for(List<SObject> thisObjList : searchList){
          for(sObject thisObj : thisObjList){
            if(thisObj != null){
              objType = string.valueOf(thisObj.getsObjectType());
              if(objType == 'Intranet_Content_Version__c'){
                searchObjectIds.add(thisObj.Id);
              }
            }
          }
        }

        // Get topics for returned Feed Items
        for(FeedItem feedItem : [SELECT Id, (SELECT Topic.Name FROM TopicAssignments) FROM FeedItem WHERE Id IN :feedItemMap.keySet()]){
          Set<String> topics = new Set<String>();
          for(TopicAssignment topic : feedItem.TopicAssignments){
            topics.add(topic.Topic.Name);
          }
          feedItemMap.put(feedItem.Id, topics);
        }

        //iterate over all the search results so we can build searchResult items from them.
        //the search result is broken in a list of sObjects, each of which contain a list of results. 
        //similar to how we want to evenetually return the data, but we gotta do some formatting to it first.
        for(List<sObject> thisObjList : searchList){
          for(sObject thisObj : thisObjList){   
            //create a new search result object.
            searchResult thisResult = new searchResult();
            
            //find the sObject type of this object.
            objType = string.valueOf(thisObj.getsObjectType());
            objLabel = objType;

            //set some default information that all returned objects should have.
            thisResult.type = objType;
            thisResult.recordid = (id) thisObj.get('Id');

            if(objType != 'Intranet_Content_Version__c'){
              thisResult.link = URL.getSalesforceBaseUrl().toExternalForm() + '/' + (String)thisObj.get('Id');
            }else {
              thisResult.link = 'javascript:void(0);';    
            }

            thisResult.objectData = thisObj;

            //if a label for this object type was provided set it now. Otherwise the name of the object is also the label.
            if(objectLabels.containsKey(objType)){
              objLabel = objectLabels.get(objType);
            }
            
            // If this result is a content version object then set its properties accordingly.            
            if(objType == 'ContentVersion'){
              Boolean includeTag = false;
              Boolean includeType = false;
              Boolean include = false;
              if(thisObj.get('TagCsv')!=null){
                String str = ((String)thisObj.get('TagCsv'));
                thisResult.tags = new Set<String>(str.split(','));
              }

              // Set flag if tag filters are set in search and match is found
              if(tagList.size() > 0){
                if(!thisResult.tags.isEmpty()){
                  Set<String> resultTags = new Set<String>(thisResult.tags);
                  for(String tag : tagList){
                    if(resultTags.contains(tag)){
                      includeTag = true;
                    }
                  }
                }
              } else {
                includeTag = true;
              }

              // Set flag file type filters are set in search and match is found
              if(fileTypes.size() == 0 || fileTypes.contains((String)thisObj.get('FileType'))){
                includeType = true;
              }

              // Include if no filters or if match was found for tag or type
              if(fileTypes.size() == 0 && tagList.size() == 0
                || (includeType && includeTag)){
                thisResult.fileType = (string) thisObj.get('FileType');
                thisResult.title = ((string) thisObj.get('Title')).escapeEcmaScript();
                thisResult.description = (string) thisObj.get('Description');
                thisResult.link = ((string) thisObj.get('FileType') == 'LINK') ? (string) thisObj.get('ContentUrl') : (isMobile == true ? '/sfc/servlet.shepherd/version/download/'+(string) thisObj.get('Id')+'?asPdf=false&amp;operationContext=CHATTER' : URL.getSalesforceBaseUrl().toExternalForm() + '/' +(string) thisObj.get('ContentDocumentId'));
                thisResult.recordid = (id) thisObj.get('ContentDocumentId');
                thisResult.size = (integer) thisObj.get('ContentSize');
                mapofversionIdandVersion.put(thisResult.recordid, (ContentVersion)thisObj);
              }
            }
            
            // If this result is a content version object then set its properties accordingly, including getting the posting users name to 
            // use for the title.  
            else if(objType == 'FeedItem'){    
              //do not considered Intranet article feed.
              if(((String) thisObj.get('ParentId')).startsWith(IntranetArticleKeyPrefix)) {
                continue;
              }else {
                Boolean includeTag;
                if(tagList.size() > 0){
                  for(String tag : tagList){
                    includeTag = feedItemMap.get((Id)thisObj.get('Id')).contains(tag);
                  }
                }
                if(tagList.size() == 0 || includeTag){
                  sObject postingUser = Test.isRunningTest() ? [SELECT Id, Name FROM User WHERE Id = :(Id)thisObj.get('InsertedById')] : thisObj.getsObject('InsertedBy');               
                  thisResult.title = (String) postingUser.get('Name');
                  thisResult.description = (((string) thisObj.get('Body')) != null && ((string) thisObj.get('Body')).endsWith('.')) ? (string) thisObj.get('Body') : (string) thisObj.get('Body') + '.';
                  thisResult.startDate =  'Posted on ' + ((DateTime) thisObj.get('CreatedDate')).format('MMMM d, yyyy hh:mm:ss a', 'PST');
                  thisResult.link = '/apex/KAR_ViewUserProfile?id='+(String)postingUser.Id;
                  thisResult.tags = feedItemMap.get((Id)thisObj.get('Id'));
                }
              }
            }else if(versionContentMap.get(thisObj) != null && objType == 'Intranet_Content_Version__c' && versionContentMap.get(thisObj).RecordType.Name == 'Intranet Article'){
              objLabel = 'Articles';
              thisResult.title = (string)thisObj.get('Name');
              thisResult.description = (string)thisObj.get('Summary__c');
              thisResult.startDate = versionContentMap.get(thisObj).Start_Date__c.format('MMMM d, yyyy hh:mm:ss a', 'PST');
              if(versionContentMap.get(thisObj).URL__c != '' && versionContentMap.get(thisObj).URL__c != null) {
                if(!versionContentMap.get(thisObj).URL__c.contains('http') && !versionContentMap.get(thisObj).URL__c.contains('https')){
                  versionContentMap.get(thisObj).URL__c = 'https://' + versionContentMap.get(thisObj).URL__c;
                }
                thisResult.link = versionContentMap.get(thisObj).URL__c;
              } else {
                thisResult.link = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/KAR_Content?id=' + (string) versionContentMap.get(thisObj).Id + '&category=Content&lang=' + (string)thisObj.get('Language__c');
              }
            }else{
              if(objType != 'Intranet_Content_Version__c') {
                thisResult.link = '/' + (string)thisObj.get('Id');
                thisResult.title = (string)thisObj.get('Name');
              }
            }

            //append this search result to the proper list using the object label as the key to find the right list.
            if(thisResult.title != ''){
              if(!results.containsKey(objLabel))
              {  
                  results.put(objLabel,new list<searchResult>());
              }
              results.get(objLabel).add(thisResult);
            }
          }
        }                         
      }catch(Exception e){
        system.debug(e);
        system.debug(e.getLineNumber());
      }

      return results;
    }
    
    /*  
        method is used to find Top level parent of Selected CMS Page
        Argument:
            PageName : a CMS page name for which top level parent required.
    */
    private static void getParentpageName(String pageName) {
        tabName = pageName;
        if(parentTabMap.get(pageName) != null) {
            getParentpageName(parentTabMap.get(pageName));
        }
    }
    
    private static void getCurrentParentPageName(String pageName) {
        if(parentTabMap.get(pageName) != null) {
            tabName = parentTabMap.get(pageName);
        }   
    }
    //function for finding all the objects in this org that can be searched for. This includes custom objects
    //returns them as a map of the object label to the object name. Meant to be invoked via the interface at runtime.
    @remoteAction
    global static map<string,string> getSearchableObjects()
    {
        //list of object labels and names to return
        map<string,string> searchableObjects = new map<string,string>();
        
        //global describe of all objects in the org.
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        
        //iterate over all objects
        for(string objType : gd.keySet())
        {
            //only add this object type if it is searchable, since this list will be used to create an interface
            //where the user can select which objects to search. No sense in including non searchable objects eh?
            if(gd.get(objType).getDescribe().isSearchable())
            {
                searchableObjects.put(gd.get(objType).getDescribe().getLabel(),objType);
            }
        }
        return searchableObjects;
    }
}