public class CaseEscalationEditController {
	public Case_Escalation__c escalation {get; set;}
	
	public String selectedApprover {get; set;}
	public String selectedAssignee {get; set;}
	
	public String selectedCaseStatus {get; set;}
	public boolean editableCaseStatus {get; set;}
	
	
	public CaseEscalationEditController(ApexPages.StandardController stdController) 
	{
        ID escalationId = stdController.getId();
        escalation = 
        	[SELECT 
        		Id, 
        		Case__c, 
        		Reference_Number__c,
        		Escalation_Resolution__c,
        		Last_Comment__c, 
        		Last_Comment_Date__c,
        		Payment_sent_to_OPENLANE__c,
        		Approver__c,
        		Assigned_To__c,
        		Notify_Assignee__c,
        		Notify_Approver__c,
        		Approval_Status__c,
        		Approved__c,
        		Case__r.Claim_Resolution__c,
        		Case__r.Inspection_Company_Responsibility__c,
        		Case__r.Private_Label__c,
        		Case__r.Resolution_Subtype__c,
        		Case__r.Seller__c,
        		Case__r.Status,
        		Concession_Amount__c,
        		Resolution_Details__c,
        		Status__c,
        		Goodwill__c
        	FROM Case_Escalation__c 
        	WHERE Id = :escalationId];
        	
        selectedApprover = escalation.Approver__c;
        selectedAssignee = escalation.Assigned_To__c;
        selectedCaseStatus = escalation.Status__c;
        
        Seller_Portal_Config__c spc = SellerPortalConfigHelper.getSellerPortalConfig(escalation.Case__r.Seller__c, escalation.Case__r.Private_Label__c);
        if (spc != null && spc.Edit_Case_Status__c)
        {
        	editableCaseStatus = true;
        }
        else
        {
        	editableCaseStatus = false;
        }
	}
	
	public PageReference submit()
	{
		try
		{
			
			Set<String> ListFLSUpdate = new Set<String>();
			Boolean blnFLSOverride = Utils.GetFLS();
 
			 //Story B-44003 : FLS UPDATE ACCESS CHECK
			 if (Schema.sObjectType.Case_Escalation__c.fields.Assigned_To__c.isUpdateable() || blnFLSOverride)
			 {						 
				escalation.Assigned_To__c = selectedAssignee;
			 }
			 else
			 {						
				ListFLSUpdate.add(Schema.sObjectType.Case_Escalation__c.getName()+'.'+Schema.sObjectType.Case_Escalation__c.fields.Assigned_To__c.getName());
			 }
			 if (Schema.sObjectType.Case_Escalation__c.fields.Approver__c.isUpdateable() || blnFLSOverride)
			 {						 
				escalation.Approver__c = selectedApprover;
			 }
			 else
			 {						
				ListFLSUpdate.add(Schema.sObjectType.Case_Escalation__c.getName()+'.'+Schema.sObjectType.Case_Escalation__c.fields.Approver__c.getName());
			 }
			 
			if(ListFLSUpdate.size()>0)
			{
				Utils.SendEmailforFLS('FLS_UPDATE','CaseEscalationEditController', ListFLSUpdate);
			}
			update escalation;
			
			if (editableCaseStatus)
			{
				boolean updateCase = false;
				if (selectedCaseStatus != null && !selectedCaseStatus.equalsIgnoreCase(escalation.Status__c))
				{
					if ('CLOSED'.equalsIgnoreCase(selectedCaseStatus))
					{
						escalation.Case__r.Status = 'Closed';
						updateCase=true;
					}
					else if ('OPEN'.equalsIgnoreCase(selectedCaseStatus))
					{
						escalation.Case__r.Status = 'Re-Opened';
						updateCase=true;
					}
				}
				
				if ('BUY BACK'.equalsIgnoreCase(escalation.Escalation_Resolution__c) &&
					!'Void'.equalsIgnoreCase(escalation.Case__r.Claim_Resolution__c))
				{
					// If the Resolution is Buy Back, do NOT set Case Resolution to Void
					//  Reason is that we need to manually add Action Packages to these cases,
					//  and VCI program coordination is running a report to pick up Cases with 
					//  resolution=Pre-Void, manually setting resolution to Void, and creating Action Package
					escalation.Case__r.Claim_Resolution__C = 'Pre-Void';
					escalation.Case__r.Resolution_Subtype__c = 'Seller';
					escalation.Case__r.Inspection_Company_Responsibility__c = 'Unclear';
					updateCase=true;
				}
				else if ('DECLINE'.equalsIgnoreCase(escalation.Escalation_Resolution__c) &&
						!'DECLINE'.equalsIgnoreCase(escalation.Case__r.Claim_Resolution__c))
				{
					escalation.Case__r.Claim_Resolution__c = 'Decline';
					escalation.Case__r.Resolution_Subtype__c = 'NA';
					escalation.Case__r.Inspection_Company_Responsibility__c = 'Unclear';
					updateCase=true;
				}
				else if ('CONCESSION'.equalsIgnoreCase(escalation.Escalation_Resolution__c) &&
						!'Concessions'.equalsIgnoreCase(escalation.Case__r.Claim_Resolution__c))
				{
					escalation.Case__r.Claim_Resolution__c = 'Concessions';
					escalation.Case__r.Resolution_Subtype__c = 'Seller';
					escalation.Case__r.Inspection_Company_Responsibility__c = 'Unclear';
					updateCase=true;
				}
							
				if (updateCase)
				{
					update escalation.Case__r;
				}
			}
			
			PageReference pr = Page.case_escalation;
			pr.getParameters().put('id', escalation.Id);
			return pr;
		}
		catch (DMLException e)
		{
			ApexPages.addMessages(e);
			return null;
		}
	}
	
	public PageReference cancel()
	{
		PageReference pr = Page.case_escalation;
		pr.getParameters().put('id', escalation.Id);
		return pr;
	}
	
	public List<SelectOption> getRelatedUsers()
	{
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', '--None--'));
		
		// Find all users who have seller permissions for account specified in Case "Seller" field
		for (Seller_Permission__c sp : 
			[SELECT User__r.Name, User__r.Id FROM Seller_Permission__c WHERE Account__c = :escalation.Case__r.Seller__c])
		{
			options.add(new SelectOption(sp.User__r.Id, sp.User__r.Name));
		}
		return options;
	}
	
	public List<SelectOption> getCaseStatusOptions()
	{
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('Open', 'Open'));
		options.add(new SelectOption('Closed', 'Closed'));
		
		return options;
	}
}