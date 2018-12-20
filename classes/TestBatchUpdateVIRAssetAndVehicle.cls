@isTest
private class TestBatchUpdateVIRAssetAndVehicle  {

    static testmethod void test1() {
             
       Test.startTest();
       BatchUpdateVIRAssetAndVehicle objBatchUpdateVIRAssetAndVehicle = new BatchUpdateVIRAssetAndVehicle('',true,'lily.wu@openlane.com');
       Database.executeBatch(objBatchUpdateVIRAssetAndVehicle);
       Test.stopTest();
       
    }
    static testmethod void test2() {    
         
              
       List<VIR__c> List_VIRs = new List<VIR__c>();
       
       
        
            VIR__c v = new VIR__c();    
            v.VIR_Id__c = '123456-9362';    
            v.Dealer_Org_Id__c = '9362';    
            v.Vehicle_ID__c = '123456';    
            v.name = 'nmlgfedbca123';    
            insert v;   
        
                
       Asset__c asset = new Asset__c(Name='asset1',Source_Id__c='123456');
        Insert asset;
        
         Map<String,String>  mapVehicleIdToAssetSFID= new Map<String, String>(); 
        mapVehicleIdToAssetSFID.put('123456',asset.Id); 

    
                
       for (Integer i=0;i<1;i++) {
           v.asset__c= mapVehicleIdToAssetSFID.get('123456');                   
           v.vehicle__c = mapVehicleIdToAssetSFID.get('123456');                     

        List_VIRs.add(v);
        } 
        
       
      update List_VIRs;     
      
       

       Test.startTest();
       BatchUpdateVIRAssetAndVehicle objBatchUpdateVIRAssetAndVehicle = new BatchUpdateVIRAssetAndVehicle('',true,'lily.wu@openlane.com');
       Database.executeBatch(objBatchUpdateVIRAssetAndVehicle);
       Test.stopTest();
       
    }
}