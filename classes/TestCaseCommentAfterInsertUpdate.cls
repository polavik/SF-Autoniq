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
private class TestCaseCommentAfterInsertUpdate {

    static testMethod void myUnitTest() {
        Purchase__c p = new Purchase__c(Name = 'JNKCV54E33M212906', Vehicle_ID__c = '-1234567',Source_ID__c = '-1234567', Handles_Payment__c = 'Y', Actual_Pickup__c = Date.today(), Transport_Type__c = 2, Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Closed - Grounding Dealer');
        insert p;
        
        Case c = new Case(VIN__c = p.Id, Type = 'Arbitration', Description='PSI FAILED:Description', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', Inspection_Company_Responsibility__c='Yes');
        insert c;
        
        CaseComment cc = new CaseComment(CommentBody = 'test', ParentId = c.Id);
        insert cc;
    }
}