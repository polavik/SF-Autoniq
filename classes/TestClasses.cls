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
private class TestClasses {

    static testMethod void testArbsValidation() {     
        
        // Test non-Arb throws error
        Case c0 = new Case(Type = 'Title Inquiry', Description='asdf', Reason='Undisclosed Damages');
        boolean errorThrown = false;
        try {
            ArbsValidator.ValidationResults r0 = ArbsValidator.validate(c0);
        } catch (Exception e){
            errorThrown = true;
        }
        System.assert(errorThrown);
        
        // Test no Purchase
        Case c1 = new Case(Vehicle_Identification_Number__c = '1234567890ABCDEFG', Type = 'Arbitration', Description='PSI FAILED:Description', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true);
        insert c1;
        c1 = [SELECT CreatedDate, Reason, Type, VIN__r.ATC_Sale_Date__c, Validation_Outcome_Override__c, VIN__r.Handles_Payment__c, VIN__r.sale_class__c, VIN__r.Actual_Dropoff__c,
                VIN__r.Payment_Received__c, VIN__r.Transport_Preference__c, VIN__r.Today_Sale_Date__c
             FROM Case
             WHERE Id = :c1.Id];        
        
        ArbsValidator.ValidationResults r1 = ArbsValidator.validate(c1);
        System.assert(r1.undecided);
        
        // Test no Handles Payment
        Purchase__c p2 = new Purchase__c(Vehicle_Id__c='1234567890', Source_id__c='1234567890', Name = 'JNKCV54E33M212906', Handles_Payment__c = 'N', Actual_Dropoff__c = Date.today(), Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Open - Grounding Dealer');
        insert p2;
        
        Case c2 = new Case(VIN__c = p2.Id, Type = 'Arbitration', Description='PSI FAILED:Description', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true);
        insert c2;
        c2 = [SELECT CreatedDate, Reason, Type, VIN__r.ATC_Sale_Date__c, Validation_Outcome_Override__c, VIN__r.Handles_Payment__c, VIN__r.sale_class__c, VIN__r.Actual_Dropoff__c,
                VIN__r.Payment_Received__c, VIN__r.Transport_Preference__c, VIN__r.Today_Sale_Date__c
             FROM Case
             WHERE Id = :c2.Id];   
        
        ArbsValidator.ValidationResults r2 = ArbsValidator.validate(c2);
        System.assert(r2.undecided);
    }        
 static testMethod void testArbsValidation_CloseSale() {          
        // Test Closed Sale
        Purchase__c p3 = new Purchase__c(Vehicle_Id__c='1234567891', Source_id__c='1234567891', Name = 'JNKCV54E33M212906', Handles_Payment__c = 'Y', Actual_Dropoff__c = Date.today(), Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Closed - Grounding Dealer');
        insert p3;
        
        Case c3 = new Case(VIN__c = p3.Id, Type = 'Arbitration', Description='PSI FAILED:Description', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true);
        insert c3;
        c3 = [SELECT CreatedDate, Reason, Type, VIN__r.ATC_Sale_Date__c, Validation_Outcome_Override__c, VIN__r.Handles_Payment__c, VIN__r.sale_class__c, VIN__r.Actual_Dropoff__c,
                VIN__r.Payment_Received__c, VIN__r.Transport_Preference__c, VIN__r.Today_Sale_Date__c
             FROM Case
             WHERE Id = :c3.Id];   
        
        ArbsValidator.ValidationResults r3 = ArbsValidator.validate(c3);
        System.assert(r3.undecided);
 }        
 static testMethod void testArbsValidation_PaymentNull() {      
        // Test Payment Rec'd null
        Purchase__c p4 = new Purchase__c(Vehicle_Id__c='1234567892', Source_id__c='1234567892',Name = 'JNKCV54E33M212906', Handles_Payment__c = 'Y', Payment_Received__c = null, Actual_Dropoff__c = Date.today(), Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Open - Grounding Dealer');
        insert p4;
        
        Case c4 = new Case(VIN__c = p4.Id, Type = 'Arbitration', Description='asdf', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true);
        /* FIXME: insert c4;
        c4 = [SELECT CreatedDate, Reason, Type, VIN__r.ATC_Sale_Date__c, Validation_Outcome_Override__c, VIN__r.Handles_Payment__c, VIN__r.sale_class__c, VIN__r.Actual_Dropoff__c,
                VIN__r.Payment_Received__c, VIN__r.Transport_Preference__c, VIN__r.Today_Sale_Date__c
             FROM Case
             WHERE Id = :c4.Id];   
        
        ArbsValidator.ValidationResults r4 = ArbsValidator.validate(c4);
        System.assert(r4.paymentError);
        */
 }    
static testMethod void testArbsValidation_Odo() {   
        // Test Odometer Discrepancy
        Purchase__c p5 = new Purchase__c(Vehicle_Id__c='1234567893', Source_id__c='1234567893', Name = 'JNKCV54E33M212906', Handles_Payment__c = 'Y', Payment_Received__c = null, Actual_Dropoff__c = Date.today(), Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Open - Grounding Dealer');
        insert p5;
        
        Case c5 = new Case(VIN__c = p5.Id, Type = 'Arbitration', Description='PSI FAILED:Description', Reason='Odometer Discrepancy', Validation_Outcome_Override__c = true);
        insert c5;
        c5 = [SELECT CreatedDate, Reason, Type, VIN__r.ATC_Sale_Date__c, Validation_Outcome_Override__c, VIN__r.Handles_Payment__c, VIN__r.sale_class__c, VIN__r.Actual_Dropoff__c,
                VIN__r.Payment_Received__c, VIN__r.Transport_Preference__c, VIN__r.Today_Sale_Date__c
             FROM Case
             WHERE Id = :c5.Id];   
        
        ArbsValidator.ValidationResults r5 = ArbsValidator.validate(c5);
        System.assert(r5.undecided);
}        
static testMethod void testArbsValidation_TransportNull() {   
        // Test transport pref null
        Purchase__c p6 = new Purchase__c(Vehicle_Id__c='1234567894', Source_id__c='1234567894', Name = 'JNKCV54E33M212906', Handles_Payment__c = 'Y', Payment_Received__c = null, Actual_Dropoff__c = Date.today(), Transport_Preference__c = null, sale_Class__c = 'Open - Grounding Dealer');
        insert p6;
        
        Case c6 = new Case(VIN__c = p6.Id, Type = 'Arbitration', Description='PSI FAILED:Description', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true);
        insert c6;
        c6 = [SELECT CreatedDate, Reason, Type, VIN__r.ATC_Sale_Date__c, Validation_Outcome_Override__c, VIN__r.Handles_Payment__c, VIN__r.sale_class__c, VIN__r.Actual_Dropoff__c,
                VIN__r.Payment_Received__c, VIN__r.Transport_Preference__c, VIN__r.Today_Sale_Date__c
             FROM Case
             WHERE Id = :c6.Id];   
             
        ArbsValidator.ValidationResults r6 = ArbsValidator.validate(c6);
        System.assert(r6.undecided);
}        
       
static testMethod void testArbsValidation_CancelledTransport() {          
/* FIXME: data is not available in Release
        // Test cancelled transport treated as no transport
        Account a7 = [select Id from Account where ADESA_COM_Business_ID__c = '23758'];
        
        Purchase__c p7 = new Purchase__c(Vehicle_Id__c='1234567895', Source_id__c='1234567895', Name = 'JNKCV54E33M212906', ATC_Transporter__c = a7.Id, Handles_Payment__c = 'Y', Payment_Received__c = Date.today(), ATC_Sale_Date__c = DateTime.now().addDays(-20), Actual_Dropoff__c = Date.today().addDays(-20), Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Open - Grounding Dealer');
        insert p7;
        
        Case c7 = new Case(VIN__c = p7.Id, Type = 'Arbitration', Description='asdf', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true);
        insert c7;
        c7 = [SELECT CreatedDate, Reason, Type, VIN__r.ATC_Sale_Date__c, Validation_Outcome_Override__c, VIN__r.Handles_Payment__c, VIN__r.sale_class__c, VIN__r.Actual_Dropoff__c,
                VIN__r.Payment_Received__c, VIN__r.Transport_Preference__c, VIN__r.Today_Sale_Date__c
             FROM Case
             WHERE Id = :c7.Id];   
        
        ArbsValidator.ValidationResults r7 = ArbsValidator.validate(c7);
        System.assert(!r7.deliveryDateError);
*/
}   

        // Test OL Arranged transport
  /*     
        Account a8 = new Account(Name = 'Mr. Stevebobs Volvo', ADESA_COM_Business_ID__c = '54321');
        insert a8;
        
        Purchase__c p8 = new Purchase__c(Vehicle_Id__c='1234567896', Name = 'JNKCV54E33M212906', ATC_Transporter__c = a8.Id, Handles_Payment__c = 'Y', Payment_Received__c = Date.today(), ATC_Sale_Date__c = DateTime.now().addDays(-20), Actual_Dropoff__c = Date.today().addDays(-20), Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Open - Grounding Dealer');
        insert p8;
        
        Case c8 = new Case(VIN__c = p8.Id, Type = 'Arbitration', Description='asdf', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true);
        insert c8;
        c8 = [SELECT CreatedDate, Reason, Type, Validation_Outcome_Override__c, VIN__r.Handles_Payment__c, VIN__r.sale_class__c, VIN__r.Actual_Dropoff__c,
                VIN__r.Payment_Received__c, VIN__r.Transport_Preference__c, VIN__r.Today_Sale_Date__c
             FROM Case
             WHERE Id = :c8.Id];   
        
        ArbsValidator.ValidationResults r8 = ArbsValidator.validate(c8);
        System.assert(r8.deliveryDateError);
        }
        */
    

}