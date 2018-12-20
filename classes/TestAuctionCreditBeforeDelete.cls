/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestAuctionCreditBeforeDelete 
{
	static testMethod void myUnitTest() 
    {
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
		
		Boolean errorThrown = false;
		try
		{
			delete credit;
		}
		catch(Exception e)
		{
			errorThrown = true;
		}
		
		System.assert(errorThrown, 'Should not be able to delete Auction Credits.');
    }
}