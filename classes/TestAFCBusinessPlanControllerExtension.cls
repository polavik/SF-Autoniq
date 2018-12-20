@isTest
public with sharing class TestAFCBusinessPlanControllerExtension {
    public TestAFCBusinessPlanControllerExtension() {
    }

    static testMethod void testGetBusinessPlans(){
        TestSetupData testData = getTestSetupData();
        ApexPages.StandardController sc = new ApexPages.standardController(testData.afcBusinessPlan);
        AFCBusinessPlanControllerExtension bpce = new AFCBusinessPlanControllerExtension(sc);
        System.assert(bpce.businessPlan != null);
        System.assertEquals(bpce.businessPlan.Name,'2015 MOTOWN Business Plan');
    }

    static testMethod void testMultipleBusinessPlans(){
        TestSetupData testData = getTestSetupData();
        AFC_Business_Plan__c bp = new AFC_Business_Plan__c(Name='2015 Ann Arbor Business Plan',AFC_Branch__c=testData.afcBranch.id);
        insert bp;      

        ApexPages.StandardController sc = new ApexPages.standardController(new AFC_Business_Plan__c());
        AFCBusinessPlanControllerExtension bpce = new AFCBusinessPlanControllerExtension(sc);
        System.assertEquals(bpce.businessPlanOptions.size(),3); // Including the "Please Select" option
    }

    static testMethod void testSelectBusinessPlan(){
        TestSetupData testData = getTestSetupData();
        AFC_Business_Plan__c bp = new AFC_Business_Plan__c(Name='2015 Ann Arbor Business Plan',AFC_Branch__c=testData.afcBranch.id);
        insert bp;      

        ApexPages.StandardController sc = new ApexPages.standardController(new AFC_Business_Plan__c());
        AFCBusinessPlanControllerExtension bpce = new AFCBusinessPlanControllerExtension(sc);
        System.assertEquals(bpce.businessPlanOptions.size(),3); // Including the "Please Select" option
        bpce.selectedBusinessPlan = bpce.businessPlanOptions[1].getValue();
        PageReference pageRef = bpce.selectBusinessPlan();
        System.assertEquals(pageRef.getUrl(),'/apex/afcbusinessplan?id='+bpce.selectedBusinessPlan);
    }

    static testMethod void testSaveAllChanges(){
        TestSetupData testData = getTestSetupData();

        ApexPages.StandardController sc = new ApexPages.standardController(testData.afcBusinessPlan);
        AFCBusinessPlanControllerExtension bpce = new AFCBusinessPlanControllerExtension(sc);
        bpce.businessPlanGoals[0].AFC_Goal_Actions__r[0].Name='Goal11';
        Id bpgoalactionid = bpce.businessPlanGoals[0].AFC_Goal_Actions__r[0].id;
        bpce.saveAllChanges();
        AFC_Goal_Action__c ga = [select id,name from AFC_Goal_Action__c where id = :bpgoalactionid];
        System.assertEquals(ga.Name,'Goal11');
    }

    static testMethod void testCancelAllChanges(){
        TestSetupData testData = getTestSetupData();

        ApexPages.StandardController sc = new ApexPages.standardController(testData.afcBusinessPlan);
        AFCBusinessPlanControllerExtension bpce = new AFCBusinessPlanControllerExtension(sc);
        bpce.businessPlanGoals[0].AFC_Goal_Actions__r[0].Name='Goal11';
        Id bpgoalactionid = bpce.businessPlanGoals[0].AFC_Goal_Actions__r[0].id;
        bpce.cancelAllChanges();
        AFC_Goal_Action__c ga = [select id,name from AFC_Goal_Action__c where id = :bpgoalactionid];
        System.assertEquals(ga.Name,'Goal1 Action');
    }

    static testMethod void testAddAction(){
        TestSetupData testData = getTestSetupData();

        AFC_Goal_Action__c newGoalAction = new AFC_Goal_Action__c(
            Name='Goal1 Action 2',
            AFC_Goal__c=testData.afcBusinessPlanGoals[0].id,
            AFC_Business_Plan__c=testData.afcBusinessPlan.id,
            Start_Date__c=System.today(),
            End_Date__C=System.today(),
            Who_is_responsible__c=testData.afcBusinessPlanUser.id);     

        PageReference pageRef = Page.AFCBusinessPlan;
        pageRef.getParameters().put('goalid',testData.afcBusinessPlanGoals[0].id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.standardController(testData.afcBusinessPlan);
        AFCBusinessPlanControllerExtension bpce = new AFCBusinessPlanControllerExtension(sc);

        bpce.newActionGoalId = testData.afcBusinessPlanGoals[0].id;
        bpce.newGoalActionsMap.put(testData.afcBusinessPlanGoals[0].id,newGoalAction);

        List<AFC_Goal_Action__c> goalActions = [select id,name from AFC_Goal_Action__c where AFC_Goal__c = :testData.afcBusinessPlanGoals[0].id];

        bpce.addAction();

        List<AFC_Goal_Action__c> goalActions2 = [select id,name from AFC_Goal_Action__c where AFC_Goal__c = :testData.afcBusinessPlanGoals[0].id];
        System.assertEquals(goalActions.size()+1,goalActions2.size());
        System.assertEquals(null,bpce.newActionGoalId);
    }

    static testMethod void testSubmitForApproval(){
        TestSetupData testData = getTestSetupData();

        ApexPages.StandardController sc = new ApexPages.standardController(testData.afcBusinessPlan);
        AFCBusinessPlanControllerExtension bpce = new AFCBusinessPlanControllerExtension(sc);
        try{
            bpce.submitForApproval();
            for(Apexpages.Message msg:ApexPages.getMessages()){
                System.assert(msg.getDetail().contains('An error has occurred updating your goal levels.'));
            }           
        } catch(Exception e){
            System.assert(1==2); // If we get an exception, the test fails;
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
        result.afcBranch = branch;
        AFC_Business_Plan__c bp = new AFC_Business_Plan__c(Name='2015 MOTOWN Business Plan',AFC_Branch__c=branch.id);
        insert bp;
        result.afcBusinessPlan = bp;

        result.afcBusinessPlanGoals.add(new AFC_Goal__c(name='Goal1',AFC_Business_Plan__c=bp.id,Level__c=10));
        result.afcBusinessPlanGoals.add(new AFC_Goal__c(name='Goal2',AFC_Business_Plan__c=bp.id,Level__c=20));
        result.afcBusinessPlanGoals.add(new AFC_Goal__c(name='Goal3',AFC_Business_Plan__c=bp.id,Level__c=30));
        insert result.afcBusinessPlanGoals;

        AFC_Goal_Action__c goalAction = new AFC_Goal_Action__c(
            Name='Goal1 Action',
            AFC_Goal__c=result.afcBusinessPlanGoals[0].id,
            AFC_Business_Plan__c=bp.id,
            Start_Date__c=System.today(),
            End_Date__C=System.today(),
            Who_is_responsible__c=u.id);
        insert goalAction;

        return result;
    }

    private class TestSetupData{
        AFC_Branch__c afcBranch;
        AFC_Business_Plan__c afcBusinessPlan;
        List<AFC_Goal__c> afcBusinessPlanGoals;
        User afcBusinessPlanUser;

        public TestSetupData(){
            afcBusinessPlanGoals = new List<AFC_Goal__c>();
        }
    }
}