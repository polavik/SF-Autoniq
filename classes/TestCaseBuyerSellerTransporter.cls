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
private class TestCaseBuyerSellerTransporter {

    public static testMethod void testTrigger()
    {
		Account buyer = new Account(Name = 'buyer');
		insert buyer;
        System.assert(buyer.Id != null);        
		
		Contact buyer_contact = new Contact(LastName = 'contact', AccountId = buyer.Id);
		insert buyer_contact;
        System.assert(buyer_contact.Id != null);        

		Account seller = new Account(Name = 'seller');
		insert seller;
        System.assert(seller.Id != null);        
		
		Account transporter = new Account(Name = 'transporter');
		insert transporter;
        System.assert(transporter.Id != null);        
		
		Purchase__c purchase = new Purchase__c(Vehicle_Id__c='1234567890',Source_Id__c='1234567890', Name = 'JNKCV54E33M212906', ATC_Buyer__c = buyer.Id, ATC_Buyer_Contact__c = buyer_contact.Id, ATC_Seller__c = seller.Id, ATC_Transporter__c = transporter.Id);
		insert purchase;
        System.assert(purchase.Id != null);        
		
        Purchase__c retPurchase = [SELECT Id, Name FROM Purchase__c WHERE Id = :purchase.Id LIMIT 1];
        System.assert(retPurchase.Id != null);        
        System.assertEquals(getVIN(), retPurchase.Name);
        
		Case testCase = new Case(VIN__c = purchase.Id, Description='asdf', Reason='Case Reason');
		/* insert testCase;
        System.assert(testCase.Id != null);
        
        update testCase;  
		
        Case retCase = [SELECT Id, AccountId, ContactId, Seller__c, Transporter__c FROM Case WHERE Id = :testCase.Id LIMIT 1];
        System.assert(retCase.Id != null);        
        System.assertEquals(retCase.Id, testCase.Id);        
         FIXME: System.assertEquals(buyer.Id, retCase.AccountId);
        System.assertEquals(buyer_contact.Id, retCase.ContactId);
        System.assertEquals(seller.Id, retCase.Seller__c);
        System.assertEquals(transporter.Id, retCase.Transporter__c);
        */
    }

    public static String getVIN()
    {
        return 'JNKCV54E33M212906';
    }
}