@isTest
private class ActivityDetailBeforeUpdateTest {
	
	@isTest static void test_method_one() {

		test.startTest();
		Contact con = TestUtility.createContact(1, true);

		Lead lid = TestUtility.createLead(1,false);
		lid.Opportunity_Method__c = 'BDC';
		lid.AFC_Branch__c = 'BOSTON';
		insert lid;

		Activity_Detail__c actDet = new Activity_Detail__c();
		actDet.Sale_Event_Date_2__c = system.Today();
		actDet.Call_Outcome_Log_2_Link__c = 'Http://calllogURL.com';
		actDet.Activity_Type1__c = 'Attempt to Contact';
		actDet.Activity_Type2__c = 'Sent Email & Text';
		insert actDet;


		actDet.Activity_Type2__c = 'Attempt to Contact';
		update actDet;

		Activity_Detail__c chlActDet = [Select Id, Sale_Event_Date_2__c,Call_Outcome_Log_2_Link__c, Activity_Type1__c, Activity_Type2__c from Activity_Detail__c Where Id =: actDet.Id];
		system.assert(chlActDet!=null, 'Unable to find Activity Detail record');

		actDet.Call_Outcome_Log_2_Link__c = null;
		update actDet;


		Task tsk = TestUtility.createTask(1, false, con.Id);
		tsk.Activity_Detail__c = actDet.Id;
		tsk.Customert_Type__c ='Warm Prospect';
		insert tsk;

		Task chlTsk = [Select Id, Subject from Task Where Id =: tsk.Id];
		system.assert(chlTsk!=null, 'Unable to find Task  record');


		actDet.Activity_Type2__c = 'Attempt to Contact';
		update actDet;


		Task tsk2 = TestUtility.createTask(2, false, lid.Id);
		tsk2.Activity_Detail__c = actDet.Id;
		tsk2.Customert_Type__c ='Warm Prospect';
		insert tsk2;


		actDet.Activity_Type2__c = 'Attempt to Contact';
		update actDet;



		test.stopTest();

	}
	

	
}