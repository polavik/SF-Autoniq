@isTest
private class TestBatch_Purchase_Update  {

    static testmethod void test1() {
             
       Test.startTest();
       Batch_Purchase_Update objBatch_Purchase_Update  = new Batch_Purchase_Update();
       Database.executeBatch(objBatch_Purchase_Update);
       Test.stopTest();
       
    }
       static testmethod void test2() {
       
       
       Account acct2 = new Account(Name='Test Account2',Master_Index__c='100');
       Insert acct2;
       
       Auction_Detail__c ad = new Auction_Detail__c(
                                Op_Account_ATC_ORG_ID__c = '100',
                                Op_Auction_ATC_ORG_ID__c = '100',                                
                                Name='Auction Detail 2',
                                Account__c=acct2.Id,
                                Source_Id__c='123'
                            );
       insert ad; 
        
        purchase__c Purchase_Object = new purchase__c(Name='Purchase2',Source_Id__c='444',buyer_auction_detail_source_id__c=ad.Source_Id__c ,Seller_Auction_Detail_Source_Id__c=ad.Source_Id__c);

        Insert Purchase_Object;        

        
               
        
        
       Test.startTest();
       Batch_Purchase_Update ObjBatch_Purchase_Update = new Batch_Purchase_Update();
       Database.executeBatch(ObjBatch_Purchase_Update);
       Test.stopTest();
       
    }
   
}