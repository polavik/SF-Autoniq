/**
  * Apex Class: KAR_HomeController
  * Description: Controller for KAR_Home page
  * Created By: Matt Salpietro
  * Created Date: 1 Feb, 2016
*/
public with sharing class KAR_HomeController {
  DateTime todayDate = DateTime.now();
  private static String RECORDTYPE_FEATURED_USER = 'Home Page Featured Employee';

  // AA: W-000057 Hawkins, Justin
  // Restrict query to internal only users
  private static final String LICENSE_NAME_CHATTER_ONLY = 'Chatter Only';
  private static final String LICENSE_NAME_SALESFORCE = 'Salesforce';

  //String hold page name selected by current user on Intranet. 
  public String pageName {get;set;}

  public List<Intranet_Content__c> featuredUsers {get;set;}        

  public KAR_HomeController(){
    //Default selected page would be home page
    pageName = 'Home';
    //Populate selected page name.
    //Based on selected page name other information will be populated on intranet page like Banners,Articles,Links etc.
    if(ApexPages.currentPage().getParameters().get('tabName') != null){
      pageName = ApexPages.currentPage().getParameters().get('tabName');
    }
    getFeaturedUsers();
  }

  public void getFeaturedUsers(){
    featuredUsers = new List<Intranet_Content__c>();
    for(Intranet_Content__c content : [SELECT Featured_User__r.FirstName, Featured_User__r.LastName, Featured_User__r.Id, URL__c, Target__c
                                       , Featured_User__r.SmallPhotoUrl, (SELECT Id, Name FROM Attachments LIMIT 1)
                                       FROM Intranet_Content__c
                                       WHERE Start_Date__c <= :todayDate
                                       AND End_Date__c >= :todayDate
                                       AND RecordType.Name = :RECORDTYPE_FEATURED_USER 
                                       ORDER BY Sequence__c
                                       LIMIT 5]){
      featuredUsers.add(content);
    }                                    
  }

  // AA: W-000057 Hawkins, Justin
  // Restrict query to internal only users
  @RemoteAction
  public static List<User> searchFilters(String searchTerm, String searchField) {
    return Database.query('SELECT Id, SmallPhotoUrl, CompanyName, Title, Email, '+searchField+' FROM User '
                        +' WHERE '+searchField+' LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\' '
                        + 'AND (License_Type__c = :LICENSE_NAME_CHATTER_ONLY OR License_Type__c = :LICENSE_NAME_SALESFORCE) '
                        +' LIMIT 100');
  }
}