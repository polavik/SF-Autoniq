trigger setEscalatedToTaskOld on Collection_Old__c (after insert, after update) {
	// Only work on Collections where the Escalated_To__c field has changed
	List<Collection_Old__c> changed = new List<Collection_Old__c>();

	if (Trigger.isUpdate) {
		for (Collection_Old__c newColl : Trigger.new) {
			Collection_Old__c oldColl = Trigger.oldMap.get(newColl.Id);
			if (newColl.Escalated_To__c != null && 
				oldColl.Escalated_To__c != newColl.Escalated_To__c) {
				changed.add(newColl);
			}
		}
	} else if (Trigger.isInsert) {
		for (Collection_Old__c newColl : Trigger.new) {
			if (newColl.Escalated_To__c != null) {
				changed.add(newColl);
			}
		}
	}

	
	// If nothing has changed, exit
	if (changed.size() == 0)
		return;
	
	// Pull the Record Type of the Task that we're going to be creating
	Id rTypeId = [select Id 
				  from RecordType 
				  where SobjectType='Task' and Name='Escalation Notice'].Id;
	
	// Create new Task and Send notification email for each changed Collection
	for (Collection_Old__c coll : changed) {
		ID targetId = coll.Escalated_To__c;
		Task task = new Task();
		task.OwnerId = targetId;
		task.Subject = 'Collections Escalation';
		task.RecordTypeId = rTypeId;
		task.WhatId = coll.Id;
		task.WhoId = coll.Contact__c;
		task.ActivityDate = Date.today();
		task.ReminderDateTime = datetime.now().addDays(2);
		task.IsReminderSet = true;
		insert task;
		
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String subject = 'Collection Escalation';
		String textBody = 'Greetings,\n\n' + 
						  'This is an automatically generated notification that a Collection has been escalated to you in Salesforce.\n\n' +
						  'Collection Number: ' + coll.Name;
		
		String htmlBody = 'Greetings,<p>' + 
						  'This is an automatically generated notification that a Collection has been escalated to you in Salesforce.<p>' + 
						  'Collection Number: <a href=' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + coll.Id + '>' + coll.Name + '</a>';
		
		mail.setTargetObjectId(targetId);
		mail.setSubject(subject);
		mail.setPlainTextBody(textBody);
		mail.setHtmlBody(htmlBody);
		mail.setSaveAsActivity(false);
		
		if(!Sandbox.isSandbox())
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}