public without sharing class SPCaseCommentNotificationController 
{
	
	public String escalationNumber {get; set;}
	public String commentBody {get; set;}
	public String commentBy {get; set;}
	
	public String caseId
	{
		get;
		
		set
		{
			caseId = value;
			
			Case c = 
			[
				SELECT Id, 
				(
					SELECT Id, CommentBody, CreatedBy.Name 
					FROM CaseComments
					ORDER BY CreatedDate DESC
				)
				FROM Case
				WHERE Id = :caseId
			];
			
						
			Case_Escalation__c escalation = 
			[
				SELECT Id, Name, Case__c FROM Case_Escalation__c
				WHERE Case__c = :caseId
			];
			
			escalationNumber = escalation.Name;
			
						
			// We assume that at least one comment exists on the Case, otherwise this code would
			// not be called.  Therefore, no need to check for array boundaries/null pointers
			commentBy = c.CaseComments.get(0).CreatedBy.Name;
			commentBody = c.CaseComments.get(0).CommentBody;
			
			// Carriage returns need to be converted to HTML line breaks to display propery in email
			commentBody = commentBody.replace('\n', '<br/>');

		}
	}
}