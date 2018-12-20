trigger ApplicationTrigger on Application__c (before insert, before update, after insert, after update)
{
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
    {
        //Attach Applications to their Contracts
        Map<String, Application__c> contractIDAppMap = new Map<String, Application__c>();

        for(Application__c app : Trigger.new)
        {
            if(app.Contract_ID__c != null)
            {
                    contractIDAppMap.put(app.Contract_ID__c, app);
            }
        }

        List<AFC_Contracts__c> contracts =
        [
                  select Id, Contract_ID__c
                    from AFC_Contracts__c
                   where Contract_ID__c in :contractIDAppMap.keySet()
        ];

        for(String contId : contractIDAppMap.keySet())
        {
            for(AFC_Contracts__c cont : contracts)
            {
                if(contId == cont.Contract_ID__c)
                {
                    contractIDAppMap.get(contId).AFC_Contract_Number__c = cont.ID;
                }
            }
        }
    }

    if(Trigger.isBefore && Trigger.isUpdate)
    {
        ApplicationServices.deleteInProgressApplications(Trigger.new);
    }
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
    {
        ApplicationServices.updateBranchNumber(Trigger.new);
    }
    if(Trigger.isAfter && Trigger.isInsert && Trigger.size == 1)
    {
        ApplicationServices.updateCreditAndCTUserLookups(Trigger.new[0]);
    }
    if(Trigger.isAfter && Trigger.isUpdate )
    {
        ApplicationServices.processApplications(Trigger.new, Trigger.oldMap);
    }

}