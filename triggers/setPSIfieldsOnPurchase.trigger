trigger setPSIfieldsOnPurchase on Purchase__c (before insert) {

    List<Purchase__c> purs = Trigger.new;
    List<String> vids = new List<String>();
    Map<String, Purchase__c> pLookUp= new Map<String,Purchase__c>();
    for(Purchase__c pur: purs){
        vids.add(pur.source_id__c);
        pLookUp.put(pur.source_id__c, pur);
    }
    List<Inspection_Request__c> irList = [SELECT id, vehicle_id__c, Purchase__c, Order_Complete_date__c, order_request_date__c, inspection_company_name__c  
                                            FROM Inspection_request__c 
                                           WHERE vehicle_Id__c in :vids 
                                             and (inspection_type__c = 'PSI' OR inspection_type__c = 'PDI')                                            
                                        order by vehicle_id__c, order_request_date__c];
    
    if(irList.size() > 0){
       for(Inspection_Request__c ir: irList){
          
          Purchase__c p = pLookUp.get(ir.vehicle_id__c);
          p.psi_ordered_date__c = ir.order_request_date__c;
          p.psi_completed_date__c = ir.order_complete_date__c;
          p.psi_inspection_company_name__c = ir.inspection_company_name__c;
          
       }
      
    }

}