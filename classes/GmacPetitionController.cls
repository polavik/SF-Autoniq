public class GmacPetitionController 
{

	public GMAC_Floorplan_Petition__c petition {get; set;}
	public boolean isValid {get; set;}

	public GmacPetitionController()
	{
		petition = new GMAC_Floorplan_Petition__c();
		isValid = true;	
	}
	
	public PageReference submit()
	{
		try
		{
			insert petition;
		}
		catch (Exception e)
		{
			isValid = false;
			return null;
		}
		
		return Page.thank_you;
	}
	
	

}