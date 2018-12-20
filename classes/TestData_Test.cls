@isTest
private class TestData_Test {

    static testMethod void testData() {
        
        string zip = '12345';
        
        // BEGIN S-444338, T-566678 : Run the test data without any issue
        User thisUser1 = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser1){
        Branch__c br = TestData.CreateBranch(1, zip);
        insert br;
        
        
        ZipCode__c z = TestData.CreateZips(zip, br.id);
        insert z;
        
        ZipCode__c zp = TestData.CreateZips(null, br.id);
        insert zp;
        }
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){
        User u = TestData.CreateUser(1);
        insert u;
        IAASettings__c iaa = TestData.CreateSetting('DefaultOwnerId', u.Id);
        insert iaa;
        
        
        Account acct = TestData.CreateAccount(1, zip);
        insert acct;
        
        //User usr = TestData.CreateUser(1);
        //insert usr;
        
        Lead ld = TestData.CreateLead(1, zip);
        insert ld;
        }
      }
      // END S-444338, T-566678 : Run the test data without any issue
}