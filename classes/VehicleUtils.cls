public class VehicleUtils {
    
    
    //create dummy vehicle in KARAsset if the vehicle does not exist
    public static void createVehicle(String vehicleid)
    {
        Asset__c va = new Asset__c();
        Set<String> ListFLSCreate = new Set<String>();
		Boolean blnFLSOverride = Utils.GetFLS();
		//Story B-44003 : FLS CREATE ACCESS CHECK
		if (Schema.sObjectType.Asset__c.fields.Source_Id__c.isCreateable() || blnFLSOverride)
		{
			va.Source_Id__c = vehicleid;			 
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Asset__c.getName()+'.'+Schema.sObjectType.Asset__c.fields.Source_Id__c.getName());
		}
		if (Schema.sObjectType.Asset__c.fields.Vehicle_Id__c.isCreateable() || blnFLSOverride)
		{
			va.Vehicle_Id__c = vehicleid;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Asset__c.getName()+'.'+Schema.sObjectType.Asset__c.fields.Vehicle_Id__c.getName());
		}
		if (Schema.sObjectType.Asset__c.fields.Name.isCreateable() || blnFLSOverride)
		{
			va.Name = 'Dummy' + vehicleid;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Asset__c.getName()+'.'+Schema.sObjectType.Asset__c.fields.Name.getName());
		}
			 
        try
        {
			if(ListFLSCreate.size()>0)
			{
				Utils.SendEmailforFLS('FLS_CREATE','CLASS:VehicleUtils', ListFLSCreate);
			}
			else
			{
				insert va;
			}
        }
        catch (Exception e) 
        {
           System.debug(e);
        }
    }
    
    //Consumer will send a list of Vehicle ID to current function.
    //checkVehicle fucntion will search all Vehicles in KarAsset object.
    //If the vehicle does not exist, a dummy Vehicle with valid Vehicle ID will be created.
    public static Map<String,ID> checkVehicle(List<String> vList)
    {      
		Set<String> ListFLSCreate = new Set<String>();
		Boolean blnFLSOverride = Utils.GetFLS();
        Set<String> vSet = new Set<String>(vList);
        List<Asset__c> ilv = new List<Asset__c>();//not existing assets from passing vids, the list of assets going to be created as dummy
        List<Asset__c> lv = new List<Asset__c>();//all assets from passing vids
        List<Asset__c> lva = new List<Asset__c>();//existing assets from passing vids
        List<String> existVList = new List<String>();
        List<String> noVList = new List<String>();
        Map<String,ID> vehicle2upd = new Map<String,ID>();
        try {
           lva = [select id,Source_Id__c from Asset__c where Source_Id__c in :vSet];
        }catch (Exception e) {
           System.debug(e);
        }
        //System.Debug('checkVehicle2, lva size: '+ lva.size());      
        
        if ( lva != null) {
           For (Asset__c eva: lva){
               lv.add(eva);
               existVList.add(eva.Source_Id__c);
           }
        }
        
        for (String v1: vSet) {
            //System.Debug('checkVehicle3, v1 in vList: '+ v1); 
            //System.Debug('checkVehicle4, existVList: '+ existVList); 
          if ( (existVList == null) || !Utils.stringExistInList(v1,existVList)) {
              Asset__c va = new Asset__c();
			 //Story B-44003 : FLS CREATE ACCESS CHECK
			 if (Schema.sObjectType.Asset__c.fields.Source_Id__c.isCreateable() || blnFLSOverride)
			 {
				va.Source_Id__c = v1;
			 }
			 else
			 {						
				ListFLSCreate.add(Schema.sObjectType.Asset__c.getName()+'.'+Schema.sObjectType.Asset__c.fields.Source_Id__c.getName());
			 }
			 if (Schema.sObjectType.Asset__c.fields.Vehicle_Id__c.isCreateable() || blnFLSOverride)
			 {
				va.Vehicle_Id__c = v1;
			 }
			 else
			 {						
				ListFLSCreate.add(Schema.sObjectType.Asset__c.getName()+'.'+Schema.sObjectType.Asset__c.fields.Vehicle_Id__c.getName());
			 }
			 if (Schema.sObjectType.Asset__c.fields.Name.isCreateable() || blnFLSOverride)
			 {
				va.Name = 'Dummy' + v1;
			 }
			 else
			 {						
				ListFLSCreate.add(Schema.sObjectType.Asset__c.getName()+'.'+Schema.sObjectType.Asset__c.fields.Name.getName());
			 }
           
              ilv.add(va);
              lv.add(va);
              //System.Debug('checkVehicle6 ilv size: '+ ilv.size());
              //System.Debug('checkVehicle7 lv size: '+ lv.size());
          }
        } 
    
       if (ilv.size() > 0){
           try{
			   if(ListFLSCreate.size()>0)
				{
					Utils.SendEmailforFLS('FLS_CREATE','CLASS:VehicleUtils', ListFLSCreate);
				}
				else
				{
					insert(ilv);
				}
           }catch (Exception e){
            System.Debug('Dummy Vehicle creation was failed!');
            System.debug(e);
           }
        }
        
        For (Asset__c v2upd: lv) {
            //System.Debug('checkVehicle8 v2upd source id: ' + v2upd.Source_Id__c + ', v2upd SF id: ' + v2upd.id);
            vehicle2upd.put(v2upd.Source_Id__c, v2upd.id);
        }
        //System.Debug('checkVehicle9 vehicle2upd size: '+ vehicle2upd.size());
        
        return vehicle2upd;
    }
 
}