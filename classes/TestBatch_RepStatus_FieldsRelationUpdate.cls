@isTest
private class TestBatch_RepStatus_FieldsRelationUpdate {

    static testmethod void test1() {
             
       Test.startTest();
       Batch_RepStatus_FieldsRelationUpdate objBatch_RepStatus_FieldsRelationUpdate = new Batch_RepStatus_FieldsRelationUpdate();
       Database.executeBatch(objBatch_RepStatus_FieldsRelationUpdate);
       Test.stopTest();
       
    }
    static testmethod void test2() {
    
       
       String UserId = UserInfo.getUserId();
       String UserName = UserInfo.getUserName();
       
       Account acct1 = new Account(Name='Test Account1',Master_Index__c='100');
       Insert acct1;
        
        Adesa_com_Detail__c Adesa1 = new Adesa_com_Detail__c(Name='Adesa1',ATC_Organization_ID__c='100',Account__c=acct1.Id);
        Insert Adesa1;
        
        Contact Contact1 = new Contact(LastName='Patel',OpenLane_Details__c=Adesa1.Id,Login_ID__c='100');
        Insert Contact1;
        
        Asset__c Asset1 = new Asset__c(Name='Asset1',Source_Id__c='OL',Buyer_ADESA_com_Detail__c=Adesa1.Id,Consignee_ADESA_com_Detail__c=Adesa1.Id,Grounding_Dealer_ADESA_com_Detail__c=Adesa1.Id,Partner_ADESA_com_Detail__c=Adesa1.Id,Seller_ADESA_com_Detail__c=Adesa1.Id);
        Insert Asset1;
        
        Auction__c Aux1 = new Auction__c(Name='Aux1',Asset__c=Asset1.id,Highest_Bidder_Adesa_ORG__c=Adesa1.Id);
        Insert Aux1;
        
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
       
       Rep_Status_ADESA_Auction__c  objRepStatus = new Rep_Status_ADESA_Auction__c (
                                Op_Account_ATC_ORG_ID__c = '100',
                                Op_Auction_ATC_ORG_ID__c = '100',
                                Op_Contact_LOGIN_ID__c = '100',
                                Name='Rep_Status_ADESA_Auction 1',
                                ADESA_Auction_Detail__c = ad.id,
                                Is_Migrated_Record__c = true
                            );          
        Insert objRepStatus;
        
        
        
       Test.startTest();
        Batch_RepStatus_FieldsRelationUpdate objBatch_RepStatus_FieldsRelationUpdate = new Batch_RepStatus_FieldsRelationUpdate();
       Database.executeBatch(objBatch_RepStatus_FieldsRelationUpdate);
       Test.stopTest();
       
    }
}