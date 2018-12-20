trigger ChecklistItemTrigger on Checklist_Item__c (before insert, before update) 
{
	/*
	if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
	{
		ChecklistItemServices.updateCLIAssignedDepartmentUser(Trigger.new, Trigger.oldMap);
		
		string getTriggerErrorMessages = ChecklistItemServices.triggerErrorMessages;
		if(String.isNotBlank(getTriggerErrorMessages))
		{
			Trigger.new[0].addError(getTriggerErrorMessages);
		}
	}
	*/
}