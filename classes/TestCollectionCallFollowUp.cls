@isTest
public class TestCollectionCallFollowUp {
	static testMethod void doTest() {
		Account a = new Account();
		//a.ATC_Organization_ID__c = '123456';
		a.Name = 'Mr Stevebobs Volvo';
		insert a;

		Collection_Call__c cc = new Collection_Call__c();
		cc.Collection__c = a.Collection__c;
		cc.Date_Time__c = System.now();
		cc.Follow_Up__c = true;
		cc.Follow_Up_Time__c = System.now();
		insert cc;
	}
}