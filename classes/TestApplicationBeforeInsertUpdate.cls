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
private class TestApplicationBeforeInsertUpdate {

    static testMethod void myUnitTest() {
        Account a = new Account(Name='Test0',Master_Index__c='Test0',AFC_Dealer_ID__c='12345');
        upsert a;
        User testUser = TestServices.createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = TestServices.createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);
        Opportunity opp = TestServices.createTestOpportunity('Test Opp', 'Closed Won', 'Indianapolis', true);
        Application__c app = TestServices.createTestApplication(opp.Id, 'Shull', false);
        app.Contract_ID__c = '123';
        app.Applications_Accounts__c = a.id;
        insert app;
        
        AFC_Contracts__c contract = new AFC_Contracts__c();
        contract.Account__c = a.id;
        contract.Contract_ID__c = '123';
        insert contract;
    }
}