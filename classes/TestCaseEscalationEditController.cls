@isTest
private class TestCaseEscalationEditController {

    static testMethod void myUnitTest() {
        Purchase__c p = new Purchase__c(Name = 'JNKCV54E33M212906', Vehicle_ID__c = '-1234567', Source_ID__c = '-1234567', Handles_Payment__c = 'Y', Actual_Pickup__c = Date.today(), Transport_Type__c = 2, Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Closed - Grounding Dealer');
        insert p;
        
        Case c = new Case(VIN__c = p.Id, Type = 'Arbitration', Description='PSI FAILED:Description', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', Inspection_Company_Responsibility__c='Yes');
        insert c;
        
        Case_Escalation__c ce = new Case_Escalation__c(Case__c = c.Id);
        insert ce;
        
        PageReference currentPR = Page.case_escalation_comment;
        currentPR.getParameters().put('id', ce.Id);
        Test.setCurrentPageReference(currentPR);
        
        Test.startTest();
        
        CaseEscalationEditController ceec = new CaseEscalationEditController(new ApexPages.Standardcontroller(ce));
        ceec.cancel();
        ceec.editableCaseStatus = true;
        ceec.selectedCaseStatus = 'Closed';
        ceec.escalation.Escalation_Resolution__c = 'Declined';
        ceec.submit();
    }
}