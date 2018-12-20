/**
 * An apex page controller that supports self registration of users in communities that allow self registration
 */
@IsTest public with sharing class CommunitiesSelfRegControllerTest {
  @IsTest(SeeAllData=true) 
  public static void testCommunitiesSelfRegController() {
    CommunitiesSelfRegController controller = new CommunitiesSelfRegController();
     Account acc = TestUtility.createAccount(1, true );
    //Fixing insufficient code coverage for default Communities Apex Tests
    controller.firstName = 'Bob';
    controller.lastName = 'Jones';
    controller.email = 'bob@jones.com';
    controller.password = '8yhMsHDN&ituQgO$WO';
    controller.confirmPassword = '8yhMsHDN&ituQgO$WO';
    controller.communityNickname = 'bob-jones-testing';

    PageReference pageRef = controller.registerUser();
  }
  // Fixing insufficient code coverage for default Communities Apex Tests
  @IsTest(SeeAllData=true) 
  public static void testInvalidPassword() {
    CommunitiesSelfRegController controller = new CommunitiesSelfRegController();
     Account acc = TestUtility.createAccount(1, true );
    controller.firstName = 'Bob';
    controller.lastName = 'Jones';
    controller.email = 'bob@jones.com';
    controller.password = '8yhMsHDN&ituQgO$WO';
    controller.confirmPassword = 'not the same';
    controller.communityNickname = 'bob-jones-testing';

    PageReference pageRef = controller.registerUser();
    System.debug('-------------pageRef' + pageRef);
    System.assert(pageRef == null, 'The returned page reference should be null');
  }
  // Fixing insufficient code coverage for default Communities Apex Tests
  @IsTest(SeeAllData=true) 
  public static void testNullPassword() {
    CommunitiesSelfRegController controller = new CommunitiesSelfRegController();
     Account acc = TestUtility.createAccount(1, true );
    controller.firstName = 'Bob';
    controller.lastName = 'Jones';
    controller.email = 'bob@jones.com';
    controller.communityNickname = 'bob-jones-testing';

    PageReference pageRef = controller.registerUser();
    System.debug('-------------pageRef 2' + pageRef);
    System.assert(pageRef != null, 'The returned page reference should not be null- /apex/communitiesselfregconfirm');
  }
}