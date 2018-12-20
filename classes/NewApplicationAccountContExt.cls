public with sharing class NewApplicationAccountContExt
{
	private ApexPages.StandardController stdCont;
	private Application_Account_Role__c record;
	public boolean showPage {get; private set;}
	
	public NewApplicationAccountContExt(ApexPages.StandardController stdCont)
	{
		this.stdCont = stdCont;
		this.record = (Application_Account_Role__c)this.stdCont.getRecord();
	}
	public PageReference saveAccount()
	{
		PageReference pageRef = this.stdCont.save();
		if(pageRef != null)
		{
			Id aarId = this.stdCont.getId();
			return new PageReference('/flow/Create_Business_Account_Checklists?varAFCBusinessAccountId='+aarId+'&retURL=/'+aarId);
		}
		else
		{
			return pageref;
		}
		
		/*
		this.stdCont.save();
		
		Id aarId = this.stdCont.getId();
		return new PageReference('/flow/Create_Business_Account_Checklists?varAFCBusinessAccountId='+aarId+'&retURL=/'+aarId);
		*/			
	}
}