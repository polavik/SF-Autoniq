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
private class TestCRFFormController {

    static testMethod void myUnitTest() 
    {        
        Account a = new Account();
        //a.ATC_Organization_ID__c = '123456';
        a.Name = 'Mr Stevebobs Volvo';
        insert a;
        
        Purchase__c p = new Purchase__c
        (
            Vehicle_Id__c='1234567890', 
            Source_Id__c='1234567890', 
            Name = 'JNKCV54E33M212906', 
            Handles_Payment__c = 'Y', 
            Actual_Dropoff__c = Date.today(), 
            Transport_Preference__c = 'OPENLANE Arranged', 
            sale_Class__c = 'Closed - Grounding Dealer', 
            ATC_Sale_Date__c = Date.today()
        );
        insert p;
        
        Case c = new Case(VIN__c = p.Id, Type = 'Arbitration', Description='PSI FAILED:Description', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', Inspection_Company_Responsibility__c='Yes');
        insert c;
        
        Action_Package__c pkg = new Action_Package__c(Case__c = c.Id, Package_Type__c = 'Auction Void', Status__c = 'Approved', Approved__c = true, House_Transport_Responsible_Party__c = 'Seller', Standard_SAP_Transactions__c = true, Directions_For_Accounting__c = null);
        insert pkg;
        
        ID goodwillRT = Utils.getRecordTypeId('Auction_Credit__c', 'Auction Credit - Goodwill');
        
        Auction_Credit__c credit = new Auction_Credit__c();
        credit.Credit_Amount__c = 260;
        credit.Account__c = a.Id;
        credit.RecordTypeId = goodwillRT;
        credit.Purchase__c = p.id;
        credit.Action_Package__c = pkg.Id;
        insert credit;
        
        Test.startTest();
        
        PageReference pg = Page.crf_form;
        pg.getParameters().put('id', credit.Id);
        pg.getParameters().put('src', 'AUCTION_CREDIT__C');
        Test.setCurrentPageReference(pg);
        
        CRFFormController con = new CRFFormController();
        
        Test.stopTest();
        
        
        

        
    }
}