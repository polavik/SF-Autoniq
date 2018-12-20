trigger AuctionCreditBeforeInsertUpdate on Auction_Credit__c (before insert, before update) 
{
	Set<ID> accountIds = new Set<ID>();
	for (Auction_Credit__c credit : Trigger.new)
	{
		accountIds.add(credit.Account__c);
	}
	
	Map<ID, Account> accounts = new Map<ID, Account>(
		[
			SELECT BillingCountry
			FROM Account
			WHERE Id IN :accountIds
		]
	);
	
	
	// Set CurrencyIsoCode based on the BillingCountry of the credit's Account
	for (Auction_Credit__c credit : Trigger.new)
	{
		Account acct = accounts.get(credit.Account__c);
		if (acct != null)
		{
			if ('CANADA'.equalsIgnoreCase(acct.BillingCountry))
			{
				credit.CurrencyIsoCode = 'CAD';
			}
			else
			{
				credit.CurrencyIsoCode = 'USD';
			}
		}
	}
}