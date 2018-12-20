trigger CollectionCaseTrigger on AFC_Collection_Case__c (before insert, before update) {
	if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {
		CollectionCaseTriggerHelper.updateNotificationUser(Trigger.new);
		CollectionCaseTriggerHelper.checkNonClosedCasesPerContract(Trigger.new);
	}
}