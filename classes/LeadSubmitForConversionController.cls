public class LeadSubmitForConversionController {
    public String defaultEmailBody {get;set;}
    public String defaultEmailSubject {get;set;}
    public String leadId {get;set;}
    
    public LeadSubmitForConversionController() {
        leadId = ApexPages.currentPage().getParameters().get('Id');
        defaultEmailBody = 'Lead Conversion request from: ' + UserInfo.getName() + ' for record: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' +leadId ;
        defaultEmailSubject = 'Requested Lead Conversion';
    }
    
    public void SendEmail() {
        Messaging.SingleEmailMessage newEmail;
        newEmail = new Messaging.SingleEmailMessage();

        //newEmail.setToAddresses('');
        List<String> addressList = new List<String>();
        addressList.add('adesadealeroperations@adesa.com'); 
        newEmail.setToAddresses(addressList);
        newEmail.setSubject(defaultEmailSubject);
        newEmail.setHtmlBody(defaultEmailBody);
        newEmail.setSaveAsActivity(false);
        
        Messaging.sendEmail(new List<Messaging.Email> {newEmail});
    }
    
}