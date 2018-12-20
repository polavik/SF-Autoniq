@isTest
private class CaseCommentNotificationControllerTest {
	
	@isTest static void test_method_one() {

		RecordType CaseRecordTypeid = [Select Id 
		                                   From RecordType 
		                                   Where SObjectType='Case' 
		                                   and Name='Customer Service'];
		Map<String, String> purchase = new Map<String, String>();
		Integer i = 1;
        purchase.put('Name', 'JNKCV54E33M21291');
        purchase.put('Vehicle_ID__c', '-7777001');
        purchase.put('Source_ID__c', '-7777001');
        purchase.put('Handles_Payment__c', 'y');
        purchase.put('Transport_Type__c', '2');
        purchase.put('Transport_Preference__c', 'OPENLANE Arranged');
        purchase.put('sale_Class__c', 'Closed - Grounding Dealer');         
        Purchase__c p = TestUtility.createPurchaseRec(i,purchase,true);


        system.debug('---------------' + p.Id);

        Case caseObj = new Case(VIN__c = p.Id,RecordTypeId= CaseRecordTypeid.Id, Type = 'Arbitration', Description='PSI FAILED:Description', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', Inspection_Company_Responsibility__c='Yes');
		insert caseObj;
		system.debug('-------------' + caseObj.Id);
		CaseComment com = new CaseComment(parentId=caseObj.Id, commentBody= 'test 639');
		insert com;
        caseObj.Case_Comment_Id__c = com.Id;
		update caseObj;

		Test.StartTest();

		CaseCommentNotificationController controller = new CaseCommentNotificationController();
		controller.caseId =caseObj.Id;
		Test.StopTest();

	}
	

	
}