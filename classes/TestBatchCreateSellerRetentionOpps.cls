@isTest private class TestBatchCreateSellerRetentionOpps  {
    static testMethod void testBatch1() {
        Test.StartTest();
        BatchCreateSellerRetentionOpps om = new BatchCreateSellerRetentionOpps();
        om.query = om.query + ' LIMIT 200 ';
        Database.executeBatch(om);
        Test.StopTest(); 
    }
    
     static testMethod void testBatch2() {
       Test.StartTest();
                
       Account acct1 = TestUtility.createAccount(1, false);
       acct1.Master_Index__c = '100';  
         
       User user = TestUtility.createTestUser(false);  
       Insert user;
         
       acct1.Owner = user; 
       acct1.OwnerId = user.id;
       Insert acct1;
        
       Adesa_com_Detail__c Adesa1 = TestUtility.createAdesaComDetail(1, false, '100', acct1.Id); 
       Insert Adesa1;
        
       Contact Contact1 = new Contact(LastName='Patel',OpenLane_Details__c=Adesa1.Id,Login_ID__c='100');
       Insert Contact1;
         
       Car_Group_Config__c carGroup =  TestUtility.createCarGroup(1, false, 2);
       Insert carGroup; 
      
       //Asset__c Asset1 = new Asset__c(Name='Asset1',Source_Id__c='OL',Buyer_ADESA_com_Detail__c=Adesa1.Id,Consignee_ADESA_com_Detail__c=Adesa1.Id,Grounding_Dealer_ADESA_com_Detail__c=Adesa1.Id,Partner_ADESA_com_Detail__c=Adesa1.Id,Seller_ADESA_com_Detail__c=Adesa1.Id);        
       Asset__c Asset1 = TestUtility.createAsset(1, false, 'OL');
       Asset1.Buyer_ADESA_com_Detail__c = Adesa1.Id;
       Asset1.Consignee_ADESA_com_Detail__c = Adesa1.Id;
       Asset1.Grounding_Dealer_ADESA_com_Detail__c = Adesa1.Id;
       Asset1.Partner_ADESA_com_Detail__c = Adesa1.Id;
       Asset1.Car_Group__c = carGroup.id;         
       Asset1.First_Date_in_Auction__c = System.today() - 180;
       Asset1.Seller_Account__c = acct1.id;
       Asset1.Buyer_Account__c = acct1.id;
       Asset1.vehicle_id__c = '123';
       Asset1.Seller_ADESA_com_Detail__c = Adesa1.Id;  
       List<Asset__c> ListAssets = new List<Asset__c>();              
       ListAssets.add(Asset1);        
       insert ListAssets; 
                
       BatchCreateSellerRetentionOpps om = new BatchCreateSellerRetentionOpps();
       om.query = om.query + ' LIMIT 200 ';
       Database.executeBatch(om);
       Test.StopTest(); 
    }
    
}