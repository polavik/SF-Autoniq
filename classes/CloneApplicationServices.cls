public class CloneApplicationServices 
{
	public static Application__c cloneRecord(Id controllerId, string crdStatus)
	{
		Application__c approvedApp = new Application__c();
			
		string conrtrollerTestId = controllerId;
			
		for(Application__c app : [select id, CreatedDate, AFC_Contract_Number__c, Credit_Status__c from Application__c where AFC_Contract_Number__c = :conrtrollerTestId AND AFC_Credit_Status__c = :crdStatus])
		{
			approvedApp = app;
				
			if(app.CreatedDate >= approvedApp.CreatedDate)
			{
				approvedApp = app;
			}
		}		

		return approvedApp;	
	}
	
	/*Start Parent Methods*/
	public static list<string> parentFields(sObject sObj, string objType)
	{
		if(sObj != null && objType != null)
		{
			Map<String, Schema.SObjectField> objFieldMap = Schema.getGlobalDescribe().get(objType).getDescribe().fields.getMap();
			
			list<string> sObjectFields = new list<string>{};
			
			if (objFieldMap != null)
			{
            	for (Schema.SObjectField ft : objFieldMap.values())
            	{
	                Schema.DescribeFieldResult fd = ft.getDescribe();
	                if (fd.isCreateable())
	                { 
	                    sObjectFields.add(fd.getName());
                	}
            	}
            	
            	return sObjectFields;
       		}
       		else
       		{
       			return null;
       		}			
		}
		else
		{
			return null;
		}			
	}

	public static string buildParentQuery(list<string> fieldList, string objName, string objId)
	{
		set<string> fieldExceptions = new set<string>();
		fieldExceptions.add('Source_Id__c');
			
		if(fieldList != null)
		{
	        string sObjectQuery = 'SELECT '; 
		    	
	        for (string str: fieldList)
	        {
	        	if(!fieldExceptions.contains(str))
	        	{
	        		sObjectQuery += str + ', ' ;
	        	}
	        }
	
	        sObjectQuery = sObjectQuery.substring(0,sObjectQuery.length()-2);
	        	
        	sObjectQuery += ' FROM ' + objName ;
	        	
        	if(objId != '' && objId != null)
        	{
        		sObjectQuery += ' WHERE ID = \'' + objId + '\'';
        	}

        	return sObjectQuery;
		}
		else
		{
			return null;
		}			
	}

	public static string startParentClone(string sObjectQuery)
	{
		sObject appSrcObj = Database.query(sObjectQuery);
		sObject appDstObj = appSrcObj.clone(false, true, false, false);
			
		insert appDstObj;		

		return appDstObj.Id;	
	} 

	/*Start Child Methods*/
	public static map<string,list<string>> childFields()
	{
		list<ApplicationCloneFields__c> acfCustomSettingFields = ApplicationCloneFields__c.getall().values();

		map<string,list<string>> childObjectFieldMap = new map<string,list<string>>();
		for(ApplicationCloneFields__c acf : acfCustomSettingFields)
		{
			Map<String, Schema.SObjectField> objFieldMap = Schema.getGlobalDescribe().get(acf.ObjectApiName__c).getDescribe().fields.getMap();
				
			childObjectFieldMap.put(acf.ObjectApiName__c, new list<string>());
				
			for (Schema.SObjectField ft : objFieldMap.values())
           	{
                Schema.DescribeFieldResult fd = ft.getDescribe();
                if (fd.isCreateable())
                { 
                    childObjectFieldMap.get(acf.ObjectApiName__c).add(fd.getName());
               	}
           	}
		}
			
		return childObjectFieldMap;
	}

	public static list<string> buildChildQuery(map<string,list<string>> cofm, string parentId)
	{
		map<string, string> csValues = new map<string, string>();
		for(ApplicationCloneFields__c acf : ApplicationCloneFields__c.getAll().values())
		{
			csValues.put(acf.ObjectApiName__c, acf.ParentFieldApiName__c);
		}
			
		list<string> stringQuery = new list<string>();
			
		for(string mapStr: cofm.keySet())
		{
	        string sObjectQuery = 'SELECT '; 
		    	
	        for (string str: cofm.get(mapStr))
	        {
	        	sObjectQuery += str + ', ' ;
	        }
	
	        sObjectQuery = sObjectQuery.substring(0,sObjectQuery.length()-2);
	        	
        	sObjectQuery += ' FROM ' + mapStr ;
	        	
        	if(parentId != '' && parentId != null)
        	{
        		sObjectQuery += ' WHERE ' + csValues.get(mapStr) + ' = \'' + parentId + '\'';
        	}
	        	
        	stringQuery.add(sObjectQuery);
		}

       	return stringQuery;
	}
	
	public static void startChildClone(list<string> sObjectQuery, string cloneParentId)
	{
		map<string, string> csValues = new map<string, string>();
		for(ApplicationCloneFields__c acf : ApplicationCloneFields__c.getAll().values())
		{
			csValues.put(acf.ObjectApiName__c, acf.ParentFieldApiName__c);
		}
			
		list<sObject> childToInsert = new list<sObject>();

		for(string str: sObjectQuery)
		{
					
			list<sObject> appSrcObj = Database.query(str);
			for(sObject sObj : appSrcObj)
			{
				sObject appDstObj = sObj.clone(false, true, false, false);

				if(csValues.containsKey(string.valueOf(sObj.getsObjectType())))
				{
					appDstObj.put(csValues.get(string.valueOf(sObj.getsObjectType())), cloneParentId); 
				}

				childToInsert.add(appDstObj);
			}
		}
		insert childToInsert;
	}
}