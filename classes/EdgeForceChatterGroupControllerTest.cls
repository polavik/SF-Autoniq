/**
  * Apex Class: EdgeForceChatterGroupControllerTest
  * Description: Test class for EdgeForceChatterGroupController
  * Created By: Ashish Sharma (JDC)
  * Created Date: December 27th, 2013.
*/
@isTest(seeAllData = false)
private class EdgeForceChatterGroupControllerTest {

    static testMethod void chatterGroupTest() {
        User user = IntranetTestUtility.createUser(Integer.valueOf(Math.random() +6), true);
        System.runAs(user){
            User user1 = IntranetTestUtility.createUser(Integer.valueOf(Math.random() +5), true);
            CollaborationGroup testGroup = IntranetTestUtility.createGroup(true);
            CollaborationGroupMember testGroupMember =  IntranetTestUtility.createGroupMember(user1.Id, testGroup.Id, true);

            ApexPages.currentPage().getParameters().put('g', testGroup.Id);
            EdgeForceChatterGroupController controller = new EdgeForceChatterGroupController();
            controller.showAllUsers();
            controller.getIsMember();
            controller.getIsAdmin();
            controller.getIsOwner();
            controller.joinGroup();
            controller.leaveGroup();
            
            controller.fileData='';
            
            controller.searchText = '';
            controller.searchUser();
            
            controller.searchText = UserInfo.getFirstName();

            controller.searchUser();
            //Asser test for userList
            System.assert(controller.userMap.size() > 0);
        }
    }
    
}