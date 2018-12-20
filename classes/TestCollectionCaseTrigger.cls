@isTest
private class TestCollectionCaseTrigger {

	static User createUser(
			String alias, String email, String lastname, 
			String communitynick, Id managerId) {
		String tz = 'GMT';
		String locale = 'en_US';
		String emailEncodingKey = 'ISO-8859-1';
		String languageLocaleKey = 'en_US';
		Id profileId = UserInfo.getProfileId();
		User u = new User(Alias = alias, Email = email, ManagerId = managerId,
			UserName = email, LastName = lastname, CommunityNickname = communitynick,
			TimeZoneSidKey = tz, LocaleSidKey = locale, EmailEncodingKey = emailEncodingKey,
			ProfileId = profileId, LanguageLocaleKey = languageLocaleKey);
		insert u;
		return u;
	}
	
	@testSetup
	static void testSetup() {
		Account account = new Account(Name = 'related');
		insert account;
		AFC_Contracts__c contract = new AFC_Contracts__c(Account__c = account.id);
		insert contract;
		User manager = createUser('theman', 'manager@someorg.com', 'man last name', 'man comm nick', null);
		User nextManager = createUser('nextman', 'nextmanager@someorg.com', 'next man last name', 'next man comm nick', null);
		User u = createUser('analias', 'someuser@someorg.com', 'user last name', 'user comm nick', manager.Id);
		System.runAs(u) {
			AFC_Collection_Case__c collectionCase = 
				new AFC_Collection_Case__c(AFC_Contract__c = contract.Id, AFC_Case_Status__c = 'Closed');
			insert collectionCase;
		}
	}

	@isTest static void insert_NotificationUserIsFilledWithOwnerManager() {
		User manager = [select id from User where Alias = 'theman'];
		AFC_Collection_Case__c collectionCase = [select AFC_Collection_Manager__c from AFC_Collection_Case__c];
		System.assertEquals(manager.id, collectionCase.AFC_Collection_Manager__c);
	}
	
	@isTest static void update_NotificationUserIsChangedToOwnerManager() {
		User nextManager = [select id from User where Alias = 'nextman'];
		User u = [select ManagerId from User where Alias = 'analias'];
		u.ManagerId = nextManager.Id;
		update u;
		AFC_Collection_Case__c collectionCase = [select AFC_Assess_Comments__c from AFC_Collection_Case__c];
		collectionCase.AFC_Assess_Comments__c = 'some comments';
		update collectionCase;
		collectionCase = [select AFC_Collection_Manager__c from AFC_Collection_Case__c];
		System.assertEquals(nextManager.id, collectionCase.AFC_Collection_Manager__c);
	}

	@isTest static void insert_fails_thereIsAlreadyANonClosedCase() {
		AFC_Contracts__c contract = [select id from AFC_Contracts__c];
		AFC_Collection_Case__c collectionCase = new AFC_Collection_Case__c(AFC_Contract__c = contract.Id, AFC_Case_Status__c = 'Open');
		insert collectionCase;
		collectionCase = new AFC_Collection_Case__c(AFC_Contract__c = contract.Id, AFC_Case_Status__c = 'Open');
		try {
			insert collectionCase;
			System.assert(false, 'Case insertion did not fail');
		} catch(Exception e) {
			System.assert(true);
		}
	}

	//@isTest static void update_ok_onlyNonClosedCasePassesToNonClosedStatus() {
	//	AFC_Contracts__c contract = [select id from AFC_Contracts__c];
	//	AFC_Collection_Case__c collectionCase = new AFC_Collection_Case__c(AFC_Contract__c = contract.Id, AFC_Case_Status__c = 'Open');
	//	insert collectionCase;
	//	collectionCase.AFC_Case_Status__c = 'In review';
	//	update collectionCase;
	//}

	@isTest static void insert_ok_thereArentNonClosedCases() {
		AFC_Contracts__c contract = [select id from AFC_Contracts__c];
		AFC_Collection_Case__c collectionCase = new AFC_Collection_Case__c(AFC_Contract__c = contract.Id, AFC_Case_Status__c = 'Closed');
		insert collectionCase;
		collectionCase = new AFC_Collection_Case__c(AFC_Contract__c = contract.Id, AFC_Case_Status__c = 'Open');
		insert collectionCase;
	}
	
}