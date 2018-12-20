trigger livehelp on Case (before insert) 
{
    Map<String, Id> ownerUser = new Map<String, Id>();
    Id casRecordTyepeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IAA Buyer Services').getRecordTypeId();


    for(Case record :Trigger.new)
    {
        // S-444999 and T-570979
        if(record.recordTypeId == casRecordTyepeId) //check for case Record type == "IAA Buyer Services"
        {
            ownerUser.put(record.Case_owner__c, null);
        }

    }
    for(User record:[select Name 
    				 From User 
    				 Where Name IN :ownerUser.keySet()])
    {
    	ownerUser.put(record.Name, record.Id);
    }
    for(Case record : Trigger.new)
    {
    	if(ownerUser.get(record.Case_owner__c) != null)
    	{
    		record.OwnerId = ownerUser.get(record.Case_owner__c);
    	}
    }
}