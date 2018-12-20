public with sharing class StewardshipHelper {
	public static Id stewardshipRtId;
	public static Set<String> stewardshipUsernames;
	public static Set<Id> stewardshipUserIds;
	public static Map<String,List<String>> stewardshipKeyFieldsMap;
	static{
		stewardshipRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Stewardship').getRecordTypeId();
    	stewardshipUsernames = new Set<String>();
		    for(Stewardship_Users__c u : Stewardship_Users__c.getAll().values()){
		        stewardshipUsernames.add(u.name);
		    }
		    stewardshipUserIds = new Set<Id>();
		    for(User u : [select id from user where username in :stewardshipUsernames]){
		    	stewardshipUserIds.add(u.Id);
		    }
		stewardshipKeyFieldsMap = new Map<String,List<String>>();
	    for(Stewardship_Key_Fields__c u : Stewardship_Key_Fields__c.getAll().values()){
	    	if(stewardshipKeyFieldsMap.get(u.Object_Name__c) == null){
	    		stewardshipKeyFieldsMap.put(u.Object_Name__c,new List<String>{u.Field_Name__c});
	    	} else {
	    		List<String> tempList = stewardshipKeyFieldsMap.get(u.Object_Name__c);
	    		tempList.add(u.Field_Name__c);
	    		stewardshipKeyFieldsMap.put(u.Object_Name__c,tempList);
	    	}
	    }	
	}

	public StewardshipHelper() {
	}

    // This method  updates the Account In_Stewardship__c asynchronously to avoid trigger collisions
    @future
    public static void updateAccountStewardship(Set<Id> accountIdSet){
	    List<Account> aList = [select id, In_Stewardship__c, (select id from Cases where RecordTypeId = :StewardshipHelper.stewardshipRtId and status = 'Open') from account where id in :accountIdSet];
	    for(Account a : aList){
	        a.In_Stewardship__c = !(a.Cases.size() == 0);
	    }
	    update aList;
    }

	public static void createDuplicateIntegrationIdCase(String integrationId, List<Id> accountIdList){
		String subjectText = 'Duplicate Integration Id: '+integrationId;
		if([select id, status, createdbyid from Case where Status = 'Open' and RecordTypeId = :stewardshipRtId and Subject = :subjectText].size() == 0){
			Case stewardshipNotification = new Case(RecordTypeId = stewardshipRtId, Subject = subjectText);
			stewardshipNotification.Description = 'The following Accounts all utilize the same integration id ('+integrationId+'): \r\n';
			for(Id accountId : accountIdList){
				stewardshipNotification.Description = stewardshipNotification.Description + '\r\n'+URL.getSalesforceBaseUrl().toExternalForm() + '/'+accountId; 
			}
			insert stewardshipNotification;
		}
	}

	public static void createLocalAccountIntegrationCases(List<Id> accountIdList){
		Set<Id> accountsWithCases = new Set<Id>();
		String currentUserName = UserInfo.getUserName();
		for(Case c : [select id, status, createdbyid, accountId from Case where Status = 'Open' and RecordTypeId = :stewardshipRtId and Subject = 'Local Account Integration' and AccountId in :accountIdList and CreatedById = :UserInfo.getUserId()]){
			accountsWithCases.add(c.AccountId);
		}
		List<Case> newCaseList = new List<Case>();
		for(Id accountId : accountIdList){
			if(!accountsWithCases.contains(accountId)){
				Case stewardshipNotification = new Case(RecordTypeId = stewardshipRtId, Subject = 'Local Account Integration', AccountId=accountId);
				stewardshipNotification.Description = 'An Account was inserted by '+currentUserName+' that did not include an Integration Id';	
				newCaseList.add(stewardshipNotification);
			}	
		}
		if(newCaseList.size() > 0){
			insert newCaseList;
		}
	}

	public static void createKeyFieldDeletionCase(Id accountId, Set<String> keyFieldsDeleted){
		if([select id from Case where Status = 'Open' and RecordTypeId = :stewardshipRtId and Subject = 'Key Field Deletion Attempt' and AccountId = :accountId and CreatedById = :UserInfo.getUserId()].size() == 0){
			Case stewardshipNotification = new Case(RecordTypeId = stewardshipRtId, Subject = 'Key Field Deletion Attempt', AccountId=accountId);
			stewardshipNotification.Description = UserInfo.getUserName()+' attempted to delete the following fields from the referenced Account: '+keyFieldsDeleted;
			insert stewardshipNotification;
		}
   	}

	public static void createDataFlippingCase(Id accountId, Set<String> flipFields){
		if([select id from Case where Status = 'Open' and RecordTypeId = :stewardshipRtId and Subject = 'Data Flipping Notification' and AccountId = :accountId and CreatedById = :UserInfo.getUserId()].size() == 0){
			Case stewardshipNotification = new Case(RecordTypeId = stewardshipRtId, Subject = 'Data Flipping Notification',AccountId=accountId);
			stewardshipNotification.Description = 'The following data fields are flipping for Account '+accountId+', due to competing data sources: '+flipFields;
			insert stewardshipNotification;
		}
   	}

   	public static void createPossibleDuplicatesCase(String integrationId, List<Id> accountIdList){
		String subjectText = 'Possible Duplicates for Integration Id: '+integrationId;
		if([select id, status, createdbyid from Case where Status = 'Open' and RecordTypeId = :stewardshipRtId and Subject = :subjectText].size() == 0){
			Case stewardshipNotification = new Case(RecordTypeId = stewardshipRtId, Subject = subjectText);
			stewardshipNotification.Description = 'The following Accounts have at least one key data element that matches this record (integration id '+integrationId+':) \r\n';
			for(Id accountId : accountIdList){
				stewardshipNotification.Description = stewardshipNotification.Description + '\r\n'+URL.getSalesforceBaseUrl().toExternalForm() + '/'+accountId; 
			}
			insert stewardshipNotification;
		}
   	}   

   	/* This version supports bulkified Trigger and take a Map holding the Account Id and a Set of field names that are flipping */
	public static void createDataFlippingCases(Map<Id,List<String>> flipMap){
		List<Case> caseList = new List<Case>();
		Set<Id> existingCaseAccountIds = new Set<Id>();
		for(Case existingCase : [select id, AccountId, description from Case where Status = 'Open' and RecordTypeId = :stewardshipRtId and Subject = 'Data Flipping Notification' and AccountId in :flipMap.keySet() and CreatedById = :UserInfo.getUserId()]){
			existingCase.Description = 'The following data fields are flipping for Account '+existingCase.accountId+', due to competing data sources: '+flipMap.get(existingCase.accountId);
			caseList.add(existingCase);
			existingCaseAccountIds.add(existingCase.AccountId);
		}
		for(Id accountId : flipMap.keySet()){
			if(!existingCaseAccountIds.contains(accountId)){
				Case stewardshipNotification = new Case(RecordTypeId = stewardshipRtId, Subject = 'Data Flipping Notification',AccountId=accountId);
				stewardshipNotification.Description = 'The following data fields are flipping for Account '+accountId+', due to competing data sources: '+flipMap.get(accountId);
				caseList.add(stewardshipNotification);
			}
		}
		if(caseList.size() > 0){
			upsert caseList;
		}
   	}
}