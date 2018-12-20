@isTest
private class TestPurchaseTrigger {

    static testMethod void myUnitTestforPurchase() {
        
        Asset__c at = new Asset__c(Name='VIN1234567980Test', Source_Id__c='OL-123456789', Vehicle_Id__c ='123456789');
        insert at;
              
        Auction__c a = new Auction__c(Name='AuctionTest01', Auction_Id__c='A01010101', Asset__c=at.id,Auction_Status_Name__c='Auction');
        // Auction
        insert a;   
        
        at.Vehicle_Id__c='321456';
        update at;
        
        a.Name='AuctionUpdate01';
        update a; 
        
         Test.startTest();
         
        Purchase__c p = new Purchase__c (Name=at.Name, Source_Id__c='OL-VIN1234567980Test', Vehicle_ID__c ='123456789');
        
        insert p;
        
        String amsRecordType = Utils.getRecordTypeId('Purchase__c', 'ADESA AMS Purchase');    
        p.recordTypeId = amsRecordType;
        p.Segment_Name__c = 'ADESA INLANE';
        p.Private_Label__c = 'PL001';
        //p.ATC_Buyer_Contact__r.Openlane_US_Purchase_Last_120__c = true;
        //p.ATC_Buyer_Contact__r.Openlane_CA_Purchase_Last_120__c = true;
        //p.Auction_Detail__c =a.Id;
        p.ATC_Sale_Date__c = datetime.now();
        p.Title_Received__c = System.today();
        update p;
        p.Contract_ID__c = '123456';
        p.Buyer_Auction_Detail_Source_Id__c = '300095-248529';
        p.Seller_Auction_Detail_Source_Id__c = '300095-248529';
        p.AMS_Inventory_ID__c = '12345';
        p.Buyer_Contact_AAID__c = '54321';
        p.Seller_Contact_AAID__c = '5999998';        
        p.Hi_Res_Images_Fee__c = 13.1;
        p.ATC_Seller_Adesa_com_Detail__c = new Adesa_com_detail__c(ATC_Organization_ID__c='300095').Id;
        p.ATC_Buyer_Adesa_com_Detail__c = new Adesa_com_detail__c(ATC_Organization_ID__c='23456').Id;

        update p;
        p.Purchase_Type__c = 'IAA';
        p.Home_Branch__c = 'IAA';
        p.Problem_Status__c = '18';
        update p;
        p.Problem_Status__c = '24';
        update p;
        p.Problem_Status__c = '31';
        update p;
        p.Problem_Status__c = '414';
        update p;
      //  p.Segment_Name__c = 'inlane';
      //  update p;
      Test.stopTest();
     }
}