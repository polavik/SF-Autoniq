/*
Created By : Harshit Jain
Created Date : December 12,2012
Description  : Controller for IntranetTeam page.

****************************************************
* Modified By     : Jim Cook
* Modified Date   : 29 August, 2016 (Ref: various)
* Summary         : The code was modified to make component placement declarative through the UI.
*
* Modified By     : Lovish Goyal
* Modified Date   : 12 April, 2016 (Ref: T-491188)
*@modified by : sil
*@modified Date : 17-march-2014
*@purpose : process custom resource content document
* 
* Modified By     : Niza Khunger
* Modified Date   : 21 September, 2016 (Ref: various)
* Summary         : The code was modified to use the Page_Type__c of the record is "Brand" or "Team"
*/
public class EdgeForceIntranetTeamController {
    //String to hold team name selected by current user
    public String groupName {get;set;}
    public String tabName   {get;set;}
    public String mission   {get;set;}
    public String description {get;set;}
    public String teamTitle {get;set;}
    public String bgImg     {get;set;}
    public String pageName  {get;set;}
    public String exploreButton {get;set;}
    public String selectButton 	{get;set;}
    public String overlayColor {get; set;}
    public List<EdgeForceIntranetContentController.ContentVersionWrapper> subTeams {get; set;} 
    public Integer subTeamSize {get; set;}
    public Boolean isBrand     {get; set;}
    public String styleHide    {get; set;}
    public String miscMsgs     {get; set;}
    public List<EdgeForceIntranetContentController.ContentVersionWrapper> brands {get; set;} 
    
    // Dynamic components.
    transient Component.KAR_MeetTheTeam meetTheTeamDC;
    transient Component.KAR_SubTeam     subTeamDC;
    transient Component.KAR_TeamNews    newsGridDC;
    transient Component.Chatter_Feed    chatterDC ;
    transient Component.KAR_Calendar    calendarDC;
    transient Component.AboutUs         aboutUsDC;
    transient Component.KAR_Collapsible collapsibleDC;
    transient Component.KAR_Resources   resourcesDC;
    transient Component.KAR_Banner      newsBannerDC;
    transient Component.NewsCarousel    newsCarouselDC;
    
    transient public ApexPages.Component[] dcLeftList {get;set;}
    transient public ApexPages.Component[] dcRightList {get;set;}
    // This is a blank widget. 
    transient Component.BaseDynamicComponent baseDC;
    
    // Counters for column items used.
    public Integer leftColCounter  = 0;
    public Integer rightColCounter = 0;
    
    //Respective group id of selected team 
    public Id groupId {get;set;}

    //public String pageLanguage {get;set;}
    public boolean showCRMContent {get;set;} {showCRMContent = true;}


 public static final String RECORDTYPE_TEAM = 'Team Page RT';

    public EdgeForceIntranetTeamController() {
        // Dynamic components.
        dcLeftList     = new ApexPages.Component[9];
        dcRightList    = new ApexPages.Component[9];
        baseDC         = new Component.BaseDynamicComponent();
        subTeamDC      = new Component.KAR_SubTeam();
        meetTheTeamDC  = new Component.KAR_MeetTheTeam(); 
        newsGridDC     = new Component.KAR_TeamNews();
        calendarDC     = new Component.KAR_Calendar();
        aboutUsDC      = new Component.AboutUs();
        chatterDC      = new Component.Chatter_Feed();
        collapsibleDC  = new Component.KAR_Collapsible();
        resourcesDC    = new Component.KAR_Resources();
        newsBannerDC   = new Component.KAR_Banner();
        newsCarouselDC = new Component.NewsCarousel();
        exploreButton  = 'Explore the Team';
        selectButton   = 'Select the Team';
        
        try{groupName = ApexPages.currentPage().getParameters().get('name');}catch(Exception e){groupName='none';}
        try{tabName =  ApexPages.currentPage().getParameters().get('tabName');}catch(Exception e){tabName='none';}
        //fetch groupId of selected team show chatter feed on IntranetTeam page.
        
        // Check for mobile. 
  	   if(null == ApexPages.currentPage().getParameters().get('hideHeaders') || '' == ApexPages.currentPage().getParameters().get('hideHeaders')) styleHide = '';
  	   else styleHide = 'display:none;';
        
        
        for(CollaborationGroup groupObj : [SELECT c.Name, c.Id
                                           FROM CollaborationGroup c
                                           WHERE c.Name = :groupName LIMIT 1] ) 
        {
            groupId = groupObj.Id;
        }
        
        if(ApexPages.currentPage().getParameters().get('name') != null) {
  	       pageName = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('name'), 'UTF-8');
        }

        // This is the final list of relevant content recirds, with versioning.
        List<EdgeForceIntranetContentController.ContentVersionWrapper> finalList = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();

        // This is an intermediate list of content which must be filtered. 
        List<EdgeForceIntranetContentController.ContentVersionWrapper> tempList = ContentUtilities.getAllContent();

        // This loop does the filtering.
        for(EdgeForceIntranetContentController.ContentVersionWrapper x : tempList) {
           if(x.content.RecordType.Name == RECORDTYPE_TEAM && 
              x.content.Name == pageName
           ) finalList.add(x);   
           else {
           	if(x.content.RecordType.Name == RECORDTYPE_TEAM) miscMsgs+= x.content.Name +' : ' + pageName + ' <br />';  
           }
        }
        
        // If we didn't find any content, produce an "error" page and bail out.
        if(finalList.size() == 0 ) {
           EdgeForceIntranetContentController.ContentVersionWrapper badResult = new EdgeForceIntranetContentController.ContentVersionWrapper();
           badResult.content.Page_Type__c='Team';
           badResult.contentVersionforDisplay.Description__c = 'This page does not exist. ' + pageName;
           finalList.add(badResult);
        }

        // This code sets some misc. instance variables.
        if(finalList[0].content.Page_Type__c=='Brand'){
           isBrand=true;
           exploreButton = label.KAR_Explore_The_Brands;
           selectButton  = label.KAR_Select_A_Brand;
        }
        else{
           isBrand=false;
           exploreButton = label.KAR_Explore_The_Teams;
           selectButton  = label.KAR_Select_A_Team;
        }

        // Initialize all content sections with a blank area.                                                  
        for(Integer i=0;i<9;i++) { 
           dcLeftList[i]  = new Component.BaseDynamicComponent();
           dcRightList[i] = new Component.BaseDynamicComponent();
        } 
     
     try{description = finalList[0].contentVersionforDisplay.Description__c;}catch(Exception e){description = '';}
     try{mission = finalList[0].contentVersionforDisplay.Team_Mission_Statement__c;}catch(Exception e){mission = '';}
     try{
     	for(Attachment att : finalList[0].content.Attachments) {
     		System.debug('ATT =>' + finalList[0].content.Team_Brand_Image_File_Name__c);
     		System.debug('ATT => seeking ' + att.Name);
            if(att.Name == finalList[0].content.Team_Brand_Image_File_Name__c) { 
           	   System.debug('ATT => HIT ' + att.Name);
     	       bgImg = att.Id;
           }
     	}
     }
     catch(Exception e) { bgImg=''; System.debug('KABOOM =>' + e.getMessage());}
     try{teamTitle = finalList[0].contentVersionforDisplay.Title__c;}catch(Exception e){teamTitle='';}
     try{overLayColor = finalList[0].content.Overlay_Color__c;}catch(Exception e){overlayColor = 'black';}

     try {
        if(null != finalList[0].content) {
           for(Integer i=0;i<9;i++) { 
              dcLeftList[i]   = assignLeftComponent(  finalList[0].content, i+1);
              dcRightList[i]  = assignRightComponent( finalList[0].content, i+1);
           }
        }
     }
     catch(Exception e){System.debug('NO CONTENT FOUND.');}
                                         
   // Set up subteams for menu drop down.
   subTeams = buildSubTeamListForDropdown();
   subTeamSize = subTeams.size();
   
   BrandsLandingController brandcontroller = new BrandsLandingController();
   brands = brandcontroller.getBrandList();
    }
    
/* Here is the old approach to fetchign the Intranet_Content__c data. It's been replaced, above, 
   with a call to a static object which reduces the number of SOQL calls.

        // Versioning
        // Get the buckets a user has access to.
        List<String> buckets = ContentBucketUtilities.getBucketNamesForAUser(UserInfo.getUserId());
        // A list ofr intermediate results.
        List<EdgeForceIntranetContentController.ContentVersionWrapper> tempListofLocalContentVersionWrapper = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
        // A list for final results.
        List<EdgeForceIntranetContentController.ContentVersionWrapper> listofLocalContentVersionWrapper = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
        String queryString = 'SELECT Name, Id, URL__c, Target__c, Template__c, Team_Brand_Image_File_Name__c,' + 
                                     'Content_Type__c, Language__c, Team_Mission_Statement__c, Title__c, ' +
                                     'Show_Sub_Team__c, Sub_Team_Sequence__c, ' +
                                     'Show_Meet_The_Team__c, Meet_The_Team_Sequence__c, ' +
                                     'Show_About_The_Team__c, About_The_Team_Sequence__c, ' +
                                     'Show_News__c, News_Sequence__c, ' +
                                     'Show_Calendar__c, Calendar_Sequence__c, ' +
                                     'Show_Chatter_Feed__c, Chatter_Feed_Sequence__c, ' +
                                     'Show_Collapsible_Content__c, Collapsible_Content_Sequence__c, ' +
                                     'Show_News_Banner__c, News_Banner_Sequence__c, ' +
                                     'Show_Resource_Library__c, Resource_Library_Sequence__c, ' +
                                     'Content_Bucket__c, Overlay_Color__c, ' + 
                                     '(SELECT Id, Name FROM Attachments) ' +
                             'FROM Intranet_Content__c ' + 
                             'WHERE RecordType.Name = \'' + RECORDTYPE_TEAM + '\'';
        if(buckets.size() > 0 ){
      	   // Add the bucket list.
      	   queryString+= 'AND Content_Bucket__r.Name in ('; 
           // loop through all the buckets and add each one.
           for(String x : buckets) queryString+= '\'' + x + '\',';
           // Strip out the trailing comma.
           queryString =  queryString.substring(0, queryString.length()-1);
           // Close out the bucket list.
           queryString += ' ) ';
        }      
        
        queryString += ' ORDER BY Sequence__c ASC';
        EdgeForceIntranetContentController contentController = new EdgeForceIntranetContentController();
        tempListofLocalContentVersionWrapper = contentController.processContentAndVersionMenu(queryString);
          
        for(Intranet_Content__C teamContent : [SELECT Id, Page_Type__c
                                               FROM Intranet_Content__c
                                               WHERE Name = :pageName
                                               AND RecordType.Name = :RECORDTYPE_TEAM 
                                               ORDER BY Sequence__c ASC
                                              ])
        {        
           for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempListofLocalContentVersionWrapper) {
             if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(teamContent.Id).substring(0,15)){
                listofLocalContentVersionWrapper.add(wrapper);
                
               // Added for Brand and Team Button by Niza Khunger (T-536477) 
                if(teamContent.Page_Type__c=='Brand'){
                  isBrand=true;
                  exploreButton = label.KAR_Explore_The_Brands;
                  selectButton  = label.KAR_Select_A_Brand;
                }
                
              else{
              	  isBrand=false;
                  exploreButton = label.KAR_Explore_The_Teams;
                  selectButton  = label.KAR_Select_A_Team;
              }
             }
           }
        }

     // Initialize all content sections with a blank area.                                                  
      for(Integer i=0;i<9;i++) { 
         dcLeftList[i]  = new Component.BaseDynamicComponent();
         dcRightList[i] = new Component.BaseDynamicComponent();
      } 
     
     try{mission = listofLocalContentVersionWrapper[0].contentVersionforDisplay.Team_Mission_Statement__c;}catch(Exception e){mission = '';}
     try{
     	for(Attachment att : listofLocalContentVersionWrapper[0].content.Attachments) {
     		System.debug('ATT =>' + listofLocalContentVersionWrapper[0].content.Team_Brand_Image_File_Name__c);
     		System.debug('ATT => seeking ' + att.Name);
            if(att.Name == listofLocalContentVersionWrapper[0].content.Team_Brand_Image_File_Name__c) { 
           	   System.debug('ATT => HIT ' + att.Name);
     	       bgImg = att.Id;
           }
     	}
     }
     catch(Exception e) { bgImg=''; System.debug('KABOOM =>' + e.getMessage());}
     try{teamTitle = listofLocalContentVersionWrapper[0].contentVersionforDisplay.Title__c;}catch(Exception e){teamTitle='';}
     try{overLayColor = listofLocalContentVersionWrapper[0].content.Overlay_Color__c;}catch(Exception e){overlayColor = 'black';}

     try {
        if(null != listofLocalContentVersionWrapper[0].content) {
           for(Integer i=0;i<9;i++) { 
              dcLeftList[i]   = assignLeftComponent(  listofLocalContentVersionWrapper[0].content, i+1);
              dcRightList[i]  = assignRightComponent( listofLocalContentVersionWrapper[0].content, i+1);
           }
        }
     }
     catch(Exception e){System.debug('NO CONTENT FOUND.');}
                                         
   // Set up subteams for menu drop down.
   subTeams = buildSubTeamListForDropdown();
   subTeamSize = subTeams.size();
  }
*/

  
  private ApexPages.Component assignLeftComponent( Intranet_Content__c tc, Integer seq) {  
           // Left-hand components.        
           if(tc.Show_Sub_Team__c                   && Integer.valueOf(tc.Sub_Team_Sequence__c)             == seq) return subTeamDC; 
           else if(tc.Show_Meet_The_Team__c         && Integer.valueOf(tc.Meet_The_Team_Sequence__c)        == seq) return meetTheTeamDC; 
           else if(tc.Show_News__c                  && Integer.valueOf(tc.News_Sequence__c)                 == seq) return newsGridDC; 
           else if(tc.Show_Calendar__c              && Integer.valueOf(tc.Calendar_Sequence__c)             == seq) return calendarDC; 
           else if(tc.Show_Collapsible_Content__c   && Integer.valueOf(tc.Collapsible_Content_Sequence__c)  == seq) return collapsibleDC; 
           else if(tc.Show_News_Banner__c           && Integer.valueOf(tc.News_Banner_Sequence__c)          == seq) return newsCarouselDC; 
           else if(tc.Show_About_The_Team__c        && Integer.valueOf(tc.About_The_Team_Sequence__c)       == seq) return aboutUsDC; 
           return new Component.BaseDynamicComponent();
  }                    
  
  private ApexPages.Component assignRightComponent( Intranet_Content__c tc, Integer seq) {  
           // Right-hand components.
           if( null != tc.Show_Chatter_Feed__c && null != tc.Chatter_Feed_Sequence__c &&
               tc.Show_Chatter_Feed__c  && Integer.valueOf(tc.Chatter_Feed_Sequence__c) == seq) return chatterDC; 
           else if( null != tc.Show_Resource_Library__c && null != tc.Resource_Library_Sequence__c &&
               tc.Show_Resource_Library__c  && Integer.valueOf(tc.Resource_Library_Sequence__c) == seq) return resourcesDC; 

           return new Component.BaseDynamicComponent();
  }
  
  public List<EdgeForceIntranetContentController.ContentVersionWrapper> buildSubTeamListForDropdown() {
  	  // For brands.
  	  if(isBrand) return BrandUtilities.getBrandList();
  	  
  	  // For teams.
      // This is the final list of relevant content recirds, with versioning.
      List<EdgeForceIntranetContentController.ContentVersionWrapper> finalList = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();

      // This is an intermediate list of content which must be filtered. 
      List<EdgeForceIntranetContentController.ContentVersionWrapper> tempList = contentUtilities.getAllContent();

      // This loop does the filtering.
      for(EdgeForceIntranetContentController.ContentVersionWrapper x : tempList) 
         if(x.content.RecordType.Name == 'Sub Team RT' && 
            x.content.Parent__r.Name == pageName && 
            x.content.Status__c == 'Published'  
         ) finalList.add(x);       

      return finalList;
  }

/* Here's the old approach.
      List<EdgeForceIntranetContentController.ContentVersionWrapper> tempList = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
      List<EdgeForceIntranetContentController.ContentVersionWrapper> resultList = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
      
      String queryString =  'Select Id, Name, ' + 
                                    'Target__c,Frame_Height__c, URL__c ' + 
                                    'From Intranet_Content__c  '  + 
                                    'WHERE Status__c=\'Published\' ' +
                                    'AND RecordType.Name =\'Sub Team RT\' AND Parent__r.Name = \'' + pageName + '\' order by Name';
      EdgeForceIntranetContentController versionHandler = new EdgeForceIntranetContentController();
      tempList = versionHandler.processContentAndVersionMenu(queryString);
      
        for(Intranet_Content__c bList : [Select Id From Intranet_Content__c 
                                         WHERE Status__c='Published' 
                                         AND RecordType.Name ='Sub Team RT' 
//                                         AND Content_Bucket__r.Name= :pageName
                                         AND Parent__r.Name= :pageName
                                         order by Name])
        { 
           Integer attachCount = 0;       
           for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempList) {
             if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(bList.Id).substring(0,15)){
                resultList.add(wrapper);
             }
           }
        }
        
      return resultList;
  }
*/  
  
  public PageReference test(){
    return null;
  }
 
}