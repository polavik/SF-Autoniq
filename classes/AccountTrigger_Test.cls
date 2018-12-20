@isTest
private class AccountTrigger_Test {

//=============================================================================================
    static testMethod void testAccountTriggerWithMemberDefault() {
       
        integer z = 10001;
       
        
        //BEGIN: S-444338 When we run this test class we are getting Mixed DML Operations error, to avoid this we need modify this TEST Apex class
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){
        
        Branch__c b = TestData.CreateBranch(1, '10000');
        insert b;
        
        User u = TestData.CreateUser(1);
        insert u;
        
        IAASettings__c iaa = TestData.CreateSetting('DefaultOwnerId', u.Id);
        insert iaa;
        
        BranchTeamMember__c btm = TestData.CreateBranchTeamMember(b, u, true);
        insert btm;
        
        list<ZipCode__c> zips = new list<ZipCode__c>();
        
        for(integer x = 1; x < 200; x++){
            //system.debug('================================ CURRENT ZIP INTEGER: ' + z);
            ZipCode__c zip = TestData.CreateZips(string.valueOf(z), b.id);  
            zips.add(zip);
            //system.debug('================================ CURRENT ZIP: ' + zip);
            z += x;
            
        }
        
        insert zips;
        
        z = 10001;
        
        list<Account> accts = new list<Account>();
        
        for(integer y = 0; y < 200; y++){
            Account acct = TestData.CreateAccount(y, string.valueOf(z));    
            accts.add(acct);
            z += y;
        }
       
       system.debug('TRIGGER TEST ACCOUNTS:' + accts);
       
       insert accts;
       
     }
       //AccountController.GetBranchDistance(accts);  
    }
//=============================================================================================
    static testMethod void testAccountTriggerWithoutMember(){
        
         integer z = 10001;
        
        //BEGIN: S-444338 When we run this test class we are getting Mixed DML Operations error, to avoid this we need modify this TEST Apex class
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){
        
        Branch__c b = TestData.CreateBranch(1, '10000');
        insert b;
        
        User u = TestData.CreateUser(1);
        insert u;
        
        IAASettings__c iaa = TestData.CreateSetting('DefaultOwnerId', u.Id);
        insert iaa;
        
        list<ZipCode__c> zips = new list<ZipCode__c>();
        
        for(integer x = 1; x < 200; x++){
            //system.debug('================================ CURRENT ZIP INTEGER: ' + z);
            ZipCode__c zip = TestData.CreateZips(string.valueOf(z), b.id);  
            zips.add(zip);
            //system.debug('================================ CURRENT ZIP: ' + zip);
            z += x;
            
        }
        
        insert zips;
        
        z = 10001;
        
        list<Account> accts = new list<Account>();
        
        for(integer y = 0; y < 200; y++){
            Account acct = TestData.CreateAccount(y, string.valueOf(z));    
            accts.add(acct);
            z += y;
        }
       
       system.debug('TRIGGER TEST ACCOUNTS:' + accts);
       
       insert accts;
       }
    }
//=============================================================================================
    static testMethod void testAccountTriggerWithMemberNoDefault() {
       
        integer z = 10001;
        
        //BEGIN: S-444338 When we run this test class we are getting Mixed DML Operations error, to avoid this we need modify this TEST Apex class
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){
        
        Branch__c b = TestData.CreateBranch(1, '10000');
        insert b;
        
        User u1 = TestData.CreateUser(1);
        insert u1;
        User u2 = TestData.CreateUser(2);
        insert u2;
        
        IAASettings__c iaa = TestData.CreateSetting('DefaultOwnerId', u1.Id);
        insert iaa;
        
        BranchTeamMember__c btm1 = TestData.CreateBranchTeamMember(b, u1, false);
        insert btm1;
        BranchTeamMember__c btm2 = TestData.CreateBranchTeamMember(b, u2, false);
        insert btm2;
        
        
        list<ZipCode__c> zips = new list<ZipCode__c>();
        
        for(integer x = 1; x < 200; x++){
            //system.debug('================================ CURRENT ZIP INTEGER: ' + z);
            ZipCode__c zip = TestData.CreateZips(string.valueOf(z), b.id);  
            zips.add(zip);
            //system.debug('================================ CURRENT ZIP: ' + zip);
            z += x;
            
        }
        
        insert zips;
        
        z = 10001;
        
        list<Account> accts = new list<Account>();
        
        for(integer y = 0; y < 200; y++){
            Account acct = TestData.CreateAccount(y, string.valueOf(z));    
            accts.add(acct);
            z += y;
        }
       
       system.debug('TRIGGER TEST ACCOUNTS:' + accts);
       
       insert accts;
     }
        //AccountController.GetBranchDistance(accts);  
    }   
//=============================================================================================
    static testMethod void testAccountTriggerWithNoBranch() {
        
        string zipStart = '07081';
        string zipEnd = '08884';
        
        
        //BEGIN: S-444338 When we run this test class we are getting Mixed DML Operations error, to avoid this we need modify this TEST Apex class
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){
        
        Branch__c branch = TestData.CreateBranch(1, zipStart);
        insert branch;
        
        User u = TestData.CreateUser(1);
        insert u;
        
        IAASettings__c iaa = TestData.CreateSetting('DefaultOwnerId', u.Id);
        insert iaa;
        
        ZipCode__c zip = TestData.CreateZips(zipEnd, branch.id);
        insert zip;
        
        Account acct = TestData.CreateAccount(1, zipEnd);
        insert acct;
       }        
    }
//=============================================================================================
 
     static testMethod void testAccountTriggerDistance() {
        
        string zipStart = '07081';
        string zipEnd = '08884';
        
        //BEGIN: S-444338 When we run this test class we are getting Mixed DML Operations error, to avoid this we need modify this TEST Apex class
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){
        
        Branch__c branch = TestData.CreateBranch(1, zipStart);
        insert branch;
        
        User u = TestData.CreateUser(1);
        insert u;
        
        IAASettings__c iaa = TestData.CreateSetting('DefaultOwnerId', u.Id);
        insert iaa;
        
        ZipCode__c zip = TestData.CreateZips(zipEnd, branch.Id);
        insert zip;
        
        //test.startTest();
        
        list<Account> accounts = new list<Account>();
        BranchController.isRunningFuture = false;
        
        //Distance calculation is only done when trigger size = 1
        Account acct = TestData.CreateAccount(1, zipEnd);
        accounts.add(acct);
        
        test.startTest();
            insert accounts;
        //test.stopTest();
        
        for(Account acc : accounts){
            acc.BillingPostalCode = zipEnd;
        }
        
        update accounts;
        test.stopTest();
        //AccountController.GetBranchDistance(accounts);
       }        
    }
  
//=============================================================================================      
    static testMethod void testGMap(){
        
        string zipStart = '07081';
        string zipEnd = '08884';
        
        //BEGIN: S-444338 When we run this test class we are getting Mixed DML Operations error, to avoid this we need modify this TEST Apex class
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){
        
        Branch__c branch = TestData.CreateBranch(1, zipStart);
        insert branch;
        
        User u = TestData.CreateUser(1);
        insert u;
        
        IAASettings__c iaa = TestData.CreateSetting('DefaultOwnerId', u.Id);
        insert iaa;
        
        ZipCode__c zip = TestData.CreateZips(zipEnd, branch.Id);
        insert zip;
        
        Account acct = TestData.CreateAccount(1, zipEnd);
        acct.IAARecordTypes__c = 'IAA Remarketing';
        acct.IAA_Type__c = 'Remarketing';
        insert acct;
        
        //test.startTest();
        //  BranchController.CalculateDistance(branch.id, acct.id, 'Account');
        //test.stopTest();
      }  
    }
}