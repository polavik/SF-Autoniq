public class ActionPkgDistributionListHelper 
{
	private static List<Action_Pkg_Distribution_List__c> allDistributions;
	
	public static List<Action_Pkg_Distribution_List__c> 
	getDistributions(String country, String cgc, String packageType, Long transportCancelled, String handlesTitle)
	{
		List<Action_Pkg_Distribution_List__c> results = new List<Action_Pkg_Distribution_List__c>();
		if (allDistributions == null)
		{
			populateAllDistributions();
		}
		for (Action_Pkg_Distribution_List__c dist : allDistributions)
		{
			if (match(dist, country, cgc, packageType, transportCancelled, handlesTitle))
			{
				results.add(dist);
			}
		}
		return results;
	}
	
	private static boolean match(Action_Pkg_Distribution_List__c dist, 
		String country, String cgc, String packageType, Long transportCancelled, String handlesTitle)
	{
		if (dist.Countries__c != null &&
			(country == null || !dist.Countries__c.toUpperCase().contains(country.toUpperCase())))
		{
			return false;
		}
			
		if (dist.Car_Group_Config_Ids__c != null &&
			(cgc == null || !dist.Car_Group_Config_Ids__c.contains(cgc)))
		{
			return false;
		}
		
		if (dist.Package_Types__c != null &&
			(packageType == null || !dist.Package_Types__c.toUpperCase().contains(packageType.toUpperCase())))
		{
			return false;
		}
		
		if (dist.Includes_Transport__c != null &&
			(transportCancelled == null || dist.Includes_Transport__c != transportCancelled))
		{
			return false;
		}
		
		if (dist.Handles_Title__c != null &&
			(handlesTitle == null || !dist.Handles_Title__c.toUpperCase().contains(handlesTitle.toUpperCase())))
		{
			return false;
		}
		return true;
	}
	
	private static void populateAllDistributions()
	{
		allDistributions = 
		[
			SELECT Email__c, Send_Attachments__c, Countries__c, Car_Group_Config_Ids__c,
				Package_Types__c, Includes_Transport__c, Handles_Title__c
			FROM Action_Pkg_Distribution_List__c
		];
	}
	
}