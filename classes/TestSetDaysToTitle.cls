@isTest
private class TestSetDaysToTitle {
	
	static testMethod void testSatToSat() {
		Datetime saleDate = Datetime.newInstance(2008,8,9);
		date titleReceived = Date.newInstance(2008,8,9);
		System.assertEquals(getDaysBetween(saleDate, titleReceived), 0.0);
	}
	
	static testMethod void testSatToSun() {
		Datetime saleDate = Datetime.newInstance(2008,8,9);
		date titleReceived = Date.newInstance(2008,8,10);
		System.assertEquals(getDaysBetween(saleDate, titleReceived), 0.0);
	}
	
	static testMethod void testSatToMon() {
		Datetime saleDate = Datetime.newInstance(2008,8,9);
		date titleReceived = Date.newInstance(2008,8,11);
		System.assertEquals(getDaysBetween(saleDate, titleReceived), 0.0);
	}
	
	static testMethod void testSunToMon() {
		Datetime saleDate = Datetime.newInstance(2008,8,10);
		date titleReceived = Date.newInstance(2008,8,11);
		System.assertEquals(getDaysBetween(saleDate, titleReceived), 0.0);
	}
	
	static testMethod void testMonToFriday() {
		Datetime saleDate = Datetime.newInstance(2008,8,11);
		date titleReceived = Date.newInstance(2008,8,15);
		System.assertEquals(getDaysBetween(saleDate, titleReceived), 4.0);
	}
	
	static testMethod void testMonToMon() {
		Datetime saleDate = Datetime.newInstance(2008,8,11);
		date titleReceived = Date.newInstance(2008,8,11);
		System.assertEquals(getDaysBetween(saleDate, titleReceived), 0.0);
	}
	
	static testMethod void testFriToMon() {
		Datetime saleDate = Datetime.newInstance(2008,8,8);
		date titleReceived = Date.newInstance(2008,8,11);
		System.assertEquals(getDaysBetween(saleDate, titleReceived), 1.0);
	}
	
	static testMethod void threeWeeks() {
		Datetime saleDate = Datetime.newInstance(2008,8,4);
		date titleReceived = Date.newInstance(2008,8,25);
		System.assertEquals(getDaysBetween(saleDate, titleReceived), 15.0);
	}
	
	static testMethod void testSatToNull() {
		Datetime saleDate = Datetime.newInstance(2008,8,9);
		System.assertEquals(getDaysBetween(saleDate, null), null);
	}
	
	static testMethod void testNullToSat() {
		date titleReceived = Date.newInstance(2008,8,11);
		System.assertEquals(getDaysBetween(null, titleReceived), null);
	}
	
	static testMethod void backwardsInTime() {
		Datetime saleDate = Datetime.newInstance(2008,8,12);
		date titleReceived = Date.newInstance(2008,8,6);
		System.assertEquals(getDaysBetween(saleDate, titleReceived), -4.0);
	}
	
	private static Double getDaysBetween(Datetime saleDate, Date titleReceived) {
		Purchase__c p = new Purchase__c();
		p.Vehicle_Id__c='1234567890'; 
		p.Source_Id__c='1234567890'; 
		p.ATC_Sale_Date__c = saleDate;
		p.Title_Received__c = titleReceived;
		insert p;
		Purchase__c result = [select Days_To_Title__c from Purchase__c where Id = :p.Id];
		return result.Days_To_Title__c;
	}
	
}