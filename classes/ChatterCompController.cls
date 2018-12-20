public with sharing class ChatterCompController {
	
    // Group id of selected team 
    public Id groupId {get;set;}
    public String groupName {get;set;}
    public boolean isMobile {get; set;}
        
    public ChatterCompController() {
  	   // Are we in mobile?
  	   if(null == ApexPages.currentPage().getParameters().get('hideHeaders') || '' == ApexPages.currentPage().getParameters().get('hideHeaders')) isMobile=false;
  	   else isMobile=true;
       
       groupName = ApexPages.currentPage().getParameters().get('name');
       for(CollaborationGroup groupObj : [SELECT c.Name, c.Id
                                          FROM CollaborationGroup c
                                          WHERE c.Name = :groupName LIMIT 1] ) {
          groupId = groupObj.Id;
        }
    }
    
}