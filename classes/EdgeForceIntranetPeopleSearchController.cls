/*
*@author Debadyuti Sil
*@purpose Controller for IntranetPeople search vf component
*/
public class EdgeForceIntranetPeopleSearchController {
    public String searchInputinController {get;set;}
    public List<User> listofUsers {get;set;}
    public Boolean allResults {get;set;}

    private Integer resultLimit;
    private Set<String> setofUserId;
    private String searchString;

    // AA: W-000057 Hawkins, Justin
    // Restrict query to internal only users
    private static final String LICENSE_NAME_CHATTER_ONLY = 'Chatter Only';
    private static final String LICENSE_NAME_SALESFORCE = 'Salesforce';

    public EdgeForceIntranetPeopleSearchController() {
        clear();
        resultLimit = 10;
        processPeopleSearch();
    }
    
    public void clear(){
        listofUsers = new List<User>();
        setofUserId = new Set<String>();
    }
    
    // AA: W-000057 Hawkins, Justin
    // Restrict query to internal only users
    public void processPeopleSearch(){
        //string chatteronly='Chatter Only';
        //string sf='Salesforce';
        clear();
        String urlInput = apexpages.currentPage().getParameters().get('searchInput');
        if((urlInput <> null && urlInput <> '') || (searchInputinController <> null && searchInputinController <> '')){
            searchString = searchInputinController <> null ? searchInputinController : urlInput;
            if(searchString.length()>=2){
                String userSearchInput = '%'+searchString+'%';
                String query = 'SELECT Id, Name, Email, Title, FullPhotoUrl, SmallPhotoUrl, Department, CompanyName'
                             + ', Country, IsActive, Phone, MobilePhone, Street, City, State, PostalCode, Alias'
                             + ', LocaleSidKey, TimeZoneSidKey, EmployeeNumber, Manager.Name, UserType '
                             + 'FROM User WHERE (Email LIKE :userSearchInput OR NAME LIKE :userSearchInput OR Title LIKE :userSearchInput ) '
                             + 'AND (License_Type__c = :LICENSE_NAME_CHATTER_ONLY OR License_Type__c = :LICENSE_NAME_SALESFORCE) '
                             + 'AND Id NOT IN :setofUserId AND IsActive = true LIMIT '+resultLimit;
                Integer i = 0;
                for(User chatterUser : database.query(query)){
                    if(chatterUser <> null){
                        i++;
                        listofUsers.add(chatterUser);
                        setofUserId.add(chatterUser.id);
                    }              
                }
                allResults = (i < resultLimit);     
            }else{
                clear();
            }
         }
    }   
    
    // AA: W-000057 Hawkins, Justin
    // Restrict query to internal only users
    public void processPeopleSearchMore(){
        if(searchString <> null && searchString <> ''){
            if(searchString.length()>=2){
                String userSearchInput = '%'+searchString+'%';
                String query = 'SELECT Id, Name, Email, Title, FullPhotoUrl, SmallPhotoUrl, Department, CompanyName'
                             + ', Country, IsActive, Phone, MobilePhone, Street, City, State, PostalCode, Alias'
                             + ', LocaleSidKey, TimeZoneSidKey, EmployeeNumber, Manager.Name, UserType '
                             + 'FROM User '
                             + 'WHERE (Email LIKE :userSearchInput OR NAME LIKE :userSearchInput OR Title LIKE :userSearchInput ) '
                             + 'AND (License_Type__c = :LICENSE_NAME_CHATTER_ONLY OR License_Type__c = :LICENSE_NAME_SALESFORCE) '
                             + 'AND Id NOT IN :setofUserId AND IsActive = true LIMIT '+resultLimit ;
                for(User chatterUser :database.query(query)){
                    if(chatterUser <> null){
                        listofUsers.add(chatterUser);
                        setofUserId.add(chatterUser.id);
                    }
                }        
            }else{
                clear();
            }
        }
    }
}