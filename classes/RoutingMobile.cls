public class RoutingMobile 
{
    public list<sma__MARoute__c> routes {get;set;}
    public list<sma__MAWaypoint__c> checkedInWaypoints {get;set;}
    public list<sma__MAWaypoint__c> remainingWaypoints {get;set;}
    public list<sma__MAWaypoint__c> checkedOutWaypoints {get;set;}
    public sma__MAWaypoint__c waypointInfo {get;set;}
    public sma__MARoute__c selectedRoute {get;set;}
    public string state {get;set;}
    public string routeId {get;set;}
    public string waypointId {get;set;}
    public string accountId {get;set;}
    public string tooltipTable {get;set;}
    public string dispostionType {get;set;}
    public string dispostionSubType {get;set;}
    public string serializedDisposition {get;set;}
    public string saveType {get;set;}
    public string serializedNote {get;set;}
    public string waypointSelectionType {get;set;}
    public string existingContractObject {get;set;}
    
    //disposition
    public Task TaskObj {get;set;}
    public string SaveFeedBack {get;set;}
    public string SaveJSFeedBack {get;set;}
    public double accuracy {get;set;}
    public double latitude {get;set;}
    public double longitude {get;set;}
    
    public RoutingMobile()
    {
        getRoutes();
        SaveFeedBack = '';
    }
    
    public void getWaypoints()
    {
        //set state to show waypoints
        state = 'Waypoints';
        
        //grab selected waypoint info
        selectedRoute = [SELECT Id, Name FROM sma__MARoute__c WHERE Id = :routeId];
        
        //prepare to sort waypoints into remaining and dispositioned
        List<sma__MAWaypoint__c> allWaypoints = [SELECT Id, Name, sma__LinkId__c FROM sma__MAWaypoint__c WHERE sma__LinkId__c!=null AND sma__Route__c = :routeId AND sma__LinkId__c LIKE '001%'];
        checkedInWaypoints = new List<sma__MAWaypoint__c>();
        remainingWaypoints = new List<sma__MAWaypoint__c>();
        checkedOutWaypoints = new List<sma__MAWaypoint__c>();
        
        //loop over waypoints to get all of the related ids that we need to check for dispositions
        set<string> waypointIds = new set<string>();
        for (sma__MAWaypoint__c waypoint : allWaypoints)
        {
            waypointIds.add(waypoint.sma__LinkId__c);
        }
        
        //create a set of all task ids that are checked in or were checked out today
        set<string> checkedInIds = new set<string>();
        set<string> checkedOutIds = new set<string>();
        for (Task t : [SELECT WhoId, WhatId, IsClosed FROM Task WHERE (WhoId IN :waypointIds OR WhatId IN :waypointIds) AND Subject LIKE 'Check In%' AND ((IsClosed = true AND sma__CheckOutDate__c = TODAY) OR IsClosed = false)])
        {
            if (!t.IsClosed) {
                checkedInIds.add(string.valueOf(t.WhoId == null ? t.WhatId : t.WhoId).left(15));
            }
            else {
                checkedOutIds.add(string.valueOf(t.WhoId == null ? t.WhatId : t.WhoId).left(15));
            }
        }
        
        //loop over the waypoints one more time and put them in the proper bucket
        for (sma__MAWaypoint__c waypoint : allWaypoints)
        {
            if (checkedInIds.contains(waypoint.sma__LinkId__c) || checkedInIds.contains(waypoint.sma__LinkId__c.left(15))) 
            {
                checkedInWaypoints.add(waypoint);
            }
            else if (checkedOutIds.contains(waypoint.sma__LinkId__c) || checkedOutIds.contains(waypoint.sma__LinkId__c.left(15))) {
                checkedOutWaypoints.add(waypoint);
            }
            else {
                remainingWaypoints.add(waypoint);
            }
        }
    }
    
    public void getRoutes()
    {
        state = 'MyRoutes';
        routes = [SELECT Id, Name, sma__Date__c FROM sma__MARoute__c WHERE OwnerId = :UserInfo.getUserId() AND (sma__Date__c = LAST_N_DAYS:30 OR sma__Date__c = NEXT_N_DAYS:30) ORDER BY sma__Date__c];
    }
    
    public void getWaypointOptions()
    {
        state = 'modifyWaypoint';
        
        //grab waypoint info
        waypointInfo = [SELECT Id, Name, sma__LinkId__c, sma__BaseObject__c, sma__Address__c, sma__Notes__c, sma__AdditionalData__c, sma__Latitude__c, sma__Longitude__c FROM sma__MAWaypoint__c WHERE Id = :waypointId];
        
        //look for an open check in
        TaskObj = null;
        for (Task t : [SELECT Id, Subject, Description, Seller__c, Activity_Type__c, sma__CreatedLocationAccuracy__c, sma__CreatedLatitude__c, sma__CreatedLongitude__c, sma__DistanceFromRecordMi__c, ActivityDate, sma__CheckOutDate__c, sma__CheckOutAccuracy__c, sma__CheckOutDistanceFromRecordMi__c, sma__CheckOutLatitude__c, sma__CheckOutLongitude__c, Status FROM Task WHERE (WhoId = :waypointInfo.sma__LinkId__c OR WhatId = :waypointInfo.sma__LinkId__c) AND Subject LIKE 'Check In%' AND IsClosed = false])
        {
            TaskObj = t;
        }
        
        //tooltips
        try
        {
            //grab tooltip info
            string linkId = waypointInfo.sma__LinkId__c;
            string tooltipsString = waypointInfo.sma__AdditionalData__c;
            string baseObject = waypointInfo.sma__BaseObject__c;
            string tooltips = '<table>';
            
            //convert the tooltips param to a list of field names and add to query
            set<string> tooltipsList = new set<string>();
            if(tooltipsString != null) { tooltipsList = (set<string>)JSON.deserialize(tooltipsString, set<string>.class); }
            tooltipsList.add('Id');
            
            //get the tooltips
            sObject b = database.query('SELECT '+string.join(new List<string>(tooltipsList), ',')+' FROM '+baseObject+' WHERE Id = \''+linkId+'\' LIMIT 1');
            
            //This section will get the label of any field for any object by passing these parameters; It will also return the value for lookup fields
            //linkId is the Id of the object
            //s is the API name of the field
            for(string s : tooltipsList) 
            {
                try {
                    //split the field name to help with lookups
                    list<string> fieldSplit = s.split('[.]');
                    string s0c = fieldSplit[0].replace('__r', '__c');
                    string s0Id = fieldSplit[0]+'Id';
                    string label, value, objId;
                    
                    //get a map of fields for the base object type
                    map<string, Schema.SObjectField> objFieldMap = ID.valueOf(linkId).getSObjectType().getDescribe().fields.getMap();
                    
                    try 
                    { 
                        value = string.valueOf(b.get(s0c));
                        label = objFieldMap.get(s0c).getDescribe().getLabel(); 
                    } 
                    catch(Exception exc) 
                    {
                        value = string.valueOf(b.get(s0Id));
                        label = objFieldMap.get(s0Id).getDescribe().getLabel();
                    }
                    
                    if(fieldSplit.size() > 1) 
                    {
                        string s1 = fieldSplit[1];
                        string objName = ID.valueOf(value).getSObjectType().getDescribe().getName();
                        value = string.valueOf(database.query('SELECT '+s1+' FROM '+objName+' WHERE Id = \''+value+'\' LIMIT 1')[0].get(s1));
                    }
                    
                    tooltips += 
                        '<tr>' +
                            '<td>' + label + '</td>' +
                            '<td>' + (value == null ? '' : value) + '</td>' +
                        '</tr>';
                }
                catch (Exception e) { }
            }
            
            tooltipTable = tooltips + '</table>';
        }
        catch (Exception e) {
            tooltipTable = '';
        }
    }
    
    public void waypointSelectionType () 
    {
        if (waypointSelectionType == 'createDisposition')
        {
            state = 'Disposition';
        }
        else if (waypointSelectionType == 'createNote')
        {
            state='CreateNote';
        }
        else if (waypointSelectionType == 'return')
        {
            getWaypoints();
        }
        else if (waypointSelectionType == 'returnDisposition')
        {
            state = 'Disposition';
        }
    }
    
    public void dispositionTypeClick ()
    {
        if(dispostionType == 'NextVisit')
        {
            state='NextVisit';
        }
        else if (dispostionType == 'ExistingContract')
        {
            state='ExistingContract';
        }
        else if (dispostionType == 'alertDialog')
        {
            state='alertDialog';
        }
    }
    
    public void checkIn()
    {
		Set<String> ListFLSCreate = new Set<String>();
		Boolean blnFLSOverride = Utils.GetFLS();

		//Story B-44003 : FLS CREATE ACCESS CHECK
		if (!Schema.sObjectType.Task.fields.Subject.isCreateable() || blnFLSOverride)
		{							
			ListFLSCreate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.Subject.getName());
		}
		if (!Schema.sObjectType.Task.fields.Description.isCreateable() || blnFLSOverride)
		{							
			ListFLSCreate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.Description.getName());
		}
		if (!Schema.sObjectType.Task.fields.Seller__c.isCreateable() || blnFLSOverride)
		{							
			ListFLSCreate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.Seller__c.getName());
		}
		if (!Schema.sObjectType.Task.fields.WhoId.isCreateable() || blnFLSOverride)
		{							
			ListFLSCreate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.WhoId.getName());
		}
		if (!Schema.sObjectType.Task.fields.WhatId.isCreateable() || blnFLSOverride)
		{							
			ListFLSCreate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.WhatId.getName());
		}
		if(ListFLSCreate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_CREATE','CLASS:RoutingMobile', ListFLSCreate);
		}
		else
		{
			//create a new task
			TaskObj = new Task(
				Subject = 'Check In @ ' + waypointInfo.Name + (latitude > 90 ? ' - Location Services Unavailable' : ''),
				Description = '',
				Seller__c = 'ADESA Auction',
				sma__CreatedLocationAccuracy__c = latitude > 90 ? 0 : accuracy,
				sma__CreatedLatitude__c = latitude > 90 ? double.valueOf(waypointInfo.sma__Latitude__c) : latitude,
				sma__CreatedLongitude__c = latitude > 90 ? double.valueOf(waypointInfo.sma__Longitude__c) : longitude,
				sma__DistanceFromRecordMi__c = latitude > 90 ? 0 : haversineDistance(double.valueOf(waypointInfo.sma__Latitude__c), double.valueOf(waypointInfo.sma__Longitude__c), latitude, longitude) * 0.000621371
			);
			
			//assign it to the proper record
			if (waypointInfo.sma__LinkId__c.startsWith('003') || waypointInfo.sma__LinkId__c.startsWith('00Q')){ 
				TaskObj.WhoId = waypointInfo.sma__LinkId__c;
			}
			else {
				TaskObj.WhatId = waypointInfo.sma__LinkId__c;
			}
			
			//insert the task
			insert TaskObj;
		}
    }
    public void checkOut()
    {
		Set<String> ListFLSUpdate = new Set<String>();
		Boolean blnFLSOverride = Utils.GetFLS();
		
		 //Story B-44003 : FLS UPDATE ACCESS CHECK
		 if (Schema.sObjectType.Task.fields.ActivityDate.isUpdateable() || blnFLSOverride)
		 {
			TaskObj.ActivityDate = Datetime.now().date();
		 }
		 else
		 {						
			ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.ActivityDate.getName());
		 }
		 if (Schema.sObjectType.Task.fields.sma__CheckOutDate__c.isUpdateable() || blnFLSOverride)
		 {
			TaskObj.sma__CheckOutDate__c = Datetime.now();
		 }
		 else
		 {						
			ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.sma__CheckOutDate__c.getName());
		 }
		 if (Schema.sObjectType.Task.fields.sma__CheckOutAccuracy__c.isUpdateable() || blnFLSOverride)
		 {
			TaskObj.sma__CheckOutAccuracy__c = latitude > 90 ? 0 : accuracy;
		 }
		 else
		 {						
			ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.sma__CheckOutAccuracy__c.getName());
		 }
		 if (Schema.sObjectType.Task.fields.sma__CheckOutDistanceFromRecordMi__c.isUpdateable() || blnFLSOverride)
		 {
			TaskObj.sma__CheckOutDistanceFromRecordMi__c = latitude > 90 ? 0 : haversineDistance(double.valueOf(waypointInfo.sma__Latitude__c), double.valueOf(waypointInfo.sma__Longitude__c), latitude, longitude) * 0.000621371;
		 }
		 else
		 {						
			ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.sma__CheckOutDistanceFromRecordMi__c.getName());
		 }
		 if (Schema.sObjectType.Task.fields.sma__CheckOutLatitude__c.isUpdateable() || blnFLSOverride)
		 {
			TaskObj.sma__CheckOutLatitude__c = latitude > 90 ? double.valueOf(waypointInfo.sma__Latitude__c) : latitude;
		 }
		 else
		 {						
			ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.sma__CheckOutLatitude__c.getName());
		 }
		 if (Schema.sObjectType.Task.fields.sma__CheckOutLongitude__c.isUpdateable() || blnFLSOverride)
		 {
			TaskObj.sma__CheckOutLongitude__c = latitude > 90 ? double.valueOf(waypointInfo.sma__Longitude__c) : longitude;
		 }
		 else
		 {						
			ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.sma__CheckOutLongitude__c.getName());
		 }
         if (Schema.sObjectType.Task.fields.Status.isUpdateable() || blnFLSOverride)
		 {
			TaskObj.Status = 'Completed';
		 }
		 else
		 {						
			ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.Status.getName());
		 }
		
		if(ListFLSUpdate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_UPDATE','CLASS:RoutingMobile', ListFLSUpdate);
		}
		
        update TaskObj;
        
        //return to the waypoint list
        getWaypoints();
    }
    
    public void addDisposition()
    {
        state = 'Disposition';
    }
    
    public void addNote ()
    {
        Note n = (Note)JSON.deserialize(serializedNote, Note.class);
        insert n;
        
        if(saveType == 'AccountReturn')
        {
            getWaypointOptions();
        }
        else if(saveType == 'WaypointReturn')
        {
            getWaypoints();
        }
    }
    
    //gis functions
    public static double haversineDistance(double lat1, double lng1, double lat2, double lng2) 
    {
        //earth radius in meters
        double earthRadius = 6370990;
    
        //convert to radians
        lat1 = RoutingMobile.degreesToRadians(lat1);
        lng1 = RoutingMobile.degreesToRadians(lng1);
        lat2 = RoutingMobile.degreesToRadians(lat2);
        lng2 = RoutingMobile.degreesToRadians(lng2);
    
        //get lat/long differences
        double dlon = lng2 - lng1;
        double dlat = lat2 - lat1;
    
        //return the distance
        double a = Math.pow((Math.sin(dlat/2)),2) + Math.cos(lat1) * Math.cos(lat2) * Math.pow(Math.sin(dlon/2),2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        return earthRadius * c;
    }
    public static double degreesToRadians(double degrees)
    {
        return degrees * (3.14159265358979323846/180);
    }
}