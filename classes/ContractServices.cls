public with sharing class ContractServices {
	
	//takes a master contract id and returns the contract shell with that matching master contract id
	public static AFC_Contract_Shell__c getContractShell(Integer masterContractId){
		try{
			return [SELECT Id,
					   Contract_ID__c
				FROM AFC_Contract_Shell__c 
				WHERE Master_Contract_ID__c = :masterContractId]; 
				}catch(QueryException e){
					throw new CustomExceptions.WebServiceException(System.Label.No_Contract_Shells_For_Master_Contract_Id);
				}
	}

	//updates a contract shells Received_from_Dealer__c and Contract_Status__c fields
	public static AFC_Contract_Shell__c updateContractShellFields(AFC_Contract_Shell__c theContractShell, Date recievedFromDate, String contractStatus){
		theContractShell.Received_from_Dealer__c = recievedFromDate;
		theContractShell.Contract_Status__c = contractStatus;
		update theContractShell;
		return theContractShell;
	}

	//returns the active contract that has a contract id matching the contract shells contract id (if one exists)
	public static AFC_Contracts__c matchingActiveContracts(AFC_Contract_Shell__c theContractShell){
		List<AFC_Contracts__c> matchingContractsList = [SELECT Id, 
									     Contract_ID__c, 
									     Contract_Status__c 
							 	  FROM AFC_Contracts__c 
							 	  WHERE Contract_ID__c =:theContractShell.Contract_ID__c 
								  AND Contract_Status__c = 'Active'];
		if(matchingContractsList.size() > 1){
			throw new CustomExceptions.WebServiceException(System.Label.multiple_active_contracts_exception);
		}else if (matchingContractsList.size() == 1){
			return matchingContractsList[0];
		}else{
			return null;
		} 
	}

	//copies a contract over to a contract version
	public static void cloneContractToContractVersionAndUpdateContract(AFC_Contracts__c contract, AFC_Contract_Shell__c theContractShell){
		List<String> fieldsList = createFieldListOfAllCustomUpdatableFields();

		Contract_Versions__c contractVersions = (Contract_Versions__c)cloneContractRecords(contract, new Contract_Versions__c(), fieldsList);
		contractVersions.Contract_Status__c = 'Amended';
		contractVersions.AFC_Contracts__c = contract.Id;

		fieldsList = createFieldListFromFieldSet('Promoted_Fields');

		contract = (AFC_Contracts__c)cloneContractRecords(theContractShell, contract, fieldsList);
		update contract;
		insert contractVersions;
		//move all junction objects over to the contract versions
		transferJunctionObjects(contract, contractVersions, 'AFC_Contracts__c', 'Contract_Version__c', true);
		transferJunctionObjects(theContractShell, contract, 'AFC_Contract_Shell__c', 'AFC_Contracts__c', false);
	}

	//create a new contract from the contract shell
	public static void createContractFromContractShell(AFC_Contract_Shell__c theContractShell){
		List<String> fieldsList = createFieldListFromFieldSet('Promoted_Fields');
		AFC_Contracts__c contract = (AFC_Contracts__c)cloneContractRecords(theContractShell, new AFC_Contracts__c(), fieldsList);
		insert contract;
		transferJunctionObjects(theContractShell, contract, 'AFC_Contract_Shell__c', 'AFC_Contracts__c', false);
	}

	//clone one contract into another (regardless of the object type of the contract)
	private static SObject cloneContractRecords(SObject fromObject, SObject toObject, List<String> fieldsList)
	{
		String fieldCSVNames = String.join(fieldsList, ', ');
		String fromObjectId = fromObject.Id;
		String fromObjectName = fromObject.getSObjectType().getDescribe().getName();
		//query for all of the fields from the fromObject
		fromObject = Database.query('SELECT ' + fieldCSVNames + ' FROM ' + fromObjectName + ' WHERE Id = \'' + fromObjectId + '\'');
		for(String field : fieldsList){
			toObject.put(field, fromObject.get(field));
		}

		return toObject;
	}

	//transfer junction objects from one contract to another (regardless of the contract object types)
	private static void transferJunctionObjects(SObject fromObject, SObject toObject, String fromLookupField, String toLookupField, Boolean nullOldLookups){
		String fromId = fromObject.Id;
		List<Application_Contact_Role__c> applicationContactRoleList = Database.query('SELECT Id, ' + fromLookupField + 
			' FROM Application_Contact_Role__c WHERE ' + fromLookupField + ' = \'' + fromId + '\'');
		List<Application_Account_Role__c> applicationAccountRoleList = Database.query('SELECT Id, ' + fromLookupField + 
			' FROM Application_Account_Role__c WHERE ' + fromLookupField + ' = \'' + fromId + '\'');
		List<AFC_Contract_Terms__c> afcContractTermsList = Database.query('SELECT Id, ' + fromLookupField + 
			' FROM AFC_Contract_Terms__c WHERE ' + fromLookupField + ' = \'' + fromId + '\'');

		for(Application_Contact_Role__c acr : applicationContactRoleList){
			if(nullOldLookups){
				acr.put(fromLookupField, null);
			}
			acr.put(toLookupField, toObject.Id);
		}
		for(Application_Account_Role__c aar : applicationAccountRoleList){
			if(nullOldLookups){	
				aar.put(fromLookupField, null);
			}
			aar.put(toLookupField, toObject.Id);
		}
		for(AFC_Contract_Terms__c act : afcContractTermsList){
			if(nullOldLookups){	
				act.put(fromLookupField, null);
			}
			act.put(toLookupField, toObject.Id);
		}

		update applicationContactRoleList;
		update applicationAccountRoleList;
		update afcContractTermsList;
	}

	private static List<String> createFieldListFromFieldSet(String fieldSetName){
		Schema.FieldSet theFieldSet = Schema.SObjectType.AFC_Contracts__c.fieldSets.getMap().get(fieldSetName);
		List<String> fieldsList = new List<String>();
		for(Schema.fieldSetMember fsm : theFieldSet.getFields()){
			fieldsList.add(fsm.getFieldPath());
		}
		return fieldsList;
	}

	private static List<String> createFieldListOfAllCustomUpdatableFields(){
		//Assumption is that AFC_Contracts__c, Contract_Versions__c, and AFC_Contract_Shell__c all have the exact same set of custom fields
		//with the same API names and data types
		Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.AFC_Contracts__c.fields.getMap();
		List<String> fieldsList = new List<String>();
		for(String field : fieldMap.keySet()){
			if(fieldMap.get(field).getDescribe().isCustom() && fieldMap.get(field).getDescribe().isUpdateable()){
				fieldsList.add(field);
			}
		}
		fieldsList.add('Name');
		return fieldsList;
	}
}