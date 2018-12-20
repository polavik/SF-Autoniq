@isTest
private class TestBatch_VehSold_FieldsRelUpdate {

    static testmethod void test1() {
             
       Test.startTest();
       Batch_VehSold_FieldsRelationUpdate objBatch_VehSold_FieldsRelationUpdate = new Batch_VehSold_FieldsRelationUpdate();
       Database.executeBatch(objBatch_VehSold_FieldsRelationUpdate);
       Test.stopTest();
       
    }
    static testmethod void test2() {
    
       
       String UserId = UserInfo.getUserId();
       String UserName = UserInfo.getUserName();
       
       Account acct1 = new Account(Name='Test Account1',Master_Index__c='100');
       Insert acct1;
        
         Auction_Detail__c ad = new Auction_Detail__c(
                                Op_Account_ATC_ORG_ID__c = '100',
                                Op_Auction_ATC_ORG_ID__c = '100',
                                Op_Inside_Sales_Queue_USERNAME__c = UserName,
                                Op_Inside_Sales_Rep_USERNAME__c = UserName,
                                Op_Outside_Sales_Rep_USERNAME__c = UserName,
                                Is_Migrated_Record__c = true,
                                Name='Auction Detail 1',
                                Account__c=acct1.Id,
                                Source_Id__c='123'
                            );
       insert ad; 
       
       Vehicles_Sold_ADESA_Auction__c  objVehSold = new Vehicles_Sold_ADESA_Auction__c (
                                Op_Auction_Site_ATC_ORG_ID__c = '100',
                                Op_Account_ATC_ORG_ID__c = '100',                                
                                Name='Vehicles Sold-ADESA Auction 1',
                                ADESA_Auction_Detail__c = ad.id,                                
                                Is_Migrated_Record__c = true,
                                Source_Id__c='123'
                            );          
        Insert objVehSold;
        
        
        
       Test.startTest();
        Batch_VehSold_FieldsRelationUpdate objBatch_VehSold_FieldsRelationUpdate = new Batch_VehSold_FieldsRelationUpdate();
       Database.executeBatch(objBatch_VehSold_FieldsRelationUpdate);
       Test.stopTest();
       
    }
}