public with sharing class CollectionCaseTriggerHelper {
	public static void updateNotificationUser(List<AFC_Collection_Case__c> cases) {
		Map<Id, User> owners = getOwners(cases);
		for (AFC_Collection_Case__c collectionCase : cases) {
			User ownerUser = owners.get(collectionCase.ownerId);
			collectionCase.AFC_Collection_Manager__c = ownerUser.ManagerId;
		}
	}

	private static Map<Id, User> getOwners(List<AFC_Collection_Case__c> cases) {
		Set<Id> ownerIds = getOwnerIds(cases);
		return new Map<Id, User>([select ManagerId from User where id in :ownerIds]);
	}

	private static Set<Id> getOwnerIds(List<AFC_Collection_Case__c> cases) {
		Set<Id> ownerIds = new Set<Id>();
		for (AFC_Collection_Case__c collectionCase : cases) {
			ownerIds.add(collectionCase.ownerId);
		}
		return ownerIds;
	}

	public static void checkNonClosedCasesPerContract(List<AFC_Collection_Case__c> cases) {
		List<Id> contractIds = getContractIds(cases);
		List<Id> caseIds = new List<Id>();
		for (AFC_Collection_Case__c c : cases) {
			if (c.Id != null) {
				caseIds.add(c.id);
			}
		}
		Map<Id, AFC_Contracts__c> contracts = new Map<Id, AFC_Contracts__c>(
			getContractsWithNonClosedCases(contractIds, caseIds));
		Map<Id, Integer> contractCases = new Map<Id, Integer>();
		for (AFC_Collection_Case__c c : cases) {
			AFC_Contracts__c contract = contracts.get(c.AFC_Contract__c);
			if (!contractCases.containsKey(contract.Id)) {
				contractCases.put(contract.Id, contract.AFC_Collection_Cases__r.size());
			}
			if (c.AFC_Case_Status__c != 'Closed') {
				Integer n = contractCases.get(contract.Id);
				if (n == 0) {
					contractCases.put(contract.Id, n + 1);
				} else {
					c.addError('Can\'t have more than one non closed case associated to the contract');
				}
			}
		}
	}

	private static List<Id> getContractIds(List<AFC_Collection_Case__c> cases) {
		List<Id> contractIds = new List<Id>();
		for (AFC_Collection_Case__c c : cases) {
			contractIds.add(c.AFC_Contract__c);
		}
		return contractIds;
	}

	private static List<AFC_Contracts__c> getContractsWithNonClosedCases(List<Id> contractIds, List<Id> caseIds) {
		return [select 
			(select AFC_Case_Status__c from AFC_Collection_Cases__r 
				where AFC_Case_Status__c != 'Closed'
				and id not in :caseIds)
			from AFC_Contracts__c where id in :contractIds];
	}
}