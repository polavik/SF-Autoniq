// Modified By: Amit SanWariya (Appirio)
// Modified On: 14-Oct-2016
// Modification: Added Call to LeadTriggerHandler to restrict task creation on Lead conversion
trigger LeadTrigger on Lead (after update) {
	
	if(Trigger.isAfter && Trigger.isUpdate)
	{
		LeadServices.insertAdditionalContacts(Trigger.new);
        //Added by Amit SanWariya
        LeadTriggerHandler.AfterUpdate(Trigger.new, Trigger.oldMap);
	}
}