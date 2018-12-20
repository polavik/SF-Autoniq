@isTest(seeAllData = false)
private class TestLeadSubmitForConversionController {
    	static testMethod void TestLeadSubmitForConversionController () {
        User user = IntranetTestUtility.createUser(Integer.valueOf(Math.random() +6), true);
        System.runAs(user){
            User user1 = IntranetTestUtility.createUser(Integer.valueOf(Math.random() +5), true);
            CollaborationGroup testGroup = IntranetTestUtility.createGroup(true);
            CollaborationGroupMember testGroupMember =  IntranetTestUtility.createGroupMember(user1.Id, testGroup.Id, true);
            ApexPages.currentPage().getParameters().put('g', testGroup.Id);                   
            LeadSubmitForConversionController controller = new LeadSubmitForConversionController();
            controller.SendEmail();
    }
  }
	
}