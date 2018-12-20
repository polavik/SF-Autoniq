@isTest
public class TestUserLoginHistory {

    public static testMethod void testUserLoginHistory() {
        ApexPages.currentPage().getParameters().put('u', UserInfo.getUserId());
        UserLoginHistory controller = new UserLoginHistory();
        
    }       
}