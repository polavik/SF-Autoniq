trigger AuctionCreditBeforeDelete on Auction_Credit__c (before delete) 
{
	for (Auction_Credit__c credit : Trigger.old)
	{
		credit.addError('Cannot delete Auction Credits, please Deactivate instead.');
	}
}