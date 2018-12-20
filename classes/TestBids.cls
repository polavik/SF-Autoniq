@isTest
private class TestBids {

    static testMethod void myUnitTest() {
    
    Asset__c a = new Asset__c(Name = 'VIN1234567980Test', Source_Id__c = '11223322');
    insert a; 
    
    Bids__c b = new Bids__c(Name = 'assetBidTest', Proxy_ID__c = 'abTest', Vehicle_Id__c = '11223322');
    insert b;


    List<Bids__c> blist = new List<Bids__c>();
    Bids__c bid = new Bids__c();
    bid.Name = 'My test bid3';
    bid.Proxy_ID__c = 'Test1234521ProxyID';
    bid.Vehicle_Id__c = '98989891';
    blist.add(bid);
    
    Bids__c bid1 = new Bids__c();  
    bid1.Name = 'My test bid1';
    bid1.Proxy_ID__c = 'Te1234501ProxyID';
    bid1.Vehicle_Id__c = '989898010';
    blist.add(bid1);
    Bids__c bid2 = new Bids__c();
    bid2.Name = 'My test bid2';
    bid2.Proxy_ID__c = 'T123450421ProxyID';
    bid2.Vehicle_Id__c = '989898891';
    blist.add(bid2);
   

    insert(blist);
  

    }
}