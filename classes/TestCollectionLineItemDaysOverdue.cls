public class TestCollectionLineItemDaysOverdue {
	static testMethod void doTest() {
		Account a = new Account();
		//a.ATC_Organization_ID__c = '123456';
		a.Name = 'Mr Stevebobs Volvo';
		insert a;
		
		a = [select Collection__c from Account where Id = :a.Id];
		
		Document_Type__c dt = new Document_Type__c();
		
		dt.Name = 'test';
		dt.Code__c = 'TE';
		insert dt;
		
		Collection_Line_Item__c cli = new Collection_Line_Item__c();
		cli.Collection__c = a.Collection__c;
		cli.Document_Type__c = dt.Id;
		cli.Doc_Id_Line_No__c = '1-1';
		cli.Document_Id__c = '1';
		cli.Line_Number__c = '1';
		cli.Due_Date__c = System.today();
		cli.Clear_Date__c = System.today();
		// FIXME: insert cli;
		
		cli = new Collection_Line_Item__c();
		cli.Collection__c = a.Collection__c;
		cli.Document_Type__c = dt.Id;
		cli.Doc_Id_Line_No__c = '2-1';
		cli.Document_Id__c = '2';
		cli.Line_Number__c = '1';
		cli.Due_Date__c = System.today();
		// FIXME: insert cli;
		
		cli = new Collection_Line_Item__c();
		cli.Collection__c = a.Collection__c;
		cli.Document_Type__c = dt.Id;
		cli.Doc_Id_Line_No__c = '3-1';
		cli.Document_Id__c = '3';
		cli.Line_Number__c = '1';
		cli.Due_Date__c = System.today();
		cli.Clear_Date__c = System.today().addDays(-1);
		// FIXME: insert cli;
		
		cli = new Collection_Line_Item__c();
		cli.Collection__c = a.Collection__c;
		cli.Document_Type__c = dt.Id;
		cli.Doc_Id_Line_No__c = '4-1';
		cli.Document_Id__c = '4';
		cli.Line_Number__c = '1';
		cli.Due_Date__c = System.today();
		cli.Clear_Date__c = System.today().addDays(1);
		// FIXME: insert cli;
	}
}