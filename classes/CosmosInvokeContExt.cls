public with sharing class CosmosInvokeContExt 
{
    private AFC_Contract_Shell__c contractRecord;
    private Application_Account_Role__c aarRecord;
    private ApexPages.StandardController stdCont;
    public Boolean invoke {get; private set;}
    public CosmosInvokeContExt(ApexPages.StandardController stdCont)
    {
        this.stdCont = stdCont;
        this.contractRecord = (AFC_Contract_Shell__c)stdCont.getRecord();
        try
        {
            this.aarRecord = ApplicationAccountRoleServices.getApplicationAccountRole(this.contractRecord.Account__c, this.contractRecord.Application__c);
            invoke = true;
        }
        catch(Exception e)
        {
            ControllerServices.displayExceptionAsMessage(e, BWAppsConfigModel.enableStackTrace);
            invoke = false;
        }
    }
    public void cosmosInvoke()
    {
        try
        {
            
            IHubWebServices.cosmosInvoke(this.contractRecord, this.aarRecord);
            //Save contract with newly updated Master Contract ID
            contractRecord.Last_Synced_Date__c = Datetime.now();
            stdCont.save();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Success'));
        }
        catch(Exception e)
        {
            ControllerServices.displayExceptionAsMessage(e, BWAppsConfigModel.enableStackTrace);
        }
    }
}