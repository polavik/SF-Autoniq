/* *************************************************
Created By : Jim Cook
Created Date : Sept , 2016
Description  : Controller for Intranet Sub-Team page.

*************************************************** */
public with sharing class EFISubTeamController {
    //String to hold team name selected by current user
    public String groupName {get;set;}
    public String tabName   {get;set;}
    public String mission   {get;set;}
    public String description {get;set;}
    public String teamTitle	{get;set;}
    public String bgImg     {get;set;}
    public String pageName 	{get;set;}
    public String parent    {get; set;}
    public String parent2   {get;set;}
    public List<EdgeForceIntranetContentController.ContentVersionWrapper> subTeams {get; set;} 
    public Integer subTeamSize {get; set;}
    public String selectButton {get;set;}
    public String styleHide    {get; set;}        
            
    // Dynamic components.
    transient Component.KAR_MeetTheSubTeam meetTheSubTeamDC;
    transient Component.KAR_SubTeam        subTeamDC; 
    transient Component.KAR_TeamNews       newsGridDC;
    transient Component.Chatter_Feed       chatterDC ;
    transient Component.KAR_Calendar       calendarDC;
    transient Component.KAR_Collapsible    collapsibleDC;
    transient Component.AboutUs            aboutUsDC;
    transient Component.KAR_REsources      resourcesDC;
    transient Component.NewsCarousel       newsCarouselDC;
    
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
    public String parentName {get;set;}

    public EFISubTeamController() {
    	
    	// Dynamic components.
        dcLeftList       = new ApexPages.Component[9];
        dcRightList      = new ApexPages.Component[9];
        baseDC           = new Component.BaseDynamicComponent();
        meetTheSubTeamDC = new Component.KAR_MeetTheSubTeam(); 
		newsGridDC       = new Component.KAR_TeamNews();
		calendarDC       = new Component.KAR_Calendar();
		chatterDC        = new Component.Chatter_Feed();
        collapsibleDC    = new Component.KAR_Collapsible();
        aboutUsDC        = new Component.AboutUS();
        resourcesDC      = new Component.KAR_Resources();
        subTeamDC        = new Component.KAR_SubTeam();
        newsCarouselDC   = new Component.NewsCarousel();
       
  	    try{parent = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('parent'), 'UTF-8');}catch(Exception e){parent = '';}
        try{groupName  = ApexPages.currentPage().getParameters().get('name');} catch(Exception e){groupName='';}
        try{tabName    = ApexPages.currentPage().getParameters().get('tabName');} catch(Exception e){tabName='';}
        //fetch groupId of selected team show chatter feed on IntranetTeam page.
        for(CollaborationGroup groupObj : [SELECT c.Name, c.Id
                                           FROM CollaborationGroup c
                                           WHERE c.Name = :groupName LIMIT 1] ) {
            groupId = groupObj.Id;
        }
//        if(null==groupId)groupId=''; 
        if(ApexPages.currentPage().getParameters().get('name') != null) {
  	       pageName = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('name'), 'UTF-8');
        }
        
        if(ApexPages.currentPage().getParameters().get('groupName') != null){
            parentName = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('groupName'), 'UTF-8');
        }
       // Check for mobile. 
  	   if(null == ApexPages.currentPage().getParameters().get('hideHeaders') || '' == ApexPages.currentPage().getParameters().get('hideHeaders')) styleHide = '';
  	   else styleHide = 'display:none;';
        
        
        // Versioning
        List<EdgeForceIntranetContentController.ContentVersionWrapper> tempList = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
        List<EdgeForceIntranetContentController.ContentVersionWrapper> finalList = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
        String queryString = 'SELECT Name, Id, URL__c, Target__c, Template__c, ' +
                                               'Content_Type__c, Language__c, Team_Mission_Statement__c,Description__c,Title__c,  ' +
                                               'Show_Sub_Team__c, Sub_Team_Sequence__c,  ' +
                                               'Show_Meet_The_Team__c, Meet_The_Team_Sequence__c, ' +
                                               'Show_News__c, News_Sequence__c, ' +
                                               'Show_Calendar__c, Calendar_Sequence__c, ' +
                                               'Show_Chatter_Feed__c, Chatter_Feed_Sequence__c, ' +
                                               'Show_Collapsible_Content__c, Collapsible_Content_Sequence__c, ' +
                                               'Show_About_The_Team__c, About_The_Team_Sequence__c,  ' +
                                               'Show_News_Banner__c, News_Banner_Sequence__c,  ' +
                                               'Show_Resource_Library__c, Resource_Library_Sequence__c, ' +
                                               'Content_Bucket__c, Target_URL__c, Parent__r.Name, ' +
                                               '(SELECT Id FROM Attachments LIMIT 1) ' +
                             'FROM Intranet_Content__c ' + 
                             'WHERE  Name = \'' + pageName + '\'' + 
                             'AND RecordType.Name = \'Sub Team RT\' ORDER BY Sequence__c ASC';
        EdgeForceIntranetContentController contentController = new EdgeForceIntranetContentController();
        tempList = contentController.processContentAndVersionMenu(queryString);
                
        for(Intranet_Content__C teamContent : [SELECT Id 
                                               FROM Intranet_Content__c 
                                               WHERE Name = :pageName 
                                               AND RecordType.Name = 'Sub Team RT' 
                                               ORDER BY Sequence__c ASC
                                              ]){
           if( null != teamContent) {
              for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempList)   {
                 if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(teamContent.Id).substring(0,15)){
                    try{mission = wrapper.contentVersionForDisplay.Team_Mission_Statement__c;}catch(Exception e) { wrapper.content.Team_Mission_Statement__c='';}
                    try{description = wrapper.contentVersionForDisplay.Description__c;}catch(Exception e) { wrapper.content.Description__c='';}
                     try{bgImg = wrapper.content.Attachments[0].Id;}catch(Exception e) { bgImg='';}
                    try{teamTitle = wrapper.contentVersionForDisplay.Title__c;}catch(Exception e) { wrapper.content.Title__c='';}

                    finalList.add(wrapper);
            }
         }
      }
 
     // Initialize all content sections with a blank area.                                               	
      for(Integer i=0;i<9;i++) { 
         dcLeftList[i]  = new Component.BaseDynamicComponent();
         dcRightList[i] = new Component.BaseDynamicComponent();
      } 

     if(null != finalList[0]) {
        //Changed By Hemendra And Arvind To Counter the functionality
        parent = finalList[0].content.Name;
         parent2 = parentName;
	    for(Integer i=0;i<9;i++) { 
		   dcLeftList[i]   = assignLeftComponent(  finalList[0].content, i+1);
		   dcRightList[i]  = assignRightComponent( finalList[0].content, i+1);
	    }
     }
  }
  
  // Set up subteams for menu drop down.
  subTeams = buildSubTeamListForDropdown();
  subTeamSize = subTeams.size();
  selectButton   = 'Select the Team';
}
  
  private ApexPages.Component assignLeftComponent( Intranet_Content__c tc, Integer seq) {  
  	       // Left-hand components.	       
		   if(tc.Show_Meet_The_Team__c 				&& Integer.valueOf(tc.Meet_The_Team_Sequence__c) 		== seq) return meetTheSubTeamDC; 
 	       else if(tc.Show_Sub_Team__c          	&& Integer.valueOf(tc.Sub_Team_Sequence__c)        		== seq) return subTeamDC; 
 	       else if(tc.Show_News__c          		&& Integer.valueOf(tc.News_Sequence__c)          		== seq) return newsGridDC; 
  	       else if(tc.Show_Calendar__c      		&& Integer.valueOf(tc.Calendar_Sequence__c)      		== seq) return calendarDC; 
  	       else if(tc.Show_Collapsible_Content__c	&& Integer.valueOf(tc.Collapsible_Content_Sequence__c)	== seq) return collapsibleDC; 
 	       else if(tc.Show_About_The_Team__c		&& Integer.valueOf(tc.About_The_Team_Sequence__c)		== seq) return aboutUsDC; 
           else if(tc.Show_News_Banner__c           && Integer.valueOf(tc.News_Banner_Sequence__c)          == seq) return newsCarouselDC; 
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
  	  // For teams.
      // This is the final list of relevant content records, with versioning.
      List<EdgeForceIntranetContentController.ContentVersionWrapper> finalList = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();

      // This is an intermediate list of content which must be filtered. 
      List<EdgeForceIntranetContentController.ContentVersionWrapper> tempList = contentUtilities.getAllContent();

      // This loop does the filtering.
      for(EdgeForceIntranetContentController.ContentVersionWrapper x : tempList) {
         try{
         	if(
         	    x.content.RecordType.Name == 'Sub Team RT' && 
                x.content.Parent__r.Name.toUpperCase() == parent.toUpperCase() && 
                x.content.Status__c == 'Published'
            ) {
                finalList.add(x);
            }
         }
         catch(Exception e){
         System.debug('NULL ERROR ON: ' + x.content.Name + ' ' + x.content.Parent__r.Name + ' ' + parent);
         }       
      }
      return finalList;
  }  
  
}