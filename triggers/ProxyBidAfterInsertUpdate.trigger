trigger ProxyBidAfterInsertUpdate on Proxy_Bid__c (after insert, after update) 
{
	List<ID> highProxyIds = new List<ID>();
	for (Proxy_Bid__c proxy : Trigger.new)
	{
		if (proxy.High_Bid_Flag__c)
		{
			highProxyIds.add(proxy.Id);
		}
	}
	
	List<Proxy_Bid__c> highProxiesWithAuctions = 
	[
		SELECT
			Account__c,
			High_Bid_Flag__c,
			Contact__r.Email,
			Contact__r.MobilePhone,
			Contact__r.Phone,			
			Auction__r.Highest_Bidder__c, 
			Auction__r.Highest_Bidder_Account__c,
			Auction__r.Highest_Bidder_Contact_Email__c,
			Auction__r.Highest_Bidder_Contact_Mobile__c,
			Auction__r.Highest_Bidder_Contact_Phone__c	
		FROM Proxy_Bid__c
		WHERE Id IN :highProxyIds
	];
	
	Set<Auction__c> auctionsToUpdate = new Set<Auction__c>();
	for (Proxy_Bid__c proxy : highProxiesWithAuctions)
	{
		proxy.High_Bid_Flag__c = false;
		
		Auction__c auction = proxy.Auction__r;
		auction.Highest_Bidder__c = proxy.Id;
		auction.Highest_Bidder_Account__c = proxy.Account__c;
		auction.Highest_Bidder_Contact_Email__c = proxy.Contact__r.Email;
		auction.Highest_Bidder_Contact_Mobile__c = proxy.Contact__r.MobilePhone;
		auction.Highest_Bidder_Contact_Phone__c = proxy.Contact__r.Phone;
		
		auctionsToUpdate.add(auction);
	}
	
	update new List<Auction__c>(auctionsToUpdate);
	
	update highProxiesWithAuctions;	
}