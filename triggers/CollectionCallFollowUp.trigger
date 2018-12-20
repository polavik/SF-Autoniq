trigger CollectionCallFollowUp on Collection_Call__c (after insert, after update) {
	
	// Add Collection Calls where "Follow_Up__c" has been checked to "changed" list
	List<Collection_Call__c> changed = new List<Collection_Call__c>();
	if (Trigger.isUpdate) {
		for (Collection_Call__c newCall : Trigger.new) {
			Collection_Call__c oldCall = Trigger.oldMap.get(newCall.Id);
			if (newCall.Follow_Up__c == true && oldCall.Follow_Up__c != true) {
				changed.add(newCall);
			}
		}
	} else if (Trigger.isInsert) {
		for (Collection_Call__c newCall : Trigger.new) {
			if (newCall.Follow_Up__c == true) {
				changed.add(newCall);
			}
		}
	}
	
	// If nothing has changed, exit
	if (changed.size() == 0)
		return;
		
	// Perform Validation
	List<Collection_Call__c> valid = new List<Collection_Call__c>();
	for (Collection_Call__c call : changed) {
		if (call.Follow_Up_Time__c != null) {
			valid.add(call);	
		} else {
			call.addError('Follow Up Time required to create Follow Up Task.');
		}
	}
	
	// Get List of Collection Names
	Map<ID, Collection_Call__c> callMap = new Map<ID, Collection_Call__c>(
		[select Id, Collection__r.Name from Collection_Call__c where Id in :valid]);
	
	// Pull the Record Type of the Task that we're going to be creating
	Id rTypeId = [select Id 
				  from RecordType 
				  where SobjectType='Task' and Name= 'Collection Call Follow Up'].Id;
	
	for (Collection_Call__c call : valid) {
		String collectionName = callMap.get(call.id).Collection__r.name;
		
		Task task = new Task();
		task.OwnerId = UserInfo.getUserId();
		task.Subject = 'Follow Up with ' + collectionName;
		task.RecordTypeId = rTypeId;
		task.WhatId = call.Collection__c;
		task.ActivityDate = Date.newInstance(call.Follow_Up_Time__c.year(),
											 call.Follow_Up_Time__c.month(),
											 call.Follow_Up_Time__c.day());
		task.ReminderDateTime = call.Follow_Up_Time__c;
		task.IsReminderSet = true;
		insert task;
	}
	
}