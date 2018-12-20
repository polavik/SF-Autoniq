@TestVisible
@isTest
private class TestApplicationServices
{
	static final String CREDIT_USER_LOOKUP = 'Credit_User__c';
    static final String CT_USER_LOOKUP = 'CT_Processing_User__c';
    static final Set<String> ALL_CHANGED_FIELDS = new Set<String>{ CREDIT_USER_LOOKUP, CT_USER_LOOKUP};
    static final String INVALID_CREDIT_DEPT = 'Credit2';
    static final String CREDIT_DEPT = 'Credit';
    static final String CT_PROCESSING = 'CT Processing';
    static final List<String> VALID_DEPARTMENTS_FIELDS = new List<String>{ CREDIT_DEPT, CT_PROCESSING};
    static final String PROFILE_NAME = 'Standard User';
    static final String CREDIT_PROFILE='AFC Credit Analyst';
    static final String CT_PROFILE='AFC CT Processing Specialist';
    static final List<String> COMPLETE_STATUS = new List<String> { 'Excluded' };
    static List<Id> recordTypeDeveloperNameIds;
    static id unqualifyingRecordType;
    static User creditUser1;
    static User creditUser2;
    static User ctUser1;
    static User ctUser2;
    
    static void setupApplicationsWithChecklistItems(){
        final String TEST_REGION = 'Test';
        final String TEST_BRANCH = 'Test';
        final String CREDIT_TYPE='Platinum';

        creditUser1 = TestUtils.createUsers(1, CREDIT_PROFILE, false)[0];
        creditUser1.AFC_Region_Responsible__c = TEST_REGION;
        creditUser1.AFC_Branch_Responsible__c = TEST_BRANCH;
        creditUser1.Credit_or_Contract__c = CREDIT_DEPT;
        creditUser1.Credit_Type__c = CREDIT_TYPE;
        ctUser1 = TestUtils.createUsers(1, CT_PROFILE, false)[0];
        ctUser1.AFC_Region_Responsible__c = TEST_REGION;
        ctUser1.AFC_Branch_Responsible__c = TEST_BRANCH;
        ctUser1.Credit_or_Contract__c = CT_PROCESSING;

        insert new List<User>{creditUser1, ctUser1};
        
        UnitTest.addData(TestUtils.createApplications(3, false)).tag('All Applications').divide(3).part('Applications with no checklist items in filter')
                                                                                                  .part('Applications with some checklist items in filter')
                                                                                                  .part('Applications with all checklist items in filter');
                                                                                                  
        UnitTest.get('All Applications').minus('Applications with no checklist items in filter').tag('Qualifying Applications');                                                                                          
        
        UnitTest.get('Qualifying Applications').property('Credit_User__c').assign( creditUser1.id );
        UnitTest.get('Qualifying Applications').property('CT_Processing_User__c').assign( ctUser1.id );
        
        UnitTest.get( 'All Applications' ).insertAll();
                                                                                                  
        UnitTest.addData(TestUtils.createChecklists(3, null, false)).tag('All Checklists').divide(3).part('Checklist with no items')
                                                                                                    .part('Checklist with some items')
                                                                                                    .part('Checklist with all items');
                                                                                                    
                                                                                                    
        UnitTest.get('Checklist with no items').tag('Unqualifying and qualifying checklists');
        UnitTest.get('Checklist with some items').tag('Unqualifying and qualifying checklists');
        UnitTest.get('Checklist with some items').tag('Qualifying checklists');
        UnitTest.get('Checklist with all items').tag('Qualifying checklists');
        UnitTest.get('All Checklists').property('Application__c').assignFrom('All Applications');
        
        UnitTest.get('All Checklists').insertAll();
        
        UnitTest.addData(TestUtils.createChecklistItems(30, null, false)).tag('All Checklist Items').divide(3).part('Checklist items without department')
                                                                                                              .part('Checklist items with department')
                                                                                                              .part('checklist items incomplete with department');
        
        UnitTest.get('Checklist items without department').property('Checklist__c').assignFrom('Unqualifying and qualifying checklists').tag('Unqualifying Items');                                                                                                   
        UnitTest.get('Checklist items with department').property('Checklist__c').assignFrom('Unqualifying and qualifying checklists').tag('Unqualifying Items');                                                                                                      
        UnitTest.get('checklist items incomplete with department').property('Checklist__c').assignFrom('Qualifying checklists').tag('Qualifying Items');                                                                                                      
        
        UnitTest.get('Checklist items without department').property('Item_Status__c').assignFrom(ApplicationServices.INCOMPLETE_STATUS);
        UnitTest.get('Checklist items without department').property('For_Department__c').assign(INVALID_CREDIT_DEPT);
        
        UnitTest.get('Checklist items with department').property('Item_Status__c').assignFrom(COMPLETE_STATUS);
        UnitTest.get('Checklist items with department').property('For_Department__c').assignFrom(VALID_DEPARTMENTS_FIELDS);
        
        UnitTest.get('checklist items incomplete with department').property('Item_Status__c').assignFrom(ApplicationServices.INCOMPLETE_STATUS);
        UnitTest.get('checklist items incomplete with department').property('For_Department__c').assignFrom(VALID_DEPARTMENTS_FIELDS);
        
        UnitTest.get('All Checklist Items').property('Primary_Return_Reason__c').assign('Incomplete');
        UnitTest.get('All Checklist Items').property('Document_Attached__c').assign(true);
        System.runAs(creditUser1){
            UnitTest.get('All Checklist Items').insertAll();
        }
        
        
    }
    
    static testMethod void testFilterApplicationsThatHaveChangedUsers()
    {
        
        UnitTest.addData(TestUtils.createApplications(4, false)).tag('All Applications');
        
        creditUser1 = TestUtils.createUsers(1, PROFILE_NAME, true)[0];
        creditUser2 = TestUtils.createusers(1, PROFILE_NAME, true)[0];
        ctUser1 = TestUtils.createUsers(1, PROFILE_NAME, true)[0];
        ctUser2 = TestUtils.createUsers(1, PROFILE_NAME, true)[0];
        
        
        UnitTest.get('All Applications').divide(4).part('Application with no change')
                                                  .part('Application with credit user change')
                                                  .part('Application with ct user change')
                                                  .part('Application with both credit user and ct user change');
                                                  
        UnitTest.get('All Applications').property('Credit_User__c').assign(creditUser1.Id);
        UnitTest.get('All Applications').property('CT_Processing_User__c').assign(ctUser1.Id);
        
        UnitTest.get('All Applications').dummyInsert();
        
        Map<Id, Application__c> oldSnapshot = new Map<Id, Application__c> ((List<Application__c>) UnitTest.get('All Applications').getList().deepClone(true));
        
        UnitTest.get('Application with credit user change').property('Credit_User__c').assign(creditUser2.Id).tag('Applications with changes');
        UnitTest.get('Application with ct user change').property('CT_Processing_User__c').assign(ctUser2.Id).tag('Applications with changes');
        UnitTest.get('Application with both credit user and ct user change')
                .property('CT_Processing_User__c')
                    .assign(ctUser2.Id)
                .property('Credit_User__c')
                    .assign(creditUser2.Id).tag('Applications with changes');

        Test.startTest();
            Map<Id, List<String>> actualResults = ApplicationServices.filterApplicationsThatHaveChangedUsers(UnitTest.get('All Applications').getList(), oldSnapshot, new Set<String> {CREDIT_USER_LOOKUP, CT_USER_LOOKUP});
            Map<Id, List<String>> actualResults_NoUserFields = ApplicationServices.filterApplicationsThatHaveChangedUsers(UnitTest.get('All Applications').getList(), oldSnapshot, new Set<String> {});
        Test.stopTest();
        
        System.assertEquals(null, actualResults_NoUserFields, 'We expect filter to return no applications if no user fields are specified');
        
        Set<Id>expectedApplicationIds = new Map<Id, Application__c> ((List<Application__c>)UnitTest.get( 'Applications with changes' ).getList()).keySet();
        System.assertEquals( expectedApplicationIds, actualResults.keySet(),  'We expect filter to return application ids with a change to the user lookup fields');
        
        for( Id changedApplicationId : actualResults.keySet()){
                List<String> changedFields = actualResults.get(changedApplicationId);
            if( UnitTest.analyze( 'Application with both credit user and ct user change' ).hasId( changedApplicationId )){  
                System.assertEquals( 2, changedFields.size(), 'Two fields should be detected as changed');
                System.assertEquals( ALL_CHANGED_FIELDS, new Set<String>( changedFields ), 'We expect to only see the fields that we changed detected');
            }
            else if( UnitTest.analyze( 'Application with ct user change' ).hasId( changedApplicationId )){
                System.assertEquals( 1, changedFields.size(), 'One field should be detected as changed');
                System.assertEquals( CT_USER_LOOKUP, changedFields[0], 'The ct user lookup should be detected');
            }
            else{
                System.assertEquals( 1, changedFields.size(), 'One field should be detected as changed');
                System.assertEquals( CREDIT_USER_LOOKUP, changedFields[0], 'The credit user lookup should be detected');
            }
        }       
    }
    

    static testMethod void testProcessApplicationCheckListItems(){
        
        setupApplicationsWithChecklistItems();
        
        Set<Id> allApplicationIds = new Map<Id, Application__c> ((List<Application__c>)UnitTest.get( 'All Applications' ).getList()).keySet();
        
        UnitTest.get('Qualifying Items')
            .divide( 2 )
                .part( 'Qualifying Items with ctUserDept')
                .part( 'Qualifying Items with creditUserDept');
        
        UnitTest.get( 'Qualifying Items with ctUserDept' ).property('For_Department__c').assign( CT_PROCESSING );
        UnitTest.get( 'Qualifying Items with creditUserDept' ).property('For_Department__c').assign( CREDIT_DEPT );
        UnitTest.get('Qualifying Items').updateAll();
        
        Map<Id, List<Checklist_Item__c>> applicationIdsToMatchingCheckListItems = ApplicationServices.findChecklistItems( allApplicationIds, new Set<String> {CREDIT_USER_LOOKUP, CT_USER_LOOKUP}, VALID_DEPARTMENTS_FIELDS);
        Map<Id, Application__c> filteredApplicationMap = new Map<Id, Application__c> ((List<Application__c>)UnitTest.get( 'Qualifying Applications' ).getList());
        Map<Id, List<String>> applicationIdToChangedFields = new Map<Id, List<String>>();
        
        for(Id applicationId : filteredApplicationMap.keySet() )
            applicationIdToChangedFields.put( applicationId, new List<String>{ CT_USER_LOOKUP, CREDIT_USER_LOOKUP});

        ApplicationCreditUserChecklistType__c setting1 = new ApplicationCreditUserChecklistType__c( Name = CT_USER_LOOKUP, Checklist_For_Department_Value__c = CT_PROCESSING);      
        ApplicationCreditUserChecklistType__c setting2 = new ApplicationCreditUserChecklistType__c( Name = CREDIT_USER_LOOKUP, Checklist_For_Department_Value__c = CREDIT_DEPT);
        
        Map<String, ApplicationCreditUserChecklistType__c> settingsMapByName = new Map<String, ApplicationCreditUserChecklistType__c>();
        settingsMapByName.put(CT_USER_LOOKUP, setting1);
        settingsMapByName.put(CREDIT_USER_LOOKUP, setting2);
            
        Test.startTest();
            List<Checklist_Item__c> actualItems = ApplicationServices.processApplicationCheckListItems( applicationIdToChangedFields, applicationIdsToMatchingCheckListItems, settingsMapByName, filteredApplicationMap);
            List<Checklist_Item__c> nullactualItems1 = ApplicationServices.processApplicationCheckListItems( null, applicationIdsToMatchingCheckListItems, settingsMapByName, filteredApplicationMap);
            List<Checklist_Item__c> nullactualItems2 = ApplicationServices.processApplicationCheckListItems( applicationIdToChangedFields, null, settingsMapByName, filteredApplicationMap);
            List<Checklist_Item__c> nullactualItems3 = ApplicationServices.processApplicationCheckListItems( applicationIdToChangedFields, applicationIdsToMatchingCheckListItems, null, filteredApplicationMap);
        Test.stopTest();
        
        
        System.assertEquals( 10, actualItems.size(), 'We expect to receive 10 valid checklist items that are prepped for update');
        for(Checklist_Item__c item : actualItems){
            if(!UnitTest.analyze('Qualifying Items').hasId(item.Id)){
                System.assert(false, 'We expect only qualifying checklist items to be returned');
            }
            if(UnitTest.analyze('Qualifying Items with ctUserDept').hasId(item.Id))
                System.assertEquals( ctUser1.Id, item.Assigned_Department_User__c );
            else
                System.assertEquals( creditUser1.Id, item.Assigned_Department_User__c );
        }

        System.assertEquals( null, nullactualItems1, 'We expect null since we have no changed fields');
        System.assertEquals( null, nullactualItems2, 'We expect null since we have no checklist items');
        System.assertEquals( null, nullactualItems3, 'We expect null since we have no custom settings');
        
    }
    
    static testMethod void testUpdateCheckListItems(){
        setupApplicationsWithChecklistItems();
        
        UnitTest.addData([Select id, Item_Status__c, CheckList__r.Application__c from Checklist_Item__c where id in : UnitTest.get('Qualifying Items').getList() ]).tag('Database Qualified Items');
        
        UnitTest.get('Database Qualified Items').divide(2).part('Error Items').part('Success Items');
        UnitTest.get('Error Items').property('Checklist__c').assign( null );
        
        Map<Id, Application__c> newMapToAddErrors = new Map<Id, Application__c>( (List<Application__c>) UnitTest.get( 'Qualifying Applications' ).getList());
        List<Checklist_Item__c> itemsToUpdate = (List<Checklist_Item__c>) UnitTest.get('Database Qualified Items').getList();
        
        Test.StartTest();
            List<Checklist_Item__c> errorItems = new List<Checklist_Item__c>();
            ApplicationServices.updateCheckListItems(itemsToUpdate, newMapToAddErrors); 
        Test.StopTest();

        System.assertEquals( 1, ApexPages.getMessages().size(),' A page message Error should be thrown');
        
    }

    static testMethod void updateAppStatusFromContractReceivedDate_validParams_returnsNothing()
	{
		AFC_Contract_Shell__c afcConShell = TestServices.insert_AFCContractShell();
        Test.startTest();
    		Application__c app = [select Application_Stage__c from Application__c where Id = :afcConShell.Application__c];
            app.Application_Stage__c = null;
            update app;
            System.assert(String.isBlank(app.Application_Stage__c), 'Newly created app should have a blank Stage');
            afcConShell.Received_from_Dealer__c = null;
            update afcConShell;

            app = [select Application_Stage__c from Application__c where Id = :afcConShell.Application__c];
    		System.assert(String.isBlank(app.Application_Stage__c), 'Stage should still be blank since Received was not changed from null to not null');

    		afcConShell.Received_from_Dealer__c = Date.today();
    		update afcConShell;
    		app = [select Application_Stage__c from Application__c where Id = :afcConShell.Application__c];
    		System.assertEquals('Contract Active', app.Application_Stage__c, 'After updating contract Received field from null to not null, updateAppStatusFromContractReceivedDate should run from trigger and update Stage');
        Test.stopTest();
	}
	static testMethod void updateBranchNumber_validParams_returnsNothing()
    {
    	BranchNumber__c testBn = new BranchNumber__c(Name='One', Branch_Number__c=1);
    	insert testBn;
    	
        User testUser = TestServices.createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = TestServices.createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);
        Opportunity opp = TestServices.createTestOpportunity('Test Opp', 'Closed Won', 'Indianapolis', true);
        Application__c testApp = TestServices.createTestApplication(opp.Id, 'Shull', true);
    }

    static testMethod void  testDetectAndApplyAppAccountChanges(){
        Account acc = TestServices.getTestAccount('TestAccount', true);
        Account accDif = TestServices.getTestAccount('TestAccount', true);
        Application__c app = TestApplicationServices.createApplication(true,accDif);

        Application_Account_Role__c acr = TestApplicationServices.createApplicationAccountRole(true, acc, app, true);
        List<Application_Account_Role__c> aarList = new List<Application_Account_Role__c>();
        aarList.add(acr);

        Account acc2 = TestServices.getTestAccount('TestAccount', true);
        Application__c app2 = TestApplicationServices.createApplication(true,acc2);
        Application_Account_Role__c acrOld = TestApplicationServices.createApplicationAccountRole(true, acc2, app2, false);

        Map<Id, Application_Account_Role__c> oldAppAccountsMap = new Map<Id, Application_Account_Role__c>();
        oldAppAccountsMap.put(acrOld.id,acrOld);
        Test.startTest();
            ApplicationServices.detectAndApplyAppAccountChanges(aarList, oldAppAccountsMap, true);
            Application__c upApp = [select Id, Applications_Accounts__c FROM Application__c WHERE Id = :app.id];
            System.assert(upApp.Applications_Accounts__c != null);
            System.assert(app.Applications_Accounts__c != upApp.Applications_Accounts__c);
        Test.stopTest();
    }
    static testMethod void  testDetectAndApplyAppAccountChangesNegative(){

        Account acc = TestServices.getTestAccount('TestAccount', true);
        Account accDif = TestServices.getTestAccount('TestAccount', true);
        Application__c app = TestApplicationServices.createApplication(true,accDif);

        //Both Application Account Roles do not have primary
        Application_Account_Role__c acr = TestApplicationServices.createApplicationAccountRole(true, acc, app, false);
        List<Application_Account_Role__c> aarList = new List<Application_Account_Role__c>();
        aarList.add(acr);

        Account acc2 = TestServices.getTestAccount('TestAccount', true);
        Application__c app2 = TestApplicationServices.createApplication(true,acc2);
        Application_Account_Role__c acrOld = TestApplicationServices.createApplicationAccountRole(true, acc2, app2, false);

        Map<Id, Application_Account_Role__c> oldAppAccountsMap = new Map<Id, Application_Account_Role__c>();
        oldAppAccountsMap.put(acrOld.id,acrOld);
        
        Test.startTest();
            ApplicationServices.detectAndApplyAppAccountChanges(aarList, oldAppAccountsMap, true);
            Application__c upApp = [select Id, Applications_Accounts__c FROM Application__c WHERE Id = :app.id];
            System.assert(upApp.Applications_Accounts__c != null);
            System.assertEquals(app.Applications_Accounts__c, upApp.Applications_Accounts__c);
        Test.stopTest();
    }
    static testMethod void testClearPrimaryApplicationAccountsfield(){

        Account acc = TestServices.getTestAccount('TestAccount', true);
        Application__c app = TestApplicationServices.createApplication(true,acc);
        List<Application_Account_Role__c> aarList = new List<Application_Account_Role__c>();

        Application_Account_Role__c acr = TestApplicationServices.createApplicationAccountRole(true, acc, app, true);
        aarList.add(acr);

        Map<Id, Application_Account_Role__c> mapNewappAccs = new Map<Id, Application_Account_Role__c>();
        mapNewappAccs.put(acr.id,acr);

        Test.startTest();
            ApplicationServices.clearprimaryApplicationAccountsfield(aarList, mapNewappAccs, true);
            for(Application__c testApp : [select Id, Applications_Accounts__c from Application__c]){
                System.assertEquals(null,testApp.Applications_Accounts__c);
            }
        Test.stopTest();


    }    
    static testMethod void testClearPrimaryApplicationAccountsfieldNegative(){

        Account acc = TestServices.getTestAccount('TestAccount', true);
        Application__c app = TestApplicationServices.createApplication(true,acc);
        List<Application_Account_Role__c> aarList = new List<Application_Account_Role__c>();

        Application_Account_Role__c acr = TestApplicationServices.createApplicationAccountRole(true, acc, app, false);
        aarList.add(acr);

        Map<Id, Application_Account_Role__c> mapNewappAccs = new Map<Id, Application_Account_Role__c>();
        mapNewappAccs.put(acr.id,acr);
        Test.startTest();
            ApplicationServices.clearprimaryApplicationAccountsfield(aarList, mapNewappAccs, true);
            for(Application__c testApp : [select Id, Applications_Accounts__c from Application__c]){
                System.assert(testApp.Applications_Accounts__c != null);
            }
        Test.stopTest();
    }
    static testMethod void testDeleteInProgressApplicationsBulk()
    {
        User testUser = TestServices.createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = TestServices.createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);
        Opportunity opp = TestServices.createTestOpportunity('Test Opp', 'Closed Won', 'Indianapolis', true);
    	Application__c[] apps = new Application__c[]{};
    	for(Integer i=0; i < 250; i++)
    	{
			apps.add(TestServices.createTestApplication(opp.Id, 'Shull', false));
    	}
    	insert apps;
    	apps = [select Id from Application__c];
    	System.assertEquals(250, apps.size());
    	
    	for(Integer i=0; i < 250; i++)
    	{
    		if(Math.mod(i, 10) == 0)
    		{
    			apps[i].Application_Flow_In_Progress__c = true;
    		}
    	}
    	update apps;
    	
    	Test.startTest();
    	   update apps[1];
    	Test.stopTest();
    	
    	apps = [select Id from Application__c];
    	System.assertEquals(225, apps.size());
    }

    private static Application__c createApplication(boolean doInsert, Account acc){
        User testUser = TestServices.createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = TestServices.createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);
        Opportunity opp = TestServices.createTestOpportunity('Test Opp', 'Closed Won', 'Indianapolis', true);

        Id recordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Line Mod').getRecordTypeId();

        Application__c app = new Application__c(Applications_Accounts__c = acc.Id,
        Name = 'TestApplication',
        DBA_Name__c             = 'TestAccount Inc.',
        Dealer_Entity_Type__c   = 'CORPORATION',
        AFC_Branch_Number__c    = 123456,
        RecordTypeId            = recordTypeId,
        //AFC_Contract_Number__c  = afcCon.Id,
        AFC_Credit_Status__c    = 'APPROVED', 
        Lot_Ownership__c        = 'Own',
        Credit_Decision__c      = 'Credit Decision',
        Credit_Product_Type__c  = 'COMMERCIAL TRUCK',
        Credit_Decision_Date__c = Date.today(),
        Credit_Amount__c        = 100.00,
        FP_Fee__c               = 100.00,
        Floorplan_Days__c       = 100,
        Number_of_Curtailments__c = 10,
        Interest_Rate_Base__c   = 'AFC PRIME FLOOR',
        Curtailment_Fee__c      = 100.00,
        Curtailment_Days__c     = 12,
        Curtailment_Reduction_Percentage__c = 10.0,
        KO_Book__c              = 'In KO',
        Interest_Charge__c      = 10.0,
        Next_Renewal_Date__c    = '3 Months',
        Opportunity__c          = opp.Id,
        AFC_Region__c           = 'Shull');  

        if(doInsert){
            insert app;
        }

        return app;

    }

    private static Application_Account_Role__c createApplicationAccountRole(boolean doInsert, Account acc, Application__c app, boolean primary){
            Application_Account_Role__c aar = new Application_Account_Role__c(
            Account__c = acc.Id,
            Application__c = app.Id,
            Primary__c = primary,
            Company_Name__c = 'Legal Name',
            DBA_Name__c = 'DBA Name',
            TIN__c = 'TIN',
            Sales_Tax_Number__c = 'STN',
            Dealer_License_Number__c = 'DLN',
            Expiration_Date__c = Date.today(),
            Entity_Type__c = 'ET',
            Years_in_Business__c = 1,
            Lot_Ownership__c = 'Own');

            if(doInsert){
                insert aar;
            }

            return aar;
        
    }
}