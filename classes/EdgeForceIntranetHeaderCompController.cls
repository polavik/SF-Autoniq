/**
  * Apex Class: IntranetHeaderComponentController
  * Description: This class is used to get current logged in user information.
  *               (T-97451)  
  * Created By: Dheeraj Kumar (Appirio Off)
  * Created Date: 23rd Nov 2012.
*/
public with sharing class EdgeForceIntranetHeaderCompController {
    public User currentUser {get; set;}
    public String pageId {get;set;}
    public String efAppId {get;set;}
    
    public boolean isMobile {get; set;}
    
    /*
     * Default Constructor, it will fetch the details of logged in user.
    */
    public EdgeForceIntranetHeaderCompController () {
       // check for mobile.
       if(null == ApexPages.currentPage().getParameters().get('hideHeaders') || '' == ApexPages.currentPage().getParameters().get('hideHeaders')) isMobile=false;
       else isMobile=true;
        
       efAppId = '';
       currentUser = [SELECT Id, Profile.UserLicense.Name, SmallPhotoUrl, Name FROM User WHERE Id = :UserInfo.getUserId()];
       for(AppMenuItem ai : [SELECT Id FROM AppMenuItem WHERE Name = 'EdgeForce_Admin' LIMIT 1]){
            efAppId = ai.Id;
       }
    }

}