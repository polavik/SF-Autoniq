public class TwilioServiceOutgoingController {

    private final Contact contact;
    private ApexPages.StandardController controller;

    public String outgoing_sms {get; set;}

    @testvisible private User loggedInUser {
        get {
            if (loggedInUser == null) {
                loggedInUser  = [SELECT Twilio_Phone__c FROM User WHERE Id = : Userinfo.getUserId() ];
            }
            return loggedInUser;
        }
        set;
    }

    public Boolean hasUpdates {get; private set;}

    public SMSMessage[] SMSMessages {
        get{
            SMSMessage[] SMSMessages = new SMSMessage[]{};
            String formatted = formatForTwilio(contact.MobilePhone);

            for (SMS_Message__c raw_sms : [
                        select Id, Message__c, Incoming__c, Destination_Phone__c, CreatedDate
                        from SMS_Message__c where Destination_Phone__c = :formatted AND Origin_Phone__c = : loggedInUser.Twilio_Phone__c order by CreatedDate asc]) {

                SMSMessages.add(new SMSMessage(raw_sms));
            }

            return SMSMessages;
        }
        private set;
    }

    public TwilioServiceOutgoingController(ApexPages.StandardController controller) {
        this.controller = controller;
        contact = [select Id, Name, AccountId, MobilePhone from Contact where Id = :controller.getId()];

        outgoing_sms = null;
        hasUpdates = true;
    }

    public PageReference setHasUpdates() {
        hasUpdates = true;

        SMSMessage[] messages = SMSMessages;
        if (messages.size() - 1 >= 0) {
            SMSMessage latest_message = messages[messages.size() - 1];
            hasUpdates = latest_message.createdDate >= Datetime.now().addMinutes(-1);
        }

        return null;
    }


    public PageReference send() {
        TwilioService.ServiceRequest request = new TwilioService.ServiceRequest();
        request.phone = formatForTwilio(contact.MobilePhone);
        request.message = outgoing_sms;
        request.contactId = contact.Id;
        request.accountId = contact.AccountId;
        TwilioService.sms(request);

        outgoing_sms = null;
        hasUpdates = true;

        return null;
    }

    public String formatForTwilio(String phone) {
        if (string.isNotBlank(phone)) {
            String regex = '[\\s,a-zA-Z()-]';
            String formatted = '+1' + phone.replaceAll(regex, '');
            return  formatted;
        } else return '';
    }

    // domain object/decorator
    public class SMSMessage {
        public Id id {get; set;}
        public String message {get; set;}
        public Boolean incoming {get; set;}
        public DateTime createdDate {get; set;}
        public String formateCreatedDate {get; set;}
        public String phone {get; set;}

        public SMSMessage(SMS_Message__c raw_sms) {
            id = raw_sms.Id;
            incoming = raw_sms.Incoming__c;
            createdDate = raw_sms.CreatedDate;
            formateCreatedDate = createdDate.format('EEE, d MMM yyyy z HH:mm:ss a');
            phone = raw_sms.Destination_Phone__c;
            message = formatSMSBody(raw_sms.Message__c);
        }

        public String formatSMSBody(String sms_body) {
            String result = '';

            String template = '<a href="{0}" target="blank">{1}</a>';
            String[] words = sms_body.split(' ');

            String regex = '^((http|https)://)??(www[.])??([a-zA-Z0-9]|-)+?([.][a-zA-Z0-9(-|/|=|?)??]+?)+?$';
            Pattern url_pattern = Pattern.compile(regex);

            for (integer i = 0; i < words.size(); i++) {
                String word = words[i];
                Integer column = 0;

                if (url_pattern.matcher(word).matches()) {
                    String original_word = word;
                    String url_formatted = word;

                    if (!original_word.startsWith('https://') && !original_word.startsWith('http://')) {
                        url_formatted = 'http://' + original_word;
                    }

                    word = String.format(template, new String[] {url_formatted, original_word});
                }

                result = result + ' ' + word;

            }


            return result;
        }
    }

}