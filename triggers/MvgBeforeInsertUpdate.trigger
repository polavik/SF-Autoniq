trigger MvgBeforeInsertUpdate on MVG_Price__c (before insert, before update) {
    List<Asset__c> existingVehicles = new List<Asset__c>();
    Map<String, Asset__c> existingVehicleMap = new Map<String, Asset__c>();
    List<Asset__c> allVehicles = new List<Asset__c>();
    Map<String, Asset__c> dummyVehicleMap = new Map<String, Asset__c>();
    List<String> vehicleIds = new List<String>();
    
    for(MVG_Price__c mvg : Trigger.new){
        if(mvg.Vehicle_Id__c != null && mvg.Vehicle_Id__c != ''){
            if(mvg.Vehicle__c == null){
                vehicleIds.add(mvg.Vehicle_Id__c);
                Asset__c v = new Asset__c(source_id__c = mvg.Vehicle_Id__c, name = mvg.name);
                allVehicles.add(v);
            }
        }
    }
    existingVehicles = [select source_id__c, name from Asset__c where source_id__c in: vehicleIds];
    
    for(Asset__c v: existingVehicles){
        existingVehicleMap.put(v.source_id__c, v);
    }
    
    for(Asset__c v: allVehicles){
        if(!existingVehicleMap.isEmpty()){
            if(!existingVehicleMap.containsKey(v.source_id__c)){
                dummyVehicleMap.put(v.source_id__c, v);
            }else{
                //if vehicle was already there, there should be logic exist to populate vehicle field in MVG
                //otherwise, put mapping logic here
            }
        }else{
            //cannot find any asset from the list
            dummyVehicleMap.put(v.source_id__c, v);
        }
    }
    insert dummyVehicleMap.values();
    
    //create mapping btw mvg and vehicle, or do test
    for(MVG_Price__c mvg : Trigger.new){
        if(mvg.Vehicle_Id__c != null && mvg.Vehicle_Id__c != ''){
            if(mvg.Vehicle__c == null){
                //PPM#99235 changes 
                //mvg.Vehicle__c = dummyVehicleMap.get(mvg.Vehicle_Id__c).Id;
                if(existingVehicleMap.get(mvg.Vehicle_Id__c)!=null)
                {
                    mvg.Vehicle__c = existingVehicleMap.get(mvg.Vehicle_Id__c).Id;
                }
                else if(dummyVehicleMap.get(mvg.Vehicle_Id__c)!=null)
                {
                    mvg.Vehicle__c = dummyVehicleMap.get(mvg.Vehicle_Id__c).Id;
                }
            }
        }
    }
}