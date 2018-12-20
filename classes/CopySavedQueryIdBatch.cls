global class CopySavedQueryIdBatch implements Database.Batchable<sObject>
{
    //database.executebatch(new CopySavedQueryIdBatch(),100);

    global CopySavedQueryIdBatch()
    {
        
    }

    global database.querylocator start(Database.BatchableContext BC)
    {
        
        return Database.getQueryLocator([SELECT Id,sma__Details__c FROM sma__MALog__c WHERE  MASavedQuery__c=null AND Name='Saved Query View'] );
    }

    global void execute(Database.BatchableContext BC, List<sma__MALog__c > scope)
    {
        set<string> SavedQueryIds = new set<string>();
        
        //Populate
        for (sma__MALog__c log : scope)
        {
            if (log.sma__Details__c !=null)
            {
                SavedQueryIds.add(log.sma__Details__c );
            }
        }
        
        
        set<Id> VerifiedSavedQueryIds = new set<Id>();
        
        //Check if they exists
        for (sma__MASavedQry__c obj : [SELECT Id FROM sma__MASavedQry__c  WHERE Id IN :SavedQueryIds])
        {
            VerifiedSavedQueryIds.add(obj.Id);
        }
        
        
        list<sma__MALog__c> LogsToUpdate = new list<sma__MALog__c>();
        
        //Populate Lookup Field
		Set<String> ListFLSUpdate = new Set<String>();
		Boolean blnFLSOverride = Utils.GetFLS();
        for (sma__MALog__c log : scope)
        {
            if (VerifiedSavedQueryIds.contains(log.sma__Details__c))
            {
				//Story B-44003 : FLS UPDATE ACCESS CHECK
				 if (Schema.sObjectType.sma__MALog__c.fields.MASavedQuery__c.isUpdateable() || blnFLSOverride)
				 {						 
					log.MASavedQuery__c = log.sma__Details__c;
				 }
				 else
				 {						
					ListFLSUpdate.add(Schema.sObjectType.sma__MALog__c.getName()+'.'+Schema.sObjectType.sma__MALog__c.fields.MASavedQuery__c.getName());
				 }
				 
                LogsToUpdate.add(log);
            }
        }
		if(ListFLSUpdate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_UPDATE','CLASS:CopySavedQueryIdBatch', ListFLSUpdate);
		}
        
        //Update Records
        if (LogsToUpdate.size() > 0)
        {
            update LogsToUpdate;
        }
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
    
}