trigger MarketingAttributeTrigger on Marketing_Attribute__c (after insert, after update, after delete) {
	if (Trigger.isAfter) {
		Map<Id, List<Marketing_Attribute__c>> triggerMap = 
			MarketingAttributeServices.groupByApplication(Trigger.isDelete ? trigger.old : trigger.new);
		if (Trigger.isInsert || Trigger.isDelete || Trigger.isUndelete) {
			Set<Id> appsFilteredOut = new Set<Id>();
			for (Id appId : triggerMap.keySet()) {
				if (MarketingAttributeServices.filterMarketingAttributes(triggerMap.get(appId)))
					appsFilteredOut.add(appId);
			}
			for (Id appId : appsFilteredOut) {
				triggerMap.remove(appId);
			}
		} 
		if (!triggerMap.isEmpty()) {
			List<Application__c> appsToUpdate = MarketingAttributeServices.processMarketingAttributes(triggerMap);
			System.debug('^^^MAs to Update : ' + appsToUpdate);
			MarketingAttributeServices.updateApplications (appsToUpdate, triggerMap);
		}
	}
}