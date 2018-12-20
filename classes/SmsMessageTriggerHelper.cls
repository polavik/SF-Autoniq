public class SmsMessageTriggerHelper {
    @TestVisible private static boolean hasRun = false;
    public static void notify(SMS_Message__c[] messages) {
        Map <string, string> userPhone_to_userEmail  = new Map <string, string> ();

        for (SMS_Message__c sms  : messages) {
            if (sms.Incoming__c) {
                userPhone_to_userEmail.put(sms.Origin_Phone__c, null);
            }
        }

        for (User u : [SELECT Twilio_Phone__c, Email FROM User WHERE Twilio_Phone__c IN : userPhone_to_userEmail.keySet() ]) {
            userPhone_to_userEmail.put(u.Twilio_Phone__c, u.Email);
        }

        for (SMS_Message__c sms  : messages) {
            if (sms.Incoming__c) {
                sendEmail(sms.Message__c, sms.Destination_Phone__c, userPhone_to_userEmail.get(sms.Origin_Phone__c), sms.Contact__c);
            }
        }
    }

    @future public static void sendEmail(String message, String phone, String email, Id contactId) {
        hasRun = true;

        Messaging.SingleEmailMessage single_email = new Messaging.SingleEmailMessage();
        single_email.setToAddresses(new List<String> {email});
        single_email.setUseSignature(false);
        string body = 'You got message from: ' + '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + contactId + '">' + phone + '</a><br /><br /> Message: ' + message;
        single_email.setHtmlBody(body);
        single_email.setSubject('New Incoming SMS');
        Messaging.sendEmail(new List <Messaging.SingleEmailMessage> {single_email});
    }
}