public class Logger {

	private static Map<String, Map<String, List<String>>> typeIdLinesMap = new Map<String, Map<String, List<String>>>();
	private static Map<ID, List<String>> objectIdLinesMap = new Map<ID, List<String>>();
	private static Map<ID, Object_Log__c> objectIdLogMap = new Map<ID, Object_Log__c>();
	
	public static void info(SObject obj, String contents) {
		List<String> lines = getLines(obj);
		lines.add(DateTime.now() + ' -  INFO: ' + contents);
		System.debug(DateTime.now() + ' -  INFO: ' + contents);
	}
	
	public static void error(SObject obj, String contents) {
		List<String> lines = getLines(obj);
		lines.add(DateTime.now() + ' - ERROR: ' + contents);
		System.debug(DateTime.now() + ' -  ERROR: ' + contents);
		Object_Log__c log = getLog(obj);
		log.Send_Alert_Email__c = true;
	}
	
	private static List<String> getLines(SObject obj) {
		String objectType = obj.getSObjectType().getDescribe().getName();
		ID objectId = obj.Id;
		List<String> lines = objectIdLinesMap.get(objectId);
		
		Set<String> ListFLSUpdate = new Set<String>();
		Set<String> ListFLSCreate = new Set<String>();
		Boolean blnFLSOverride = Utils.GetFLS();
		
		if (lines == null) {
			lines = new List<String>();
			
			objectIdLinesMap.put(objectId, lines);
			Object_Log__c log = new Object_Log__c();			
			
			//Story B-44003 : FLS UPDATE ACCESS CHECK
			 if (Schema.sObjectType.Object_Log__c.fields.Object_Type__c.isUpdateable() && Schema.sObjectType.Object_Log__c.fields.Object_Type__c.isCreateable() || blnFLSOverride)
			 {
				log.Object_Type__c = objectType;
			 }
			 else
			 {						
				ListFLSUpdate.add(Schema.sObjectType.Object_Log__c.getName()+'.'+Schema.sObjectType.Object_Log__c.fields.Object_Type__c.getName());
				ListFLSCreate.add(Schema.sObjectType.Object_Log__c.getName()+'.'+Schema.sObjectType.Object_Log__c.fields.Object_Type__c.getName());
			 }
			 
			 if (Schema.sObjectType.Object_Log__c.fields.Object_Id__c.isUpdateable() && Schema.sObjectType.Object_Log__c.fields.Object_Id__c.isCreateable() || blnFLSOverride)
			 {
				log.Object_Id__c = objectId;
			 }
			 else
			 {						
				ListFLSUpdate.add(Schema.sObjectType.Object_Log__c.getName()+'.'+Schema.sObjectType.Object_Log__c.fields.Object_Id__c.getName());
				ListFLSCreate.add(Schema.sObjectType.Object_Log__c.getName()+'.'+Schema.sObjectType.Object_Log__c.fields.Object_Id__c.getName());
			 }
			 
			objectIdLogMap.put(objectId, log);
		}
		if(ListFLSUpdate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_UPDATE','CLASS:Logger', ListFLSUpdate);		
			Utils.SendEmailforFLS('FLS_CREATE','CLASS:Logger', ListFLSCreate);
		}
		return lines;
	}
	
	private static Object_Log__c getLog(SObject obj) {
		return objectIdLogMap.get(obj.Id);
	}
	
	
	public static void flush() {
		List<Object_Log__c> updateList = new List<Object_Log__c>();
		List<Object_Log__c> insertList = new List<Object_Log__c>();
		
		Set<String> ListFLSUpdate = new Set<String>();
		Set<String> ListFLSCreate = new Set<String>();
		Boolean blnFLSOverride = Utils.GetFLS();
		
		for (ID objectId : objectIdLinesMap.keySet()) {
			List<String> lines = objectIdLinesMap.get(objectId);
			Object_Log__c log = objectIdLogMap.get(objectId);
			
			if (Schema.sObjectType.Object_Log__c.fields.Contents__c.isUpdateable() && Schema.sObjectType.Object_Log__c.fields.Contents__c.isCreateable() || blnFLSOverride)
			{
				log.Contents__c = Utils.joinList(lines, '\n');
			}
			else
			{						
				ListFLSUpdate.add(Schema.sObjectType.Object_Log__c.getName()+'.'+Schema.sObjectType.Object_Log__c.fields.Contents__c.getName());
				ListFLSCreate.add(Schema.sObjectType.Object_Log__c.getName()+'.'+Schema.sObjectType.Object_Log__c.fields.Contents__c.getName());
			}
			

			
			if (log.Id != null) {
				updateList.add(log);
			} else {
				insertList.add(log);
			}
		}
		
		if(ListFLSUpdate.size()>0 && updateList.size()>0)
		{
			Utils.SendEmailforFLS('FLS_UPDATE','CLASS:Logger', ListFLSUpdate);
		}
		else if(ListFLSCreate.size()>0 && insertList.size()>0)
		{
			Utils.SendEmailforFLS('FLS_CREATE','CLASS:Logger', ListFLSCreate);
		}
		else
		{		
			Integer maxBlockSize = 200;
			for (Integer i = 0; i < updateList.size(); i+=maxBlockSize) {
				Integer blockSize = Math.min(maxBlockSize, updateList.size() - i);
				List<Object_Log__c> block = (List<Object_Log__c>) getSublist(updateList, i, blockSize);
				update block;
			}
			
			for (Integer i = 0; i < insertList.size(); i+=maxBlockSize) {
				Integer blockSize = Math.min(maxBlockSize, insertList.size() - i);
				List<Object_Log__c> block = (List<Object_Log__c>) getSublist(insertList, i, blockSize);
				insert block;
			}
		}
	}
	
	public static List<Object_Log__c> getSublist(List<Object_Log__c> lst, Integer start, Integer size) {
		List<Object_Log__c> sublist = new List<Object_Log__c>();
		for (Integer i = start; i < size; i++) {
			sublist.add(lst.get(i));
		}
		return sublist;
	}
}