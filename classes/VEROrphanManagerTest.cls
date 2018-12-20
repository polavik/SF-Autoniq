@isTest
private class VEROrphanManagerTest {
	
	@isTest static void test_Data() {

		// creation of data
		Map<String, String> purchase = new Map<String, String>();
        purchase.put('Name', 'JNKCV54E33M212910');
        purchase.put('Vehicle_ID__c', '7777001');
        purchase.put('Source_ID__c', '-7777001');
        purchase.put('Handles_Payment__c', 'y');
        purchase.put('Transport_Type__c', '2');
        purchase.put('Transport_Preference__c', 'OPENLANE Arranged');
        purchase.put('sale_Class__c', 'Closed - Grounding Dealer'); 

		Map<String, String> vehicalExceptionReport = new Map<String, String>();        
        vehicalExceptionReport.put('Vehicle_ID__c', '7777001');



		List<Purchase__c> purchaseLst = new List<Purchase__c>();
		List<Vehicle_Exception_Report__c> vhcRepLst = new List<Vehicle_Exception_Report__c>();

		for(Integer i=1; i<8 ; i++)
		{
        	Purchase__c p = TestUtility.createPurchaseRec(i,purchase,false);
        	purchaseLst.add(p);
        	Vehicle_Exception_Report__c vhcrep = TestUtility.createVehicalExceptionReport(i,vehicalExceptionReport, false);        	
        	vhcRepLst.add(vhcRep);
        }
        insert purchaseLst;
        insert vhcRepLst;

        Datetime oldDate = Datetime.now().addDays(-40);
        vehicalExceptionReport.put('Vehicle_ID__c', '5465465654');
        Vehicle_Exception_Report__c vhcrep = TestUtility.createVehicalExceptionReport(11,vehicalExceptionReport, true);        	
        Test.setCreatedDate(vhcrep.Id, oldDate);

	}

	@isTest static void test_VEROrphanManager() {

		test_Data();		

        Test.startTest();
	        VEROrphanManager obj = new VEROrphanManager();
	        DataBase.executeBatch(obj); 
	        // below is to cover lines of code in execute method;
	        SchedulableContext sc = null; 
	        obj.execute(sc); 
        Test.stopTest();


	}
	

}