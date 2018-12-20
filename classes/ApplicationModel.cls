public with sharing class ApplicationModel
{
	public ApplicationModel(Application__c app)
	{
		this.record = app;
		if(isExisting)
		{
			accounts = record.Application_Account_Roles__r;
			contacts = record.Application_Contact_Roles__r;
		}
		else
		{
			accounts = new Application_Account_Role__c[]{};
			contacts = new Application_Contact_Role__c[]{};
		}
	}
	public Application__c record {get; private set;}
    public Boolean isExisting {get{return this.record != null && this.record.Id != null;}}
    public Application_Account_Role__c[] accounts {get; private set;}
    public Application_Contact_Role__c[] contacts {get; private set;}
}