public class TestSetPercentCompleteTrigger {
	
	static testMethod void testHundredPercent() {
		Survey__c survey = new Survey__c();
		
		survey.DP_1__c = 'Independent';
		survey.DP_2__c = 'Yes';
		survey.DP_2a__c = 'Sonic';
		survey.DP_3__c = 'www.thisistestdata.com';
		survey.DP_4__c = 'test';
		survey.DP_5c__c = 'test';
		survey.DP_5f__c = 'test';
		survey.DP_5i__c = 'test';
		survey.DP_5j__c = 'test';
		survey.DP_6__c = 'test';
		survey.DP_6a__c = 'test';
		survey.DP_7__c = 'test';
		survey.DP_7a__c = 'test';
		survey.DP_8__c = 'test';
		survey.DP_9c__c = 'test';
		survey.DP_9f__c = 'test';
		survey.DP_9i__c = 'test';
		survey.DP_9j__c = 'test';
		survey.DP_10__c = 'test';
		survey.DP_11__c = 'test';
		survey.DP_12__c = 'test';
		survey.DP_13__c = 'test';
		survey.DP_14__c = 'test';
		survey.DP_15__c = 'test';
		survey.DP_16__c = 'test';
		survey.DP_17__c = 'test';
		survey.DP_17a__c = 'test';
		survey.DP_17b__c = 'test';
		survey.DP_17c__c = '650-458-5555';
		survey.DP_18__c = 'test';
		survey.DP_19__c = 'test';
		survey.DP_20__c = 'test';
		survey.DP_21__c = 'test';
		survey.DP_22__c = 'test';
		survey.DP_23__c = 'test';
		survey.DP_23a__c = 'test';
		survey.DP_24a__c = 'test';
		survey.DP_24b__c = 'test';
		survey.DP_24c__c = 'test';
		survey.DP_24d__c = 'test';
		survey.DP_24e__c = 'test';
		
		insert survey;
		
		/* FIXME
		Survey__c survey2 = [select Percent_Complete__c from Survey__c where Id = :survey.Id];
		Decimal result = Decimal.valueOf(survey2.Percent_Complete__c).round();
		System.assertEquals(51, result);
		*/
		
	}
}