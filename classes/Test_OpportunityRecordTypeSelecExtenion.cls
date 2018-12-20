/*
(c) 2016 Appirio, Inc.

Apex Class Name: OpportunityRecordTypeSelectionExtension

22nd October 2016   Arvind Thakur   Original (Task # T-549711) - Please see the task description for more details.
*/
@isTest
private class Test_OpportunityRecordTypeSelecExtenion {

     private static testmethod void rtSelectionControllerTest(){
     
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
      User u = new User(Alias = 'standt', Email='test1234@test8989.com', 
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='test1234@test8989.comxyz');
      
      System.runAs(u) {
      
      Account acc  = new Account();
      acc.Name = 'Test Account';
      insert acc;
      
        Opportunity testOpp = new Opportunity();
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(testOpp);
        
        PageReference tpageRef = Page.OpportunityRecordTypeSelection;
        Test.setCurrentPage(tpageRef);

        ApexPages.currentPage().getParameters().put('accountId', acc.Id);
        ApexPages.currentPage().getParameters().put('AccountName', acc.Name);
       
        Apexpages.StandardSetController stdController = new Apexpages.StandardSetController(oppList);
        OpportunityRecordTypeSelectionExtension controller = new OpportunityRecordTypeSelectionExtension(stdController);  
        controller.updateOppRecordType();
        controller.selectRecordType();
        controller.salesforceOnePage = true;
        controller.selectRecordType();  
        
        System.assert(controller.cancel() <> null);
        }
    }

}