/*
Author: Pike Pullen
Date: 11/4/2013
Description: Unit Test Coverage for iHubWebServices class
*/

@isTest
public class TestiHubWebServices
{
    public class MockIHubWebservices implements WebServiceMock, HttpCalloutMock
    {
        public void doInvoke( Object stub, Object request, Map<String, Object> response, String endpoint,
                                String soapAction, String requestName, String responseNS, String responseName, String responseType )
        {
            response.put( 'response_x', TestServices.getMockCosmosResponse( new List<Application_Contact_Role__c>() ) );
        }

        public HttpResponse respond( HttpRequest req )
        {
            HttpResponse theResponse = new HttpResponse();
            return theResponse;
        }
    }

    static
    {
        System.Test.setMock( WebServiceMock.class, new MockIHubWebservices() );
        System.Test.setMock( HttpCalloutMock.class, new MockIHubWebservices() );
    }

	static testMethod void SendTerms_validParams_returnsIdList()
    {
		AFC_Contract_Shell__c afcCon = TestServices.insert_AFCContractShell();

    	AFC_Contract_Terms__c afcContractTermsA = new AFC_Contract_Terms__c(AFC_Contract_Shell__c = afcCon.id, Term_Id__c = 'testid', Term_Type__c='testterm', Term_Name__c='testtermname', Print_On_Contract__c='1');
		AFC_Contract_Terms__c afcContractTermsB = new AFC_Contract_Terms__c(AFC_Contract_Shell__c = afcCon.id, Term_Id__c = 'testid2', Term_Type__c='testterm', Term_Name__c='testtermname', Print_On_Contract__c='0');
		list<AFC_Contract_Terms__c> afcToTest = new list<AFC_Contract_Terms__c>();
		afcToTest.add(afcContractTermsA);
		afcToTest.add(afcContractTermsB);

		list<ID> idList = new list<ID>();
    	idList = IHubWebServices.sendTerms(afcToTest);

    	System.assertEquals(idList.size(), 2);
    }

	static testMethod void SendApplicationTest_validParams_returnsNothing()
    {
		Lead application = new Lead(firstName='fName', lastName='lName', company='cName');

		IHubWebServices.sendApplication(application);
		System.assertEquals('cName', application.company, 'Application.id should be returned');
    }

    static testMethod void cosmosInvoke_validParams_returnsNothing()
    {
		AFC_Contract_Shell__c afcCon = TestServices.insert_AFCContractShell();
    Application_Account_Role__c aarRecord = ApplicationAccountRoleServices.getApplicationAccountRole(afcCon.Account__c, afcCon.Application__c);


		TestServices.insert_OrgConfig();
		PageReference pageRef = Page.CosmosInvoke;
        Test.setCurrentPage(pageRef);

      	ApexPages.CurrentPage().getParameters().put('id', afcCon.Id);

 		ApexPages.StandardController sc = New ApexPages.StandardController(afcCon);
        CosmosInvokeContExt cice = new CosmosInvokeContExt(sc);
        cice.cosmosInvoke();
    }

	/*
	Null Cosmos Invoke
	*/
	static testMethod void cosmosInvoke_nullContract_returnsNothing()
    {
		AFC_Contract_Shell__c afcCon = new AFC_Contract_Shell__c();

		TestServices.insert_OrgConfig(); //HTTP
		PageReference pageRef = Page.CosmosInvoke;
        Test.setCurrentPage(pageRef);

      	ApexPages.CurrentPage().getParameters().put('id', afcCon.Id);

 		ApexPages.StandardController sc = New ApexPages.StandardController(afcCon);
        CosmosInvokeContExt cice = new CosmosInvokeContExt(sc);
        cice.cosmosInvoke();

        System.assertEquals(System.Label.No_Business_Accounts, ApexPages.getMessages()[0].getDetail());
    }

    static testMethod void cosmosInvoke_nullCreditLimit_returnsNothing()
    {
		AFC_Contract_Shell__c afcCon = TestServices.insert_AFCContractShell();
      	afcCon.Credit_Limit__c = null;


		TestServices.insert_OrgConfig(); //HTTP

		PageReference pageRef = Page.CosmosInvoke;
        Test.setCurrentPage(pageRef);

      	ApexPages.CurrentPage().getParameters().put('id', afcCon.Id);

 		ApexPages.StandardController sc = New ApexPages.StandardController(afcCon);
        CosmosInvokeContExt cice = new CosmosInvokeContExt(sc);
        cice.cosmosInvoke();

        System.assertEquals(System.Label.Credit_Limit_Null, ApexPages.getMessages()[0].getDetail());
    }

    static testMethod void cosmosInvoke_nullAppBranchNumber_returnsNothing()
    {
		AFC_Contract_Shell__c afcCon = TestServices.insert_AFCContractShell();
      	afcCon.Application__r.AFC_Branch_Number__c = null;

		TestServices.insert_OrgConfig(); //HTTP

		PageReference pageRef = Page.CosmosInvoke;
        Test.setCurrentPage(pageRef);

      	ApexPages.CurrentPage().getParameters().put('id', afcCon.Id);

 		ApexPages.StandardController sc = New ApexPages.StandardController(afcCon);
        CosmosInvokeContExt cice = new CosmosInvokeContExt(sc);
        cice.cosmosInvoke();

        System.assertEquals(System.Label.Branch_Number_null, ApexPages.getMessages()[0].getDetail());
    }

    static testMethod void cosmosInvoke_nullAccTIN_returnsNothing()
    {
		AFC_Contract_Shell__c afcCon = TestServices.insert_AFCContractShell();
        Application_Account_Role__c aarRecord = ApplicationAccountRoleServices.getApplicationAccountRole(afcCon.Account__c, afcCon.Application__c);
        aarRecord.TIN__c = '';
        update aarRecord;
        Account a = new Account(Id=afcCon.Account__c);
        a.Tax_Identification_Number__c = '';
        update a;
        afcCon = TestServices.getContractShell(afcCon.Id);

		TestServices.insert_OrgConfig(); //HTTP

		PageReference pageRef = Page.CosmosInvoke;
        Test.setCurrentPage(pageRef);

      	ApexPages.CurrentPage().getParameters().put('id', afcCon.Id);

 		ApexPages.StandardController sc = New ApexPages.StandardController(afcCon);
        CosmosInvokeContExt cice = new CosmosInvokeContExt(sc);
        cice.cosmosInvoke();

        System.assertEquals(System.Label.TIN_null, ApexPages.getMessages()[0].getDetail());
    }

    static testMethod void cosmosInvoke_nullAppDealerEntityType_returnsNothing()
    {
		AFC_Contract_Shell__c afcCon = TestServices.insert_AFCContractShell();
      	//afcCon.Application__r.Dealer_Entity_Type__c = '';
        Application_Account_Role__c aarRecord = ApplicationAccountRoleServices.getApplicationAccountRole(afcCon.Account__c, afcCon.Application__c);

        aarRecord.Entity_Type__c = '';
        update aarRecord;

		TestServices.insert_OrgConfig(); //HTTP

		PageReference pageRef = Page.CosmosInvoke;
        Test.setCurrentPage(pageRef);

      	ApexPages.CurrentPage().getParameters().put('id', afcCon.Id);

 		ApexPages.StandardController sc = New ApexPages.StandardController(afcCon);
        CosmosInvokeContExt cice = new CosmosInvokeContExt(sc);
        cice.cosmosInvoke();

        System.assertEquals(System.Label.Dealer_Entity_Type_null, ApexPages.getMessages()[0].getDetail());
    }

    static testMethod void cosmosInvoke_nullAccPrimaryStreet_returnsNothing()
    {
		AFC_Contract_Shell__c afcCon = TestServices.insert_AFCContractShell();
      	afcCon.Account__r.Primary_Street1__c 	= '';
      	afcCon.Account__r.Corrected_P_Street__c = '';

		TestServices.insert_OrgConfig(); //HTTP

		PageReference pageRef = Page.CosmosInvoke;
        Test.setCurrentPage(pageRef);

      	ApexPages.CurrentPage().getParameters().put('id', afcCon.Id);

 		ApexPages.StandardController sc = New ApexPages.StandardController(afcCon);
        CosmosInvokeContExt cice = new CosmosInvokeContExt(sc);
        cice.cosmosInvoke();

        System.assertEquals(System.Label.Account_Address_fields_null, ApexPages.getMessages()[0].getDetail());
    }

	static testMethod void cosmosInvoke_nullAccAddresses_returnsNothing()
    {
		AFC_Contract_Shell__c afcCon = TestServices.insert_AFCContractShell();
      	afcCon.Account__r.Primary_Street1__c = '';
      	afcCon.Account__r.Primary_City__c = '';
      	afcCon.Account__r.Primary_State__c = '';
      	afcCon.Account__r.Primary_PostalCode__c = '';
      	afcCon.Account__r.Corrected_P_Street__c = '';
      	afcCon.Account__r.Corrected_P_City__c = '';
      	afcCon.Account__r.Corrected_P_State__c = '';
      	afcCon.Account__r.Corrected_P_Postalcode__c = '';

		TestServices.insert_OrgConfig(); //HTTP

		PageReference pageRef = Page.CosmosInvoke;
        Test.setCurrentPage(pageRef);

      	ApexPages.CurrentPage().getParameters().put('id', afcCon.Id);

 		ApexPages.StandardController sc = New ApexPages.StandardController(afcCon);
        CosmosInvokeContExt cice = new CosmosInvokeContExt(sc);
        cice.cosmosInvoke();

        System.assertEquals(System.Label.Account_Address_fields_null, ApexPages.getMessages()[0].getDetail());
    }

	static testMethod void cosmosInvoke_nullAccStreets_returnsNothing()
    {
		AFC_Contract_Shell__c afcCon = TestServices.insert_AFCContractShell();
      	afcCon.Account__r.Corrected_P_Street__c = '';
      	afcCon.Account__r.Primary_Street1__c = '';

		TestServices.insert_OrgConfig(); //HTTP

		PageReference pageRef = Page.CosmosInvoke;
        Test.setCurrentPage(pageRef);

      	ApexPages.CurrentPage().getParameters().put('id', afcCon.Id);

 		ApexPages.StandardController sc = New ApexPages.StandardController(afcCon);
        CosmosInvokeContExt cice = new CosmosInvokeContExt(sc);
        cice.cosmosInvoke();

        System.assertEquals(System.Label.Account_Address_fields_null, ApexPages.getMessages()[0].getDetail());
    }

    static testMethod void cosmosInvoke_nullAppLotOwnership_returnsNothing()
    {
		AFC_Contract_Shell__c afcCon = TestServices.insert_AFCContractShell();
        Application_Account_Role__c aarRecord = ApplicationAccountRoleServices.getApplicationAccountRole(afcCon.Account__c, afcCon.Application__c);

        aarRecord.Lot_Ownership__c = '';
        update aarRecord;

		TestServices.insert_OrgConfig(); //HTTP

		PageReference pageRef = Page.CosmosInvoke;
        Test.setCurrentPage(pageRef);

      	ApexPages.CurrentPage().getParameters().put('id', afcCon.Id);

 		ApexPages.StandardController sc = New ApexPages.StandardController(afcCon);
        CosmosInvokeContExt cice = new CosmosInvokeContExt(sc);
        cice.cosmosInvoke();

        System.assertEquals(System.Label.Lot_Ownership_null, ApexPages.getMessages()[0].getDetail());
    }

    static testMethod void cosmosInvoke_nullContractType_returnsNothing()
    {
		AFC_Contract_Shell__c afcCon = TestServices.insert_AFCContractShell();

      	afcCon.Contract_Type__c = '';

		TestServices.insert_OrgConfig(); //HTTP

		PageReference pageRef = Page.CosmosInvoke;
        Test.setCurrentPage(pageRef);

      	ApexPages.CurrentPage().getParameters().put('id', afcCon.Id);

 		ApexPages.StandardController sc = New ApexPages.StandardController(afcCon);
        CosmosInvokeContExt cice = new CosmosInvokeContExt(sc);
        cice.cosmosInvoke();

        System.assertEquals(System.Label.Contract_Type_null, ApexPages.getMessages()[0].getDetail());
    }

	static testMethod void cosmosInvoke_nullProductType_returnsNothing()
    {
		AFC_Contract_Shell__c afcCon = TestServices.insert_AFCContractShell();
      	afcCon.Product_Type__c 	= null;

		TestServices.insert_OrgConfig(); //HTTP

		PageReference pageRef = Page.CosmosInvoke;
        Test.setCurrentPage(pageRef);

      	ApexPages.CurrentPage().getParameters().put('id', afcCon.Id);

 		ApexPages.StandardController sc = New ApexPages.StandardController(afcCon);
        CosmosInvokeContExt cice = new CosmosInvokeContExt(sc);
        cice.cosmosInvoke();

        System.assertEquals(System.Label.Product_Type, ApexPages.getMessages()[0].getDetail());
    }

	/*
	Null Contact Role
	*/
	static testMethod void cosmosInvoke_nullContactRoleFName_returnsNothing()
    {
		AFC_Contract_Shell__c afcCon = TestServices.insert_AFCContractShell();
		afcCon.Application_Contacts__r[0].Contact__r.FirstName = '';
		TestServices.insert_OrgConfig(); //HTTP

		PageReference pageRef = Page.CosmosInvoke;
        Test.setCurrentPage(pageRef);

      	ApexPages.CurrentPage().getParameters().put('id', afcCon.Id);

 		ApexPages.StandardController sc = New ApexPages.StandardController(afcCon);
        CosmosInvokeContExt cice = new CosmosInvokeContExt(sc);

        cice.cosmosInvoke();
        System.assertEquals(System.Label.First_Name_null + ' LastName', ApexPages.getMessages()[0].getDetail());

    }

    static testMethod void cosmosInvoke_nullContactRolePrimaryStreet_returnsNothing()
    {
		AFC_Contract_Shell__c afcCon = TestServices.insert_AFCContractShell();
		afcCon.Application_Contacts__r[0].Contact__r.AFC_Primary_Street__c = '';

		TestServices.insert_OrgConfig(); //HTTP

		PageReference pageRef = Page.CosmosInvoke;
        Test.setCurrentPage(pageRef);

      	ApexPages.CurrentPage().getParameters().put('id', afcCon.Id);

 		ApexPages.StandardController sc = New ApexPages.StandardController(afcCon);
        CosmosInvokeContExt cice = new CosmosInvokeContExt(sc);

        cice.cosmosInvoke();
        System.assertEquals(System.Label.Contact_Address_fields_null + ' FirstName LastName', ApexPages.getMessages()[0].getDetail());
    }

    static testMethod void cosmosInvoke_nullContactRoleOwn_returnsNothing()
    {
		AFC_Contract_Shell__c afcCon = TestServices.insert_AFCContractShell();
        afcCon.Application_Contacts__r[0].Contact__r.Type_of_Home_Ownership__c = '';

		TestServices.insert_OrgConfig(); //HTTP

		PageReference pageRef = Page.CosmosInvoke;
        Test.setCurrentPage(pageRef);

      	ApexPages.CurrentPage().getParameters().put('id', afcCon.Id);

 		ApexPages.StandardController sc = New ApexPages.StandardController(afcCon);
        CosmosInvokeContExt cice = new CosmosInvokeContExt(sc);

        cice.cosmosInvoke();
        System.assertEquals(System.Label.Ownership_null + ' FirstName LastName', ApexPages.getMessages()[0].getDetail());
    }

    static testMethod void cosmosInvoke_nullContactRolePH_returnsNothing()
    {
		AFC_Contract_Shell__c afcCon = TestServices.insert_AFCContractShell();
		afcCon.Application_Contacts__r[0].Contact__r.Phone = '';

		TestServices.insert_OrgConfig(); //HTTP

		PageReference pageRef = Page.CosmosInvoke;
        Test.setCurrentPage(pageRef);

      	ApexPages.CurrentPage().getParameters().put('id', afcCon.Id);

 		ApexPages.StandardController sc = New ApexPages.StandardController(afcCon);
        CosmosInvokeContExt cice = new CosmosInvokeContExt(sc);

        cice.cosmosInvoke();
        System.assertEquals(System.Label.Contact_Phone_null + ' FirstName LastName', ApexPages.getMessages()[0].getDetail());
    }

    static testMethod void cosmosInvoke_nullContactRoleBD_returnsNothing()
    {
		AFC_Contract_Shell__c afcCon = TestServices.insert_AFCContractShell();
    Application_Account_Role__c aarRecord = ApplicationAccountRoleServices.getApplicationAccountRole(afcCon.Account__c, afcCon.Application__c);

		afcCon.Application_Contacts__r[0].Contact__r.Birthdate = null;

		TestServices.insert_OrgConfig(); //HTTP

		PageReference pageRef = Page.CosmosInvoke;
        Test.setCurrentPage(pageRef);

      	ApexPages.CurrentPage().getParameters().put('id', afcCon.Id);

 		ApexPages.StandardController sc = New ApexPages.StandardController(afcCon);
        CosmosInvokeContExt cice = new CosmosInvokeContExt(sc);

        cice.cosmosInvoke();
        System.assertEquals(System.Label.Birthdate_null + ' FirstName LastName', ApexPages.getMessages()[0].getDetail());
    }

    static testMethod void cosmosInvoke_nullContactRoleDL_returnsNothing()
    {
		AFC_Contract_Shell__c afcCon = TestServices.insert_AFCContractShell();
		afcCon.Application_Contacts__r[0].Contact__r.Driver_s_License__c = '';

		TestServices.insert_OrgConfig(); //HTTP

		PageReference pageRef = Page.CosmosInvoke;
        Test.setCurrentPage(pageRef);

      	ApexPages.CurrentPage().getParameters().put('id', afcCon.Id);

 		ApexPages.StandardController sc = New ApexPages.StandardController(afcCon);
        CosmosInvokeContExt cice = new CosmosInvokeContExt(sc);

        cice.cosmosInvoke();
        string assertString = System.Label.Driver_s_License_null + ' FirstName LastName';
        System.assertEquals(assertString, ApexPages.getMessages()[0].getDetail());
    }

    /*
    Null Account Address
    */
    static testMethod void cosmosInvoke_nullAccountStreet_returnsNothing()
    {
		AFC_Contract_Shell__c afcCon = TestServices.insert_AFCContractShell();
		afcCon.Account__r.Primary_Street1__c = '';

		TestServices.insert_OrgConfig(); //HTTP

		PageReference pageRef = Page.CosmosInvoke;
        Test.setCurrentPage(pageRef);

      	ApexPages.CurrentPage().getParameters().put('id', afcCon.Id);

 		ApexPages.StandardController sc = New ApexPages.StandardController(afcCon);
        CosmosInvokeContExt cice = new CosmosInvokeContExt(sc);

        cice.cosmosInvoke();

        afcCon = TestServices.getContractShell(afcCon.Id);

        System.assertEquals('123456789', afcCon.AFC_Dealer_ID__c);
        System.assertEquals(987654321, afcCon.Master_Contract_ID__c);
        System.assertEquals('Success', ApexPages.getMessages()[0].getDetail());
    }

    static testMethod void cosmosInvoke_CanadianAccountCountry_returnsNothing()
    {
		AFC_Contract_Shell__c afcCon = TestServices.insert_AFCContractShell();
		afcCon.Account__r.Primary_Country__c = 'Canada';

		TestServices.insert_OrgConfig(); //HTTP

		PageReference pageRef = Page.CosmosInvoke;
        Test.setCurrentPage(pageRef);

      	ApexPages.CurrentPage().getParameters().put('id', afcCon.Id);

 		ApexPages.StandardController sc = New ApexPages.StandardController(afcCon);
        CosmosInvokeContExt cice = new CosmosInvokeContExt(sc);

        cice.cosmosInvoke();

        afcCon = TestServices.getContractShell(afcCon.Id);

        System.assertEquals('123456789', afcCon.AFC_Dealer_ID__c);
        System.assertEquals(987654321, afcCon.Master_Contract_ID__c);
        System.assertEquals('Success', ApexPages.getMessages()[0].getDetail());
    }

    static testMethod void testMapContractMarketingAttributes()
    {
        final Integer NUM_ATTRIBUTES = 12;
        AFC_Contract_Shell__c testContractShell = TestServices.insert_AFCContractShell();
        List<Marketing_Attribute__c> testAttributes = new List<Marketing_Attribute__c>();
        Set<String> attributeComposites = new Set<String>();
        for( Integer index = 0; index < NUM_ATTRIBUTES; index++ )
        {
            Marketing_Attribute__c newAttribute = TestServices.createMarketingAttribute( testContractShell.Application__c, false );
            newAttribute.High__c = 'someHigh_' + index;
            newAttribute.Medium__c = 'someMedium_' + index;
            newAttribute.Low__c = 'someLow_' + index;
            testAttributes.add( newAttribute );

            attributeComposites.add( newAttribute.High__c + '|' + newAttribute.Medium__c + '|' + newAttribute.Low__c );
        }
        insert testAttributes;

        TestServices.insert_OrgConfig();
        CosmosWebServices.DealerAndContractType testDealerCalloutWrapper = new CosmosWebServices.DealerAndContractType();

        Test.startTest();

            IHubWebServices.mapContractMarketingAttributes( testDealerCalloutWrapper, testContractShell );

        Test.stopTest();

        System.assertEquals( NUM_ATTRIBUTES, testDealerCalloutWrapper.MarketingAttributes.MarketingAttribute.size(), 'There should be as many attribute wrappers as were created' );
        Set<String> actualAttributeComposites = new Set<String>();
        for( CosmosWebServices.MarketingAttributeType anAttribute : testDealerCalloutWrapper.MarketingAttributes.MarketingAttribute )
        {
            actualAttributeComposites.add( anAttribute.High + '|' + anAttribute.Medium + '|' + anAttribute.Low );
        }
        System.assertEquals( actualAttributeComposites.containsAll( attributeComposites ), attributeComposites.containsAll( actualAttributeComposites ), 'All marketing attributes should have been retrieved' );
    }

    static testMethod void sendLineMod(){
        AFC_Contracts__c testContract = TestServices.insert_AFCContract();
        testContract.Contract_Status__c = IHubWebServices.ACTIVE_STATUS;
        update testContract;
        String dealerId = testContract.AFC_Dealer_Id__c;
        Account contractAcct = [SELECT Id, Name, AFC_Branch__c FROM Account WHERE Id = :testContract.Account__c ];
        Double amount = 0.0;
        String agreeToTerms = IHubWebServices.AFC_AGREE;
        String agreeToElectronicConsent = IHubWebServices.AFC_AGREE;
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = :IHubWebServices.SENDLINEMOD_RECORDTYPE LIMIT 1];

        insert new ContractTypeToOpportunityType__c(Name=testContract.Product_Type__c, Opportunity_Product_Type__c = 'PASSED');

        User branchManager = TestServices.createTestUser('manager@afc.com', 'region', 'Test Branch', 'Neither', true);

        AFC_Branch__c branch = new AFC_Branch__c(
            Branchnumber__c = testContract.AFC_Branch_Number__c,
            Name = contractAcct.AFC_Branch__c,
            Branch_Manager_1__c = branchManager.Id
        );
        insert branch;

        Test.startTest();
        Id oppId;
        try{
            oppId = IHubWebServices.sendLineMod(amount, dealerId, agreeToTerms, agreeToElectronicConsent);
        } catch (CustomExceptions.SendLineModException e){
            System.assert(false, 'Test should not throw an exception: ' + e.getMessage());
        }
        Test.stopTest();

        Opportunity dbOpp = null;
        try{
            dbOpp = [SELECT Id, Name, OwnerId, Type, Credit_Limit_Requested__c, RecordTypeId, AFC_Contracts__c, AccountId, AFC_Branch__c, 
                            StageName, CloseDate, Opportunity_Method__c, Opportunity_Source__c, Opportunity_Product_Type__c
                     FROM Opportunity 
                     WHERE Id = :oppId LIMIT 1];
        } catch (QueryException e){
            System.assert(false, 'No opportunity found in database with id: ' + oppId);
        }
        System.assertEquals(contractAcct.Id, dbOpp.AccountId);
        System.assertEquals(testContract.Id, dbOpp.AFC_Contracts__c);
        System.assertEquals(contractAcct.AFC_Branch__c, dbOpp.AFC_Branch__c);
        System.assertEquals(amount, dbOpp.Credit_Limit_Requested__c);
        System.assertEquals(Date.today().addDays(14), dbOpp.CloseDate);
        System.assertEquals(IHubWebServices.SENDLINEMOD_OPP_STAGE, dbOpp.StageName);
        System.assertEquals(rt.Id, dbOpp.RecordTypeId);
        System.assertEquals(IHubWebServices.SENDLINEMOD_GOLDLINE, dbOpp.Type);
        System.assertEquals(branchManager.Id, dbOpp.OwnerId);
        System.assertEquals(IHubWebServices.SENDLINEMOD_OPP_METHOD, dbOpp.Opportunity_Method__c);
        System.assertEquals(IHubWebServices.SENDLINEMOD_OPP_SOURCE, dbOpp.Opportunity_Source__c);
        System.assertEquals('PASSED', dbOpp.Opportunity_Product_Type__c);
    }

    static testMethod void sendLineMod_fail(){
        Test.startTest();
        try{
            IHubWebServices.sendLineMod(Double.valueof('0.0'), '00000', 'Y', 'Y');
            System.assert(false, 'Test should have thrown an exception');
        } catch (CustomExceptions.SendLineModException e){}
        Test.stopTest();
    }
}