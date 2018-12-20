@isTest
private class BatchPurgeOldPromotionsTest {
	
    static testMethod void testBatch() {
		List<SObject> listObj = new List<SObject>();
        SF_Tech_Admin_Email__c sfObj = new SF_Tech_Admin_Email__c(Email__c = 'abc@test.com', Name = 'abc@test.com' );
        insert sfObj;
        
        List<Promotions__c>  listObj1 = new List<Promotions__c>();
		Date expDt =  Date.valueOf((System.now()).date().addDays(-30));
        
        for(Integer i=1; i<=15 ; i++)
          listObj1.add(new Promotions__c(Expiry_Date__c= expDt ));    
        insert listObj1;
        
        Test.StartTest();
        BatchPurgeOldPromotions om = new BatchPurgeOldPromotions();
        //om.query = om.query ;
        //Database.executeBatch(om);
		om.execute(null);	
        om.execute(null, listObj);	        
        Test.StopTest(); 
    }


}