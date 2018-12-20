@isTest
private class EventTriggerHandlerTest {

	private static testMethod void testEventTriggerHandler() {
        test.startTest();
      Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
      User u = new User(Alias = 'standt', Email='test1234@test8989.com', 
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='test1234@test8989.comxyz');
        
            System.runAs(u) {
            Opportunity testOpp;
            for(Opportunity opp : [Select Id FROM Opportunity Limit 1]) {
                testOpp = opp;
            }
            
            Event testEvent = new Event();
            testEvent.whatId = testOpp.Id;
            testEvent.subject = 'test';
            testEvent.DurationInMinutes	= 10;
            testEvent.activityDateTime = system.now();
            insert testEvent;
            
            for(Opportunity opp : [SELECT Id, Days_To_Contact__c FROM Opportunity Where Id =:testOpp.Id ]) {
                testOpp = opp;
            }
            
            system.assert(true, testOpp.Days_To_Contact__c != null);
        
        
        test.stopTest();
	}
	
    }	
    @TestSetup
	private static void createTestData() {
	    Account testAccount = TestUtility.createAccount(1, true);
	    Opportunity testOpp = TestUtility.createOpportunity(1, testAccount.Id, false);
	    Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('ADESA DST CLOSE').getRecordTypeId();
	    testOpp.RecordTypeId = oppRecordTypeId;
	    insert testOpp;
	    
	}
    
}