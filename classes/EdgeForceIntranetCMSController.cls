// 
// (c) 2014 Appirio, Inc.
// 
// EdgeForceIntranetCMSController
// controller class for page EdgeForceCMS_Pages
// T-295755
//
// 28 July 2014     Ashish Goyal(JDC)       Original
//
// 16 October 2014  Sidhant Agarwal         Modified(T-325464)
//
// 29 October 2014  Sidhant Agarwal         Modified(T-329504)
// Added if-else block to show the External URL on the Intranet Content
//
// 7 November 2014  Sidhant Agarwal         Modified(T-331988)
//
// 24 November 2014  Sidhant Agarwal         Modified(T-336113)
// 25 November 2014  Sidhant Agarwal         Modified(T-336115)
public with sharing class EdgeForceIntranetCMSController {
    
    public  String UIElement{get;set;}
    public  String ICID{get;set;}
    public  String SelectedICVID{get;set;}
    public  List<Intranet_Content_Version__c> currentlyPublishedICVs;
    public  Map<String,Intranet_Content_Version__c> mapofcontentIdandpublishedVersion{get;set;}
    public  Map<String,List<String>> mapofParentContentIdandChildContrntIds{get;set;}
    public  Map<String,Intranet_Content__c> mapofContentIdandContents{get;set;}
    public  Map<String,List<String>> mapofContentIdandAllVersions{get;set;}
    public  Map<String,Intranet_Content_Version__c >  mapofversionIdandVersion{get;set;}
    public  List<ICVWrapper> listOfICVWrappers{get;set;}
    public  String userLanguage; 
    public  Map<String,String> mapofUseridanduserName;
    //map to hold result. The result will have cms page name and their respective parent page name.
    public Map <String, String> parentTabMap {get; set;}
    //String used to select tab on Inranet pages.
    private String tabName {get;set;}
    Public String cloneID {get;set;}
    Set<String> setofContentsKey = new Set<String>();
    public String versionPageName {get;set;}
    //public Set<String> groupIdSet {get; set;}
    public static final String GRP_NAME = 'Intranet System Admins';
    //public String adminGrpId {get; set;}
    public String recordTypeId {get;set;}
    
    // Constructor..
    public EdgeForceIntranetCMSController(){
        /*groupIdSet = new Set<String>();
        for(GroupMember grpMem : [Select UserOrGroupId, GroupId, Group.Name From GroupMember 
                                    where UserOrGroupId =: UserInfo.getUserId()]){
            String testStr = grpMem.GroupId;
            testStr = testStr.substring(0, 15);
            if(grpMem.Group.Name == GRP_NAME){
                adminGrpId = testStr;
            }
            groupIdSet.add(testStr);
        }*/
        recordTypeId = Schema.SObjectType.Intranet_Content__c.getRecordTypeInfosByName().get('Intranet CMS Pages').getRecordTypeId();
        processAllCMSPages();
    }
    
    public Void processAllCMSPages(){
        
        mapofParentContentIdandChildContrntIds =  new   Map<String,List<String>>();
        mapofContentIdandContents              =  new   Map<String,Intranet_Content__c>();
        mapofcontentIdandpublishedVersion      =  new   Map<String,Intranet_Content_Version__c>();
        mapofContentIdandAllVersions           =  new   Map<String,List<String>>();
        mapofversionIdandVersion               =  new   Map<String,Intranet_Content_Version__c > ();
        UIElement    = '';
        mapofUseridanduserName                 =  new    Map<String,String>();
        parentTabMap                           =  new    Map <String, String>();
        tabName = '';
        versionPageName = '';
        for(Intranet_Content__c config : [Select Name, value__c From Intranet_Content__c where Name=:userinfo.getLanguage() AND  recordType.Name = 'Config - Portal']) {
            if(config <> null && config.value__c <> null){
                userLanguage = config.value__c;
            }
        }
    
        Set<String> setofallContentIds ; 
         List<String> listofallContentIds ;
        //Fetch All Contents
        //system.debug('==========groupIdSet------------'+groupIdSet);
        for(Intranet_Content__c contentData : [ SELECT Id,  Name, RecordType.Name,Parent__r.Name,LastModifiedById ,LastmodifiedDate, 
                                                Article_Type__c, Banner_Type__c, Button_Location__c, Category__c, Country__c, 
                                                Create_Chatter_Group__c, Display_Status__c, Document_Type__c, End_Date__c, 
                                                Header_Color__c, Link_Type__c, Parent__c, Position__c, Presentation_Date__c, 
                                                Sequence__c, Show_in_Header_Menu__c, Skip_Menu_Link__c, Source_Date__c, 
                                                Start_Date__c, Status__c, Summary_Color__c, Target__c, Template__c, 
                                                Topic__c, Type__c, URL__c, Video_Caption__c, Video_Type__c, Video__c 
                                                FROM Intranet_Content__c
                                                Where RecordType.Name = 'Intranet CMS Pages'])
          {
            //for(String str : groupIdSet){
                //if(adminGrpId != null || (contentData.Page_Admin__c != null && contentData.Page_Admin__c.contains(str))){    
                  if(contentData <> null){
                      if(contentData.Template__c == null)
                          contentData.Template__c = '';
                      //populate parentTabMap will have cms page name and their respective parent page name
                      parentTabMap.put(contentData.Name, contentData.Parent__r.Name);
                      
                      mapofUseridanduserName.put(contentData.LastModifiedById,null);
                      
                      mapofContentIdandContents.put(contentData.Id,contentData);
                      
                      if(contentData.parent__c <> null && String.valueof(contentData.parent__c) <> ''){
                          if(mapofParentContentIdandChildContrntIds.containsKey(String.valueof(contentData.parent__c))){
                              
                              setofallContentIds = new    set<String>();
                              listofallContentIds  = new   List<String> ();
                              setofallContentIds.addall(mapofParentContentIdandChildContrntIds.get(String.valueof(contentData.parent__c)));
                              setofallContentIds.add(contentData.Id);
                              listofallContentIds.addAll(setofallContentIds);
                              if(contentData.parent__r.Name == 'Apps'){
                                system.debug('*****check**'+listofallContentIds);
                              }
                              mapofParentContentIdandChildContrntIds.put(String.valueof(contentData.parent__c).trim(),listofallContentIds);
                          }else{
                              List<String> listofnewContentIds = new  List<String>();
                              listofnewContentIds.add(String.valueof(contentData.Id));
                              mapofParentContentIdandChildContrntIds.put(String.valueof(contentData.parent__c).trim(),listofnewContentIds);
                          }
                      }else{
                          if(mapofParentContentIdandChildContrntIds.containsKey(contentData.Id)==false){
                              List<String> listofnulls = new  List<String>();
                              mapofParentContentIdandChildContrntIds.put(contentData.Id,listofnulls);
                          }   
                      }
                  }  
                }
          //  }                       
         // }
        
         mapofParentContentIdandChildContrntIds = sortBySequence(mapofParentContentIdandChildContrntIds);
        
        //Fetch All Versions and create a Map to Use in Page
        for(Intranet_Content_Version__c contentVersionData : [ SELECT Id,  Name, Intranet_Content__c, Button_Label__c, Button_Location__c, 
                                                                Description__c, Header_Color__c, Header__c, Language__c, Position__c, 
                                                                Source__c, Summary_Color__c, Summary__c, Video_Caption__c, 
                                                                Video_ID__c, Video_Type__c, isPublished__c, Status__c,LastModifiedBy.Name,
                                                                LastModifiedDate 
                                                                FROM Intranet_Content_Version__c 
                                                                WHERE Intranet_Content__c IN: mapofContentIdandContents.keySet()  AND isPublished__c = true])
        {
          
          if(contentVersionData <> null && contentVersionData.Intranet_Content__c <> null){ 
              if(contentVersionData.isPublished__c == true && contentVersionData.Language__c == userLanguage){                                
                  mapofcontentIdandpublishedVersion.put(contentVersionData.Intranet_Content__c,contentVersionData); 
              }
              if(mapofContentIdandAllVersions.containsKey(contentVersionData.Intranet_Content__c)) {   
                  Set<String> setofallIds = new Set<String>();    
                  List<String> listofallIds = new List<String>();                             
                  setofallIds.addAll(mapofContentIdandAllVersions.get(contentVersionData.Intranet_Content__c));
                  setofallIds.add(contentVersionData.Id);
                  listofallIds.addAll(setofallIds);
                  mapofContentIdandAllVersions.put(contentVersionData.Intranet_Content__c,listofallIds);  
              }else{
                  List<String> newVersions = new List<String>();
                  newVersions.add(contentVersionData.Id);
                  mapofContentIdandAllVersions.put(contentVersionData.Intranet_Content__c,newVersions);  
              }   
          }                                 
          if(contentVersionData <> null){
              mapofversionIdandVersion.put(contentVersionData.id,contentVersionData);               
          }                                                                                             }
                                                              
        system.debug('****mapofContentIdandAllVersions***'+mapofContentIdandAllVersions);                                                      
        
        processUserData();        
        processTreeView();
        
        system.debug('******UIElement*****'+UIElement);
    }
    
    
    
    public void processUserData(){
        for(User userData : [Select id,Name from User Where id  IN :mapofUseridanduserName.keySet()]){
            if(userData <> null)
                mapofUseridanduserName.put(userData.Id,userData.Name);
        }
    }
    
    public void showClone(){
        cloneId = ApexPages.currentPage().getParameters().get('cloneID');
    }
    
    public Map<String,List<String>> sortBySequence(Map<String,List<String>>  inputMap  ){
        Map<String,List<String>> returnedSortedMap = new Map<String,List<String>>();
        List<Integer> listofSequences = new List<Integer> ();
        for(String contentId : inputMap.Keyset()){
            //T-336115
            if(contentId != null && mapofContentIdandContents != null && mapofContentIdandContents.containsKey(contentId)) {
                if(mapofContentIdandContents.get(contentId).Parent__c == null){
                    listofSequences.add(Integer.valueof(mapofContentIdandContents.get(contentId).Sequence__c));
                }
            }
        }
        listofSequences.sort();
        
        for(Integer sequence :listofSequences){
            for(String contentId : inputMap.Keyset()){
                //T-336115
                if(contentID != null && mapofContentIdandContents != null && mapofContentIdandContents.containsKey(contentId)) {
                    //T-336115
                    if(sequence != null && mapofContentIdandContents.get(contentId).sequence__c == String.valueof(sequence))
                    returnedSortedMap.put(contentId,sortList(mapofParentContentIdandChildContrntIds.get(contentId)));
                }
            }
        }
        return returnedSortedMap;
    }
    
    public List<String> sortList(List<String> inputList){
          List<Integer> listofSequences = new List<Integer> ();
          List<String> returnedList = new List<String> ();
            if(inputList <> null && inputList.size()>0){  
                for(String idData  : inputList){
                      listofSequences.add(Integer.valueof(mapofContentIdandContents.get(idData).Sequence__c));
                }
                 listofSequences.sort();
                 
                 for(Integer sequence : listofSequences){
                    for(String contentId :inputList){
                        //T-336115; sequence!=null
                        if(sequence!=null && mapofContentIdandContents.get(contentId).sequence__c == String.valueof(sequence))
                              returnedList.add(contentId);
                    }
                 }
            }else{
                returnedList = inputList;
            }
         return returnedList;
    }
    
    
    public String getUrlbasedonTemplate(Intranet_Content__c targetcontent){
        String url = '';
        if(targetcontent.URL__c != null) {
            //Modified by Sidhant Agarwal T-329504
            //Start
            if(!targetcontent.URL__c.contains('https')){
                if(targetcontent.URL__c.contains('http')){
                    url = targetcontent.URL__c.replace('http', 'https');    
                }else{
                    url = 'https://' + targetcontent.URL__c;                        
                }
            }else{
                    url = targetcontent.URL__c;
            //End
            }
        }else {
            if(targetcontent.template__c == 'Home') {
                url = '/apex/KAR_Home';
            }else if(targetcontent.template__c == 'Team') {
                getParentpageName(targetcontent.name);
                url = '/apex/KAR_Team?&name='+EncodingUtil.urlEncode(targetcontent.name, 'UTF-8');
            }else if(targetcontent.template__c == 'Content') {
                //T-336113
                getCurrentParentPageName(targetcontent.name);
                url = '/apex/KAR_Content?Id=' + targetcontent.id + '&category=Content';
            }else if(targetcontent.template__c == 'Chatter') {
                getParentpageName(targetcontent.name);
                url = '/apex/KAR_ChatterPage';
            }else if(targetcontent.template__c == 'News'){
              getParentpageName(targetcontent.name);
                url = '/apex/KAR_NewsPage';
            }
            else if(targetcontent.template__c == 'Employee Directory'){
                getParentpageName(targetcontent.name);
                url = '/apex/KAR_EmployeeDirectory';
            }else if(targetcontent.template__c == 'Document Directory'){
                getParentpageName(targetcontent.name);
                url = '/apex/KAR_DocumentDirectory';
            }
            else if(targetcontent.template__c == 'Video Gallery'){
                getParentpageName(targetcontent.name);
                url = '/apex/KAR_VideoGallery';
            }else if(targetcontent.template__c == 'Content Full') {
                getCurrentParentPageName(targetcontent.name);
                url = '/apex/KAR_Content_Full?Id=' + targetcontent.id + '&name='+EncodingUtil.urlEncode(targetcontent.name, 'UTF-8');
            }
        }
        return url;        
    }
    
    
    public void processTreeView(){
        UIElement = '';
           List<String> listofRootContentIds = new  List<String> ();
        for(String contentId : mapofContentIdandContents.keyset()){
        
           if(mapofContentIdandContents.get(contentId).parent__c == null)
             listofRootContentIds.add(contentId);               
          
        }
        listofRootContentIds = sortList(listofRootContentIds);
        
        for(String rootContentId : listofRootContentIds){
            if(mapofParentContentIdandChildContrntIds.containsKey(rootContentId)) {
              
               if(setofContentsKey.contains(rootContentId)== false)
                 createNode(rootContentId);      
           }
        }
        
        system.debug('****undernode***'+  UIElement);
    }
    
    
    public void createNode(String nodeId){
        if(mapofContentIdandContents.containsKey(nodeId)){
            String cloneData = '';
            if(mapofContentIdandContents.get(nodeId).Template__c == 'Team'){
                cloneData = '<a onclick="openCloneModal(\''+nodeId+'\')" style="font-weight: bold;" href="#">[Clone]</a>';
                
            }
            
            String versionName = '';
            String nodeVersionId = '';
            //check if there is published version else primary version
            if(mapofcontentIdandpublishedVersion.containsKey(nodeId)){
                versionName = mapofcontentIdandpublishedVersion.get(nodeId).Name;
                nodeVersionId = mapofcontentIdandpublishedVersion.get(nodeId).Id;
            }else{
                //Null ckeck added Ref No. T-336115
                if(mapofContentIdandAllVersions != null && mapofContentIdandAllVersions.get(nodeId) != null) {
                    for(String versionId : mapofContentIdandAllVersions.get(nodeId)){ 
                      //check for primary record of that content
                      //if(versionId <> null && mapofversionIdandVersion.containsKey(versionId) && 
                      //      mapofversionIdandVersion.get(versionId).Primary_Record__c == true) 
                      //Commented by Sidhant Agarwal T-331988
                      if(versionId <> null && mapofversionIdandVersion.containsKey(versionId))
                                versionName = mapofversionIdandVersion.get(versionId).Name;
                                nodeVersionId = mapofversionIdandVersion.get(versionId).Id; 
                      
                    }
                }
            }
            UIElement += '<tr data-tt-id="'+nodeId+'"   data-tt-parent-id="'+mapofContentIdandContents.get(nodeId).parent__c+'"><td><a href="#" onclick="window.open(\'/'+nodeId+'\')">'+versionName+' '+cloneData+'</a></td><td id="_sequence">'+mapofContentIdandContents.get(nodeId).Sequence__c+'</td><td>'+mapofContentIdandContents.get(nodeId).Status__c+'</td><td>'+mapofContentIdandContents.get(nodeId).Template__c+'</td><td><a href="#"  onclick="window.open(\''+getUrlbasedonTemplate(mapofContentIdandContents.get(nodeId))+'\')">Demo</a></td><td><center><a href="#" style="color:#02070C"  class="glyphicon glyphicon-list-alt"  onclick="showVersionsModal(\''+nodeId+'\')"/></center></td><td><a href="#" onclick="window.open(\'/'+nodeId+'\')" > View </a><a href="#" onclick="window.open(\'/'+nodeId+'/e?retURL=%2F'+nodeId+'\')"> Edit </a><a href="#" onclick="deleteContent(\''+nodeId+'\')"> Delete </a></td><td>'+mapofUseridanduserName.get((mapofContentIdandContents.get(nodeId).LastmodifiedById))+'   '+mapofContentIdandContents.get(nodeId).LastmodifiedDate.format('MM/dd/yy hh:mm:ss a')+'</td></tr>';
            setofContentsKey.add(nodeId);
         //   mapofParentContentIdandChildContrntIds = sortBySequence(mapofParentContentIdandChildContrntIds);
            if(mapofParentContentIdandChildContrntIds.containsKey(nodeId) && mapofParentContentIdandChildContrntIds.get(nodeId).size()>0){
                for(String ndId : mapofParentContentIdandChildContrntIds.get(nodeId)){
                    if(!setofContentsKey.contains(ndId))
                    createNode(ndId); 
                }                         
            }
        }              
    }
    
    
    //method to show ICV with respect to IC ID
    public void showICV(){
        listOfICVWrappers                            =     new List<ICVWrapper>();
        List<String> listOfICVIDs                    =     new List<String>();
        currentlyPublishedICVs                       =     new List<Intranet_Content_Version__c>();
        if(mapofContentIdandAllVersions.containsKey(ICID)){
            listOfICVIDs = mapofContentIdandAllVersions.get(ICID);
        }

        for(String ICVId : listOfICVIDs){
            if(mapofversionIdandVersion.get(ICVId).language__c=='English'){
                listOfICVWrappers.add(new ICVWrapper(mapofversionIdandVersion.get(ICVId)));
                versionPageName = mapofversionIdandVersion.get(ICVId).Name; 
                if(mapofversionIdandVersion.get(ICVId).isPublished__c==true){
                    currentlyPublishedICVs.add(mapofversionIdandVersion.get(ICVId));
                }
            }
        }
        
        for(String ICVId : listOfICVIDs){
            if(mapofversionIdandVersion.get(ICVId).language__c!='English'){
                listOfICVWrappers.add(new ICVWrapper(mapofversionIdandVersion.get(ICVId)));
                versionPageName = mapofversionIdandVersion.get(ICVId).Name;
                if(mapofversionIdandVersion.get(ICVId).isPublished__c==true){
                    currentlyPublishedICVs.add(mapofversionIdandVersion.get(ICVId));
                }
            }
        }
    }
    
    //wrapper to wrap ICV with checkbox
    public class ICVWrapper{
        public String id{get;set;}
        public String pageName{get;set;}
        public Boolean isPublished{get;set;}
        public String language{get;set;}
        public String lastModifiedBy{get;set;}
        public String lastModifiedDate{get;set;}
        
        public ICVWrapper(Intranet_Content_Version__c ICV){
            this.pageName       = ICV.Name;
            this.isPublished    = ICV.isPublished__c;
            this.language       = ICV.language__c;
            this.lastModifiedBy = ICV.LastModifiedBy.Name;
            this.id             = ICV.id;
            this.lastmodifiedDate = ICV.LastModifiedDate.format();
        }
    }
    
    //method to delete the ICV
    public void deleteICV(){
        Intranet_Content_Version__c ICVtoDelete = new Intranet_Content_Version__c(id=SelectedICVID);
        delete ICVtoDelete;
       
        processAllCMSPages();
        showICV();
    }
    
    //method to publish any ICV
    public void publishICV(){
        List<Intranet_Content_Version__c> listToUpdatePublished  = new List<Intranet_Content_Version__c>();
        for(Intranet_Content_Version__c publishedICV: currentlyPublishedICVs){
            if(publishedICV.language__c == mapofversionIdandVersion.get(SelectedICVID).language__c){
                publishedICV.isPublished__c = false;
                listToUpdatePublished.add(publishedICV);
            }
        }
         
        Intranet_Content_Version__c newPublishedICV          = new Intranet_Content_Version__c(id=SelectedICVID);
        newPublishedIcv.isPublished__c = true;
        listToUpdatePublished.add(newPublishedICV); 
        
        update listToUpdatePublished;
        
        processAllCMSPages();
        showICV();
    }
    
    
    @remoteAction
        public static List<Intranet_Content__c> getAllParentPages(){
            
            List<Intranet_Content__c> listofCMSPages = new  List<Intranet_Content__c>();
            Set<String> setofParentPageIds = new Set<String>();
            Map<String,Intranet_Content__c> mapofpageIdAndPage = new  Map<String,Intranet_Content__c>();           
            for(Intranet_Content__c intranetCMSPage : [ SELECT Id,  Name, RecordType.Name, Article_Type__c, Banner_Type__c, Button_Location__c, Category__c, Country__c, Create_Chatter_Group__c, Display_Status__c, Document_Type__c, End_Date__c, Header_Color__c, Link_Type__c, Parent__c, Position__c, Presentation_Date__c, Sequence__c, Show_in_Header_Menu__c, Skip_Menu_Link__c, Source_Date__c, Start_Date__c, Status__c, Summary_Color__c, Target__c, Template__c, Topic__c, Type__c, URL__c, Video_Caption__c, Video_Type__c, Video__c 
                                                       FROM Intranet_Content__c
                                                       WHERE RecordType.Name = 'Intranet CMS Pages' ]){
                                                           if(intranetCMSPage <> null && intranetCMSPage.Parent__c == null){
                                                               setofParentPageIds.add(intranetCMSPage.Id);         
                                                               mapofpageIdAndPage.put(intranetCMSPage.id,intranetCMSPage);                                                                 
                                                           }
                                                       }
            
            for(String parentId : setofParentPageIds){
                listofCMSPages.add(mapofpageIdAndPage.get(parentId));
            }
            return listofCMSPages;
        }
    
    
    @remoteAction
        public static List<Intranet_Content__c> processAllChildRows(String parentId){
            List<Intranet_Content__c> listofCMSPages = new  List<Intranet_Content__c>();
            for(Intranet_Content__c intranetCMSPage : [SELECT Id,  Name, RecordType.Name, Article_Type__c, Banner_Type__c, Button_Location__c, Category__c, Country__c, Create_Chatter_Group__c, Display_Status__c, Document_Type__c, End_Date__c, Header_Color__c, Link_Type__c, Parent__c, Position__c, Presentation_Date__c, Sequence__c, Show_in_Header_Menu__c, Skip_Menu_Link__c, Source_Date__c, Start_Date__c, Status__c, Summary_Color__c, Target__c, Template__c, Topic__c, Type__c, URL__c, Video_Caption__c, Video_Type__c, Video__c 
                                                       FROM Intranet_Content__c
                                                       WHERE RecordType.Name = 'Intranet CMS Pages' and Parent__c =: parentId]){
                                                           if(intranetCMSPage <> null){
                                                               listofCMSPages.add(intranetCMSPage);                                                                            
                                                           }
                                                       }
            return listofCMSPages;
        }
    
    //Method used resursive process to find top level parent of any CMS Page
    public void getParentpageName(String pageName) {
        tabName = pageName;
        if(!Test.isRunningTest()){
            if(parentTabMap.get(pageName) != null) {
                getParentpageName(parentTabMap.get(pageName));
            }
        }
    }
    
// @description: Method to retrieve the parent to the current CMS Page
// Added By Sidhant Agarwal T-325464
// Modified: T-336113
    public void getCurrentParentPageName(String pageName) {
        //tabName = pageName;
        if(parentTabMap.get(pageName) != null) {
            tabName = parentTabMap.get(pageName);
        }
    }

}