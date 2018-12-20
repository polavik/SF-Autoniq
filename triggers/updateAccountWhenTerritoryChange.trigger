trigger updateAccountWhenTerritoryChange on Territory__c (after insert, after update) {
    Set<String> territoryZipSet = new Set<String>();
    Set<Id> territoryIdSet = new Set<Id>();
    

    for(Territory__c zipTer:Trigger.new){

        if(zipTer.Zipcode__c != null){//US Zip
            if(zipTer.Zipcode__c.length() >= 5)
            {
                territoryZipSet.add(zipTer.Zipcode__c);
                territoryIdSet.add(zipTer.Id); 
            }
        }  
        
        
    }   


    
    AccountTerritoryUpdateHelper.updateAccounts(territoryIdSet, territoryZipSet);
        
    
}