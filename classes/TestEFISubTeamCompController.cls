@isTest(seeAllData = false)
public class TestEFISubTeamCompController {
    static testMethod void TestEFISubTeamCompController() {
        User user = IntranetTestUtility.createUser(Integer.valueOf(Math.random() +6), true);
        System.runAs(user){
            User user1 = IntranetTestUtility.createUser(Integer.valueOf(Math.random() +5), true);
            CollaborationGroup testGroup = IntranetTestUtility.createGroup(true);
            CollaborationGroupMember testGroupMember =  IntranetTestUtility.createGroupMember(user1.Id, testGroup.Id, true);

            ApexPages.currentPage().getParameters().put('g', testGroup.Id); 
            String recordTypeId = Schema.SObjectType.Intranet_Content__c.getRecordTypeInfosByName().get('Sub Team RT').getRecordTypeId();
            Intranet_Content__c ic = new Intranet_Content__c();
            ic.RecordTypeId  = recordTypeId;
            ic.Type__c = 'Social Feed Config';
            insert ic;
            
            EFISubTeamCompController controller = new EFISubTeamCompController();
            controller.getAllSubTeamDetails();
            String pageID = controller.pageId;
            String pageIdForContent = controller.pageIdForContent;
            
    }
  }
}