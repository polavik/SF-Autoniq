trigger BidsBeforeInsert on Bids__c (before insert, before update) 
{
   
    List<String> vehicleIds = new List<String>();
    Map<String,ID> vehicle2upd = new Map<String,ID>();
    Map<String,Bids__c> UpdateList = new Map<String,Bids__C>();
    System.debug('Start Bid Before Insert Event');
    for(Bids__c bid: Trigger.new) {
        //System.debug(bid.vehicle__c); 
        //System.debug(bid.vehicle_Id__c); 
        //System.debug(bid.vehicle__r.source_Id__c); 
        if (bid.vehicle_Id__c != null ) {
            vehicleIds.add(bid.vehicle_Id__c);
            UpdateList.put(bid.vehicle_Id__c,bid);
            System.debug('Bid Before Insert Event');
        }   
        if (bid.Name == null ) {
            bid.Name = bid.Proxy_ID__c;
        }
        
    }
    if (vehicleIds.size() > 0)
    {
      vehicle2upd = VehicleUtils.checkVehicle(vehicleIds);
      System.debug('Dummy Vehicle creation!');
      For( String vid: vehicleIds)
      {
          Bids__c b2upd = UpdateList.get(vid);
          if (b2upd.vehicle__c == null) {
              b2upd.vehicle__c = vehicle2upd.get(vid);
              //System.debug(b2upd.vehicle_Id__c);
              //System.debug(b2upd.vehicle__c);
              //System.debug(b2upd.vehicle__r.source_Id__c); 
          }
      }
    }
    
    for(Bids__c bid: Trigger.new) {
        if (bid.vehicle_Id__c != null && bid.vehicle__c == null) {
            bid.vehicle__c = vehicle2upd.get(bid.vehicle_Id__c);
        }
    }
}