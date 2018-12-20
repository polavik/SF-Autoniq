/* 
*************************************************************************************************************
** Created By:    Justin Hawkins
*
** Created Date:  08/08/2017
*
** Class Purpose: Batch class intended to be executed during Sandbox refreshes.  This class will 
**                take an object query and field name and turn any full URLs for the given field into
**                relative URLs.  This will clean up any URLs fields that have been entered into production
**                with reference to the production Salesforce instance and make them usable in the Sandbox
**
*************************************************************************************************************
*/
global class BatchSandboxRefreshHelperHubUrlCleanup implements Database.Batchable<sObject> {
	
	global final String query;
	global final String fieldToUpdate;
	
	global BatchSandboxRefreshHelperHubUrlCleanup(String q, String f) {

		query = q;
		fieldToUpdate = f;		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {

		try
		{
			List<sObject> objectsToUpdate = new List<sObject>();
		
			for(sObject s : scope)
			{
				String url = (String)s.get(fieldToUpdate);
				if(String.isBlank(url) 
					|| url.indexOfIgnoreCase('/apex') == -1 
					|| url.indexOfIgnoreCase('/apex') == 0) continue;

				String refUrl = url.substring(url.indexOfIgnoreCase('/apex'));

				url = (String)s.put(fieldToUpdate, refUrl);

				objectsToUpdate.add(s);
			}

			Database.SaveResult[] list_sr = database.update(objectsToUpdate, false);

			for(Database.SaveResult sr : list_sr)
			{
				if(!sr.isSuccess())
				{
					for(Database.Error err : sr.getErrors())
					{
						System.debug('### BatchSandboxRefreshHelperHubUrlCleanup DML Error ###');
						System.debug(err.getStatusCode() + ': ' + err.getMessage());
					}
				}
			}
		}
		catch(Exception e)
		{
			System.debug('### BatchSandboxRefreshHelperHubUrlCleanup Exception ###');
			System.debug(e.getMessage());
		}
	
	}
	
	global void finish(Database.BatchableContext BC) {
		// Nothing to do here, continue on...
	}
	
}