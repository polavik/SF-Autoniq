Public class MapGuestBuyerLeadsClass  {
public static void MapRegistrantID(set<Id> LeadIDs)
{
    system.debug('leadids:'+leadIDs);
    
    //Declartion
    set<String> AcctID = new set<String>();
    Map<Id,string> GetRegistrantMap = new Map<Id,string>();
    try
    {
        for(Lead GetLeads: [SELECT convertedaccountid, RegistrantID__c 
                            FROM Lead 
                            WHERE Buyer_ID__c != null 
                            and RegistrantID__c !=null 
                            and id in :LeadIDs 
                            and isConverted = true and convertedaccountid !=null])
        {                    
               GetRegistrantMap.put(getleads.convertedaccountid,GetLeads.RegistrantID__c);
               AcctID.add(getleads.convertedaccountid);
        }
    } catch (exception e)
        {
        System.debug('Error on while mapping Lead & AccountREgistrant id:'+e.getMessage());
    }

    List<Account> Acct = [select id,Registrant_ID__c, buyer_id__c 
                          from Account 
                          where id in : AcctID];
    try
    {
        if (Acct.size()>0)
        {
        for(Account GetAcct : Acct)
        {
        system.debug('inside loop 1');
        
          if(getAcct.Registrant_ID__c == null)
          {
          system.debug('inside loop 2');
                if(GetRegistrantMap.containsKey(GetAcct.ID))
                {
                system.debug('inside loop 3');
                   getAcct.Registrant_ID__c = GetRegistrantMap.get(getAcct.ID);
                   
                 }
                 system.debug('getAcct.Registrant_ID__c:'+getAcct.Registrant_ID__c);
        }
        }
        }
    } catch(exception ME)
    {
    system.debug('Error while Mapping registrant id in Account:'+ ME.getMessage());
    }
    
    //Update the regisrant ID in Account if its Null
    try
    {
    update Acct;
    }catch(DMLException DM)
    {
    System.debug('Error while updating converted accounts:'+ DM.getMessage());
    }
}
}