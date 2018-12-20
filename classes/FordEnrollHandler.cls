public with sharing class FordEnrollHandler {
    private static final Date startDate = Date.newInstance(2015, 1, 1);
    private static final String adminEmailAddr = 'Salesforce-Alerts@openlane.com';
    public void purgeFordDoc() {
        // the attachment is currently during migration from OL to KAR
        // since the un-enrollment date tracking just to be started in 2014.12a, there would 
        // be no actual doc to be purged within 10 years
        // put detail implementation here after data migration done
        // see story B-31635
        // file name pattern: 
        // 1). DPA-%.pdf
        // 2). '%Accelerate%'
        if (startDate.addYears(8) < Date.today() ||  Test.IsRunningTest()  ) {
            sendEmail('Please verify FORD doc purge process',
                'Please revist/verify FORD doc purge process, please update apex to disable the email when all process normal'
            );
        }
        System.Debug('purgeFordDoc process executed'); 
    }
    
    
    public void sendEmail(String subject, String message) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        String[] toAddresses = new String[] {adminEmailAddr}; 
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Salesforce Support - Notification');
        mail.setSubject(subject); 
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.sethtmlBody(message);
        if(!Test.isRunningTest())
        { 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

}