trigger ContractShellTrigger on AFC_Contract_Shell__c (before update) {
	if(Trigger.isBefore && Trigger.isUpdate)
	{
		ApplicationServices.updateAppStatusFromContractReceivedDate(Trigger.new, Trigger.oldMap);
	}
}