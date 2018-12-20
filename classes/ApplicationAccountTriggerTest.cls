/*================================================================================
    Name        : ApplicationAccountTriggerTest
    Description : Test class for ApplicationAccountTrigger and ApplicationAccountTriggerManager.
    Modification History:
    09/24/2013        Sushant Bhasin           Created
==================================================================================*/
@isTest
private class ApplicationAccountTriggerTest {

    /*
    static testMethod void multiplePrimaryAccountRolesNotInserted() {
        Account tAcc = new Account(Name = 'Account_ApplicationAccountTriggerTest');
        insert tAcc;
        
        Application__c tApplication = new Application__c(Name = 'Application_ApplicationAccountTriggerTest');
        insert tApplication;
        
        LIST<Application_Account_Role__c> tprimaryAppAccList = new List<Application_Account_Role__c>{new Application_Account_Role__c(Name = 'App Account 1_ApplicationAccountTriggerTest', Account__c =tAcc.Id, Application__c = tApplication.Id, primary__c = true), 
                                                                                              new Application_Account_Role__c(Name = 'App Account 2_ApplicationAccountTriggerTest', Account__c =tAcc.Id, Application__c = tApplication.Id, primary__c = true)};
        try{
            insert tprimaryAppAccList;
            System.assert(false, 'Inserting 2 primary records should throw exception'); // should not reach this line
        }catch(Exception e)
        {
            System.assertEquals(0,[select count() from Application_Account_Role__c]);
        }
    }
    */
    
    static testMethod void singlePrimaryAccountRoleInserted() {
        Account tAcc = new Account(Name = 'Account_ApplicationAccountTriggerTest');
        insert tAcc;
        
        User testUser = TestServices.createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = TestServices.createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);
        Opportunity opp = TestServices.createTestOpportunity('Test Opp', 'Closed Won', 'Indianapolis', true);
        Application__c tApplication = TestServices.createTestApplication(opp.Id, 'Shull', true);
        
        Application_Account_Role__c tAppAccount= new Application_Account_Role__c(Name = 'App Account 1_ApplicationAccountTriggerTest', Account__c =tAcc.Id, Application__c = tApplication.Id, primary__c = true);
        insert tAppAccount;
        
        //System.assertEquals(tAcc.Id, [select Id,Applications_Accounts__c from Application__c where Id = :tApplication.Id].Applications_Accounts__c);
        System.assertEquals(null, [select Id,Applications_Accounts__c from Application__c where Id = :tApplication.Id].Applications_Accounts__c);
    }
    
    static testMethod void updatePrimaryAccountRoleNullsAccount(){
        Account tAcc = new Account(Name = 'Account_ApplicationAccountTriggerTest');
        insert tAcc;
        
        User testUser = TestServices.createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = TestServices.createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);
        Opportunity opp = TestServices.createTestOpportunity('Test Opp', 'Closed Won', 'Indianapolis', true);
        Application__c tApplication = TestServices.createTestApplication(opp.Id, 'Shull', true);
        
        Application_Account_Role__c tAppAcc_valid = new Application_Account_Role__c(Name = 'App Account 1_ApplicationAccountTriggerTest', Account__c =tAcc.Id, Application__c = tApplication.Id, primary__c = true);
        insert tAppAcc_valid;
        //System.assertEquals(1, [select count() from Application_Account_Role__c]);
        System.assertEquals(1, [select count() from Application_Account_Role__c]);
        //System.assertEquals(tAcc.Id, [select Id, Applications_Accounts__c from Application__c where Id = :tApplication.Id].Applications_Accounts__c);
        System.assertEquals(null, [select Id, Applications_Accounts__c from Application__c where Id = :tApplication.Id].Applications_Accounts__c);
        
        tAppAcc_valid.Primary__c = false;
        update tAppAcc_valid;
        System.assertEquals(null, [select Id, Applications_Accounts__c from Application__c where Id = :tApplication.Id].Applications_Accounts__c);
    }
    
    static testMethod void deletePrimaryAccountRoleNullsAccount(){ 
    
        Account tAcc = new Account(Name = 'Account_ApplicationAccountTriggerTest');
        insert tAcc;
        
        User testUser = TestServices.createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = TestServices.createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);
        Opportunity opp = TestServices.createTestOpportunity('Test Opp', 'Closed Won', 'Indianapolis', true);
        Application__c tApplication = TestServices.createTestApplication(opp.Id, 'Shull', true);
        
        Application_Account_Role__c tAppAccount= new Application_Account_Role__c(Name = 'App Account 1_ApplicationAccountTriggerTest', Account__c =tAcc.Id, Application__c = tApplication.Id, primary__c = true);
        insert tAppAccount;
        
        //System.assertEquals(tAcc.Id, [select Id,Applications_Accounts__c from Application__c where Id = :tApplication.Id].Applications_Accounts__c);
        
        Delete tAppAccount;
        System.assertEquals(null, [select Id,Applications_Accounts__c from Application__c where Id = :tApplication.Id].Applications_Accounts__c);
    }
    
    static testMethod void bulkinsertApplicationAccounts() {
        Account tAcc = new Account(Name = 'Account_ApplicationAccountTriggerTest');
        insert tAcc;
        
        User testUser = TestServices.createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = TestServices.createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);
        Opportunity opp = TestServices.createTestOpportunity('Test Opp', 'Closed Won', 'Indianapolis', true);
        Application__c tApplication = TestServices.createTestApplication(opp.Id, 'Shull', true);
        
        LIST<Application_Account_Role__c> tprimaryAppAccList = new List<Application_Account_Role__c>();
        for(Integer i =0; i<201; i++)
            tprimaryAppAccList.add(new Application_Account_Role__c(Name = 'App Account 1_ApplicationAccountTriggerTest'+i, Account__c =tAcc.Id, Application__c = tApplication.Id, primary__c = false));
                                                
        insert tprimaryAppAccList;
        
        System.assertEquals(201,[select count() from Application_Account_Role__c]);
    }   
}