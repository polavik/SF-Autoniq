global class ContactUserSynchronizer implements Database.Batchable<Sobject>, Database.Stateful, Schedulable {
    
    global String successes = 'SUCCESSFUL UPDATES:\n'; 
    global String failures = 'FAILED UPDATES:\n';
    
    String query = 
        'SELECT Username, Email, FirstName, LastName, CommunityNickname, Alias, Contact.Person_Id__c, ' +
        'Contact.Login_Name__c, Contact.FirstName, Contact.LastName, Contact.Email ' +
        'FROM User ' +
        'WHERE ContactId != NULL ' +
        'AND Contact.Login_Name__c != NULL ' +
        'AND Contact.Email != NULL ' +
        'AND Contact.LastName != NULL ' + 
        'AND User.IsActive = TRUE ' +
        'AND (NOT Contact.Person_Id__c LIKE \'-%\')';
    
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
        
       // Append suffix to username and email address to avoid accidentally sending email from sandbox
        String sandboxSuffix = Utils.getProperty('sandbox.suffix');
        if (sandboxSuffix == null) { // Production instance will have no suffix
            sandboxSuffix = '';
        }
        
        List<User> users = (List<User>) scope;
        List<User> usersToUpdate = new List<User>();
        
        for (User u : users) {
            if (!u.Username.equals(u.Contact.Login_Name__c + '@openlanecp.com' + sandboxSuffix) ||
                !u.CommunityNickname.equals(u.Contact.Login_Name__c) ||
                !u.Email.equals(u.Contact.Email) ||
                !u.FirstName.equals(u.Contact.FirstName) ||
                !u.LastName.equals(u.Contact.LastName)) 
            {
                usersToUpdate.add(u);
            }
        }
        Set<String> ListFLSUpdate = new Set<String>();
		Boolean blnFLSOverride = Utils.GetFLS();
        List<User> finalUsers = new List<User>();
        for (User u : usersToUpdate)
        {
            System.debug('----- Updating User -----');
            System.debug(u);
            System.debug(u.Contact);            
                
			
			//Story B-44003 : FLS UPDATE ACCESS CHECK
			 if (Schema.sObjectType.User.fields.Username.isUpdateable() || blnFLSOverride)
			 {						 
				u.Username = u.Contact.Login_Name__c + '@openlanecp.com' + sandboxSuffix;				
			 }
			 else
			 {						
				ListFLSUpdate.add(Schema.sObjectType.User.getName()+'.'+Schema.sObjectType.User.fields.Username.getName());
			 }
			 
            System.debug('test');
            
            if (Schema.sObjectType.User.fields.Email.isUpdateable() || blnFLSOverride)
			 {						 
				u.Email = u.Contact.Email; 				
			 }
			 else
			 {						
				ListFLSUpdate.add(Schema.sObjectType.User.getName()+'.'+Schema.sObjectType.User.fields.Email.getName());
			 }
            
			if (Schema.sObjectType.User.fields.FirstName.isUpdateable() || blnFLSOverride)
			 {						 
				u.FirstName = u.Contact.FirstName;				
			 }
			 else
			 {						
				ListFLSUpdate.add(Schema.sObjectType.User.getName()+'.'+Schema.sObjectType.User.fields.FirstName.getName());
			 }
            
			if (Schema.sObjectType.User.fields.LastName.isUpdateable() || blnFLSOverride)
			 {						 
				u.LastName = u.Contact.LastName;				
			 }
			 else
			 {						
				ListFLSUpdate.add(Schema.sObjectType.User.getName()+'.'+Schema.sObjectType.User.fields.LastName.getName());
			 }
            
			if (Schema.sObjectType.User.fields.CommunityNickname.isUpdateable() || blnFLSOverride)
			 {						 
				u.CommunityNickname = u.Contact.Login_Name__c;				
			 }
			 else
			 {						
				ListFLSUpdate.add(Schema.sObjectType.User.getName()+'.'+Schema.sObjectType.User.fields.CommunityNickname.getName());
			 }
            
            System.debug('test2');
            
            if (u.Contact.login_Name__c.length() < 8) {
                
				if (Schema.sObjectType.User.fields.Alias.isUpdateable() || blnFLSOverride)
				 {						 
					u.Alias = u.Contact.Login_Name__c.toLowerCase();			
				 }
				 else
				 {						
					ListFLSUpdate.add(Schema.sObjectType.User.getName()+'.'+Schema.sObjectType.User.fields.Alias.getName());
				 }
            } else {
               
				if (Schema.sObjectType.User.fields.Alias.isUpdateable() || blnFLSOverride)
				 {						 
					u.Alias = u.Contact.Login_Name__c.toLowerCase().substring(0, 7);			
				 }
				 else
				 {						
					ListFLSUpdate.add(Schema.sObjectType.User.getName()+'.'+Schema.sObjectType.User.fields.Alias.getName());
				 }
            }
            finalUsers.add(u);
        }
        
		if(ListFLSUpdate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_UPDATE','CLASS:ContactUserSynchronizer', ListFLSUpdate);
		}
		
        System.debug('test3');
        
        Database.SaveResult[] saveResults = Database.Update(finalUsers, false);
        for (Database.SaveResult sr : saveResults) {
            if (sr.isSuccess()) {
                successes = successes + sr.getId() + '\n';
            }
        }
        
        System.debug('test4');
        
        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                failures = failures + sr.getId() + '\n';
                for (Database.Error err : sr.getErrors()) {
                    failures = failures + '+  ' + err + '\n';
                }
            }
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