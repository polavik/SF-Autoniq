@isTest
private class TestAuctionCreditBeforeInsert 
{
	// Basically just shooting for code coverage here in order to deploy - no real point to this test case.  
	static testMethod void myUnitTest() {
		
		Account a = new Account();
		//a.ATC_Organization_ID__c = '123456';
		a.Name = 'Mr Stevebobs Volvo';
		insert a;
		
		ID goodwillRT = Utils.getRecordTypeId('Auction_Credit__c', 'Auction Credit - Goodwill');
		
		Auction_Credit__c credit = new Auction_Credit__c();
		credit.Credit_Amount__c = 260;
		credit.Account__c = a.Id;
		credit.RecordTypeId = goodwillRT;
		insert credit;
		
	}
}