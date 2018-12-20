@isTest
private class TestBatch_AD_VehilcePurchased_Update {

    static testmethod void test1() {
             
       Test.startTest();
       Batch_AD_VehilcePurchased_Update objBatch_AD_VehilcePurchased_Update = new Batch_AD_VehilcePurchased_Update();
       Database.executeBatch(objBatch_AD_VehilcePurchased_Update);
       Test.stopTest();
       
    }
    static testmethod void test2() {
            
       Account acct3 = TestUtility.createAccount(1, false);
       Insert acct3;
       
       Auction_Detail__c ad = TestUtility.createAuctionDetail(1, acct3.id, false); 
       ad.Op_Account_ATC_ORG_ID__c = '100';
       ad.Account__c = acct3.Id;
       ad.Source_Id__c = '123';
       ad.MigrationFlag__c = 1;
       insert ad; 
        
        Vehicles_Purchased_ADESA_Auction__c Adesa3 = TestUtility.createVehiclesPurchasedAdesaAuction(1, false);
        Adesa3.Source_Id__c = '222';
        Adesa3.ADESA_Auction_Detail__c = ad.id;
        Adesa3.Account__c = acct3.Id;
        Adesa3.Is_Migrated_Under_New_SourceId__c = 2;        
      
       Vehicles_Purchased_ADESA_Auction__c  objVehiclePurchased = TestUtility.createVehiclesPurchasedAdesaAuction(2, false);
        objVehiclePurchased.Source_Id__c = '333';
        objVehiclePurchased.ADESA_Auction_Detail__c = ad.id;
        objVehiclePurchased.Is_Migrated_Under_New_SourceId__c = 2;
           
       Vehicles_Purchased_ADESA_Auction__c  objVehiclePurchased1 = TestUtility.createVehiclesPurchasedAdesaAuction(3, false);
        objVehiclePurchased1.Source_Id__c = '334';
        objVehiclePurchased1.ADESA_Auction_Detail__c = ad.id;
        objVehiclePurchased1.Is_Migrated_Under_New_SourceId__c = 2;           
        
        List<Vehicles_Purchased_ADESA_Auction__c> ListVpaa = new List<Vehicles_Purchased_ADESA_Auction__c>();
        ListVpaa.add(Adesa3);
        ListVpaa.add(objVehiclePurchased);
        ListVpaa.add(objVehiclePurchased1);
             
        Insert ListVpaa ;
               
       Test.startTest();
       Batch_AD_VehilcePurchased_Update objBatch_AD_VehilcePurchased_Update = new Batch_AD_VehilcePurchased_Update();
       Database.executeBatch(objBatch_AD_VehilcePurchased_Update);
       Test.stopTest();
       
    }
}