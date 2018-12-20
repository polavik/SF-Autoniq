@isTest
private class TestAttachInspectionRequestToPurchase{
   private static testMethod void testInsertPurchase(){
      Test.startTest();
      purchase__c p = TestAttachInspectionRequestToPurchase.createPurchaseTestObject();
      Inspection_Request__c ir = TestAttachInspectionRequestToPurchase.createInspectionRequestTestObject(p.Vehicle_id__c);
      insert p;
      List<Inspection_Request__c> irResult = [SELECT purchase__c FROM Inspection_Request__c WHERE VEHICLE_ID__C = :p.vehicle_id__c];
      system.assert(irResult != null);
      system.assert(irResult.size()==1);
      //FIXME: system.assertEquals(p.id, irResult.get(0).purchase__c);
      Test.stopTest();
   }
   
   private static purchase__c createPurchaseTestObject(){
       List<purchase__c> pList = [SELECT id, vehicle_id__c FROM purchase__c WHERE Source_ID__c = '12345'];
       purchase__c p = null;
       if(pList != null && pList.size() == 1){
         p = pList.get(0);
         delete p;
       }else{
         p =  new purchase__c();
         p.Vehicle_ID__c = '12345';
         p.Source_ID__c='12345';
         p.Name = 'WBAEK13537CN81688';
       }
       return p;
   }
   
   private static Inspection_Request__c createInspectionRequestTestObject(String vehicleId){
       List<Inspection_Request__c> irList = [SELECT id, vehicle_id__c FROM Inspection_Request__c WHERE vehicle_Id__c = :vehicleId];
       Inspection_Request__c ir = null;
       if(irList != null && irList.size() == 1){
         ir = irList.get(0);
       }else{
         ir =  new Inspection_Request__c();
         ir.Vehicle_ID__c = vehicleId;
         ir.Name = 'WBAEK13537CN81688';
         insert ir;
       }
       return ir;
   }
}