trigger setPercentComplete on Survey__c (before insert, before update) {
	
	RecordType dpRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Survey__c' AND Name = 'Dealer Profile'];
	
	for (Survey__c survey : Trigger.new) {
		
		Integer answered = 0;
		
		if (survey.RecordTypeId != dpRecordType.Id) {
			survey.Percent_Complete__c = null;
			return;
		}
			
		if (survey.DP_1__c != null) answered++;
		if (survey.DP_2__c != null) answered++;
		if (survey.DP_2a__c != null) answered++;
		if (survey.DP_2b__c != null) answered++;
		if (survey.DP_3__c != null) answered++;
		if (survey.DP_4__c != null) answered++;
		if (survey.DP_4a_1_1__c != null) answered++;
		if (survey.DP_4a_1_2__c != null) answered++;
		if (survey.DP_4a_1_3__c != null) answered++;
		if (survey.DP_5a__c != null) answered++;
		if (survey.DP_5b__c != null) answered++;
		if (survey.DP_5c__c != null) answered++;
		if (survey.DP_5d__c != null) answered++;
		if (survey.DP_5e__c != null) answered++;
		if (survey.DP_5f__c != null) answered++;
		if (survey.DP_5g__c != null) answered++;
		if (survey.DP_5h__c != null) answered++;
		if (survey.DP_5i__c != null) answered++;
		if (survey.DP_5j__c != null) answered++;
		if (survey.DP_6__c != null) answered++;
		if (survey.DP_6a__c != null) answered++;
		if (survey.DP_7__c != null) answered++;
		if (survey.DP_7a__c != null) answered++;
		if (survey.DP_8__c != null) answered++;
		if (survey.DP_9a__c != null) answered++;
		if (survey.DP_9b__c != null) answered++;
		if (survey.DP_9c__c != null) answered++;
		if (survey.DP_9d__c != null) answered++;
		if (survey.DP_9e__c != null) answered++;
		if (survey.DP_9f__c != null) answered++;
		if (survey.DP_9g__c != null) answered++;
		if (survey.DP_9h__c != null) answered++;
		if (survey.DP_9i__c != null) answered++;
		if (survey.DP_9j__c != null) answered++;
		if (survey.DP_10__c != null) answered++;
		if (survey.DP_11__c != null) answered++;
		if (survey.DP_12__c != null) answered++;
		if (survey.DP_13__c != null) answered++;
		if (survey.DP_14__c != null) answered++;
		if (survey.DP_15__c != null) answered++;
		if (survey.DP_16__c != null) answered++;
		if (survey.DP_17__c != null) answered++;
		if (survey.DP_17a__c != null) answered++;
		if (survey.DP_17b__c != null) answered++;
		if (survey.DP_17c__c != null) answered++;
		if (survey.DP_18__c != null) answered++;
		if (survey.DP_19__c != null) answered++;
		if (survey.DP_20__c != null) answered++;
		if (survey.DP_21__c != null) answered++;
		if (survey.DP_22__c != null) answered++;
		if (survey.DP_23__c != null) answered++;
		if (survey.DP_23a__c != null) answered++;
		if (survey.DP_24a__c != null) answered++;
		if (survey.DP_24b__c != null) answered++;
		if (survey.DP_24c__c != null) answered++;
		if (survey.DP_24d__c != null) answered++;
		if (survey.DP_24e__c != null) answered++;
		if (survey.DP_24f__c != null) answered++;
		if (survey.DP_24g__c != null) answered++;
		if (survey.DP_25__c != null) answered++;
		if (survey.DP_26__c != null) answered++;
		if (survey.DP_27__c != null) answered++;
		if (survey.DP_27a__c != null) answered++;
		if (survey.DP_28__c != null) answered++;
		if (survey.DP_29__c != null) answered++;
		if (survey.DP_29a__c != null) answered++;
		if (survey.DP_30__c != null) answered++;
		if (survey.DP_31__c != null) answered++;
		if (survey.DP_31a__c != null) answered++;
		if (survey.DP_32__c != null) answered++;
		if (survey.DP_33__c != null) answered++;
		if (survey.DP_33a__c != null) answered++;
		if (survey.DP_33b__c != null) answered++;
		if (survey.DP_33c__c != null) answered++;
		if (survey.DP_34__c != null) answered++;
		if (survey.DP_34a__c != null) answered++;
		if (survey.DP_34b__c != null) answered++;
		if (survey.DP_35__c != null) answered++;
		if (survey.DP_35a__c != null) answered++;
		if (survey.DP_36__c != null) answered++;
		if (survey.DP_36a__c != null) answered++;
		if (survey.DP_37__c != null) answered++;
		if (survey.DP_37a__c != null) answered++;
		
		survey.Percent_Complete__c = (answered/83.0) * 100;
		
		
	}
}