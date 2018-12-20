trigger SmsMessageTrigger on SMS_Message__c (before insert, before update, before delete, after insert, after update, after delete) {
    if (trigger.isAfter) {
		if (trigger.isInsert) {        
        	SmsMessageTriggerHelper.notify(trigger.new);
    	}      
    }
}