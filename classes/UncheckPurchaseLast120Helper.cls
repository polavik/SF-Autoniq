global class UncheckPurchaseLast120Helper 
{
	

	public static void sortContacts(List<Contact> conts)
	{
		Map<Contact, List<Purchase__c>> contPurchMap = new Map<Contact, List<Purchase__c>>();
		List<Contact> contsToUpdate = new List<Contact>();
		
		for(Contact cont : conts)
		{
			List<Purchase__c> purchs =
			[
			SELECT Id,
			ATC_Sale_Date__c,
			Private_Label__c
			FROM Purchase__c
			WHERE ATC_Buyer_Contact__r.Id = :cont.Id
			];
			
			//Logger.info(cont, 'Purchases mapped to Contact: ' + cont);
			contPurchMap.put(cont, purchs);
			
		}
		
		for(Contact cont : conts)
		{
	      	Boolean updateContCA = false;
	      	Boolean updateContUS = false;
			if(cont.Openlane_CA_Purchase_Last_120__c == true)
			{
				//Logger.info(cont, 'Contact being checked for CA Purchases: ' + cont);
				updateContCA = checkCAPurchases(cont, contPurchMap.get(cont));				
			}
			
			if(cont.Openlane_US_Purchase_Last_120__c == true)
			{
				//Logger.info(cont, 'Contact being checked for US Purchases: ' + cont);
				updateContUS = checkUSPurchases(cont, contPurchMap.get(cont));				
			}
			
			if(updateContCA == true || updateContUS == true)
			{
				//Logger.info(cont, 'Contact will be updated: ' + cont);
				contsToUpdate.add(cont);
			}
		}
	 
		if (contsToUpdate.size() > 0)
		{
    		Database.update(contsToUpdate);
    	}
	}
	
	
	public static Boolean checkCAPurchases(Contact cont, List<Purchase__c> purchs)
	{	
		if(purchs != null)
		{		
			for(Purchase__c purch : purchs)
			{
				//Logger.info(purch, 'Purchase PL: ' +purch.Private_Label__c+ ' and Sale Date: '+ purch.ATC_Sale_Date__c);
				if(purch.Private_Label__c == 'OPENLANE.ca Open Auction'
					&& purch.ATC_Sale_Date__c > (system.today() - 120))
					{
						//Logger.info(purch, 'Purchase was new, breaking...' + purch);
						return false;
					}
			}
		}	

		//Logger.info(cont, 'Purchase was old, unchecking...' + cont);
		cont.Openlane_CA_Purchase_Last_120__c = false;
		return true;

	}
	
	public static Boolean checkUSPurchases(Contact cont, List<Purchase__c> purchs)
	{	
		if(purchs != null)
		{	
			for(Purchase__c purch : purchs)
			{
				//Logger.info(purch, 'Purchase PL: ' +purch.Private_Label__c+ ' and Sale Date: '+ purch.ATC_Sale_Date__c);
				if(purch.Private_Label__c == 'OPENLANE Auction'
					&& purch.ATC_Sale_Date__c > (system.today() - 120))
					{
						//Logger.info(purch, 'Purchase was new, breaking...' + purch);
						return false;
					}
			}
		}	

		
		//Logger.info(cont, 'Purchase was old, unchecking...' + cont);
		cont.Openlane_US_Purchase_Last_120__c = false;
		return true;
		
	}
	
}