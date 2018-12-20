@isTest(seeAllData = false)
private class TestEF_SocialFeedController {
    static testMethod void TestEF_SocialFeedController() {
        User user = IntranetTestUtility.createUser(Integer.valueOf(Math.random() +6), true);
        System.runAs(user){
            User user1 = IntranetTestUtility.createUser(Integer.valueOf(Math.random() +5), true);
            CollaborationGroup testGroup = IntranetTestUtility.createGroup(true);
            CollaborationGroupMember testGroupMember =  IntranetTestUtility.createGroupMember(user1.Id, testGroup.Id, true);

            ApexPages.currentPage().getParameters().put('g', testGroup.Id); 
            String recordTypeId = Schema.SObjectType.Intranet_Content__c.getRecordTypeInfosByName().get('Home Page Social Feed').getRecordTypeId();
            Intranet_Content__c ic = new Intranet_Content__c();
            ic.RecordTypeId  = recordTypeId;
            ic.Type__c = 'Social Feed Config';
            insert ic;
            
            Intranet_Content__c ic2 = new Intranet_Content__c();
            ic2.RecordTypeId  = recordTypeId;
            ic2.Type__c = 'Social Feed Link';
            insert ic2;            
            EF_SocialFeedController controller = new EF_SocialFeedController();
    }
  }
}