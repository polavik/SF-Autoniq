@isTest
public class TestAFCRiskListController {
	public TestAFCRiskListController() {
	}

	public static testMethod void testCreateCase() {
		Account a = new Account(Name='Test Account');
		insert a;
		AFC_Contracts__c contract = new AFC_Contracts__c(Account__c=a.id,Name='test',AFC_Branch__c='Flint',AFC_Division__c='division',AFC_Country__c='United States',AFC_Risk_Group__c='Less Than 1%',AFC_Yield_Group__c='10% - 14.9%',
															AFC_Default_Risk__c = .05, Current_Principle_Amt_Oustanding__c=50000.00,PLN__c=false,Product_Type__c='WHOLESALE ONLY',AFC_Type__c='test',Contract_Status__c='ACTIVE');
		insert contract;

		Test.startTest();
			PageReference pageRef = new PageReference('Page.AFCRiskList');
			pageRef.getParameters().put('contractid',contract.Id);
			Test.setCurrentPage(pageRef);
			AFCRiskListController afcrlc = new AFCRiskListController();

			afcrlc.selectedContract = contract.Id;
			afcrlc.refreshSummary();

			afcrlc.newCase.ownerid = UserInfo.getUserId();
			afcrlc.newCase.AFC_Priority__c = '3';
			afcrlc.newCase.AFC_FU_date__c = System.today();
			
			afcrlc.createCase();

			AFC_Collection_Case__c collectionCase = [select id, Name, AFC_Contract__c, CreatedDate, AFC_Risk_Group__c, AFC_Product_Type__c, AFC_Type__c, AFC_Yield_Group__c, AFC_PLN__c, AFC_Principal_OS__c,AFC_Case_Status__c, AFC_Branch_Name__c,AFC_Region__c,AFC_Division__c,AFC_Country__c,AFC_FU_date__c, AFC_Priority__c, AFC_Assess_Comments__c, AFC_Identify__c, AFC_Develop_Plan__c, OwnerId 
                                                        from AFC_Collection_Case__c where AFC_Contract__c = :contract.Id limit 1];

			//AFCRiskListController.ContractSummary cs = afcrlc.contractSummaryMap.get(pageRef.getParameters().get('contractid'));
			System.assertEquals(contract.id,collectionCase.AFC_Contract__c);
			System.assertEquals('Open',collectionCase.AFC_Case_Status__c);
			System.assertEquals(contract.AFC_Branch__c,collectionCase.AFC_Branch_Name__c);
			System.assertEquals(contract.AFC_Region__c,collectionCase.AFC_Region__c);
			System.assertEquals(contract.AFC_Division__c,collectionCase.AFC_Division__c);
			System.assertEquals(contract.AFC_Country__c,collectionCase.AFC_Country__c);
			System.assertEquals(contract.AFC_Risk_Group__c,collectionCase.AFC_Risk_Group__c);
			System.assertEquals(contract.AFC_Yield_Group__c,collectionCase.AFC_Yield_Group__c);
			System.assertEquals(contract.PLN__c,collectionCase.AFC_PLN__c);
			System.assertEquals(contract.Current_Principle_Amt_Oustanding__c,collectionCase.AFC_Principal_OS__c);
			System.assertEquals(contract.Product_Type__c,collectionCase.AFC_Product_Type__c);
			System.assertEquals(contract.AFC_Type__c,collectionCase.AFC_Type__c);
		Test.stopTest();
	}

	public static testMethod void testRefreshSummary() {
		Account a = new Account(Name='Test Account');
		insert a;
		AFC_Contracts__c contract = new AFC_Contracts__c(Account__c=a.id,Name='test',AFC_Branch__c='Flint',AFC_Division__c='division',AFC_Country__c='United States',AFC_Risk_Group__c='Less Than 1%',AFC_Yield_Group__c='10% - 14.9%',
															AFC_Default_Risk__c = .05, Current_Principle_Amt_Oustanding__c=50000.00,PLN__c=false,Product_Type__c='WHOLESALE ONLY',AFC_Type__c='test',Contract_Status__c='ACTIVE');
		insert contract;

		Test.startTest();
			PageReference pageRef = new PageReference('Page.AFCRiskList');
			pageRef.getParameters().put('contractid',contract.Id);
			Test.setCurrentPage(pageRef);
			AFCRiskListController afcrlc = new AFCRiskListController();
			
			afcrlc.refreshSummary();
			System.assertEquals(afcrlc.selectedContract,contract.Id);
		Test.stopTest();			
	}
}