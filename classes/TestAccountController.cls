@isTest
private class TestAccountController {
    
    static testMethod void myUnitTest() {
        List<Account> AcList = new List<Account>();
        Account act1 = new Account(    Name='Dummy Account1',BillingPostalCode='31796' , BuyerID__c = '12345', SPID__c= '5682' );
        insert act1;

        Account act2 = new Account(    Name='Dummy Account2',BillingPostalCode='31795' , BuyerID__c = '12355', SPID__c='5666' );
        insert act2; 
        AcList.add(act1);
        AcList.add(act2);
        
        IAASettings__c iasetting = new  IAASettings__c(Name='DefaultOwnerId',SettingValue__c='0051300000CLWc2');
        
        insert iasetting; 
        
        Branch__c brnch = new Branch__c(Name='Tifton');
        insert brnch;
        //<Id> brid = new<Id>;
        
        string brid = [SELECT Id,Name,OwnerId FROM Branch__c where name = 'Tifton'].Id;
   
        ZipCode__c zipcd = new ZipCode__c(Name='31796', Branch__c=brid );
        insert zipcd ;
        
        ZipCode__c zipcd1 = new ZipCode__c(Name='31795', Branch__c=brid);
        insert zipcd1 ;
        
        BranchTeamMember__c bmember = new BranchTeamMember__c( Default__c=TRUE,Branch__c=brid);
        BranchTeamMember__c bmember1= new BranchTeamMember__c( Default__c=FALSE,Branch__c=brid);
        insert bmember;
        insert bmember1;
        //SELECT Branch__c,Id,Name FROM BranchTeamMember__c
        
        //AccountController TestActController = new AccountController();
        
        //System.assertNotEquals(null,AccountController.GetAccountBranches(AcList) );
        AccountController.GetAccountBranches(AcList);

        
    }
}