@isTest
private class TwilioServiceIncomingController_Test {
	 @testSetup static void testSetup() {
        Account account = TestUtility.createAccount(1, true);
        
        Contact contact = new Contact(
        	Firstname = 'First1', 
        	Lastname = 'Last1', 
        	Email = 'test@test.com', 
        	MobilePhone = '(847) 840-3177', 
        	AccountId = account.Id
        );
        insert contact;
        
        insert new TwilioConfig__c(Name = 'PROD', AccountSid__c = 'ACADFB5891C0E4F8C6C34BE620A8EC1EF3', AuthToken__c = '12345678901234567890123456789012');
    }

	@isTest static void testIncomingMessage () {
		User newUser = TestUtility.createUser((Integer) Math.round(Math.random()*1000) + '');
        newUser.Twilio_Phone__c = '+15023852776';
        newUser.Email = 'test@test.com';
        update newUser;
		
		PageReference pageRef = Page.TwillioIncoming;        
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('AccountSid', 'ACADFB5891C0E4F8C6C34BE620A8EC1EF3' );
        pageRef.getParameters().put('From', '+18478403177' );
        pageRef.getParameters().put('To', '+15023852776' );
        pageRef.getParameters().put('Body', 'test message' );
        pageRef.getParameters().put('SmsSid', '111' );
        
		TwilioServiceIncomingController controller =  new TwilioServiceIncomingController();
		Test.startTest();
			system.runAs(newUser) {
				controller.execute();
			}
		Test.stopTest();
		
		SMS_Message__c message = [SELECT Message__c, SMS_Thread__c, Sid__c, Incoming__c FROM SMS_Message__c];
		
		system.assertEquals('test message', message.Message__c);
		system.assertEquals('111', message.Sid__c);
		system.assertEquals(true , message.Incoming__c);
	}
	
	
}