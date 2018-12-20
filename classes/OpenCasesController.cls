public class OpenCasesController 
{
	public PageReference redirect()
	{
		ID currentProfileId = UserInfo.getProfileId();
		ID sellerPortalProfileId = Utils.getProperty('portalutils.seller.profile.id');
		if (currentProfileId == sellerPortalProfileId)
		{
			return Page.open_case_escalations;
		}
		
		return new PageReference(Utils.getProperty('open.cases.listview'));
	}
}