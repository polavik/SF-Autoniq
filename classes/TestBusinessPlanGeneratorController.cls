@isTest
public with sharing class TestBusinessPlanGeneratorController {
	public TestBusinessPlanGeneratorController() {
	}

	static testMethod void testGetBusinessPlans(){
		TestSetupData testData = getTestSetupData();
		BusinessPlanGeneratorController bpgc = new BusinessPlanGeneratorController();
		System.assertEquals(String.valueOf(System.today().year()),bpgc.businessPlanYear);
		System.assertEquals(1,bpgc.plannedBranches.size());
		System.assertEquals(2,bpgc.unplannedBranches.size());
	}

	static testMethod void testGenerateBusinessPlans(){
		TestSetupData testData = getTestSetupData();
		BusinessPlanGeneratorController bpgc = new BusinessPlanGeneratorController();
		bpgc.unplannedBranches[0].selected = true;
		bpgc.generateBusinessPlans();
		System.assertEquals(2,bpgc.plannedBranches.size());
		System.assertEquals(1,bpgc.unplannedBranches.size());
		for(AFC_Branch__c plannedBranch : bpgc.plannedBranches){
			System.assert(plannedBranch.AFC_Business_Plans__r != null);
			System.assertEquals(3,plannedBranch.AFC_Business_Plans__r[0].AFC_Goals__c);
		}
	}

	public static TestSetupData getTestSetupData(){
		TestSetupData result = new TestSetupData();
		Profile p = [select id from profile where name='Standard User'];
		User u = new User(alias = 'u1', email='ewhipple@afc.com',emailencodingkey='UTF-8', lastname='UserLastName', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,  country='United States', CommunityNickname = 'u1',timezonesidkey='America/Los_Angeles', username='regionalmanager@donan.com');
		insert u;
		result.afcBusinessPlanUser = u;

		AFC_Branch__c branch = new AFC_Branch__c(Name='MOTOWN',Branch_Manager_1__c=u.id);
		insert branch;
		result.afcPlannedBranch = branch;

		AFC_Branch__c branch2 = new AFC_Branch__c(Name='MOTOWN2',Branch_Manager_1__c=u.id);
		insert branch2;
		result.afcUnplannedBranch = branch2;

		AFC_Branch__c branch3 = new AFC_Branch__c(Name='MOTOWN3',Branch_Manager_1__c=u.id);
		insert branch3;

		result.afcBusinessPlanGoals.add(new AFC_Business_Plan_Goal__c(name='Goal1',Active__c=true,Branch_Goal__c=true,Default_Level__c=10,Year__c=String.valueOf(System.Today().year())));
		result.afcBusinessPlanGoals.add(new AFC_Business_Plan_Goal__c(name='Goal2',Active__c=true,Branch_Goal__c=true,Default_Level__c=20,Year__c=String.valueOf(System.Today().year())));
		result.afcBusinessPlanGoals.add(new AFC_Business_Plan_Goal__c(name='Goal3',Active__c=true,Branch_Goal__c=true,Default_Level__c=30,Year__c=String.valueOf(System.Today().year())));
		insert result.afcBusinessPlanGoals;

		AFC_Business_Plan__c bp = new AFC_Business_Plan__c(Name='2015 MOTOWN Business Plan',AFC_Branch__c=result.afcPlannedBranch.id,Year__c=String.valueOf(System.today().year()));
		insert bp;
		result.afcBusinessPlan = bp;
		AFC_Goal__c afcGoal = new AFC_Goal__c(name='Goal1',AFC_Business_Plan__c=bp.id,Level__c=10);
		insert afcGoal;
		AFC_Goal__c afcGoal2 = new AFC_Goal__c(name='Goal1',AFC_Business_Plan__c=bp.id,Level__c=10);
		insert afcGoal2;
		AFC_Goal__c afcGoal3 = new AFC_Goal__c(name='Goal1',AFC_Business_Plan__c=bp.id,Level__c=10);
		insert afcGoal3;
		return result;
	}

	private class TestSetupData{
		AFC_Branch__c afcPlannedBranch;
		AFC_Branch__c afcUnplannedBranch;
		AFC_Business_Plan__c afcBusinessPlan;
		List<AFC_Business_Plan_Goal__c> afcBusinessPlanGoals;
		User afcBusinessPlanUser;

		public TestSetupData(){
			afcBusinessPlanGoals = new List<AFC_Business_Plan_Goal__c>();
		}
	}	
}