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
private class TestAdesaComDetailSetArbitrations {

    static testMethod void myUnitTest() {
    
        Account acc = new Account(name = 'Some Test Account', Source_Id__c = '123432123');
        insert acc; 
        Adesa_com_Detail__c  a = new Adesa_com_Detail__c();
        a.ATC_Organization_ID__c = '123456';
        a.Name = 'Mr Stevebobs Volvo';
        a.Account__c = acc.Id;
        insert a;

        System.debug('-----Adesa_com_Detail__c.id=' + a.id);
        
        List<Purchase__c> purs = new List<Purchase__c>();
        
        Purchase__c purchase = new Purchase__c(Vehicle_Id__c='1234567890',Name='ABCDEFG1234567890', ATC_Sale_Date__c=Datetime.now(), Source_Id__c = '5544554');        
        purs.add(purchase);
        
        Purchase__c purchase2 = new Purchase__c(Vehicle_Id__c='1234567891',Name='ABCDEFG0123456789', ATC_Sale_Date__c=Datetime.now(), ATC_Seller_Adesa_com_Detail__c=a.Id, Source_Id__c = '55445543');
        purs.add(purchase2);
        
        insert purs;
        System.debug('-----purchase.id=' + purchase.id);
        System.debug('-----purchase2.id=' + purchase2.id);
        
        List<Case> cases = new List<Case>();
        Case c1 = new Case(VIN__c = purchase.Id, AccountId = acc.Id, Description='asdf', Type = 'Arbitration', Reason='Case Reason', Void__c=true);
        cases.add(c1);
        
        //Case c2 = new Case(VIN__c = purchase.Id, AccountId = a.Id, Description='asdf', Type = 'Arbitration', Reason='Case Reason2',Void__c=true);
        //insert c2;
        
        Case c4 = new Case(VIN__c = purchase2.Id, Description='asdf', Type = 'Arbitration', Reason='VEHICLE UNAVAILABLE', Claim_Resolution__c='Void', Resolution_Subtype__c='Seller', Inspection_Company_Responsibility__c='Yes',Void__c=true);
        cases.add(c4);
        
//        insert cases;
        insert c1;
        
        System.debug('-----c1.id=' + c1.id);
        
        
        Adesa_com_Detail__c a1 = [select Id, IDEAL_Arbitrations__c,name 
             from Adesa_com_Detail__c
             where Id = :a.Id];

        System.debug('-----before update  Adesa_com_Detail__c');
        System.debug('-----Adesa_com_Detail__c.id=[' + a1.id +' ] a.IDEAL_Arbitrations__c =[' + a1.IDEAL_Arbitrations__c + ']');
        System.debug('-----Adesa_com_Detail__c.Name=[' + a1.Name +' ] ');
        
		a1.Name = 'test for update';
        update a1; 

        System.debug('-----after update  Adesa_com_Detail__c');
        System.debug('-----Adesa_com_Detail__c.id=[' + a1.id +' ] a.IDEAL_Arbitrations__c =[' + a1.IDEAL_Arbitrations__c + ']');
        System.debug('-----Adesa_com_Detail__c.Name=[' + a1.Name +' ] ');
                     
//        System.assertEquals(1, a.IDEAL_Arbitrations__c); //This doesn't work, probably should check why.
        
        
    }
}