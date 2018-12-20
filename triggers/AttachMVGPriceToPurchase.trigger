trigger AttachMVGPriceToPurchase on Purchase__c (after insert) {

    List<Purchase__c> pList = Trigger.new;
    List<String> vids = new List<String>();
    Map<String, Purchase__c> purchases = new Map<String, Purchase__c>();
    for(Purchase__c p: pList){
        if(p.vehicle_id__c != null && p.vehicle_id__c != ''){
            vids.add(p.vehicle_id__c);
        }
        purchases.put(p.vehicle_id__c, p);
    }
    List<MVG_PRICE__c> mvgList = [SELECT id, vehicle_id__c, Purchase__c FROM MVG_PRICE__c WHERE vehicle_Id__c in :vids];
    List<MVG_PRICE__c> updateList = new List<MVG_PRICE__C>();
    for(MVG_PRICE__c mvg: mvgList){
       mvg.Purchase__c = purchases.get(mvg.vehicle_id__c).id;
       updateList.add(mvg);
    }
    update updateList;

}