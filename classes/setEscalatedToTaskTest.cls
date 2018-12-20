@isTest
private class setEscalatedToTaskTest {
	
	@isTest static void test_method_one() {
		

		Account acc = TestUtility.createAccount(1, true);
		User usr1 = TestUtility.createUser('user1');
		User usr2 = TestUtility.createUser('user2');
		Collection__c coll = new Collection__c(Account__c=acc.Id, 
											   Name='Test setEscalatedToTask', Organization_Id__c='Test 64654654', 
											   Escalated_To__c = usr1.Id ,
											   Exception_Rule__c='NO EXCEPTIONS', Status__c='In Good Standing');
		insert coll;
		system.debug('------------ coll' + coll);
		system.debug('------------ coll.Id' + coll.Id);

		Collection__c updCol = [Select Id,Organization_Id__c, Escalated_To__c From Collection__c Where Name = 'Test setEscalatedToTask' ];
		updCol.Organization_Id__c = 'Test Update 1312';
		updCol.Escalated_To__c = usr2.Id;
		Update updCol;


	}
	

	
}