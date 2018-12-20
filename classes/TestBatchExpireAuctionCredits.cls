@isTest
private class TestBatchExpireAuctionCredits  {

    static testmethod void test1() {
             
       Test.startTest();
       BatchExpireAuctionCredits objBatchExpireAuctionCredits = new BatchExpireAuctionCredits ();
       Database.executeBatch(objBatchExpireAuctionCredits);
       Test.stopTest();
       
    }
    static testmethod void test2() {
                    
       Auction_Credit__c ac = TestUtility.createAuctionCredit(false);
       ac.Expires__c=System.today()-5;
       ac.status__c='Available';
       Auction_Credit__c ac1 = TestUtility.createAuctionCredit(false);
       ac1.Expires__c=System.today()-8;
       ac1.status__c='Available';
       List<Auction_Credit__c> ListAc = new List<Auction_Credit__c>();
       ListAc.add(ac);
       ListAc.add(ac1); 
       insert ListAc;         
               
       Test.startTest();
       BatchExpireAuctionCredits objBatchExpireAuctionCredits = new BatchExpireAuctionCredits ();
       Database.executeBatch(objBatchExpireAuctionCredits );
       Test.stopTest();
       
    }
}