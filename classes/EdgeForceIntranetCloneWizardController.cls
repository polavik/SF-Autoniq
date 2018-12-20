/*******************************************************************************************
  *Modified by   : Sil
  *Modified date : 10-March-2014
  *purpose       : Issue with tag Cloning
  *changeid      : c001 
   ******************************************************************************************
   */
public  class EdgeForceIntranetCloneWizardController {

   
    public String contentIdParameter{get;set;}
  
    public  Map<String,Intranet_Content_Version__c> mapofcontentIdandpublishedVersion{get;set;}
    public  Map<String,List<String>> mapofParentContentIdandChildContentIds{get;set;}
    public  Map<String,Intranet_Content__c> mapofContentIdandContents{get;set;}
    public  Map<String,List<String>> mapofContentIdandAllVersions{get;set;}
    public  Map<String,Intranet_Content_Version__c >  mapofversionIdandVersion{get;set;}
    public  Set<String> setofAllPageNames;
  public  boolean isPrefixChecked{get;set;}{isPrefixChecked = false;}
  public  String newPageName{get;set;}
  public  String NewPrefixName{get;set;}
    public  List<SelectOption> listofoptionsforUI{get;set;}   
    public  String[] optionsSelected{get;set;}
    public  String statusMessage{get;set;}{statusMessage = '';}
    public  boolean isError{get;set;}
    public  Intranet_Content__c  newPrimaryContentafterClone{get;set;}
    public  List<String> listofrecordTypenames {get;set;}
    public String blankPrefix{get;set;}{blankPrefix = '';}
    
    public String userLanguage{get;set;}
    
  
  public EdgeForceIntranetCloneWizardController(){
    contentIdParameter = '';
    if(apexpages.currentPage().getParameters().get('id') <> null && apexpages.currentPage().getParameters().get('id') <> ''){
      contentIdParameter = apexpages.currentPage().getParameters().get('id');    
      listofoptionsforUI = new  List<SelectOption>();
      
      mapofParentContentIdandChildContentIds =  new   Map<String,List<String>>();
        mapofContentIdandContents              =  new   Map<String,Intranet_Content__c>();
         mapofcontentIdandpublishedVersion      =  new   Map<String,Intranet_Content_Version__c>();
      mapofContentIdandAllVersions           =  new   Map<String,List<String>>();
      mapofversionIdandVersion               =  new   Map<String,Intranet_Content_Version__c > ();
      setofAllPageNames                      =  new   Set<String>();
      newPrimaryContentafterClone            =  new   Intranet_Content__c();
      listofrecordTypenames                  =  new   List<String>();
      
      for(Intranet_content__c config : [Select Name, value__c From Intranet_content__c where Name=:userinfo.getLanguage() AND  recordType.Name = 'Config - Portal']) {
            if(config<> null && config.value__c <> null){
                userLanguage = config.value__c;
            }
        }
      
      processAllTags();
      
      populateOptions();
      getAllContentData();
      
      
    }
  }
  
  
  public void populateOptions(){
    listofoptionsforUI.add(new SelectOption('Child Pages','Child Pages'));
    listofoptionsforUI.add(new SelectOption('Quick Links','Quick Links'));
    listofoptionsforUI.add(new SelectOption('Banners','Banners'));
    listofoptionsforUI.add(new SelectOption('Articles','Articles'));
    optionsSelected = new List<String>();
    optionsSelected.add('Child Pages');
    optionsSelected.add('Quick Links');
    optionsSelected.add('Banners');
    optionsSelected.add('Articles');
  }
  
  
  public void processAllTags(){
    for(Tags__c allTag : [SELECT Id,tag__c, Name FROM Tags__c limit 1000]){
      if(allTag <> null && allTag.tag__c <> null && allTag.tag__c <> '')
      setofAllPageNames.add(allTag.tag__c.touppercase());
    }
  }
  public void getAllContentData(){
    
  
         
         //Fetch All Contents
         for(Intranet_Content__c contentData : [ SELECT Id,  Name, RecordType.Name, Article_Type__c, Banner_Type__c, Button_Location__c, Category__c, Country__c, Create_Chatter_Group__c, Display_Status__c, Document_Type__c, End_Date__c, Header_Color__c, Link_Type__c, Parent__c, Position__c, Presentation_Date__c, Sequence__c, Show_in_Header_Menu__c, Skip_Menu_Link__c, Source_Date__c, Start_Date__c, Status__c, Summary_Color__c, Target__c, Template__c, Topic__c, Type__c, URL__c, Video_Caption__c, Video_Type__c, Video__c 
                                                 FROM Intranet_Content__c
                                              
                                                ]){
                                                  
                                     if(contentData <> null){
                                       
                                       setofAllPageNames.add(contentData.Name.toUppercase());
                                       mapofContentIdandContents.put(contentData.Id,contentData);
                                       if(contentData.parent__c <> null){
                                         if(mapofParentContentIdandChildContentIds.containsKey(contentData.parent__c)){
                                           Set<String> setofallContentIds = new   set<String>();
                                             List<String> listofallContentIds = new    List<String> ();
                                           setofallContentIds.addAll(mapofParentContentIdandChildContentIds.get(contentData.parent__c));
                                           setofallContentIds.add(contentData.Id);
                                           listofallContentIds.addAll(setofallContentIds);
                                           mapofParentContentIdandChildContentIds.put(contentData.parent__c,listofallContentIds);
                                         }else{
                                           List<String> listofnewContentIds = new   List<String>();
                                           listofnewContentIds.add(contentData.Id);
                                           mapofParentContentIdandChildContentIds.put(contentData.parent__c,listofnewContentIds);
                                         }
                                       }else{
                                         List<String> listofnulls = new   List<String>();
                                         mapofParentContentIdandChildContentIds.put(contentData.Id,listofnulls);
                                       }
                                     }                         
          }
             
         Map<String,Intranet_Content_Version__c> mapofFinalVersionIdandVersion ;
          //Fetch All Versions and create a Map to Use in Page
          for(Intranet_Content_Version__c contentVersionData : [ SELECT Id,  Name, Intranet_Content__c, Button_Label__c, Button_Location__c, Description__c, Header_Color__c, Header__c, Language__c, Position__c, Primary_Record__c, Source__c, Summary_Color__c, Summary__c, Video_Caption__c, Video_ID__c, Video_Type__c, isPublished__c, Status__c 
                                                                 FROM Intranet_Content_Version__c 
                                                                 WHERE Intranet_Content__c IN: mapofContentIdandContents.keySet() ]){
                                                                   
                                           if(contentVersionData <> null && contentVersionData.Intranet_Content__c <> null){  
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
                                             
                                             if(contentVersionData.Intranet_Content__c == contentIdParameter && contentVersionData.isPublished__c == true &&  contentVersionData.Language__c == userLanguage){
                                               mapofcontentIdandpublishedVersion.put(contentVersionData.Intranet_Content__c,contentVersionData);
                                             }
                                             mapofversionIdandVersion.put(contentVersionData.id,contentVersionData);                                
                                           } 
                                           
                                                                         
                                                                 
          }
        
         for(String contentId : mapofContentIdandContents.keyset()){
           if(mapofcontentIdandpublishedVersion.containsKey(contentId)==false && mapofContentIdandAllVersions.containsKey(contentId) && mapofContentIdandAllVersions.get(contentId).size()>0){
             
             for(String versionId : mapofContentIdandAllVersions.get(contentId)){
               if(mapofversionIdandVersion.containsKey(versionId) && mapofversionIdandVersion.get(versionId).Primary_Record__c == true){
                    mapofcontentIdandpublishedVersion.put(contentId,mapofversionIdandVersion.get(versionId));
               }
             }
           }
         }
   }
  
  
  
  //this method will clone main content and its version and generate a new version based on page name 
  public String processContentClone(){
    
     Intranet_Content__c newContent = new Intranet_Content__c();
        if(mapofContentIdandContents != null && mapofContentIdandContents.containsKey(contentIdParameter))
          newContent = mapofContentIdandContents.get(contentIdParameter).clone(false,false);
        newContent.Name = newPageName;
        newContent.Status__c = 'New';
        List<Intranet_Content_Version__c> listofNewVersions = new  List<Intranet_Content_Version__c>();
      
          database.insert(newContent);
          newPrimaryContentafterClone = newContent;
          if(mapofContentIdandAllVersions !=null && mapofContentIdandAllVersions.containsKey(contentIdParameter)){
            for(String newVersionId : mapofContentIdandAllVersions.get(contentIdParameter)){
               if( mapofversionIdandVersion.get(newVersionId).isPublished__c == true){
                  Intranet_Content_Version__c newVersionData = new Intranet_Content_Version__c();
                  newVersionData = mapofversionIdandVersion.get(newVersionId).clone(false,false);
                  newVersionData.Intranet_Content__c = newContent.Id;                
                  newVersionData.Name = newPageName;//all versions will be of same name:
            
              listofNewVersions.add(newVersionData);
                }
            }
          }
           /* Intranet_Content_Version__c finalPublisedversion = new Intranet_Content_Version__c();
              finalPublisedversion.Name = newPageName;
              finalPublisedversion.isPublished__c = true;
              finalPublisedversion.Intranet_Content__c = newContent.Id;         
          if(userLanguage <> null ){
               finalPublisedversion.Language__c = userLanguage;
          }
      listofNewVersions.add(finalPublisedversion);    */
      if(listofNewVersions <> null && listofNewVersions.size()>0)
            database.insert(listofNewVersions);
            return newContent.Id;
     }
  
    public void  processChildContentsClone(String parentContentId){
      
       List<Intranet_Content__c> listofClonedChildContents          = new  List<Intranet_Content__c>();
       List<Intranet_Content__c> listofChildContents                = new  List<Intranet_Content__c>();
       List<Intranet_Content_Version__c> listofChildVersionstoClone = new  List<Intranet_Content_Version__c>();
         Map <String,String> mapofNewNameandOldContenedId= new  Map <String,String>();
         Map<String,String>  mapofoldcontentnameandId = new  Map<String,String>();
         String appendName = '';
         if(mapofParentContentIdandChildContentIds.containsKey(contentIdParameter) &&  mapofParentContentIdandChildContentIds.get(contentIdParameter).size()>0){
           for(String childcontentIds : mapofParentContentIdandChildContentIds.get(contentIdParameter)){         
             listofChildContents.add(mapofContentIdandContents.get(childcontentIds));
             mapofoldcontentnameandId.put(mapofContentIdandContents.get(childcontentIds).name,childcontentIds);
           }
        
        
         listofClonedChildContents = listofChildContents.deepclone();
         for(Integer i=0;i<listofClonedChildContents.size();i++){
           
           listofClonedChildContents[i].Parent__c = parentContentId;
           listofClonedChildContents[i].status__c = 'New';
           
           String oldcontentId = mapofoldcontentnameandId.get(listofClonedChildContents[i].Name);
           if(isPrefixChecked == true && NewPrefixName <> null && NewPrefixName <> ''){
             listofClonedChildContents[i].Name = NewPrefixName + listofClonedChildContents[i].Name ;
             appendName = NewPrefixName;
           }else{
             listofClonedChildContents[i].Name = newPageName + listofClonedChildContents[i].Name ;
             appendName = newPageName;
           }
           mapofNewNameandOldContenedId.put(listofClonedChildContents[i].Name.trim().touppercase(),oldcontentId);
           
         }
        }
        
       Database.insert(listofClonedChildContents);
       system.debug('listofClonedChildContents***'+listofClonedChildContents);
      for(Intranet_Content__c clonedContentAfterInsert : [ SELECT Id,  Name, RecordType.Name, Article_Type__c, Banner_Type__c, Button_Location__c, Category__c, Country__c, Create_Chatter_Group__c, Display_Status__c, Document_Type__c, End_Date__c, Header_Color__c, Link_Type__c, Parent__c, Position__c, Presentation_Date__c, Sequence__c, Show_in_Header_Menu__c, Skip_Menu_Link__c, Source_Date__c, Start_Date__c, Status__c, Summary_Color__c, Target__c, Template__c, Topic__c, Type__c, URL__c, Video_Caption__c, Video_Type__c, Video__c 
                                                            FROM Intranet_Content__c Where Name IN: mapofNewNameandOldContenedId.keyset()]){
                                                              
           system.debug('clonedContentAfterInsert***'+clonedContentAfterInsert);
            system.debug('mapofNewNameandOldContenedId****'+ mapofNewNameandOldContenedId);
        if(clonedContentAfterInsert.Name <> null && mapofNewNameandOldContenedId.containsKey(clonedContentAfterInsert.Name.trim().touppercase()) && mapofContentIdandAllVersions.containskey(mapofNewNameandOldContenedId.get(clonedContentAfterInsert.Name.trim().touppercase()) )){
          for(String versionIdtobeCloned  : mapofContentIdandAllVersions.get(mapofNewNameandOldContenedId.get(clonedContentAfterInsert.Name.trim().touppercase()))){            
             if(mapofversionIdandVersion.containsKey(versionIdtobeCloned)){
               if(  mapofversionIdandVersion.get(versionIdtobeCloned).ispublished__c == true ){
                  Intranet_Content_Version__c newVersiontobeCloned = new Intranet_Content_Version__c();
                 newVersiontobeCloned = mapofversionIdandVersion.get(versionIdtobeCloned).clone(false,false);         
                 newVersiontobeCloned.Intranet_Content__c = clonedContentAfterInsert.Id;
                 newVersiontobeCloned.Name = appendName + newVersiontobeCloned.Name; //all page name will be based on content data insert
                 listofChildVersionstoClone.add(newVersiontobeCloned);
                 }
             }
          }
           system.debug('listofChildVersionstoClone***'+listofChildVersionstoClone); 
              /* Intranet_Content_Version__c newCurrentVersiontobeCloned = new Intranet_Content_Version__c();
             newCurrentVersiontobeCloned.Name = clonedContentAfterInsert.Name;
             newCurrentVersiontobeCloned.isPublished__c = true;
                 newCurrentVersiontobeCloned.Intranet_Content__c = clonedContentAfterInsert.Id;
                 if(userLanguage <> null ){
                 newCurrentVersiontobeCloned.Language__c = userLanguage;
               }
              listofChildVersionstoClone.add(newCurrentVersiontobeCloned);*/
        }
        
        
      }
      
       // system.debug('listofChildVersionstoClone1***'+listofChildVersionstoClone); 
       if(listofChildVersionstoClone <> null && listofChildVersionstoClone.size()>0)
       Database.insert(listofChildVersionstoClone);
    }
    
    
    public void processQuickLinksClone(){
      List<Intranet_Content_Tags__c> listoftagdatatobecloned = new List<Intranet_Content_Tags__c>();
       Tags__c tagData  = new Tags__c();
    
        if(listofrecordTypenames <> null && listofrecordTypenames.size()>0){
         for( Tags__c localtagData : [SELECT Id ,tag__c from tags__c Where tag__c =:newPrimaryContentafterClone.Name]){
            tagData = localtagData;
         }
         //c001 
        for(Intranet_Content_Tags__c intranetContenttagData : [SELECT Id,  Name,Intranet_Content__c,  Tags__r.tag__c FROM Intranet_Content_Tags__c Where
                                    Tags__r.tag__c=:mapofContentIdandContents.get(contentIdParameter).Name
                                    AND Intranet_Content__r.recordtype.name IN : listofrecordTypenames]){
                        if(intranetContenttagData <> null){              
                            Intranet_Content_Tags__c newtagContent = new Intranet_Content_Tags__c();
                            newtagContent = intranetContenttagData.clone();  
                            if(tagData.Id <> null)                        
                            newtagContent.Tags__c = tagData.Id; 
                            listoftagdatatobecloned.add(newtagContent);  
                            
                        }           
        }
        database.insert(listoftagdatatobecloned);    
        }
                            
    }
    
    public void processCloning(){
      statusMessage = '';
      String mainContentId = '';
      isError = false;
      if(newPageName <> null && newPageName <> ''){
        if(isPrefixChecked == true && (NewPrefixName == '' ||  NewPrefixName == '')){
          isError = true;
            statusMessage = 'Please Enter a Valid Prefix';
            return;
         }
        
           if(!setofAllPageNames.contains((newPageName.trim()).touppercase())){
             
              if(isPrefixChecked == true && NewPrefixName <> null && setofAllPageNames.contains(((NewPrefixName+newPageName).trim()).touppercase())){
            isError = true;
              statusMessage = 'A page already exist with that name - please enter a different Prefix';
              return;
              }
           try{
             //status message is returned content Id
            statusMessage = processContentClone();
            mainContentId = statusMessage;
            //check for all childPages and Clone
            Set<String> setofAllOptions = new Set<String> ();
            setofAllOptions.addall(optionsSelected);
            if(setofAllOptions.contains('Child Pages')){
              
              system.debug('optionsSelected*****'+optionsSelected);  
                processChildContentsClone(mainContentId);
              
            }else{
              NewPrefixName = '';
            }
            listofrecordTypenames = new List<String>();
            
            if(setofAllOptions.contains('Quick Links')){
              if(newPrimaryContentafterClone.Id <> null)
              listofrecordTypenames.add('Intranet Link');
            }
            if(setofAllOptions.contains('Banners')){
              
              if(newPrimaryContentafterClone.Id <> null)
              listofrecordTypenames.add('Intranet Banner');
            }
            if(setofAllOptions.contains('Articles')){
              if(newPrimaryContentafterClone.Id <> null)
              listofrecordTypenames.add('Intranet Article');
              
            }
            if(listofrecordTypenames <> null && listofrecordTypenames.size()>0)
             processQuickLinksClone();
           }catch(Exception e){
              isError = true;
              statusMessage = e.getMessage();
            }
        }else{
          isError = true;
            statusMessage = 'A page already exist with that name - please enter a different page name.';
        }
      }else{
        isError = true;
        statusMessage = 'Please Enter a Valid Page Name';
      }
    }

}