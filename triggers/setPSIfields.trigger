trigger setPSIfields on Inspection_request__c (after insert, after update) {

    List<inspection_request__c> irs = Trigger.new;
    List<String> vids = new List<String>();
    Map<String, inspection_request__c> irLookUp= new Map<String,inspection_request__c>();
    for(inspection_request__c ir: irs ){
        if(ir.inspection_type__c == 'PSI' || ir.inspection_type__c == 'PDI'){
           vids.add(ir.vehicle_id__c);
           irLookUp.put(ir.vehicle_id__c, ir);
        }
    }
    //V@A no longer exists
   /* List<Vehicle_at_auction__c> vehs = [select id, vehicle_id__c, psi_ordered_date__c, psi_completed_date__c, psi_inspection_company_name__c 
                                          from vehicle_at_auction__c
                                         where vehicle_id__c in :vids];
*/ 
    List<Purchase__c> purs = [select id, vehicle_id__c, psi_ordered_date__c, psi_completed_date__c, psi_inspection_company_name__c 
                                          from purchase__c
                                         where vehicle_id__c in :vids];  

    /*for(Vehicle_at_auction__c veh: vehs){
        Inspection_request__c ir = irLookUp.get(veh.vehicle_id__c);
        veh.psi_ordered_date__c = ir.order_request_date__c;
        veh.psi_completed_date__c = ir.order_complete_date__c;
        veh.psi_inspection_company_name__c = ir.inspection_company_name__c;
    } */
    
    for(Purchase__c p: purs){
        Inspection_request__c ir = irLookUp.get(p.vehicle_id__c);
        p.psi_ordered_date__c = ir.order_request_date__c;
        p.psi_completed_date__c = ir.order_complete_date__c;
        p.psi_inspection_company_name__c = ir.inspection_company_name__c;
    }                                        
                                         
    //update vehs;
    update purs;                                       
    

}