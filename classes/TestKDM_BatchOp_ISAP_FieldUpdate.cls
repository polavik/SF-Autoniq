@isTest
private class TestKDM_BatchOp_ISAP_FieldUpdate {

    static testmethod void test1() {
             
       Test.startTest();
       KDM_BatchOp_ISAP_FieldUpdate b = new KDM_BatchOp_ISAP_FieldUpdate('',false,'');
       Database.executeBatch(b);
       Test.stopTest();
       
    }
    
    static testmethod void test2() {
    
        Account acct1 = new Account(Name='Test AccountISAP',Master_Index__c='199');
        Insert acct1;        
        
        Adesa_com_Detail__c Adesa1 = new Adesa_com_Detail__c(Name='Adesa1',ATC_Organization_ID__c='100',Account__c=acct1.Id);
        Insert Adesa1;      
       
        
        
        Inside_Sales_Auction_Performance__c obj = new Inside_Sales_Auction_Performance__c();
        obj.Op_Account_ATC_Org_ID__c='100';        
        obj.Is_Migrated_Record__c = true;        
        Insert obj;
        
        Test.startTest();
        KDM_BatchOp_ISAP_FieldUpdate b = new KDM_BatchOp_ISAP_FieldUpdate('',true,'');
        Database.executeBatch(b);
        Test.stopTest();       
    }
}