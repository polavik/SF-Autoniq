trigger PopulateVehicleStatusForVO on vehicles_opportunities__c (before update, before insert) {
// check to see if the vehicle's iteration is same as 


   List<vehicles_opportunities__c> vos = trigger.new;
   Map<string, vehicles_opportunities__c> vom = new Map<string, vehicles_opportunities__c>();
   for(vehicles_opportunities__c vo: vos){
      if (vo.vehicle_id__c!=null)
    {  vom.put(vo.vehicle_id__c, vo);
    }
   }
   
   Set<String> vids = vom.keySet();
   List<Asset__c> vs = [select id, Source_Id__c, vehicle_status__c, last_update_date_by_partner__c from Asset__c where Source_Id__c in :vids];
   for(Asset__c v: vs){
      vom.get(v.Source_Id__c).vehicle_status__c = v.vehicle_status__c;
      vom.get(v.Source_Id__c).last_update_date_by_partner__c = v.last_update_date_by_partner__c;
   }

   


}