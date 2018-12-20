public class TwilioService {

    private static final Set<String> SUCCESS_STATES = new Set<String> {'accepted', 'queued', 'sending', 'sent', 'delivered', 'received'};
    private static final Set<String> FAILED_STATES = new Set<String> {'failed', 'undelivered'};

    public static ServiceResponse sms(ServiceRequest request) {
        ServiceResponse response = validateRequest(request);

        if (response.code == 200) {
            TwilioConfig__c twilioConfig = TwilioConfig__c.getall().get('PROD');
            User loggedInUser = [SELECT Twilio_Phone__c FROM User WHERE Id = : Userinfo.getUserId() ];
            
            TwilioRestClient client = new TwilioRestClient(twilioConfig.AccountSid__c, twilioConfig.AuthToken__c);

            String  numSegments = String.valueOf(Math.rint(request.message.length() / 160.0));

            Map<String, String> params = new Map<String, String> {
                'To'   => request.phone,
                'From' => loggedInUser.Twilio_Phone__c,
                'Body' => request.message,
                'NumSegments' => numSegments
            };


            TwilioMessage sms = client.getAccount().getMessages().create(params);

            response.status = sms.getStatus();

            if (SUCCESS_STATES.contains(response.status)) {
                logSMS(request.phone, loggedInUser.Twilio_Phone__c, request.accountId, request.contactId, request.message, sms.getSid());
            }
        }

        return response;
    }


    @future private static void logSMS(String phone, string originPhone, Id accountId, Id contactId, String message, String sid) {

        SMS_Thread__c sms_thread;
        try {
            sms_thread = [select Id from SMS_Thread__c where Destination_Phone__c = :phone AND Origin_Phone__c = : originPhone];
        } catch (Exception ex) {
            sms_thread = new SMS_Thread__c(Destination_Phone__c = phone, Origin_Phone__c = originPhone);
            insert sms_thread;
        }

        insert new SMS_Message__c(
            SMS_Thread__c = sms_thread.Id,
            Sid__c = sid,
            Account__c = accountId,
            Contact__c = contactId,
            Message__c = message,
            Incoming__c = false
        );
    }

    private static ServiceResponse validateRequest(ServiceRequest request) {
        ServiceResponse response = new ServiceResponse();
        response.code = 200;
        response.status = '';

        if (String.isBlank(request.phone)) {
            response.code = 400;
            response.status = response.status + 'Must Have Phone Number!\n';
        }

        if (String.isBlank(request.message)) {
            response.code = 400;
            response.status = response.status + 'Must Have Message!\n';
        }

        if (response.status == '') {
            response.status = 'Ok';
        }

        return response;
    }

    public class ServiceRequest {
        public String phone;
        public Id accountId;
        public Id contactId;
        public String message;
    }

    public class ServiceResponse {
        public Integer code;
        public String status;
    }
}