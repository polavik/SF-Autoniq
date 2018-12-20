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
private class TestPurchaseBeforeInsertUpdate {

    static testMethod void myUnitTest1() {
        Account a = new Account(Name='Test0',Master_Index__c='Test0',AFC_Dealer_ID__c='12345');
        upsert a;
        Purchase__c purch = new Purchase__c();
        AFC_Contracts__c contract = new AFC_Contracts__c();
        contract.Account__c = a.id;
        contract.Contract_ID__c = '123';
        
        insert contract;
        
        purch.Contract_ID__c = '123';
        purch.Account__c = a.id;
        purch.Source_Id__c = '567';
        purch.AMS_Inventory_ID__c = '12345';
        
        purch.name = 'testCoverage';
        purch.Buyer_Contact_AAID__c= '5999998';
        purch.Purchase_Type__c = 'IAA';
        purch.Home_Branch__c = 'IAA';
        purch.Problem_Status__c ='18.24.31.414';
        purch.Segment_Name__c = 'off lease';
        purch.Hi_Res_Images_Fee__c = 10.0;
        purch.Seller_Contact_AAID__c = '5999999'; 
//        purch.ATC_Seller_Adesa_com_Detail__c ='a0I1300000yOqY2EAK';
        
        insert purch;
                
    }
    
    static testMethod void myUnitTest2() {
        Account a = new Account(Name='Test0',Master_Index__c='Test0',AFC_Dealer_ID__c='12345');
        upsert a;
        Purchase__c purch = new Purchase__c();
        AFC_Contracts__c contract = new AFC_Contracts__c();
        contract.Account__c = a.id;
        contract.Contract_ID__c = '123';
        
        insert contract;
        Contact c1 = new Contact(LastName='Last Name1',FirstName='First Name1',Rep_Auction_Access_Number__c='1234501');
        Contact c2 = new Contact(LastName='Last Name2',FirstName='First Name2',Rep_Auction_Access_Number__c='1234502');
        Contact c3 = new Contact(LastName='Last Name3',FirstName='First Name3',Rep_Auction_Access_Number__c='1234503');
        insert c1;
        insert c2;
        insert c3;
        
        purch.Contract_ID__c = '123';
        purch.Account__c = a.id;
        purch.Source_Id__c = '567';
        purch.AMS_Inventory_ID__c = '12345';
        
        purch.name = 'testCoverage';
        purch.Buyer_Contact_AAID__c= '5777777';
        purch.Purchase_Type__c = 'IAA';
        purch.Home_Branch__c = 'IAA';
        purch.Problem_Status__c ='18.24.31.414';
        purch.Segment_Name__c = 'off lease';
        purch.Hi_Res_Images_Fee__c = 10.0;
        purch.Seller_Contact_AAID__c = '1234501'; 
        
        insert purch;
                
        }

    static testMethod void testVehicleUtils1() {
    
    	VehicleUtils.createVehicle('testVehicleUtilsVid01');
   		System.debug('----- test VehicleUtils.createVehicle() done ');   	    	
    
    }
    static testMethod void testVehicleUtils2() {
    
		Asset__c a = new Asset__c(Name='VIN1234567980Test21', Source_Id__c='OL-222233332', Vehicle_Id__c ='222233332');		
//		insert a;       
		Asset__c a2 = new Asset__c(Name='VIN1234567980Test22', Source_Id__c='OL-222233333', Vehicle_Id__c ='222233333');		
//		insert a2;       

        Purchase__c purch = new Purchase__c();		
        purch.Contract_ID__c = '12311';
        purch.Source_Id__c = 'OL-222233332';        
        purch.name = 'VIN1234567980Test21';

        Purchase__c purch2 = new Purchase__c();		
        purch2.Contract_ID__c = '12311';
        purch2.Source_Id__c = 'OL-222233333';        
        purch2.name = 'VIN1234567980Test22';

		insert purch;
		insert purch2;
		
    	List<String> vehicleIds = new List<String>();
    	
		vehicleIds.add(purch.Source_Id__c);
		vehicleIds.add(purch2.Source_Id__c);

    	VehicleUtils.checkVehicle(vehicleIds);
    
    }
         
}