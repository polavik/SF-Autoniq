//
// (c) 2013 Appirio, Inc.
//
// A test class for IntranetPeopleSearchController class
//
// 30 Dec 2013     Satyanarayan choudhary     Original
//
@isTest
private class IntranetPeopleSearchControllerTest {

    static testMethod void testIntranetPeopleSearchController() {
        
        Test.startTest();
        List<User> userList = new List<User>();
        // create test data
        User usr = IntranetTestUtility.createUser(121, false);
        usr.isActive = true;
        insert usr;
        System.runAs(usr){
          ApexPages.currentPage().getParameters().put('searchInput', usr.UserName);
          
          User tempUser = IntranetTestUtility.createUser(222, false);
          tempUser.isActive = true;
          insert tempUser;
          
          EdgeforceIntranetPeopleSearchController ipSearchController = new EdgeforceIntranetPeopleSearchController();
          ipSearchController.processPeopleSearch();   
                  
          // Validate Search
          System.assertEquals(ipSearchController.listofUsers.size(), 1);
          
          ipSearchController.clear();
          ApexPages.currentPage().getParameters().put('searchInput', tempUser.Email);
          //ipSearchController.searchString = tempUser.Email;        
          ipSearchController.processPeopleSearchMore();
          
          // Validate Search more
          System.assertEquals(ipSearchController.listofUsers.size(), 1);
          
        }
        
        Test.stopTest();
    }
}