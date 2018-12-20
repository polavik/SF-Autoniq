public class TestSetEscalatedToTask {
	
	static testMethod void doTest() {
		Account a = new Account();
		//a.ATC_Organization_ID__c = '123456';
		a.Name = 'Mr Stevebobs Volvo';
		insert a;
		
		a = [select Collection__c from Account where Id = :a.Id];
		/* FIXME: no data
		Collection__c c = 
			[select Escalated_To__c from Collection__c where Id = :a.Collection__c];
			
		c.Escalated_To__c = UserInfo.getUserID();
		update c;
		*/
	}
}