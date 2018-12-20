public with sharing class CloneApplicationContExt {

	private string controllerId {get;set;}
	public Application__c approvedApp {get;set;}
	public string cloneParentId {get;set;}
	public string sObjectParentQuery {get;set;}
	public list<string> sObjectChildQuery {get;set;} 
	
	public CloneApplicationContExt(ApexPages.StandardController controller)
	{
		controllerId = controller.getId();
		string appStatus = 'APPROVED';
		
		approvedApp = new Application__c();
        try
        {
			approvedApp = CloneApplicationServices.cloneRecord(controllerId, appStatus);
			
			if(approvedApp != null && approvedApp.Id != null)
			{ 
				//get parent object
				//string contId = id.valueOf(controller.getId()).getSObjectType().getDescribe().getName();
				string appName = id.valueOf(approvedApp.Id).getSObjectType().getDescribe().getName();
				
				//get parent fields
				list<string> sObjectParentFields = CloneApplicationServices.parentFields(approvedApp, appName);
				
				//build parent query
				sObjectParentQuery = CloneApplicationServices.buildParentQuery(sObjectParentFields, appName, approvedApp.Id); 
				
				//get child objects and fields
				map<string,list<string>> sObjectChildParameters = CloneApplicationServices.childFields();
				
				//build child queries
				sObjectChildQuery = CloneApplicationServices.buildChildQuery(sObjectChildParameters, approvedApp.Id);
			}
        }
        catch(Exception e)
        {
        	ControllerServices.displayExceptionAsMessage(e, BWAppsConfigModel.enableStackTrace);
        }
	}
	
	public PageReference runQuery()
	{
		if(approvedApp != null && approvedApp.Id != null)
		{
			try
			{
				//generate and insert parent query
				cloneParentId = CloneApplicationServices.startParentClone(sObjectParentQuery);	 
				
				//generate and insert child queries
				CloneApplicationServices.startChildClone(sObjectChildQuery, cloneParentId);	 
	
				PageReference pageRef = new PageReference('/' + approvedApp.AFC_Contract_Number__c);
				pageRef.setRedirect(true);
				return pageRef;
			}
	        catch(Exception e)
	        {
	            ControllerServices.displayExceptionAsMessage(e, BWAppsConfigModel.enableStackTrace);
	            return null;
	        }
		}
		else
		{
			PageReference pageRef = new PageReference('/' + controllerId);
			pageRef.setRedirect(true);
			return pageRef;
		}
	}
}