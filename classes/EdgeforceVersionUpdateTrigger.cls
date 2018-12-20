/*
Modified Date    : 07 April, 2016
Modified By      : Lovish Goyal
Descrition       : Added logic to create a new Intranet Content Version record if the Language field has changed on the record.
                   (Ref:T-490781)
*/

public with sharing class EdgeforceVersionUpdateTrigger {

  public static  void createNewVersion(Map<Id,Intranet_Content_Version__c> oldVersionMap , Map<Id,Intranet_Content_Version__c> newVersionMap){
    List<Intranet_Content_Version__c> listofVersionsToInsert = new List<Intranet_Content_Version__c>();
	
	Set<String> ListFLSCreate = new Set<String>();
	Boolean blnFLSOverride = Utils.GetFLS();
	
    for(String oldVersionId : oldVersionMap.keySet()){
      if( oldVersionMap.get(oldVersionId).Name != newVersionMap.get(oldVersionId).Name
       || oldVersionMap.get(oldVersionId).Header__c != newVersionMap.get(oldVersionId).Header__c
       || oldVersionMap.get(oldVersionId).Summary__c != newVersionMap.get(oldVersionId).Summary__c
       || oldVersionMap.get(oldVersionId).Description__c != newVersionMap.get(oldVersionId).Description__c
       || oldVersionMap.get(oldVersionId).Language__c != newVersionMap.get(oldVersionId).Language__c
       || oldVersionMap.get(oldVersionId).URL__c != newVersionMap.get(oldVersionId).URL__c) {
        
        Intranet_Content_Version__c oldVersionToInsert = new Intranet_Content_Version__c();
        oldVersionToInsert = oldVersionMap.get(oldVersionId).Clone();
		
        if(newVersionMap.get(oldVersionId).Language__c != oldVersionToInsert.Language__c){
          newVersionMap.get(oldVersionId).Primary_Record__c = false;
        } else {
			//Story B-44003 : FLS CREATE ACCESS CHECK
			if (Schema.sObjectType.Intranet_Content_Version__c.fields.isPublished__c.isCreateable() || blnFLSOverride)
			{
				oldVersionToInsert.isPublished__c = false;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.Intranet_Content_Version__c.getName()+'.'+Schema.sObjectType.Intranet_Content_Version__c.fields.isPublished__c.getName());
			}
			if (Schema.sObjectType.Intranet_Content_Version__c.fields.Primary_Record__c.isCreateable() || blnFLSOverride)
			{
				oldVersionToInsert.Primary_Record__c = false;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.Intranet_Content_Version__c.getName()+'.'+Schema.sObjectType.Intranet_Content_Version__c.fields.Primary_Record__c.getName());
			}
        }
        //oldVersionToInsert.isPublished__c = false;
        //oldVersionToInsert.Primary_Record__c = false;
        listofVersionsToInsert.add(oldVersionToInsert);
      }
    }

    try{
		if(ListFLSCreate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_CREATE','CLASS:EdgeforceVersionUpdateTrigger', ListFLSCreate);
		}
		else
		{
			Database.insert(listofVersionsToInsert);
		}
	  
    }catch(Exception e){
      system.debug(listofVersionsToInsert);
    }
  }
}