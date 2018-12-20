/*

*/
trigger CollectionCallLineItems on Collection_Call__c (after insert) {
	
	List<ID> collectionIds = new List<ID>();
	for (Collection_Call__c cc : Trigger.new) {
		if (cc.Collection__c != null) {
			collectionIds.add(cc.Collection__c);
		}
	}
	
	Integer dmlLimit = 95 * collectionIds.size();
	
	// Pull down all open Line Items for each Collection in Trigger.new
	List<Collection_Line_Item__c> allLineItems = 
		[select Id, convertCurrency(Amount__c), Collection__c, Due_Date__c, Clear_Date__c, Days_Overdue__c, CRUD__c
		 from Collection_Line_Item__c
		 where Collection__c in :collectionIds
		 and Clear_Date__c = null
		 and CRUD__c = false
		 order by Days_Overdue__c
		 limit :dmlLimit];
		 
	// Sort Line Items by Collection Id
	Map<ID, List<Collection_Line_Item__c>> lineItemsByCollId = new Map<ID, List<Collection_Line_Item__c>>();
	for (Collection_Line_Item__c li : allLineItems) {
		List<Collection_Line_Item__c> lineItemGroup = lineItemsByCollId.get(li.Collection__c);
		if (lineItemGroup == null) {
			lineItemGroup = new List<Collection_Line_Item__c>();
			lineItemsByCollId.put(li.Collection__c, lineItemGroup);
		}
		lineItemGroup.add(li);
	}
	
	// Create "Collection Call Line Items", add to Collection Calls
	List<Collection_Call_Line_Item__c> ccLineItems = new List<Collection_Call_Line_Item__c>();
	for (Collection_Call__c cc : Trigger.new) {
		List<Collection_Line_Item__c> lineItems = lineItemsByCollId.get(cc.Collection__c);
		if (lineItems != null) {
			for (Collection_Line_Item__c li : lineItems) {
				Collection_Call_Line_Item__c ccli = new Collection_Call_Line_Item__c();
				ccli.Collection_Call__c = cc.Id;
				ccli.Line_Item__c = li.Id;
				ccli.TOC_Amount__c = li.Amount__c;
				ccli.TOC_Days_Overdue__c = li.Days_Overdue__c;
				ccli.TOC_Due_Date__c = li.Due_Date__c;
				ccLineItems.add(ccli);
			}
		}
	}
	
	// Insert new Collection Line Items in blocks of 200
	for (Integer i = 0; i < ccLineItems.size(); i+=200) {
		Integer upperBound = Math.min(i + 200, ccLineItems.size());
		List<Collection_Call_Line_Item__c> block = new List<Collection_Call_Line_Item__c>();
		for (Integer j = i; j < upperBound; j++) {
			 block.add(ccLineItems.get(j));
		}
		insert block;
	}
}