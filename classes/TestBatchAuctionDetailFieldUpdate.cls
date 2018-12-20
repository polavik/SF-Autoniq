@isTest
private class TestBatchAuctionDetailFieldUpdate {

    static testmethod void test1() {
             
       Test.startTest();
       BatchAuctionDetailFieldsRelationUpdate objBatchAuctionDetailFieldsRelationUpdate = new BatchAuctionDetailFieldsRelationUpdate('',true,'Dipesh.patel@openlane.com');
       Database.executeBatch(objBatchAuctionDetailFieldsRelationUpdate);
       Test.stopTest();
       
    }
    static testmethod void test2() {
    
       //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());        
              
       Auction_Detail__c[] ListAuction_Detail = new List<Auction_Detail__c>();
       String UserId = UserInfo.getUserId();
       String UserName = UserInfo.getUserName();
       
        Property__c objProperty1 = new Property__c(Property_Id__c='migrated.case.default.owner.username',Property_Value__c=UserName);
        insert objProperty1 ; 
        
        Property__c objProperty2 = new Property__c(Property_Id__c='username.patch',Property_Value__c='@');
        insert objProperty2 ;   
        
       Account acct1 = new Account(Name='Test Account1',Master_Index__c='100');
        Insert acct1;
    
        Adesa_com_Detail__c Adesa1 = new Adesa_com_Detail__c(Name='Adesa1',ATC_Organization_ID__c='100',Account__c=acct1.Id);
        Insert Adesa1;
        
        Adesa_com_Detail__c Adesa2 = new Adesa_com_Detail__c(Name='Adesa2',ATC_Organization_ID__c='500',Account__c=acct1.Id);
        Insert Adesa2;
        
       for (Integer i=0;i<2;i++) {
           Auction_Detail__c ad = new Auction_Detail__c(
                                Op_Account_ATC_ORG_ID__c = '100',
                                Op_Auction_ATC_ORG_ID__c = '500',
                                Op_Inside_Sales_Queue_USERNAME__c = UserName,
                                Op_Inside_Sales_Rep_USERNAME__c = UserName,
                                Op_Outside_Sales_Rep_USERNAME__c = UserName,
                                Is_Migrated_Record__c = true,
                                Name='Auction Detail '+i,
                                Account__c=acct1.Id,
                                Source_Id__c=String.valueof(i)
                            );                          

        ListAuction_Detail.add(ad);
        } 
        
       
       insert ListAuction_Detail;     
      
       

       Test.startTest();
        BatchAuctionDetailFieldsRelationUpdate objBatchAuctionDetailFieldsRelationUpdate = new BatchAuctionDetailFieldsRelationUpdate('',true,'Dipesh.patel@openlane.com');
       Database.executeBatch(objBatchAuctionDetailFieldsRelationUpdate);
       Test.stopTest();
       
    }
}