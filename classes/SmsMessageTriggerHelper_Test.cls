@isTest
private class SmsMessageTriggerHelper_Test {
	@testSetup static void testSetup() {

		User newUser = TestUtility.createUser((Integer) Math.round(Math.random()*1000) + '');
		newUser.Twilio_Phone__c = '+15551112222';
		update newUser;

		insert new SMS_Thread__c (Origin_Phone__c = '+15551112222', Destination_Phone__c = '+15556667777') ;

	}
	@isTest static void testEmail_positive () {
		Test.startTest();
			insert new SMS_Message__c(Incoming__c = true, SMS_Thread__c = [SELECT Id FROM SMS_Thread__c].Id );
		Test.stopTest();

		System.assert(SmsMessageTriggerHelper.hasRun);
	}
	@isTest static void testEmail_negative () {
		Test.startTest();
			insert new SMS_Message__c(Incoming__c = false, SMS_Thread__c = [SELECT Id FROM SMS_Thread__c].Id );
		Test.stopTest();

		System.assert( !SmsMessageTriggerHelper.hasRun );
	}
}