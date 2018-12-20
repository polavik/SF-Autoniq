trigger VehicleAfterInsertUpdate on Asset__c (after insert, after update) 
{
    List<ID> vehiclesToDelete = new List<ID>();
    
    /*
     *PPM98035:  This will cause unable to lock row exception and will be replace by 
     *           MVG Before insert update trigger
    Map<String, ID> relatedVehicles = new Map<String, ID>();
    List<MVG_Price__c> mvgToUpdate = new List<MVG_Price__c>();
    */ 
    
    Map<String, List<Asset__c>> salesRetention = new Map<String, List<Asset__c>>();
    Map<String, List<Asset__c>> listingRetention = new Map<String, List<Asset__c>>();
    
    for (Asset__c v : Trigger.new)
    {        
        if ('Post-Auction'.equalsIgnoreCase(v.Auction_Status__c))
        {
            if (v.Last_Vehicle_Status_Change__c == null ||
                v.Last_Vehicle_Status_Change__c.daysBetween(Date.today()) > 60)
            {
                vehiclesToDelete.add(v.Id);
            }
        }
         if (v.System_Id__c == '8' && v.Vehicle_Status_Id__c >= 42) {
            vehiclesToDelete.add(v.Id);
        }
        
        //PPM98035: relatedVehicles.put(v.vehicle_id__c, v.Id);
    }//changed atc_org_id to Openlane_Org_ID__c for all instances
    List<Asset__c> vehicles = [select id, name, system_id__c, sales_classification__c,
                                        Buyer_Account__r.Openlane_Org_ID__c,
                                        Seller_account__r.Openlane_Org_ID__c,
                                        Car_Group__r.Car_Group_Type__c,
                                        Basic_Listing_Indicator__c
                                   from Asset__c
                                  where id in :Trigger.newMap.keySet()];
    for(Asset__c v: vehicles){
        if( Trigger.isUpdate && v.System_id__c == '4' &&
            Trigger.oldMap.get(v.Id) != null && 
            Trigger.oldMap.get(v.Id).system_id__c != '4' && 
           v.sales_classification__c != null && 
           v.Buyer_Account__r.Openlane_Org_ID__c != null &&
           (v.sales_classification__c.equals('Open D2D') ||
            v.sales_classification__c.equals('Open Non-Grounding Dealer') ||
            v.sales_classification__c.equals('Closed D2D') ||
            v.sales_classification__c.equals('Closed - Non-Grounding Dealer') ||
            v.sales_classification__c.equals('Closed - Grounding Dealer'))){
            List<Asset__c> vehs = salesRetention.get(v.Buyer_Account__r.Openlane_Org_ID__c);
            if(vehs == null){
               vehs = new List<Asset__c>();
            }
            vehs.add(v);
            salesRetention.put(v.Buyer_Account__r.Openlane_Org_ID__c, vehs);
        }
        if(Trigger.isUpdate && v.system_id__c == '3'  &&
           Trigger.oldMap.get(v.Id) != null &&
           Trigger.oldMap.get(v.Id).system_id__c != '3' &&
           v.Car_group__c != null && v.Car_Group__r.Car_Group_Type__c == 2 &&
           v.Seller_account__r.Openlane_Org_ID__c != null &&
           v.Basic_Listing_Indicator__c != null &&
           !v.Basic_Listing_Indicator__c.equals('Yes')){
            List<Asset__c> vehs = listingRetention.get(v.Seller_account__r.Openlane_Org_ID__c);
            if(vehs == null){
               vehs = new List<Asset__c>();
            }
            vehs.add(v);
            listingRetention.put(v.Seller_Account__r.Openlane_Org_ID__c, vehs);
        }
    }
    
    /*PPM98035:
    Set<String> vehIds = relatedVehicles.keySet();
    
     List<MVG_Price__c> mvgList = [select id, vehicle_id__c from MVG_Price__c m where m.vehicle_id__c in :vehIds];

    for(MVG_Price__c m: mvgList){
        m.vehicle__c = relatedVehicles.get(m.vehicle_id__c);
        mvgToUpdate.add(m);
    }
    */
     
    if (vehiclesToDelete.size() > 0)
    {//ppm 100526: set flag vehiclsDelete to 1  then bypass the error on oppotunity before update trigger 
        Utils.setDeleted();  
        Database.delete(vehiclesToDelete);
        Database.emptyRecycleBin(vehiclesToDelete);
    }

}