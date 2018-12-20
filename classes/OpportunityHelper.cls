public class OpportunityHelper 
{
	public static Opportunity createNewRegistrationOpportunity(Account acct)
	{
		Opportunity opp = new Opportunity();
		opp.AccountId = acct.Id;
		opp.RecordTypeId = Utils.getRecordTypeId('Opportunity', 'Open Auction');
		opp.List_Source__c = 'New Registration';
		opp.LeadSource = 'New Registration';
		opp.Name = acct.Name + ', New Registration';
		opp.StageName = 'Open';
		opp.Description = 'New Registration Received';
		opp.CloseDate = Date.today().addMonths(1);
		return opp;
	}
}