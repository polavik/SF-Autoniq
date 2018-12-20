//
// (c) 2014 Appirio, Inc.
//
// Handler Class for trigger IntranetContent_AutoTagCreation
//
// November 9th, 2014   Sidhant Agarwal    Original T-332237
// November 11th, 2014  Sidhant Agarwal    Modified T-332237
//
public with sharing class EF_AutoTagCreation {
  public static final String CMS_RECORD_TYPE = 'Intranet CMS Pages';
  public static void createTags(Map<Id, Intranet_Content__c> newInstanceMap) {
	Set<String> ListFLSCreate = new Set<String>();
	Boolean blnFLSOverride = Utils.GetFLS();
    Set<String> setName = new Set<String>();
    List<Tags__c> lstTag = new List<Tags__c>();
    String recordTypeId = Schema.SObjectType.Intranet_Content__c.getRecordTypeInfosByName().get(CMS_RECORD_TYPE).getRecordTypeId();
    for(Intranet_Content__c intraCont : newInstanceMap.values()){
      if(intraCont.RecordTypeId == recordTypeId) {
        setName.add(intraCont.Name);
      }
    }
    if(setName!=null) {
      Tags__c tag = new Tags__c();
      lstTag = [SELECT ID, Tag__c FROM Tags__c where Tag__c in : setName];
      if(lstTag.size()==0) {
        for(String str : setName){
			//Story B-44003 : FLS CREATE ACCESS CHECK
			if (Schema.sObjectType.Tags__c.fields.Tag__c.isCreateable() || blnFLSOverride)
			{						 
				tag.Tag__c = str;			
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.Tags__c.getName()+'.'+Schema.sObjectType.Tags__c.fields.Tag__c.getName());
			}
        }
        try{
			if(ListFLSCreate.size()>0)
			{
				Utils.SendEmailforFLS('FLS_CREATE','CLASS:EF_AutoTagCreation', ListFLSCreate);
			}
			else
			{
				insert tag;
			}
        }catch (Exception e){
          System.Debug(e);
        }
      }
    }
  }
  // @description:  Updates the tags corresponding to the Intranet Content's Name changes
  // @param1: Map<Id, Intranet_Content__c> 
  // @param2: Map<Id, Intranet_Content__c>
  // Added on T-332237
  public static void updateTags(Map<Id, Intranet_Content__c> oldInstanceMap, Map<Id, Intranet_Content__c> newInstanceMap) {
	  
	  Set<String> ListFLSUpdate = new Set<String>();
	  Boolean blnFLSOverride = Utils.GetFLS();
	  
    Map<String, String> mapOfTagsToInsert = new  Map<String, String> ();
    Map<ID, String> mapToBeUpdated = new Map<ID, String>();
    List<Tags__c> lstUpdateTags = new List<Tags__c>();
      for(String oldVersionId : oldInstanceMap.keySet()){
        if( oldInstanceMap.get(oldVersionId).Name != newInstanceMap.get(oldVersionId).Name){
          mapOfTagsToInsert.put(oldInstanceMap.get(oldVersionId).Name, newInstanceMap.get(oldVersionId).Name);
        }
    }
    for(Tags__c updateTag : [SELECT Id, Tag__c FROM Tags__c WHERE Tag__c=: mapOfTagsToInsert.keySet()]){
          mapToBeUpdated.put(updateTag.ID,mapOfTagsToInsert.get(updateTag.Tag__c));
    }
    for(Tags__c updateTag : [SELECT ID, Tag__c FROM Tags__c WHERE ID IN: mapToBeUpdated.keySet()]){
		
		//Story B-44003 : FLS UPDATE ACCESS CHECK
		if (Schema.sObjectType.Tags__c.fields.Tag__c.isUpdateable() || blnFLSOverride)
		{						 
		  updateTag.Tag__c = mapToBeUpdated.get(updateTag.ID);
		}
		else
		{						
			ListFLSUpdate.add(Schema.sObjectType.Tags__c.getName()+'.'+Schema.sObjectType.Tags__c.fields.Tag__c.getName());
		}
	  
      lstUpdateTags.add(updateTag);
    }
    try{
      update lstUpdateTags;
	  
	  if(ListFLSUpdate.size()>0)
	  {
	  	Utils.SendEmailforFLS('FLS_UPDATE','CLASS:EF_AutoTagCreation', ListFLSUpdate);
	  }
    }catch(Exception e){
      System.debug('ERROR :: ' + e.getMessage());
    }
  }
}