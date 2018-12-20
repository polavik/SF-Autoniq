@isTest
private class TestBatch_AD_RepStatus_Update {

    static testmethod void test1() {
             
       Test.startTest();
       Batch_AD_RepStatus_Update objBatch_AD_RepStatus_Update = new Batch_AD_RepStatus_Update();
       Database.executeBatch(objBatch_AD_RepStatus_Update);
       Test.stopTest();
       
    }
    static testmethod void test2() {
       
       
       Account acct1 = TestUtility.createAccount(1, false);
       Insert acct1;
       
       Auction_Detail__c ad = TestUtility.createAuctionDetail(1, acct1.id, false);
       ad.MigrationFlag__c = 1;
       insert ad; 
        
        Rep_Status_ADESA_Auction__c Adesa1 = TestUtility.createRepStatusAdesaAuction(1, false);
        Adesa1.ADESA_Auction_Detail__c = ad.id;
        Adesa1.Account__c = acct1.Id;
        Adesa1.Is_Migrated_Under_New_SourceId__c = 2;  
        
        Rep_Status_ADESA_Auction__c  objRepStatus = TestUtility.createRepStatusAdesaAuction(1, false);
        objRepStatus.Op_Account_ATC_ORG_ID__c = '100';
        objRepStatus.Op_Contact_LOGIN_ID__c = '100';
        objRepStatus.ADESA_Auction_Detail__c = ad.id;
        
        objRepStatus.Is_Migrated_Under_New_SourceId__c = 2;
        List<Rep_Status_ADESA_Auction__c> ListRsaa = new List<Rep_Status_ADESA_Auction__c>();
        ListRsaa.add(Adesa1);
        ListRsaa.add(objRepStatus);
             
        Insert ListRsaa ;        
        
       Test.startTest();
       Batch_AD_RepStatus_Update objBatch_AD_RepStatus_Update = new Batch_AD_RepStatus_Update();
       Database.executeBatch(objBatch_AD_RepStatus_Update);
       Test.stopTest();
       
    }
}