@isTest
private class TestApplicationTrigger {

    static testMethod void testApplicationTriggerFlow() {
		TestApplicationServices.setupApplicationsWithChecklistItems();
		
		TestApplicationServices.creditUser2 = TestUtils.createusers(1, TestApplicationServices.CREDIT_PROFILE, true)[0];
		TestApplicationServices.ctUser2 = TestUtils.createUsers(1, TestApplicationServices.CT_PROFILE, true)[0];
		
		ApplicationCreditUserChecklistType__c setting1 = new ApplicationCreditUserChecklistType__c( Name = TestApplicationServices.CT_USER_LOOKUP, Checklist_For_Department_Value__c = TestApplicationServices.CT_PROCESSING );		
		ApplicationCreditUserChecklistType__c setting2 = new ApplicationCreditUserChecklistType__c( Name = TestApplicationServices.CREDIT_USER_LOOKUP, Checklist_For_Department_Value__c = TestApplicationServices.CREDIT_DEPT );
		
		insert new List<ApplicationCreditUserChecklistType__c>{ setting1, setting2};
		
		UnitTest.get('Qualifying Items')
			.divide( 2 )
				.part( 'Qualifying Items with ctUserRtype1')
				.part( 'Qualifying Items with creditUserRtype2');
		
		UnitTest.get( 'Qualifying Items with ctUserRtype1' ).property('For_Department__c').assign( TestApplicationServices.CT_PROCESSING );
		UnitTest.get( 'Qualifying Items with creditUserRtype2' ).property('For_Department__c').assign( TestApplicationServices.CREDIT_DEPT );
		UnitTest.get('Qualifying Items').updateAll();
		
		UnitTest.get('Qualifying Applications').property('Credit_User__c').assign( TestApplicationServices.creditUser2.id );
		UnitTest.get('Qualifying Applications').property('CT_Processing_User__c').assign( TestApplicationServices.ctUser2.id );
	
		Test.startTest();	
			UnitTest.get('Qualifying Applications').updateAll();
		Test.stopTest();	
		
		List<Checklist_Item__c> actualItems = [Select Id, Assigned_Department_User__c from Checklist_Item__c where Id in: UnitTest.get( 'Qualifying Items' ).getList()];

		for(Checklist_Item__c item : actualItems ){
			
			if(UnitTest.analyze('Qualifying Items with ctUserRtype1').hasId(item.Id))
				System.assertEquals( TestApplicationServices.ctUser2.Id, item.Assigned_Department_User__c );
			else
				System.assertEquals( TestApplicationServices.creditUser2.Id, item.Assigned_Department_User__c );
		}
			
    }
}