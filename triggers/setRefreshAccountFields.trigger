trigger setRefreshAccountFields on AFC_Contracts__c(After insert, After update) {   

    Set<Id> accountIds = new Set<Id>();

    // Find out how many contracts have just now been maked as PLN__c = true
    for(AFC_Contracts__c contract: Trigger.new) {
        if(contract.PLN__c == true && Trigger.oldMap.get(contract.id) != null && Trigger.oldMap.get(contract.id).PLN__c == false){       
            accountIds.add(contract.Account__c);
        }
    }

    // If there are any newly marked PLNs, update their Accounts as PLN__c = true;
    if(accountIds.size() > 0){
        List<Account> accounts = [select Id, PLN__c from Account where Id in :accountIds];
        for(Account a: accounts) {
            a.PLN__c = true;
        }    

        update accounts;    
    } 
}