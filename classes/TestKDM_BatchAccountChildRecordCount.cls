@isTest
private class TestKDM_BatchAccountChildRecordCount {

    static testmethod void test1() {
             
       Test.startTest();
       KDM_BatchAccountChildRecordCount b = new KDM_BatchAccountChildRecordCount('',false,'',false);
       Database.executeBatch(b,5);
       Test.stopTest();
       
    }
    static testmethod void test2() {
        
        //Account
        Account acct1 = new Account(Name='Test Account1',Master_Index__c='100');
        Insert acct1;
       
        Account acct2 = new Account(Name='Test Account2',Master_Index__c='200');
        Insert acct2;
        
        Account_Child_Summary__c objACS = new Account_Child_Summary__c();
        objACS.Account__c = acct1.Id;
        objACS.AccountId__c = acct1.Id;
        objACS.Name = acct1.Name;
        Insert objACS;   
        
        Test.startTest();
        KDM_BatchAccountChildRecordCount b = new KDM_BatchAccountChildRecordCount('',true,'djpatel@openlane.com',false);
        Database.executeBatch(b,5);
        Test.stopTest();
       
    }
    static testmethod void test3() {
        
        //Account
        Account acct1 = new Account(Name='Test Account1',Master_Index__c='100');
        Insert acct1;
       
        Account acct2 = new Account(Name='Test Account2',Master_Index__c='200');
        Insert acct2;
        
        Account_Child_Summary__c objACS = new Account_Child_Summary__c();
        objACS.Account__c = acct1.Id;
        objACS.AccountId__c = acct1.Id;
        objACS.Name = acct1.Name;
        Insert objACS;   
        
        Test.startTest();
        KDM_BatchAccountChildRecordCount b = new KDM_BatchAccountChildRecordCount('',true,'djpatel@openlane.com',true);
        Database.executeBatch(b,5);
        Test.stopTest();
       
    }
}