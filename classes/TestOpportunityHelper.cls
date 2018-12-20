@isTest
private class TestOpportunityHelper {
    
    static testMethod void myUnitTest() {
        List<Account> AcList = new List<Account>();
        Account act1 = new Account(    Name='Dummy Account1',BillingPostalCode='31796' , BuyerID__c = '12345', SPID__c= '5682' );
        insert act1;

        Account act2 = new Account(    Name='Dummy Account2',BillingPostalCode='31795' , BuyerID__c = '12355', SPID__c='5666' );
        insert act2; 
        AcList.add(act1);
        AcList.add(act2);
        
        //AccountController TestActController = new AccountController();
        
        
        OpportunityHelper.createNewRegistrationOpportunity(act1);
        //System.assertNotEquals(null,AccountController.GetAccountBranches(AcList) );
       // AccountController.GetAccountBranches(AcList);

        
    }
}