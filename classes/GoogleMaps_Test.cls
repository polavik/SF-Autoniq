@isTest
private class GoogleMaps_Test {


//-------------------------------------------------------------------------------------------------------
    static testMethod void testGoogleWS(){
        
        string AccountZip = '08884';
        string BranchZip = '07081';
       
        //Branch__c br = TestData.CreateBranch(1, BranchZip);
        Branch__c br = TestData.CreateBranch(1, BranchZip);
        insert br;
       
        ZipCode__c zip1 = TestData.CreateZips(AccountZip, br.Id);
        ZipCode__c zip2 = TestData.CreateZips(BranchZip, br.id);
        insert zip1;
        insert zip2;
        
        User u = TestData.CreateUser(1);
        insert u;
        
        IAASettings__c iaa = TestData.CreateSetting('DefaultOwnerId', u.Id);
        insert iaa;
        
        Account acct = TestData.CreateAccount(1, AccountZip);
        insert acct;
        
        string BranchAdd = br.PrimaryZipCode__c;
        string AcctAdd = acct.BillingPostalCode;
        
        
        GoogleMaps gm = new GoogleMaps(AcctAdd, BranchAdd);
        
        string jResults = gm.getJsonResults(AcctAdd, BranchAdd);
        
        system.debug('==========================================================================jResults ' + jResults);
        
    }
//-------------------------------------------------------------------------------------------------------


}