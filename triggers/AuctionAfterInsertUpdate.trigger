trigger AuctionAfterInsertUpdate on Auction__c (after insert, after update) {
 List<Asset__c> vehiclesToUpdate = new List<Asset__c>();
 List<Asset__c> vehicles = new List<Asset__c>();
  List<ID> strVehicleIds= new List<ID>();
  Map<String, ID> relatedVehicles = new Map<String, ID>();    
  Map<String, Auction__c> AuctionMap =  new Map<String, Auction__c>();
  Map<String, Asset__c> VehicleListMap =  new Map<String, Asset__c>();
  
  for (Auction__c a : Trigger.new)
  {
    if ('Auction'.equalsIgnoreCase(a.Auction_Status_Name__c) && a.VehicleId__c != null && a.VehicleId__c != '' ) {
        AuctionMap.put(a.VehicleId__c, a);
        relatedVehicles.put(a.VehicleId__c, a.Id);       }       
    //System.debug('VehicleIdsList'+ strVehicleIds);
  }


  Set<String> vehIds = relatedVehicles.keySet();
      System.debug('vehids ...'+ vehIds );
     if (vehIds != null )
    {
      //List<Asset__c> vehicles = [select id, vehicle_id__c,Auction__c from Asset__c v where v.vehicle_id__c in :vehIds]; 
      vehicles = [select id, vehicle_id__c,Auction__c from Asset__c v where v.vehicle_id__c in :vehIds]; 
    }

    for(Asset__c v: vehicles){
        VehicleListMap.put(v.vehicle_id__c,v); 
    }

    for(Asset__c v: vehicles){

        Asset__c vehicle_obj = VehicleListMap.get(v.vehicle_id__c);
        v.Auction__c = AuctionMap.get(vehicle_obj.vehicle_id__c).id;
        vehiclesToUpdate.add(v);
    }
    
   if(vehiclesToUpdate.size() > 0){
        Database.update(vehiclesToUpdate);
    }
  
}