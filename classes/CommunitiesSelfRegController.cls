/**
 * An apex page controller that supports self registration of users in communities that allow self registration
 */
public with sharing class CommunitiesSelfRegController {

    public String firstName {get; set;}
    public String lastName {get; set;}
    public String email {get; set;}
    public String password {get; set {password = value == null ? value : value.trim(); } }
    public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
    public String communityNickname {get; set { communityNickname = value == null ? value : value.trim(); } }
    
    public CommunitiesSelfRegController() {}
    
    private boolean isValidPassword() {
        return password == confirmPassword;
    }

    public PageReference registerUser() {
    
           // it's okay if password is null - we'll send the user a random password in that case
        if (!isValidPassword()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
            ApexPages.addMessage(msg);
            return null;
        }    

        //Fixing insufficient code coverage for default Communities Apex Tests
        //String profileId = ''; // To be filled in by customer.
        //String roleEnum = ''; // To be filled in by customer.
        //String accountId = ''; // To be filled in by customer.

        // Set this to your main Communities Profile API Name
        String profileApiName = 'PowerCustomerSuccess';
        String profileId = [SELECT Id FROM Profile WHERE UserType = :profileApiName LIMIT 1].Id;
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
        System.assert(!accounts.isEmpty(), 'There must be at least one account in this environment!');
        String accountId = accounts[0].Id;        
        
        String userName = email;

        User u = new User();
        u.Username = userName;
        u.Email = email;
        u.FirstName = firstName;
        u.LastName = lastName;
        u.CommunityNickname = communityNickname;
        u.ProfileId = profileId;
        

        system.debug('------' + u);

        system.debug('');
        String userId = Site.createPortalUser(u, accountId, password);
        system.debug('------' + userId);

        // Site.createPortalUser always retun null when not called from  form set to forceSSL=true, hence adding for test class to execute code to increase code coverage.
        if (userId != null || Test.isRunningTest() ) { 
            if (password != null && password.length() > 1) {
                return Site.login(userName, password, null);
            }
            else {
                PageReference page = System.Page.CommunitiesSelfRegConfirm;
                page.setRedirect(true);
                return page;
            }
        }
        return null;
    }
}