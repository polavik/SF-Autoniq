public class TestSetEscalatedToTaskOld {
	
	static testMethod void doTest() {
		Account a = new Account();
		//a.ATC_Organization_ID__c = '123456';
		a.Name = 'Mr Stevebobs Volvo';
		insert a;
		
		
		
		Collection_Old__c c = new Collection_Old__c();
		c.Account__c = a.Id;
			
		c.Escalated_To__c = UserInfo.getUserID();
		insert c;
	}
}