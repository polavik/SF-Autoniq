global class BatchUncheckPurchaseLast120 implements Database.Batchable<SObject>, Database.Stateful, Schedulable
{
//Batch job that checks Contacts for an OA or OACA purchase int he last 120 days.
//Unchecks boxes on Contacts if no purchases made

//Query used for the getQueryLocator
	public String query = 
		'SELECT Id, Openlane_CA_Purchase_Last_120__c, Openlane_US_Purchase_Last_120__c ' + 
		'FROM Contact ' +
		'WHERE Openlane_CA_Purchase_Last_120__c = true OR Openlane_US_Purchase_Last_120__c = true ';

//First the Scheduler calls our job and 'execute' is performed
	global void execute(SchedulableContext sc) 
	{
		BatchUncheckPurchaseLast120 proc = new BatchUncheckPurchaseLast120();
		Database.executeBatch(proc, 1);  //Not sure why '1' was specified
	}
	
//Next the job starts which takes our above query and sends it to the next 'execute' method
	global Database.QueryLocator start(Database.BatchableContext bc) 
	{
		return Database.getQueryLocator(query); 
	} 

//This execute method will use the results from the query we passed it to uncheck the boxes for this story		
	global void execute(Database.BatchableContext bc, List<SObject> scope) 
	{
		List<Contact> contsToProcess = (List<Contact>) scope;
		
		UncheckPurchaseLast120Helper.sortContacts(contsToProcess);
		
		
		
		/*List<Contact> contsUS = new List<Contact>();
		List<Contact> contsCA = new List<Contact>();
		
		for (Contact cont : contsToProcess)
		{
			if(cont.Openlane_CA_Purchase_Last_120__c == true)
			{
				contsCA.add(cont);
			}
			
			if(cont.Openlane_US_Purchase_Last_120__c == true)
			{
				contsUS.add(cont);
			}
		}

	UncheckPurchaseLast120Helper.checkCAPurchases(contsCA);
	UncheckPurchaseLast120Helper.checkUSPurchases(contsUS);*/
		
		Logger.flush();
	}
	
    global void finish(Database.BatchableContext bc) 
    {
    }
    
}