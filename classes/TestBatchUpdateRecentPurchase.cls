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
private class TestBatchUpdateRecentPurchase {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
 		Test.startTest();
 		
 		String s = '\'Hello Jason\'';

		system.debug(s); // Outputs 'Hello Jason'
 		
 		
 		Purchase__c p = new Purchase__c(Name = 'JNKCV54E33M212910', Vehicle_ID__c = '-7777001',
 						Source_ID__c = '-7777001', Handles_Payment__c = 'Y', Actual_Pickup__c = Date.today(), 
 						Transport_Type__c = 2, AMS_Inventory_ID__c = null , ATC_Sale_Date__c=Datetime.now().addDays(-1), 
 						RecordTypeId  = '012a0000001FpI1AAK',				
 						Transport_Preference__c = 'OPENLANE Arranged',
 						 sale_Class__c = 'Closed - Grounding Dealer');
		insert p;

 		System.debug('----- test class excuted Purchase__c created:  id=(' + p.id + '); name = ' + p.name );
 		
 		BatchUpdateRecentPurchase c = new BatchUpdateRecentPurchase();
       Database.executeBatch(c);
 		
    	Test.stopTest();        
    }
}