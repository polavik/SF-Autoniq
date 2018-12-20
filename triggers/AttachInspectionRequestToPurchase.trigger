trigger AttachInspectionRequestToPurchase on Purchase__c (after insert) {

    List<Purchase__c> purs = Trigger.new;
    List<String> vids = new List<String>();
    Map<String, Purchase__c> pLookUp= new Map<String,Purchase__c>();
    for(Purchase__c pur: purs){
        vids.add(pur.source_id__c);
        pLookUp.put(pur.source_id__c, pur);
    }
    List<Inspection_Request__c> irList = [SELECT id, vehicle_id__c, Purchase__c FROM Inspection_request__c WHERE vehicle_Id__c in :vids];
    List<Inspection_Request__c> updateList = new List<Inspection_Request__C>();
    if(irList.size() > 0){
       for(Inspection_Request__c ir: irList){
          
          ir.Purchase__c = pLookUp.get(ir.vehicle_id__c).id;
          updateList.add(ir);
       }
       update updateList;
    }

}