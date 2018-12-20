@isTest
private class TwilioServiceOutgoingController_Test {

    @testSetup static void testSetup() {

        Account account = TestUtility.createAccount(1, true);
        Contact contact = new Contact(Firstname = 'First1', Lastname = 'Last1', Email = 'test@test.com', MobilePhone = '5551112222', AccountId = account.Id);
        insert contact;
        insert new TwilioConfig__c(Name = 'PROD', AccountSid__c = 'ACADFB5891C0E4F8C6C34BE620A8EC1EF3', AuthToken__c = '12345678901234567890123456789012');
    }
    @isTest static void newThreadStartedByUser () {
        User newUser = TestUtility.createUser((Integer) Math.round(Math.random() * 1000) + '');
        newUser.Twilio_Phone__c = '+15551112222';
        update newUser;
        
        string accountJsonResponseBody = '{'
                                         + '"account_sid": "ACADFB5891C0E4F8C6C34BE620A8EC1EF3",'
                                         + '"api_version": "2010-04-01",'
                                         + '"body": "Test sending MMS from twilio",'
                                         + '"num_segments": "1",'
                                         + '"num_media": "1",'
                                         + '"date_created": "Mon, 1 Feb 2012 10:49:17 +0000",'
                                         + '"date_sent": "Mon, 1 Feb 2012 10:49:17 +0000",'
                                         + '"date_updated": "Mon, 1 Feb 2012 10:49:17 +0000",'
                                         + '"direction": "outbound-api",'
                                         + '"from": "+14158141829",'
                                         + '"price": "null",'
                                         + '"price_unit":"usd",'
                                         + '"sid": "MM90c6fc909d8504d45ecdb3a3d5b3556e",'
                                         + '"status": "queued",'
                                         + '"to": "+14159978453",'
                                         + '"uri": "/2010-04-01/Accounts/ACADFB5891C0E4F8C6C34BE620A8EC1EF3/MM90c6fc909d8504d45ecdb3a3d5b3556e.json",'
                                         + '"subresource_uris": '
                                         + '{"media":"/2010-04-01/Accounts/ACADFB5891C0E4F8C6C34BE620A8EC1EF3/Messages/MMbd2135c6d10f417faf1e03fac4e8397b/Media.json"}'
                                         + '}';

        Twilio_TestHTTPMock.getInstance().putResponse('POST',
                'https://api.twilio.com/2010-04-01/Accounts/ACADFB5891C0E4F8C6C34BE620A8EC1EF3/Messages.json',
                new Twilio_TestHTTPMock.Response(accountJsonResponseBody, 200));

        Contact contact = [SELECT Id, MobilePhone FROM Contact];
        Account account = [SELECT Id FROM Account];

        ApexPages.StandardController sc = new ApexPages.StandardController(contact);
        TwilioServiceOutgoingController controller = new TwilioServiceOutgoingController(sc);
        controller.outgoing_sms = 'Test message http://wwww.test.com';
        
        PageReference pageRef = Page.TwillioMessagePage;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', contact.Id);

        Test.startTest();
        system.runAs(newUser) {
            system.assertEquals(controller.loggedInUser.Id, newUser.Id);
            controller.send();
        }
        Test.stopTest();
        
        controller.sethasUpdates();
        system.assertEquals(1, controller.SMSMessages.size());
    }

}