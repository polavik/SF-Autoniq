@isTest
private class IAAIAccountTrigger_Test {

//===========================================================================================
    static testMethod void testAccountTriggerWithMemberDefault() {
       
        integer z = 10001;
        
        
        Branch__c b = TestData.CreateBranch(1, '10000');
        insert b;
        

        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User u = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason.liveston@asdf.com',
                           Username = 'jason.liveston@asdffff.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );



        //User u = TestData.CreateUser(1);
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
     
        //AccountController.GetBranchDistance(accts);  
    }
//=============================================================================================
    static testMethod void testAccountTriggerWithoutMember(){
        
         integer z = 10001;
        
        Branch__c b = TestData.CreateBranch(1, '10000');
        insert b;
        
        //User u = TestData.CreateUser(1);
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User u = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason.liveston@asdf.com',
                           Username = 'jason.liveston@asdffff.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
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
//=============================================================================================
    static testMethod void testAccountTriggerWithMemberNoDefault() {
       
        integer z = 10001;
        
        Branch__c b = TestData.CreateBranch(1, '10000');
        insert b;
        
        //User u1 = TestData.CreateUser(1);
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User u1 = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason.liveston@asdf.com',
                           Username = 'jason.liveston@asdffff.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        insert u1;
        //User u2 = TestData.CreateUser(2);
       /* Profile profileId2 = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User u2 = new User(LastName = 'Bodak',
                           FirstName='Neil',
                           Alias = 'nboda',
                           Email = 'nbodak@iaaaaaai.com',
                           Username = 'nbodak@iaaaaai.com.NEOMATRIX',
                           ProfileId = profileId2.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        insert u2;*/
        
        IAASettings__c iaa = TestData.CreateSetting('DefaultOwnerId', u1.Id);
        insert iaa;
        
        BranchTeamMember__c btm1 = TestData.CreateBranchTeamMember(b, u1, false);
        insert btm1;
        //BranchTeamMember__c btm2 = TestData.CreateBranchTeamMember(b, u2, false);
        //insert btm2;
        
        
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
        
        //for(integer y = 0; y < 200; y++)
        for(integer y = 0; y < 20; y++){
            Account acct = TestData.CreateAccount(y, string.valueOf(z));    
            accts.add(acct);
            z += y;
        }
       
       system.debug('TRIGGER TEST ACCOUNTS:' + accts);
       
       insert accts;
     
        //AccountController.GetBranchDistance(accts);  
    }
//=============================================================================================
    static testMethod void testAccountTriggerWithNoBranch() {
        
        string zipStart = '07081';
        string zipEnd = '08884';
        
        Branch__c branch = TestData.CreateBranch(1, zipStart);
        insert branch;
        
        //User u = TestData.CreateUser(1);
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User u = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason.liveston@asdf.com',
                           Username = 'jason.liveston@asdffff.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        insert u;
        
        IAASettings__c iaa = TestData.CreateSetting('DefaultOwnerId', u.Id);
        insert iaa;
        
        ZipCode__c zip = TestData.CreateZips(zipEnd, branch.id);
        insert zip;
        
        Account acct = TestData.CreateAccount(1, zipEnd);
        insert acct;
               
    }
//=============================================================================================
 
     static testMethod void testAccountTriggerDistance() {
        
        string zipStart = '07081';
        string zipEnd = '08884';
        
        Branch__c branch = TestData.CreateBranch(1, zipStart);
        insert branch;
        
        //User u = TestData.CreateUser(1);
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User u = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason.liveston@asdf.com',
                           Username = 'jason.liveston@asdffff.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
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
  
//=============================================================================================      
    static testMethod void testGMap(){
        
        string zipStart = '07081';
        string zipEnd = '08884';
        
        Branch__c branch = TestData.CreateBranch(1, zipStart);
        insert branch;
        
        //User u = TestData.CreateUser(1);
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User u = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason.liveston@asdf.com',
                           Username = 'jason.liveston@asdffff.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        insert u;
        
        IAASettings__c iaa = TestData.CreateSetting('DefaultOwnerId', u.Id);
        insert iaa;
        
        ZipCode__c zip = TestData.CreateZips(zipEnd, branch.Id);
        insert zip;
        
        Account acct = TestData.CreateAccount(1, zipEnd);
        insert acct;
        
        //test.startTest();
        //  BranchController.CalculateDistance(branch.id, acct.id, 'Account');
        //test.stopTest();
         
    }
}