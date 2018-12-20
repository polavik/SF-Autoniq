@isTest
private class TestAttachMVGPriceToPurchase{
   private static testMethod void testInsertPurchase(){
      Test.startTest();
      purchase__c p = TestAttachMVGPriceToPurchase.createPurchaseTestObject();
      MVG_Price__c mvg = TestAttachMVGPriceToPurchase.createMVGPriceTestObject(p.Vehicle_id__c);
      insert p;
      List<MVG_Price__c> mvgResult = [SELECT purchase__c FROM MVG_PRICE__C WHERE VEHICLE_ID__C = :p.vehicle_id__c];
      system.assert(mvgResult != null);
      system.assert(mvgResult.size()==1);
      //purchase__c resultMvgp = mvgResult.get(0).purchase__c;
      //system.assertEquals(resultMvgp, p);
    // create a vehicle at auction object
    // create a mvg price object
      Test.stopTest();
   }
   
   private static purchase__c createPurchaseTestObject(){
   	  List<purchase__c> pList = [SELECT id, vehicle_id__c FROM purchase__c WHERE vehicle_Id__c = '12345'];
   	  purchase__c p = null;
   	  if(pList != null && pList.size() == 1){
   	  	p = pList.get(0);
   	  	delete p;
   	  }else{
   	  	p =  new purchase__c();
   	  	p.Vehicle_ID__c = '12345';
   	  	p.Source_id__c = '12345';
   	  	p.Name = 'WBAEK13537CN81688';
   	  }
   	  return p;
   }
   
   private static MVG_Price__c createMVGPriceTestObject(String vehicleId){
   	  List<MVG_Price__c> mvgList = [SELECT id, vehicle_id__c, purchase__c FROM MVG_Price__c WHERE vehicle_Id__c = :vehicleId];
   	  MVG_Price__c mvg = null;
   	  if(mvgList != null && mvgList.size() == 1){
   	  	mvg = mvgList.get(0);
   	  	//mvg.Vehicle_At_Auction__r = null;
   	  }else{
   	  	mvg =  new MVG_Price__c();
   	  	mvg.Vehicle_ID__c = vehicleId;
   	  	mvg.Name = 'WBAEK13537CN81688';
   	  	insert mvg;
   	  }
   	  return mvg;
   }
}