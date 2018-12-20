trigger CollectionLineItemDaysOverdue on Collection_Line_Item__c (before insert, before update) {
	for (Collection_Line_Item__c cli : Trigger.new) {
		if (cli.Due_Date__c == null) {
			// Do nothing
		} else if(cli.Clear_Date__c == null) {
			cli.Days_Overdue__c = cli.Due_Date__c.daysBetween(System.today());
		} else { 
			cli.Days_Overdue__c = cli.Due_Date__c.daysBetween(cli.Clear_Date__c);
		}
	}
}