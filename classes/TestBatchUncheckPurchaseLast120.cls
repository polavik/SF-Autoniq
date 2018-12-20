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
@isTest(SeeAllData=false)
private class TestBatchUncheckPurchaseLast120 {

public static testMethod void testBatch() {
// Create 4 test contacts - this simulates one execute.   
    List<Contact> contacts = new List<Contact>();
    Contact c1 = new Contact
    (
        FirstName='us',
        LastName='Checked',
        Openlane_CA_Purchase_Last_120__c = false,
        Openlane_US_Purchase_Last_120__c = true
    );
    contacts.add(c1);
    Contact c2 = new Contact
    (
        FirstName='caChecked',
        LastName='Checked', 
        Openlane_CA_Purchase_Last_120__c = true,
        Openlane_US_Purchase_Last_120__c = false
    ); 
    contacts.add(c2);
    Contact c3 = new Contact
    (
        FirstName='all1',
        LastName='Checked', 
        Openlane_CA_Purchase_Last_120__c = true,
        Openlane_US_Purchase_Last_120__c = true
    ); 
    contacts.add(c3);
    Contact c4 = new Contact
    (
        FirstName='all2', 
        LastName='Checked',
        Openlane_CA_Purchase_Last_120__c = true,
        Openlane_US_Purchase_Last_120__c = true
    );  
    contacts.add(c4);  
    
    insert contacts;
// Create 4 test purchases for the contacts 

    List<Purchase__c> purchases = new List<Purchase__c>();
    Purchase__c p1 = new Purchase__c
    (
        Name = 'JNKCV54E33M212906', 
        Vehicle_Id__c = '12345',
        Source_Id__c = '12345',
        Private_Label__c = 'OPENLANE.ca Open Auction',
        ATC_Buyer_Contact__r = c3,          
        ATC_Sale_Date__c = system.today()
    );  
    purchases.add(p1);
    Purchase__c p2 = new Purchase__c
    (
        Name = 'JNKCV54E33M212907', 
        Vehicle_Id__c = '12346',
        Source_Id__c = '12346',
        Private_Label__c = 'OPENLANE Auction',
        ATC_Buyer_Contact__r = c4,          
        ATC_Sale_Date__c = system.today()
    );
    purchases.add(p2);
    Purchase__c p3 = new Purchase__c
    (
        Name = 'JNKCV54E33M212908', 
        Vehicle_Id__c = '12347',
        Source_Id__c = '12347',
        Private_Label__c = 'OPENLANE Auction',
        ATC_Buyer_Contact__r = c3,          
        ATC_Sale_Date__c = (system.today() - 130)
    );
    purchases.add(p3);
    Purchase__c p4 = new Purchase__c
    (
        Name = 'JNKCV54E33M212909', 
        Vehicle_Id__c = '12348',
        Source_Id__c = '12348',
        Private_Label__c = 'OPENLANE.ca Open Auction',
        ATC_Buyer_Contact__r = c4,          
        ATC_Sale_Date__c = (system.today() - 130)
    );
    purchases.add(p4);
    
    insert purchases;
    
//All test data created, start test     
        
    Test.StartTest();
    BatchUncheckPurchaseLast120 uncheck = new BatchUncheckPurchaseLast120();
    uncheck.query = 
        'SELECT Id, Openlane_CA_Purchase_Last_120__c, Openlane_US_Purchase_Last_120__c ' + 
        'FROM Contact ' +
        'WHERE Openlane_CA_Purchase_Last_120__c = true OR Openlane_US_Purchase_Last_120__c = true ';
    ID batchprocessid = Database.executeBatch(uncheck);
    Test.StopTest();  
    
    //Validate test
    //Logger.info(c1, 'Contact 1 should be F/F: ' + c1);
    //Logger.info(c2, 'Contact 2 should be F/F: ' + c2);
    //Logger.info(c3, 'Contact 3 should be T/F: ' + c3);
    //Logger.info(c4, 'Contact 4 should be F/T: ' + c4);
    
/*      System.AssertEquals(false, c1.Openlane_CA_Purchase_Last_120__c);
    System.AssertEquals(false, c1.Openlane_US_Purchase_Last_120__c);
        
    System.AssertEquals(false, c2.Openlane_CA_Purchase_Last_120__c);
    System.AssertEquals(false, c2.Openlane_US_Purchase_Last_120__c);
        
    System.AssertEquals(true, c3.Openlane_CA_Purchase_Last_120__c);
    System.AssertEquals(false, c3.Openlane_US_Purchase_Last_120__c); 
       
    System.AssertEquals(false, c4.Openlane_CA_Purchase_Last_120__c);
    System.AssertEquals(true, c4.Openlane_US_Purchase_Last_120__c);*/
    






        
    
    
     
   }
}