public class DeactivateAuctionCreditController 
{
	
	private final ApexPages.StandardController controller;  
	public Auction_Credit__c credit {get; set;}
	public boolean isAvailable {get; set;}
	
	public DeactivateAuctionCreditController (ApexPages.StandardController controller) 
	{  
		this.controller = controller;
		ID creditId = controller.getId();
		isAvailable = true;
		
		credit = 
			[SELECT
				Action_Package__c,
				Deactivation_Comments__c,
				Notification_Step__c,
				Status__c
			 FROM Auction_Credit__c
			 WHERE Id = :creditId];
		
		if (!validateProfile()) 
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
				'Insufficient privileges to deactivate an Auction Credit.'));
			isAvailable = false;
		}
		else if ('Deactivated'.equals(credit.Status__c))
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
					'This Auction Credit has already been deactivated.'));
			isAvailable = false;
		}
		else if (credit.Action_Package__c != null)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
					'To deactivate this Auction Credit, please deactivate the Action Package that was used to create it.'));
			isAvailable = false;
		}
		else 
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING,
					'This action cannot be reversed.');
			ApexPages.addMessage(msg);
		}
	}
	
	public boolean validateProfile() 
	{
		Profile prof = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
		
		Set<String> allowedApprovers = new Set<String>(); 
		allowedApprovers.add('Arbitration Manager - Canada');
		allowedApprovers.add('Arbitration Manager - US');
		allowedApprovers.add('Openlane Admin');
		allowedApprovers.add('Openlane-Admin Canada');
		allowedApprovers.add('Openlane Operations Manager Canada');
		allowedApprovers.add('Openlane Operations Manager US');
		allowedApprovers.add('Openlane Sales Manager Canada');
		allowedApprovers.add('Openlane Sales Manager US');
		allowedApprovers.add('Program Coordination Manager-Canada');
		allowedApprovers.add('Transportation Manager');
		allowedApprovers.add('System Administrator');
		
		return allowedApprovers.contains(prof.Name);
	}
	
	public PageReference back() 
	{
		return controller.view();
	}
	
	public PageReference deactivate() 
	{
		Logger.info(credit, 'Deactivating Auction Credit');
		AuctionCreditHelper.deactivateCredits(new Auction_Credit__c[] {credit});
		Logger.flush();
		
		return controller.view();
	}

}