@isTest
private class BranchController_Test {

    static testMethod void testBranchMethods() {
        
        set<string> sZips = new set<string>();
        set<id> sBranch = new set<id>();
        
        //BEGIN: S-444338 When we run this test class we are getting Mixed DML Operations error, to avoid this we need modify this TEST Apex class
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){
        Branch__c b = TestData.CreateBranch(1, '99999');
        insert b;
        sBranch.add(b.Id);
        
        ZipCode__c z = TestData.CreateZips('10001', b.Id);
        insert z;
        sZips.add(z.Name);
        

        User u = TestData.CreateUser(1);
        insert u;
        
        IAASettings__c iaa = TestData.CreateSetting('DefaultOwnerId', u.Id);
        insert iaa;
        
        Account acct = TestData.CreateAccount(1, '10001');
        insert acct;
        
        Lead ld = TestData.CreateLead(1, '10001');
        insert ld;
        
        list<ZipCode__c> zipcodes = BranchController.LookupBranchByZip(sZips);
        list<Branch__c> branches = BranchController.LookupOwnerByBranch(sBranch); 
        
        string branchAdd = BranchController.BranchAddress(b);
        string acctAdd = BranchController.AccountAddress(acct);
        string leadAdd = BranchController.LeadAddress(ld);
        
        string nullString1 = BranchController.CheckForNull(acctAdd);
        string nullStrin2 = BranchController.CheckForNull('null');
        
        //BranchController.CalculateAccountDistance(b.Id, acct.Id);
        }
    }
}