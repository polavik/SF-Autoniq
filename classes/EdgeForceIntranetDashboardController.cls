/*******************************************************************
* Author        :  Harshit Jain 
* Name          :  IntranetDashboardController
* Date          :  December 03,2012
* Description   :  Used to update current user Information                 
*******************************************************************/
global with sharing class EdgeForceIntranetDashboardController {
    public User userInformation {get; set;}
    public List<CollaborationGroupMember> grpSettings {get;set;}
    public String pageMessages {get;set;}

    public String digestFreq {get; set;}

    public EdgeForceIntranetDashboardController() {
        grpSettings = new List<CollaborationGroupMember>();

        // Populate current user information
        if(Userinfo.getUserId() != null) {
            userInformation = [Select u.TimeZoneSidKey, u.Phone, u.LastName, u.UserName, 
                               u.LanguageLocaleKey, u.FirstName, u.Email, u.Id, Profile_Completion__c, 
                               u.EF_User_Function__c, u.LocaleSidKey, u.EF_User_Business_Unit__c,
                               u.Title, u.Department, u.Division, u.AboutMe, u.FullPhotoUrl,
                               u.EF_User_Fun__c, u.EF_User_History__c, u.EF_User_Feedback__c,
                               u.City, u.State, u.Country, u.Street, u.DigestFrequency 
                               From User u 
                               WHERE Id =: Userinfo.getUserId()];

            digestFreq = userInformation.DigestFrequency;

            for(CollaborationGroupMember cgm : [SELECT Id, MemberId, CollaborationGroupId, CollaborationGroup.Name
                                              , NotificationFrequency
                                                FROM CollaborationGroupMember
                                                WHERE MemberId = :userInformation.Id]){
                grpSettings.add(cgm);
            }
        }
    }
    
    // Update current User Info
    public PageReference updateUserInformation() {
       
       if(!grpSettings.isEmpty()) update grpSettings;
        
       system.debug('** * ** DigestFrequency: ' + userInformation.DigestFrequency); 
       system.debug('** * ** DigestFreq: '      + digestFreq); 
        
       // Update completion percentage on users.  
       Decimal x = 0;
       if(null != userInformation.EF_User_Fun__c      && userInformation.EF_User_Fun__c.length()      > 0) x+=25;
       if(null != userInformation.EF_User_Feedback__c && userInformation.EF_User_Feedback__c.length() > 0) x+=25;
       if(null != userInformation.EF_User_Function__c && userInformation.EF_User_Function__c.length() > 0) x+=25;
       if(null != userInformation.EF_User_History__c  && userInformation.EF_User_History__c.length()  > 0) x+=25;  
       userInformation.Profile_Completion__c = x;
        
       userInformation.DigestFrequency = digestFreq;
        
       try {        	
          update userInformation;
          return new PageReference('/apex/KAR_ViewUserProfile?id='+userInformation.Id);
       } 
       catch(DmlException e) {
          pageMessages = e.getMessage();
          return null;
        }
    }
    
    public PageReference gotoChatter(){
    	return new PageReference('_ui/core/feeds/notification/FeedsNotificationPrefEdit?setupid=CollaborationEmailSettings&retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DPersonalCollaboration' );
    }
}