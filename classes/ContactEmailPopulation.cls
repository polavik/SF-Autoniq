global class ContactEmailPopulation implements Database.Batchable<Sobject>, Database.Stateful, Schedulable {
    
    global String successes = 'SUCCESSFUL UPDATES:\n'; 
    global String failures = 'FAILED UPDATES:\n';
    global String dummyemail = 'salesforceemails@openlane.com';
    
    String query = 'SELECT id, Email FROM Contact where Email != :dummyemail';
        
    
    global void execute(SchedulableContext sc) 
    {
        ContactUserSynchronizer synchronizer = new ContactUserSynchronizer();
        Database.executeBatch(synchronizer);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Sobject> scope) {
        
        List<Contact> ct = (List<Contact>) scope;
        List<Contact> ctToUpdate = new List<Contact>();
        Set<String> ListFLSUpdate = new Set<String>();
		Boolean blnFLSOverride = Utils.GetFLS();
 
        for (Contact c : ct) {
			 //Story B-44003 : FLS UPDATE ACCESS CHECK
			 if (Schema.sObjectType.Contact.fields.Email.isUpdateable() || blnFLSOverride)
			 {						 
				c.Email = 'salesforceemails@openlane.com';
			 }
			 else
			 {						
				ListFLSUpdate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.Email.getName());
			 }                
			ctToUpdate.add(c);
        }
        update ctToUpdate;
        
        if(ListFLSUpdate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_UPDATE','CLASS:ContactEmailPopulation', ListFLSUpdate);
		}
    }
    
    global void finish(Database.BatchableContext bc) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'Salesforceemails@openlane.com'});
        mail.setSubject('Batch Process Completed - ContactUserSynchronizer');
        mail.setPlainTextBody(successes + '\n\n' + failures);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
   
}