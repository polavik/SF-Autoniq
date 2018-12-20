trigger CollectionSetAccount on Collection__c (after insert) {
	List<String> acctIds = new List<String>();
	
	for (Collection__c coll : Trigger.new) {
		acctIds.add(coll.Account__c);
	}
							 
	Map<ID, Account> acctMap = new Map<ID, Account>(
		[select Id, Collection__c
		 from Account 
		 where Id in :acctIds]);
	
	for (Collection__c coll : Trigger.new) {
		Account acct = acctMap.get(coll.Account__c);
		acct.Collection__c = coll.Id;	
	}
	
	update acctMap.values();
}