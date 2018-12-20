public without sharing class TwilioServiceIncomingController {
    public TwilioServiceIncomingController() {}

    public void execute(){        
        Map<String, String> params = ApexPages.currentPage().getParameters();

        TwilioConfig__c  twilioConfig = TwilioConfig__c.getAll().get('PROD');        
        if(params.get('AccountSid') == twilioConfig.AccountSid__c 
           && params.get('MessagingServiceSid') == twilioConfig.ApplicationSid__c  
           && params.get('From') != null){
            
            SMS_Thread__c sms_thread; 
            try{
                sms_thread = [select Id from SMS_Thread__c where Destination_Phone__c = :params.get('From') AND Origin_Phone__c = : params.get('To')  ];
            }catch(Exception ex){
                sms_thread = new SMS_Thread__c(Destination_Phone__c = params.get('From'), Origin_Phone__c = params.get('To') );
                insert sms_thread;             
            }
                                               
           Contact contact = [select Id, AccountId from Contact where MobilePhone = :sfFormtatTwilioPhoneNumber(params.get('From'))];  
               
           SMS_Message__c sms_message = new SMS_Message__c(
                Account__c = contact.AccountId,
                Contact__c = contact.Id,
                SMS_Thread__c = sms_thread.Id,
                Message__c = params.get('Body'),
                Sid__c = params.get('SmsSid'),
                Incoming__c = true
           );
           insert sms_message;
        }        
       
    }
    
    private String sfFormtatTwilioPhoneNumber(String phone){
        phone = phone.replace('+1', '');
        String result = '(' + phone.substring(0, 3) + ') ' + phone.substring(3, 6) + '-' + phone.substring(6);
        return result;
    }
}