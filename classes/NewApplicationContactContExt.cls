/*
Original Author: ?
Editor: Pike Pullen
Date: 10/30/2013
Description: There is currently no way to write a test method that directly tests the addfields method for standardController, added workaround (L.14)
*/
public with sharing class NewApplicationContactContExt
{
	private ApexPages.StandardController stdCont;
	private Application_Contact_Role__c record;
    public NewApplicationContactContExt(ApexPages.StandardController stdCont)
    {
		this.stdCont = stdCont;
		if (!Test.isRunningTest()) 
		{ 
			this.stdCont.addFields(new String[]{'Contact__r.Nick_Name__c','Contact__r.Name'});
		}
		this.record = (Application_Contact_Role__c)this.stdCont.getRecord();
	}
	public PageReference saveContact()
	{
		PageReference pageRef = this.stdCont.save();
		if(pageRef != null)
		{
			system.debug('System Test Success');
			this.assignContractName();
			this.stdCont.save();
	
			Id acrId = this.stdCont.getId();
			return new PageReference('/flow/Create_Principal_Contact_Checklists?varPrincipalContactId='+acrId+'&retURL=/'+acrId);
		}
		else
		{
			return pageref;
		}
	}
	private void assignContractName()
	{
		if(record.Show_on_Contract__c == 'Name')
			record.Contract_Name__c = record.Contact__r.Name;
		else if(record.Show_on_Contract__c == 'Nickname')
			record.Contract_Name__c = record.Contact__r.Nick_Name__c;
		else if(String.isBlank(record.Show_on_Contract__c))
			record.Contract_Name__c = '';
	}
}