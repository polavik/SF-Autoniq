trigger InspectionRequestBeforeInsertUpdate on Inspection_Request__c (before insert, before update) 
{
    List<String> vehicleIds   = new List<String>();
    Map<String, Asset__c> VehicleListMap =  new Map<String, Asset__c>();
    Map<String, Purchase__c> PurchaseListMap =  new Map<String, Purchase__c>();
    boolean IsMigrationRuning = false;               
    IsMigrationRuning = Utils.getIsMigrationRuning('is.migration.running');    
    // B-16452: PSI Workflow in Salesforce.  Set "poor man's" business day calculations
    if (!IsMigrationRuning )  {
    for (Inspection_Request__c ir : Trigger.new)
    {
        vehicleIds.add(ir.Vehicle_Id__c);
        if (ir.Order_Request_Date__c != null && ir.Order_Complete_Date__c != null)
        {
            ir.Date_Requested_to_Date_Completed__c = Utils.countWeekDays(ir.Order_Request_Date__c.date(), ir.Order_Complete_Date__c.date());
            
        }
        if (ir.Condition_Report__c != null)
        {
            //Cr_Report_Url__c 
            
            String myString1 = ir.Condition_Report__c;
            String myString2 = '?';
            
            Integer start = myString1.indexOf(myString2, 0);
            Integer stringLength = myString1.length();
            myString1 = myString1.mid(start, (stringLength-start));
            
            String myString4 = '%3D%3D';
            Integer NewStringPointer = myString1.indexOf(myString4, 0);
            myString1 = myString1.mid(0,NewStringPointer);
            
            ir.CrUrl__c = Utils.getProperty('crreport.url')+myString1;
            
        }
        if (ir.Order_Request_Date__c != null && ir.Order_Reviewed_Date__c != null)
        {
            ir.Date_Requested_to_Date_Reviewed__c = Utils.countWeekDays(ir.Order_Request_Date__c.date(), ir.Order_Reviewed_Date__c.date());
        }
        
    }
    
    List<Asset__c> ListOfVehicles = [select id, vehicle_id__c, vehicle_status__c, last_update_date_by_partner__c from Asset__c where source_id__c in :vehicleIds ];
    List<Purchase__c> ListOfPurchases = [select id, vehicle_id__c, ATC_Buyer_Contact__c from Purchase__c where source_id__c in :vehicleIds ];
    for (Asset__c vehicleObj:  ListOfVehicles)                                                           
    {
        VehicleListMap.put(vehicleObj.vehicle_id__c,vehicleObj);
        }  
        
    for (Purchase__c purchaseObj:  ListOfPurchases)                                                           
    {
        PurchaseListMap.put(purchaseObj.vehicle_id__c,purchaseObj);
    } 
    
    for (Inspection_Request__c ir : Trigger.new)
    {
        Asset__c VehicleObject = VehicleListMap.get(ir.Vehicle_Id__c);
        if (VehicleObject != null) {
            ir.Asset__c = VehicleObject.Id;
            }
            
        }
        
    for (Inspection_Request__c ir : Trigger.new)
    {
        Purchase__c PurchaseObject = PurchaseListMap.get(ir.Vehicle_Id__c);
        if (PurchaseObject != null) {
            ir.Contact__c = PurchaseObject.ATC_Buyer_Contact__c;
            }
            
        }
        
        
    for (Inspection_Request__c ir : Trigger.new)
    {   
        if('PSI by CAP'.equalsIgnoreCase(ir.Inspection_Type__c)  || 'TPI'.equalsIgnoreCase(ir.Inspection_Type__c))
        {
            ir.PSI_Passed__c = 'Unavailable';
        }
    }
                
   } 
}