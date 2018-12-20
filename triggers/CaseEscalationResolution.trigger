trigger CaseEscalationResolution on Case_Escalation__c (before update) {
	
	List<Case_Escalation__c> updatedResolutions = new List<Case_Escalation__c>();
	List<Case_Escalation__c> updatedAssignedTos = new List<Case_Escalation__c>();
	List<Case_Escalation__c> updatedApproverNotifieds = new List<Case_Escalation__c>();
	List<Case_Escalation__C> updatedApproveds = new List<Case_Escalation__C>();
	List<ID> casesToUpdateIds = new List<ID>();
	for (Case_Escalation__c escalation : Trigger.new)
	{
		Case_Escalation__c oldEscalation = Trigger.oldMap.get(escalation.Id);
		if (oldEscalation.Assigned_To__c == null && escalation.Assigned_To__c != null)
		{
			updatedAssignedTos.add(escalation);
		}
		
		if (oldEscalation.Escalation_Resolution__c == null && escalation.Escalation_Resolution__c != null)
		{
			updatedResolutions.add(escalation);
			casesToUpdateIds.add(escalation.Case__c);
		}
		
		if (oldEscalation.Notify_Approver__c == false && escalation.Notify_Approver__c == true)
		{
			updatedApproverNotifieds.add(escalation);
		}
		
		if (oldEscalation.Approved__c == false && escalation.Approved__c == true)
		{
			updatedApproveds.add(escalation);
		}
	}


	for (Case_Escalation__c escalation : updatedAssignedTos)
	{
		if (escalation.Assigned_Date_Time__c == null)
		{
			escalation.Assigned_Date_Time__c = DateTime.now();
		}
	}

	Map<ID, Case> caseMap = new Map<ID, Case>([SELECT Id, Escalation_Response_Recd__c FROM Case WHERE Id IN :casesToUpdateIds]);
	for (Case_Escalation__c escalation : updatedResolutions)
	{
		escalation.Resolution_Date__c = DateTime.now();
		caseMap.get(escalation.Case__c).Escalation_Response_Recd__c = true;
	}
	update caseMap.values();
	
	for (Case_Escalation__c escalation : updatedApproverNotifieds)
	{
		if (escalation.Approver_Notified_Date_Time__c == null)
		{
			escalation.Approver_Notified_Date_Time__c = DateTime.now();
		}
	}
	
	for (Case_Escalation__c escalation : updatedApproveds)
	{
		if (escalation.Approved_Date_Time__c == null)
		{
			escalation.Approved_Date_Time__c = DateTime.now();
		}
	}
}