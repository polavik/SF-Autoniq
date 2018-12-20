/**
  * Apex Class: IntranetChatterControllerTest
  * Description: Test class for IntranetChatterController
  * Created By: Ashish Sharma (JDC)
  * Created Date: December 26th, 2013.
*/
@isTest
private class EdgeforceIntranetChatterControllerTest {

    static testMethod void chatterControllerTest() {
      //Insert test user
      User user = IntranetTestUtility.createUser(Integer.valueOf(Math.random()), true);
      CollaborationGroup testGroup1 = IntranetTestUtility.createGroup(false,'testgroupchatterctrl1');
      insert testGroup1;

      System.runAs(user){
        CollaborationGroup testGroup2 = IntranetTestUtility.createGroup(true,'testgroupchatterctrl2');
        EdgeforceIntranetChatterController controller = new EdgeforceIntranetChatterController ();

        controller.showMyFollowers();
        System.assert(controller.lstUsersSelected <> null);

        controller.showFollowing();
        System.assert(controller.lstUsersSelected <> null);

        controller.showfeed();
        System.assertEquals(true,controller.isfeed);

        controller.showMyFeed();
        System.assert(controller.userFeed <> null);

        controller.groupDesc = 'test group';
        controller.groupName = 'testgroupchatterctrl3';
        controller.access = 'Public';
        controller.allowCustomer = false;
        System.assertNotEquals(null,controller.createNewGroup());

        controller.showGroup();
        System.assertEquals(2,controller.userGroups.size());
        System.assertEquals(1,controller.activeGroups.size());

        controller.groupId = testGroup1.Id;
        System.assertNotEquals(null,controller.joinGroup());
      }
    }
}