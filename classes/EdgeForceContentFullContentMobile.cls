/*
@Apex Class: EdgeForceContentFullContentMobile
@ Description: Added Content part on EF_Content_Full Template
@ Created By: Vipul Jain (Appirio Off)
@ Created Date: : July 14, 2015
@ Related To : I-171547 - Added Content part on EF_Content_Full Template

*/


global class EdgeForceContentFullContentMobile {

  DateTime todayDate = DateTime.now();
  public list<Attachment> galleryAttachmentList{get;set;}
  public String categoryType {get;set;}
  public String tabName {get;set;}
  //public String cmsPageId {get;set;}
  // It will use to render the attachments on content page
  public boolean renderAttachment {get;set;}
  // It will use to get the attachment
  public EdgeForceIntranetContentController.ContentVersionWrapper cmsPage{get;set;}
  // It will use to show article description on page
  public EdgeForceIntranetContentController.ContentVersionWrapper articleDetail{get;set;}
  public String contentIdinParameter{get;set;}
  public String pageName {get; set;}
  //public String groupName{get; set;}
  //Sil:Different REcordTypes of Content
  public  static String RECORDTYPE_INTERNET_BANNER   = 'Intranet Banner';
  public  static String RECORDTYPE_INTERNET_ARTICLE  = 'Intranet Article';
  public  static String RECORDTYPE_INTERNET_LINK     = 'Intranet Link';

  /*
  * Default constructor create data based on category parameter of url
  * weather it is Intranet content or Intranet Articles.
  */
   public EdgeForceContentFullContentMobile() {

      //groupName = ApexPages.currentPage().getParameters().get('category');

     renderAttachment = false;
     galleryAttachmentList = new list<Attachment>();
     tabName = 'Home';
     contentIdinParameter = '';

     /* if(ApexPages.currentPage().getParameters().get('tabName') != null && ApexPages.currentPage().getParameters().get('tabName') <> '') {
        tabName = ApexPages.currentPage().getParameters().get('tabName');
     } */
     

       //contentIdinParameter = ApexPages.currentPage().getParameters().get('Id');
      /*  if(ApexPages.currentPage().getParameters().get('Name') != null && ApexPages.currentPage().getParameters().get('Name') <> '') {
         pageName = ApexPages.currentPage().getParameters().get('Name');
       }else{ */
         pageName = 'Home';
       //}

    // It will prevent rendering attachments on IntranetContent page.

     /* if(contentIdinParameter != null && contentIdinParameter <>'') {
          contentIdinParameter = ApexPages.currentPage().getParameters().get('Id');
          processContentAndVersionforDetailpage(contentIdinParameter);

     } */

  }

  public void processContentAndVersionforDetailpage(String contentId) {
         renderAttachment = false;
         List<EdgeForceIntranetContentController.ContentVersionWrapper> listofvontentversionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
         String queryString =  'Select URL__c, Template__c, SystemModstamp,Target__c, (SELECT Id, Name  FROM Attachments),(Select Tags__r.Tag__c From Intranet_Content_Tags__r) From Intranet_Content__c  WHERE  id=\''+contentId+'\'';

         listofvontentversionWrapper = processContentAndVersion(queryString);
         if(listofvontentversionWrapper.size()>0){
            renderAttachment = true;
                cmsPage = listofvontentversionWrapper[0];
                if(listofvontentversionWrapper[0].content <> null && listofvontentversionWrapper[0].content.Attachments <> null && listofvontentversionWrapper[0].content.Attachments.size()>0){
                    galleryAttachmentList.addall(listofvontentversionWrapper[0].content.Attachments);

            }
         }

  }



   /**
     *Process Different type of Contenct and return list of wrapper
     *author Debadyuti Sil
    */ 

  public  List<EdgeForceIntranetContentController.ContentVersionWrapper> processContentAndVersion(String query){

        List<EdgeForceIntranetContentController.ContentVersionWrapper>                 listofContentandVersionWrapper      = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
        Map<String,Intranet_Content__c>             mapofContentIdAndContent            = new Map<String,Intranet_Content__c>();
        Map<String,Set<String>>                     mapofContentIdAndSetofVersionsIds  = new Map<String,Set<String>>();
        Map<String,Intranet_Content_Version__c>     mapofVersionIdIdAndVersion          = new Map<String,Intranet_Content_Version__c>();
        Set<String>                                 setofContentVersions;
        String                                      userLocalLanguage;
        Set<String>                                 setofLanguages                      = new Set<String>();


        for(Intranet_Content__c localContent :  Database.query(query)){
                  mapofContentIdAndContent.put(localContent.Id,localContent);


         }
           for(Intranet_Content_Version__c localContentVersion : [Select isPublished__c, Video_Caption__c, Primary_Record__c, Name, Language__c, Intranet_Content__c, Id, Header__c, Description__c, Button_Label__c,
                                                                Video_Type__c, Video_ID__c,Header_Color__c, Summary_Color__c, Button_Location__c, Position__c, Summary__c, URL__c 
                                                                FROM Intranet_Content_Version__c
                                                                WHERE Intranet_Content__c IN: mapofcontentIdAndContent.keySet()
                                                                order by Intranet_Content__c ]){

                                                                if(localContentVersion  <> null){
                                                                    mapofVersionIdIdAndVersion.put(localContentVersion.Id,localContentVersion);

                                                                    if(mapofContentIdAndSetofVersionsIds.containsKey(localContentVersion.Intranet_Content__c)){
                                                                        setofContentVersions = new  Set<String>();
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

         if(mapofContentIdAndSetofVersionsIds.keySet() <> null){
             for(String contentId : mapofContentIdAndContent.keySet()){
                Intranet_Content_Version__c contentVersiontoLoad = new Intranet_Content_Version__c();
                 boolean isContentFound = false;
                 String primaryVersionid = '';
                    if(mapofContentIdAndSetofVersionsIds.containsKey(contentId)){
                        for(String  versionId : mapofContentIdAndSetofVersionsIds.get(contentId)){
                            if(mapofVersionIdIdAndVersion.get(versionId).Primary_Record__c  == true){
                                    primaryVersionid = versionId;
                            }
                            //if local language available
                            if(userLocalLanguage <> null && setofLanguages.size()>0 &&  mapofVersionIdIdAndVersion.get(versionId).Language__c <> null && setofLanguages.contains(mapofVersionIdIdAndVersion.get(versionId).Language__c.trim().toUpperCase()) && mapofVersionIdIdAndVersion.get(versionId).isPublished__c==true ){
                                contentVersiontoLoad = mapofVersionIdIdAndVersion.get(versionId);
                                isContentFound = true;
                            }
                        }

                    }

                    //go for primary version
                     if(isContentFound == false && primaryVersionid <> ''){
                            contentVersiontoLoad = mapofVersionIdIdAndVersion.get(primaryVersionid);
                     }
                 listofContentandVersionWrapper.add(new EdgeForceIntranetContentController.ContentVersionWrapper(mapofContentIdAndContent.get(contentId),contentVersiontoLoad));
             }


         }

        return listofContentandVersionWrapper;

  }

    }