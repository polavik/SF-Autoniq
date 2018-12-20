@isTest
private class TestBatch_AD_VehilceSold_Update {

    static testmethod void test1() {
             
       Test.startTest();
       Batch_AD_VehilceSold_Update objBatch_AD_VehilceSold_Update = new Batch_AD_VehilceSold_Update();
       Database.executeBatch(objBatch_AD_VehilceSold_Update);
       Test.stopTest();
       
    }
    static testmethod void test2() {
       
       
       Account acct2 = TestUtility.createAccount(1, false);
       Insert acct2;
       
       Auction_Detail__c ad = TestUtility.createAuctionDetail(1, acct2.id, false);                            
       ad.MigrationFlag__c = 1;
       insert ad; 
        
        Vehicles_Sold_ADESA_Auction__c Adesa2 = TestUtility.createVehiclesSoldAdesaAuction(1, false);
        Adesa2.Source_Id__c = '444';
        Adesa2.ADESA_Auction_Detail__c = ad.id;
        Adesa2.Account__c = acct2.Id;
        Adesa2.Is_Migrated_Under_New_SourceId__c = 2;       

        
       Vehicles_Sold_ADESA_Auction__c  objVehilceSold = TestUtility.createVehiclesSoldAdesaAuction(1, false);
        objVehilceSold.Source_Id__c = '555';
        objVehilceSold.ADESA_Auction_Detail__c = ad.id;
        objVehilceSold.Account__c = acct2.Id;
        objVehilceSold.Is_Migrated_Under_New_SourceId__c = 2;
 
       Vehicles_Sold_ADESA_Auction__c  objVehilceSold1 = TestUtility.createVehiclesSoldAdesaAuction(1, false);
        objVehilceSold1.Source_Id__c = '556';
        objVehilceSold1.ADESA_Auction_Detail__c = ad.id;
        objVehilceSold1.Is_Migrated_Under_New_SourceId__c = 2;
        List<Vehicles_Sold_ADESA_Auction__c> ListVpaa = new List<Vehicles_Sold_ADESA_Auction__c>();
        ListVpaa.add(Adesa2);
        ListVpaa.add(objVehilceSold);
        ListVpaa.add(objVehilceSold1);
             
        Insert ListVpaa ;        
        
        
       Test.startTest();
       Batch_AD_VehilceSold_Update objBatch_AD_VehilceSold_Update = new Batch_AD_VehilceSold_Update();
       Database.executeBatch(objBatch_AD_VehilceSold_Update);
       Test.stopTest();
       
    }
}