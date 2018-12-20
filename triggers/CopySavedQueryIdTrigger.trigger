trigger CopySavedQueryIdTrigger on sma__MALog__c (before insert) {
    
    for (sma__MALog__c log : trigger.new)
    {
        if (log.Name == 'Saved Query View' && log.sma__Details__c  != null)
        {
            try
            {
                log.MASavedQuery__c = log.sma__Details__c;
            }
            catch (Exception e)
            {
            
            }
        }
    }
    
}