@isTest
public class AttachmentProofsCtrlTest
{
    static AFC_Contracts__c testContract;
    
    static void setup()
    {
        Test.setMock( HttpCalloutMock.class, new MockCallout() );
        testContract = TestServices.insert_AFCContract();
    }

    static testMethod void test_AttachmentProofsCtrl_monthlyReporting()
    {
        ApexPages.currentPage().getParameters().put( AttachmentProofsCtrl.OBJECT_TYPE, 'Monthly_Reporting__c' );

        Test.startTest();
            AttachmentProofsCtrl ctrl = new AttachmentProofsCtrl();
        Test.stopTest();
        
        System.assertNotEquals( null, ctrl.fieldMembers, 'We expect a field set named "' + AttachmentProofsCtrl.VIEW_REPORTING_FOR_ATTACHMENTS_FIELDS_NAME + '" to exist' );
        System.assertNotEquals( null, ctrl.additionalInput, 'We expect a field set named "' + AttachmentProofsCtrl.ADDITIONAL_INPUT_FIELDS + '" to exist' );
        System.assertEquals(false, ctrl.displayFields, 'When no object is selected, we expect not to display fields to set on a selected object that does not exist ' );
    }
    
    static testMethod void test_AttachmentProofsCtrl_monthlyReportingUploadAttachments()
    {
        setup();
        Monthly_Reporting__c testMonthlyReporting = TestServices.createMonthlyReportings( 1, testContract.Id, false )[0];
        testMonthlyReporting.Sales_Numbers__c = true;
        insert testMonthlyReporting;
        ApexPages.currentPage().getParameters().put( AttachmentProofsCtrl.OBJECT_TYPE, 'Monthly_Reporting__c' );
        ApexPages.currentPage().getParameters().put( AttachmentProofsCtrl.AFC_CONTRACT_ID, testContract.Id );
        
        Test.startTest();
            AttachmentProofsCtrl ctrl = new AttachmentProofsCtrl();
            ctrl.selectedToAttachTo = testMonthlyReporting.Id;
            ctrl.attachments[0].Body = Blob.valueOf('Hello World!');
            ctrl.attachments[0].Name = 'TestTest.txt';
            ApexPages.PageReference ref = ctrl.uploadAttachments();
        Test.stopTest();
        
        System.assertNotEquals( 0, ctrl.records.size(), 'I should have records related to the act contract id');
        System.assertEquals( true, ctrl.displayFields, 'When the field set for additional items exists and sales number is true, we expect to display the additional fields');
        System.assertNotEquals( null, ref, 'We expect to be redirected on a successful save' );
    }
    
    static testMethod void test_AttachmentProofsCtrl_ProofOfInsurance()
    {
        setup();
        Proof_of_Insurance__c proof = TestServices.createPOIs( 1, testContract.Id, true )[0];
        ApexPages.currentPage().getParameters().put( AttachmentProofsCtrl.OBJECT_TYPE, 'Proof_of_Insurance__c' );
        ApexPages.currentPage().getParameters().put( AttachmentProofsCtrl.AFC_CONTRACT_ID, testContract.Id );

        Test.startTest();
            AttachmentProofsCtrl ctrl = new AttachmentProofsCtrl();
        Test.stopTest();
        
        System.assertEquals( 1, ctrl.records.size(), 'We expect a record' );
        System.assertEquals( null, ctrl.additionalInput, 'We expect the field set to not exist' );
        System.assertEquals( false, ctrl.displayFields, 'Proof of insurance never displays additional fields' );
    }
    
    static testMethod void selectedObjectRequiresAttachmentTest(){
        setup();
        Proof_of_Insurance__c proof = TestServices.createPOIs( 1, testContract.Id, false )[0];
        proof.Insurance_Certificate__c = true;
        insert proof;
        
        Monthly_Reporting__c testMonthlyReporting = TestServices.createMonthlyReportings( 1, testContract.Id, false )[0];
        testMonthlyReporting.Sales_Numbers__c = true;
        testMonthlyReporting.Tax_Returns__c = true;
        insert testMonthlyReporting;
        
        ApexPages.currentPage().getParameters().put( AttachmentProofsCtrl.OBJECT_TYPE, 'Proof_of_Insurance__c' );
        ApexPages.currentPage().getParameters().put( AttachmentProofsCtrl.AFC_CONTRACT_ID, testContract.Id );
        
        AttachmentProofsCtrl ctrl = new AttachmentProofsCtrl();
        ctrl.selectedToAttachTo = proof.id;
        Test.startTest();
           
            boolean poiRequiresAttachment = ctrl.selectedObjectRequiresAttachment();
            ApexPages.currentPage().getParameters().put( AttachmentProofsCtrl.OBJECT_TYPE, 'MONTHLY_REPORTING__C' );
            
            ctrl = new AttachmentProofsCtrl();
            ctrl.selectedToAttachTo = testMonthlyReporting.id;
            boolean reportRequiresAttachment = ctrl.selectedObjectRequiresAttachment();
            
        Test.stopTest();
        
        System.Assert(poiRequiresAttachment, 'This proof of insurance requires an attachment');
        System.Assert(reportRequiresAttachment, 'This monthly report requires an attachment');
        
        
    }
    
    public class MockCallout implements HttpCalloutMock
    {
        public HttpResponse respond( HttpRequest req )
        {
            HttpResponse theResponse = new HttpResponse();
            return theResponse;
        }
    }
}