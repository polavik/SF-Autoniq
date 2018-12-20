public class SellerPortalConfigHelper 
{
	// Format: AccountId -> Private Label (Name) -> Seller_Portal_Config__c
	private static Map<ID, Map<String, Seller_Portal_Config__c>> sellerPortalConfigMap = null;
	
	private static void loadConfigs()
	{
		sellerPortalConfigMap = new Map<ID, Map<String, Seller_Portal_Config__c>>();
		List<Seller_Portal_Config__c> allSellerPortalConfigs = 
		[
			SELECT 
				Edit_Case_Comments__c,
				Edit_Case_Status__c, 
				Escalate_On__c, 
				Internal_Owner__c, 
				Private_Label__c, 
				Seller_Account__c,
				Send_Comment_Notifications__c
			FROM Seller_Portal_Config__c
		];
		for (Seller_Portal_Config__c spc : allSellerPortalConfigs)
		{
			if (spc.Seller_Account__c != null && spc.Private_Label__c != null)
			{
				String upcasePrivateLabel = spc.Private_Label__c.toUpperCase();
				Map<String, Seller_Portal_Config__c> plMap = 
					sellerPortalConfigMap.get(spc.Seller_Account__c);
				if (plMap == null)
				{
					plMap = new Map<String, Seller_Portal_Config__c>();
					sellerPortalConfigMap.put(spc.Seller_Account__c, plMap);
				}
				plMap.put(upcasePrivateLabel, spc);
				System.debug('Seller Portal Config Loaded: ' + spc);
			}
			else
			{
				System.debug('Invalid Seller_Portal_Config__c: ' + spc);
			}
		}
	}
	
	public static Seller_Portal_Config__c getSellerPortalConfig(String sellerId, String privateLabel)
	{
		Seller_Portal_Config__c spc = null;		
		if (sellerId == null || privateLabel == null)
		{
			return spc;
		}
		
		if (sellerPortalConfigMap == null)
		{
			loadConfigs();
		}
		
		Map<String, Seller_Portal_Config__c> plMap = sellerPortalConfigMap.get(sellerId);
		if (plMap != null)
		{
			spc = plMap.get(privateLabel.toUpperCase());
		}
		
		return spc;
	}
}