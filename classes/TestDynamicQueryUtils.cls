@isTest
private class TestDynamicQueryUtils {
	static testMethod void getDynamicQuery_NoFields(){

		Test.startTest();
			try{
				DynamicQueryUtils.getDynamicQuery('Application__c', new Set<String>(), new Set<String>(), new Application__c());
				System.assert(false, 'An exception should be thrown');
			} catch (DynamicQueryUtils.DynamicQueryException e){
				//
			}
		Test.stopTest();
	}

	static testMethod void getDynamicQuery(){
		final String TEXT_FIELD_NAME='Name';
		final String TEXT_FIELD_VALUE='Test';
		final String LOOKUP_FIELD_NAME='Credit_User__c';
		final Id LOOKUP_FIELD_VALUE=UserInfo.getUserId();
		final String NUMBER_FIELD_NAME='Units__c';
		final Integer NUMBER_FIELD_VALUE=123;
		final String DATE_FIELD_NAME='APP_Received_Date__c';
		final Date DATE_FIELD_VALUE=Date.today();
		final String DATETIME_FIELD_NAME = 'At_Credit_Date__c';
		final DateTime DATETIME_FIELD_VALUE = Datetime.now();
		final String BOOLEAN_FIELD_NAME='AFC_Web_App__c';
		final Boolean BOOLEAN_FIELD_VALUE=true;
		final String NULL_FIELD_NAME='AFC_Branch_Old__c';


		Set<String> tableFields = new Set<String>{'Name'};
		Set<String> filterFields = new Set<String>{TEXT_FIELD_NAME, LOOKUP_FIELD_NAME, NUMBER_FIELD_NAME,DATE_FIELD_NAME,DATETIME_FIELD_NAME,BOOLEAN_FIELD_NAME, NULL_FIELD_NAME};
		Application__c applicationFilters = new Application__c();
		applicationFilters.put(TEXT_FIELD_NAME, TEXT_FIELD_VALUE);
		applicationFilters.put(LOOKUP_FIELD_NAME, LOOKUP_FIELD_VALUE);
		applicationFilters.put(NUMBER_FIELD_NAME, NUMBER_FIELD_VALUE);
		applicationFilters.put(DATE_FIELD_NAME, DATE_FIELD_VALUE);
		applicationFilters.put(DATETIME_FIELD_NAME, DATETIME_FIELD_VALUE);
		applicationFilters.put(BOOLEAN_FIELD_NAME, BOOLEAN_FIELD_VALUE);

		Test.startTest();
			String actualQuery = DynamicQueryUtils.getDynamicQuery('Application__c', tableFields, filterFields, applicationFilters);
		Test.stopTest();

		System.assert(actualQuery.contains(TEXT_FIELD_NAME + '=\'' + TEXT_FIELD_VALUE + '\''));
		System.assert(actualQuery.contains(LOOKUP_FIELD_NAME + '=\'' + LOOKUP_FIELD_VALUE + '\''));
		System.assert(actualQuery.contains(NUMBER_FIELD_NAME + '=' + NUMBER_FIELD_VALUE));
		System.assert(actualQuery.contains(DATE_FIELD_NAME + '=' + String.valueOf(DATE_FIELD_VALUE)));
		System.assert(actualQuery.contains(DATETIME_FIELD_NAME + '=' +DATETIME_FIELD_VALUE.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT')));
		System.assert(actualQuery.contains(BOOLEAN_FIELD_NAME + '=' + BOOLEAN_FIELD_VALUE));
		System.assert(!actualQuery.contains(NULL_FIELD_NAME));

		try{
			Database.query(actualQuery);
		} catch(Exception e){
			System.assert(false, 'The query must be successful:' + e.getMessage());
		}
	}
}