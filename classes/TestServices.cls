/*
Class       : TestServices
Developer   : Ramon Munoz
Created     : Mar 26, 2012
Objective   : Helper class for setting up test data
*/
@isTest
public class TestServices
{
	public static AFC_Contracts__c insert_AFCContract()
	{
		Account acc = getTestAccount('TestAccount', true);

        Contact con = new Contact(AccountId = acc.Id,
        FirstName 					= 'FirstName',
        Middle_Name__c 				= 'MiddleName',
        LastName 					= 'LastName',
        Salutation					= 'King',
        Citizen__c					= true,
        BirthDate					= date.today().addYears(-30),
        Phone 						= '8889994444',
        HomePhone					= '8889994444',
        MobilePhone					= '8889994444',
        Email 						= 'test@test.com',
		AFC_Primary_Street__c		= '123 Anystreet',
		AFC_Primary_City__c			= 'MyCity',
		AFC_Primary_State__c		= 'MyState',
		AFC_Primary_PostalCode__c	= '65432',
		AFC_Primary_County__c		= 'USA',
		Type_of_Home_Ownership__c	= 'Own',
		SSN__c						= '789451234',
		Driver_s_License__c			= '1231232');
    	insert con;

        Opportunity opp = createTestOpportunity('Test Opp', 'Not Started', 'Indianapolis', true);
        User testUser = createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);

		Id recordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('New Application').getRecordTypeId();

		Application__c app = new Application__c(Applications_Accounts__c = acc.Id,
		Name                                = 'TestApplication',
		DBA_Name__c 			            = 'TestAccount Inc.',
		Dealer_Entity_Type__c 	            = 'CORPORATION',
		AFC_Branch_Number__c 	            = 123456,
		RecordTypeId			            = recordTypeId,
		Lot_Ownership__c 		            = 'Own',
		AFC_Credit_Status__c                = 'APPROVED',
		Credit_Decision__c                  = 'decision',
		Credit_Product_Type__c              = 'RENTAL',
		Credit_Amount__c                    = 50000,
		FP_Fee__c                           = 5000,
		Floorplan_Days__c                   = 5,
		Number_of_Curtailments__c           = 5,
		Interest_Rate_Base__c               = 'AFC PRIME FLOOR',
		Curtailment_Fee__c                  = 5000,
        KO_Book__c                          = 'In KO',
		Curtailment_Days__c                 = 5,
		Curtailment_Reduction_Percentage__c = 5,
		Interest_Charge__c                  = 5,
		Next_Renewal_Date__c                = '3 Months',
		Opportunity__c                      = opp.Id,
        AFC_Region__c                       = 'Shull');
		insert app;

		AFC_Contracts__c afcCon = new AFC_Contracts__c(name='test',
		AFC_Branch_Number__c					= '123123',
		Application__c 							= app.Id,
		Account__c 								= acc.Id,
		Contract_Received_At_Contracts_Date__c 	= datetime.now(),
		Master_Contract_ID__c 					= 546321,
		Affiliation_Type__c 					= 'No Affiliation',
		Contract_Type__c						= 'DEALER RETAIL MASTER CONTRACT',
		License_Type__c							= 'Business/Dealer',
		Product_Type__c							= 'WHOLESALE WITH SALVAGE',
    	Credit_Limit__c 						= 100000,
		Received_from_Dealer__c					= date.today(),
		AFC_Dealer_ID__c						= '123456');
		insert afcCon;

		app.AFC_Contract_Number__c = afcCon.Id;
		update app;

		Application_Contact_Role__c acr = new Application_Contact_Role__c(Account__c = acc.Id, Contact__c = con.Id, AFC_Contracts__c = afcCon.Id, Application__c = app.Id, Relationship__c = 'Owner' );
		insert acr;

		Application_Account_Role__c aar = new Application_Account_Role__c(
		    Account__c = acc.Id,
		    Application__c = app.Id,
		    Company_Name__c = 'Legal Name',
		    DBA_Name__c = 'DBA Name',
		    TIN__c = 'TIN',
		    Sales_Tax_Number__c = 'STN',
		    Dealer_License_Number__c = 'DLN',
		    Expiration_Date__c = Date.today(),
		    Entity_Type__c = 'ET',
		    Years_in_Business__c = 1,
		    Lot_Ownership__c = 'Own',
        AFC_Contracts__c = afcCon.Id);
		insert aar;
		/*
        afcCon.name										= 'test';
		afcCon.AFC_Branch_Number__c						= '123123';
		afcCon.Application__c 							= app.Id;
		afcCon.Account__c 								= acc.Id;
		afcCon.Contract_Received_At_Contracts_Date__c 	= datetime.now();
		afcCon.Master_Contract_ID__c 					= 546321;
		afcCon.Affiliation_Type__c 						= 'No Affiliation';
		afcCon.Contract_Type__c							= 'DEALER RETAIL MASTER CONTRACT';
		afcCon.License_Type__c							= 'Business/Dealer';
		afcCon.Product_Type__c							= 'WHOLESALE WITH SALVAGE';
    	afcCon.Credit_Limit__c 							= 100000;
    	afcCon.Received_from_Dealer__c					= date.today();
    	afcCon.AFC_Dealer_ID__c                         = '123456';
		update afcCon;
		*/
        //requery to include child records
        afcCon = getContract(afcCon.Id);

		return afcCon;
	}

	public static AFC_Contract_Shell__c insert_AFCContractShell()
	{
		Account acc = getTestAccount('TestAccount', true);

        Contact con = new Contact(AccountId = acc.Id,
        FirstName 					= 'FirstName',
        Middle_Name__c 				= 'MiddleName',
        LastName 					= 'LastName',
        Salutation					= 'King',
        Citizen__c					= true,
        BirthDate					= date.today().addYears(-30),
        Phone 						= '8889994444',
        HomePhone					= '8889994444',
        MobilePhone					= '8889994444',
        Email 						= 'test@test.com',
		AFC_Primary_Street__c		= '123 Anystreet',
		AFC_Primary_City__c			= 'MyCity',
		AFC_Primary_State__c		= 'MyState',
		AFC_Primary_PostalCode__c	= '65432',
		AFC_Primary_County__c		= 'USA',
		Type_of_Home_Ownership__c	= 'Own',
		SSN__c						= '789451234',
		Driver_s_License__c			= '1231232');
    	insert con;

        Opportunity opp = createTestOpportunity('Test Opp', 'Not Started', 'Indianapolis', true);
        User testUser = createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);

		Id recordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('New Application').getRecordTypeId();

		Application__c app = new Application__c(Applications_Accounts__c = acc.Id,
		Name                                = 'TestApplication',
		DBA_Name__c 			            = 'TestAccount Inc.',
		Dealer_Entity_Type__c 	            = 'CORPORATION',
		AFC_Branch_Number__c 	            = 123456,
		RecordTypeId			            = recordTypeId,
		Lot_Ownership__c 		            = 'Own',
		AFC_Credit_Status__c                = 'APPROVED',
		Credit_Decision__c                  = 'decision',
		Credit_Product_Type__c              = 'RENTAL',
		Credit_Amount__c                    = 50000,
		FP_Fee__c                           = 5000,
		Floorplan_Days__c                   = 5,
		Number_of_Curtailments__c           = 5,
		Interest_Rate_Base__c               = 'AFC PRIME FLOOR',
		Curtailment_Fee__c                  = 5000,
        KO_Book__c                          = 'In KO',
		Curtailment_Days__c                 = 5,
		Curtailment_Reduction_Percentage__c = 5,
		Interest_Charge__c                  = 5,
		Next_Renewal_Date__c                = '3 Months',
		Opportunity__c                      = opp.Id,
        AFC_Region__c                       = 'Shull');
		insert app;

		AFC_Contract_Shell__c afcConShell = new AFC_Contract_Shell__c(name='test',
		AFC_Branch_Number__c					= '123123',
		Application__c 							= app.Id,
		Account__c 								= acc.Id,
		Contract_Received_At_Contracts_Date__c 	= datetime.now(),
		Master_Contract_ID__c 					= 546321,
		Affiliation_Type__c 					= 'No Affiliation',
		Contract_Type__c						= 'DEALER RETAIL MASTER CONTRACT',
		License_Type__c							= 'Business/Dealer',
		Product_Type__c							= 'WHOLESALE WITH SALVAGE',
    	Credit_Limit__c 						= 100000,
		Received_from_Dealer__c					= date.today(),
		AFC_Dealer_ID__c						= '123456');
		insert afcConShell;

		//app.AFC_Contract_Number__c = afcConShell.Id;
		update app;

		Application_Contact_Role__c acr = new Application_Contact_Role__c(
      Account__c = acc.Id, 
      Contact__c = con.Id, 
      AFC_Contract_Shell__c = afcConShell.Id, 
      Application__c = app.Id, 
      End_Date__c = date.Today().addDays(30),
      Relationship__c = 'Owner' );
		insert acr;

		Application_Account_Role__c aar = new Application_Account_Role__c(
		    Account__c = acc.Id,
		    Application__c = app.Id,
		    Company_Name__c = 'Legal Name',
		    DBA_Name__c = 'DBA Name',
		    TIN__c = 'TIN',
		    Sales_Tax_Number__c = 'STN',
		    Dealer_License_Number__c = 'DLN',
		    Expiration_Date__c = Date.today(),
		    Entity_Type__c = 'ET',
		    Years_in_Business__c = 1,
		    Lot_Ownership__c = 'Own');
		insert aar;
		/*
        afcCon.name										= 'test';
		afcCon.AFC_Branch_Number__c						= '123123';
		afcCon.Application__c 							= app.Id;
		afcCon.Account__c 								= acc.Id;
		afcCon.Contract_Received_At_Contracts_Date__c 	= datetime.now();
		afcCon.Master_Contract_ID__c 					= 546321;
		afcCon.Affiliation_Type__c 						= 'No Affiliation';
		afcCon.Contract_Type__c							= 'DEALER RETAIL MASTER CONTRACT';
		afcCon.License_Type__c							= 'Business/Dealer';
		afcCon.Product_Type__c							= 'WHOLESALE WITH SALVAGE';
    	afcCon.Credit_Limit__c 							= 100000;
    	afcCon.Received_from_Dealer__c					= date.today();
    	afcCon.AFC_Dealer_ID__c                         = '123456';
		update afcCon;
		*/
        //requery to include child records
        afcConShell = getContractShell(afcConShell.Id);

		return afcConShell;
	}

    public static void insert_OrgConfig()
    {
        BW_Apps_Config__c config = new BW_Apps_Config__c();
        config.SetupOwnerId = UserInfo.getOrganizationId();
        config.IHUB_Endpoint_URL__c = 'www.org.com';
        config.IHUB_Timeout__c = 120000;
        config.Enable_Stack_Trace__c = false;
        config.Properties_Name__c = 'IHUB';
        insert config;
    }
    public static void insert_ApplicationCloneFields(String fieldName, String objApiName, String parentFieldApiName){
        ApplicationCloneFields__c acfCustomSettingFields = new ApplicationCloneFields__c(Name=fieldName);
    	acfCustomSettingFields.ObjectApiName__c = objApiName;
        acfCustomSettingFields.ParentFieldApiName__c = parentFieldApiName;
        insert acfCustomSettingFields;
    }

    public static void insert_ProfileConfig()
    {
        BW_Apps_Config__c config = new BW_Apps_Config__c();
        config.SetupOwnerId = UserInfo.getProfileId();
        config.IHUB_Endpoint_URL__c = 'www.profile.com';
        config.IHUB_Timeout__c = 60000;
        config.Enable_Stack_Trace__c = true;
        config.Properties_Name__c = 'IHUB';
        insert config;
    }
    public static Contact getTestContact(String firstName, String lastName, Id accountId)
    {
        Contact c = new Contact(FirstName = firstName, LastName = lastName, AccountId = accountId);
        return c;
    }
    public static Contact getTestContact(String firstName, String lastName, Id accountId, Boolean saveToDB)
    {
    	Contact c = getTestContact(firstName, lastName, accountId);
    	if(saveToDB != null && saveToDB)
    	{
    		insert c;
    	}
    	return c;
    }
    public static Case getTestCase(Id contactId)
    {
        Case c = new Case(ContactId = contactId);
        return c;
    }
    public static Case getTestCase(Id contactId, Boolean saveToDB)
    {
    	Case c = getTestCase(contactId);
        if(saveToDB != null && saveToDB)
        {
            insert c;
        }
        return c;
    }
    public static Account getTestAccount(String name)
    {
        Account a = new Account(Name                = name,
	        Legal_Name__c                           = 'TestAccount Inc.',
	        Website                                 = 'www.google.com',
	        Corrected_P_Street__c                   = '222 Any Street',
	        Corrected_P_City__c                     = 'Charlotte',
	        Corrected_P_State__c                    = 'NC',
	        Corrected_P_Postalcode__c               = '45678',
	        Corrected_Landline_Phone__c             = '2125551212',
	        Primary_Street1__c                      = '123 Any street',
	        Primary_Street2__c                      = 'Suite B',
	        Primary_City__c                         = 'Charlotte',
	        Primary_State__c                        = 'North Carolina',
	        Primary_PostalCode__c                   = '28273',
	        Primary_County__c                       = 'Mecklenburg',
	        Primary_Country__c                      = 'USA',
	        Phone                                   = '5556667894',
	        Dealer_License_Number__c                = '794613',
	        Tax_Identification_Number__c            = '56234512');
        return a;
    }
    public static Account getTestAccount(String name, Boolean saveToDB)
    {
    	Account a = getTestAccount(name);
        if(saveToDB != null && saveToDB)
        {
            insert a;
        }
        return a;
    }
    public static AFC_Contracts__c getContract(Id contractId)
    {
        return [select Id,
              Account__c,
              Account__r.Website,
              Account__r.Primary_Street1__c,
              Account__r.Primary_Street2__c,
              Account__r.Primary_City__c,
              Account__r.Primary_State__c,
              Account__r.Primary_Postalcode__c,
              Account__r.Primary_County__c,
              Account__r.Primary_Country__c,
              Account__r.Corrected_P_Street__c,
              Account__r.Corrected_P_City__c,
              Account__r.Corrected_P_State__c,
              Account__r.Corrected_P_Postalcode__c,
              Account__r.Corrected_Landline_Phone__c,
              Account__r.Phone,
              Account__r.Tax_Identification_Number__c,
              Account__r.Name,
              Account__r.Master_Index__c,
              Application__c,
              Application__r.AFC_Branch_Number__c,
              Application__r.RecordType.Name,
              AFC_Dealer_ID__c,
              Master_Contract_ID__c,
              Product_Type__c,
              Contract_Type__c,
              Affiliation_Type__c,
              Credit_Limit__c,
              Received_from_Dealer__c,
              Contract_Received_At_Contracts_Date__c,
              AFC_Branch_Number__c,
              Contract_Status__c,
              Last_Synced_Date__c,
              Salvage_Master_Contract_End_Date__c,
              License_Type__c,
              (select Id,
                  Contact__c,
                  Contact__r.FirstName,
                  Contact__r.Party_Id__c,
                  Contact__r.Middle_Name__c,
                  Contact__r.LastName,
                  Contact__r.Salutation,
                  Relationship__c,
                  Relationship_Subtype__c,
                  Contact__r.Birthdate,
                  Contact__r.Phone,
                  Contact__r.HomePhone,
                  Contact__r.MobilePhone,
                  Contact__r.Email,
                  Contact__r.SSN__c,
                  Contact__r.AFC_Primary_Street__c,
                  Contact__r.AFC_Primary_Street2__c,
                  Contact__r.AFC_Primary_City__c,
                  Contact__r.AFC_Primary_State__c,
                  Contact__r.AFC_Primary_Postalcode__c,
                  Contact__r.AFC_Primary_County__c,
                  Contact__r.AFC_Primary_Country__c,
                  Contact__r.End_Date__c,
                  Contact__r.Type_of_Home_Ownership__c,
                  Contact__r.Citizen__c,
                  Contact__r.Driver_s_License__c,
                  Contact__r.Suffix__c,
                  Contact__r.Driver_s_License_Expiration_Date__c,
                  Contact__r.Driver_s_Lic_State_Province__c
               from Application_Contacts__r)
              from AFC_Contracts__c
              where Id = :contractId];
    }

    public static AFC_Contract_Shell__c getContractShell(Id contractId)
    {
        return [select Id,
              Account__c,
              Account__r.Website,
              Account__r.Primary_Street1__c,
              Account__r.Primary_Street2__c,
              Account__r.Primary_City__c,
              Account__r.Primary_State__c,
              Account__r.Primary_Postalcode__c,
              Account__r.Primary_County__c,
              Account__r.Primary_Country__c,
              Account__r.Corrected_P_Street__c,
              Account__r.Corrected_P_City__c,
              Account__r.Corrected_P_State__c,
              Account__r.Corrected_P_Postalcode__c,
              Account__r.Corrected_Landline_Phone__c,
              Account__r.Phone,
              Account__r.Tax_Identification_Number__c,
              Account__r.Name,
              Account__r.Master_Index__c,
              Application__c,
              Application__r.AFC_Branch_Number__c,
              Application__r.RecordType.Name,
              Application__r.RecordType.DeveloperName,
              AFC_Dealer_ID__c,
              Master_Contract_ID__c,
              Product_Type__c,
              Contract_Type__c,
              Affiliation_Type__c,
              Credit_Limit__c,
              Received_from_Dealer__c,
              Contract_Received_At_Contracts_Date__c,
              AFC_Branch_Number__c,
              Contract_Status__c,
              Last_Synced_Date__c,
              Salvage_Master_Contract_End_Date__c,
              License_Type__c,
              (select Id,
                  Contact__c,
                  Contact__r.FirstName,
                  Contact__r.Party_Id__c,
                  Contact__r.Middle_Name__c,
                  Contact__r.LastName,
                  Contact__r.Salutation,
                  End_Date__c,
                  Relationship__c,
                  Relationship_Subtype__c,
                  Contact__r.Birthdate,
                  Contact__r.Phone,
                  Contact__r.HomePhone,
                  Contact__r.MobilePhone,
                  Contact__r.Email,
                  Contact__r.SSN__c,
                  Contact__r.AFC_Primary_Street__c,
                  Contact__r.AFC_Primary_Street2__c,
                  Contact__r.AFC_Primary_City__c,
                  Contact__r.AFC_Primary_State__c,
                  Contact__r.AFC_Primary_Postalcode__c,
                  Contact__r.AFC_Primary_County__c,
                  Contact__r.AFC_Primary_Country__c,
                  Contact__r.End_Date__c,
                  Contact__r.Type_of_Home_Ownership__c,
                  Contact__r.Citizen__c,
                  Contact__r.Driver_s_License__c,
                  Contact__r.Suffix__c,
                  Contact__r.Driver_s_License_Expiration_Date__c,
                  Contact__r.Driver_s_Lic_State_Province__c
               from Application_Contacts__r)
              from AFC_Contract_Shell__c
              where Id = :contractId];
    }

    public static CosmosWebServices.DealerAndContractReadResponseType getMockCosmosResponse(Application_Contact_Role__c[] acrs)
    {
    	CosmosWebServices.DealerAndContractReadResponseType response = new CosmosWebServices.DealerAndContractReadResponseType();
    	response.DealerID = '123456789';
    	response.MasterContractID = '987654321';
    	response.DealerRelatedPartiesID = new CosmosWebServices.DealerRelatedPartiesIDType();
    	response.DealerRelatedPartiesID.PartyID = new CosmosWebServices.PartyIDType[] {};
    	for(Integer i=0; i < acrs.size(); i++)
    	{
	        CosmosWebServices.PartyIDType partyID = new CosmosWebServices.PartyIDType();
	        partyID.CosmosPartyID = 'PARTYID'+i;
	        partyID.SalesforceContactID = acrs[i].Contact__c;
	        response.DealerRelatedPartiesID.PartyID.add(partyID);
    	}
    	return response;
    }
    public static Property__c[] getProperties()
    {
    	Property__c[] properties = new Property__c[]
    	{
    		new Property__c(Name = 'IHUB', Property_Id__c = 'Username', Property_Value_Encrypted__c = 'username'),
    		new Property__c(Name = 'IHUB', Property_Id__c = 'Password', Property_Value_Encrypted__c = 'password')
    	};
    	insert properties;
    	return properties;
    }
    public static Application__c getTestApplication(String name)
    {
        Application__c a = new Application__c(Name = name);
        return a;
    }
    public static Application__c getTestApplication(String name, Boolean saveToDB)
    {
        Application__c a = getTestApplication(name);
        if(saveToDB != null && saveToDB)
        {
            insert a;
        }
        return a;
    }
    public static User createTestUser(String username, String region, String branch, String creditOrContract, Boolean isInsert){
        User[] validUsers = [select Id, FirstName, LastName, Username, Email, Alias, CommunityNickname, AFC_Region_Responsible__c, AFC_Branch_Responsible__c,
                Credit_or_Contract__c, Credit_Type__c, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ProfileId
                from User
                where AFC_Region_Responsible__c includes (:region)
                and AFC_Branch_Responsible__c includes (:branch)
                and Credit_or_Contract__c = :creditOrContract];
        if(validUsers.isEmpty())
        {
          String profileName;
          if(creditOrContract.equalsIgnoreCase('credit')) profileName = 'AFC Credit Manager';
          else if (creditOrContract.equalsIgnoreCase('CT Processing')) profileName = 'AFC CT Processing Manager';
          else profileName = 'Standard User';

		 	Profile p = [SELECT Id FROM Profile WHERE UserType='Standard' AND Name=:profileName LIMIT 1];
		  	User testUser = new User();
		  	testUser.FirstName					= 'fName';
		  	testUser.LastName					= 'lName';
		  	testUser.Username					= username;
		  	testUser.Email						= username;
		  	testUser.Alias						= username.split('@')[0];
		  	testUser.CommunityNickname			= username.split('@')[0];
		  	testUser.AFC_Region_Responsible__c	= region;
		  	testUser.AFC_Branch_Responsible__c	= branch;
		  	testUser.Credit_or_Contract__c		= creditOrContract;
		  	testUser.Credit_Type__c             = 'Gold';
		  	testUser.TimeZoneSidKey 			= 'GMT';
		  	testUser.LocaleSidKey 				= 'en_US';
		  	testUser.EmailEncodingKey 			= 'ISO-8859-1';
		  	testUser.LanguageLocaleKey 			= 'en_US';
		  	testUser.ProfileId 					= p.id;
		  	if(isInsert){
	  			insert testUser;
		  	}
		  	return testUser;
        }
        else
        {
        	return validUsers[0];
        }
    }
    public static Opportunity createTestOpportunity(String name, String stageName, String afcBranch, Boolean isInsert){
	   	Opportunity testOpp = new Opportunity(Name=name, StageName=stageName, CloseDate=Date.Today(), AFC_Branch__c=afcBranch);
	  	if(isInsert){
  			insert testOpp;
	  	}
	  	return testOpp;
	}
	public static Application__c createTestApplication(Id oppId, String afcRegion, Boolean isInsert){
	   	Application__c testApp = new Application__c(Opportunity__c=oppId, AFC_Region__c=afcRegion);
  		if(isInsert){
			insert testApp;
	  	}
	  	return testApp;
    }
	public static Checklist__c createTestChecklist(Id appId, Boolean isInsert){
	    Checklist__c testCl = new Checklist__c(Application__c=appId);
		if(isInsert){
	  			insert testCl;
	  	}
	  	return testCl;
	}
	public static Checklist_Item__c createTestChecklistItem(Id checklistId, String forDepartment, String itemStatus, Boolean isInsert){
        Checklist_Item__c testCli = new Checklist_Item__c(Checklist__c=checklistId, For_Department__c=forDepartment, Item_Status__c=itemStatus);
		if(isInsert){
	  			insert testCli;
	  	}
	  	return testCli;
	}
  public static Marketing_Attribute__c createMarketingAttribute(Id appID, Boolean isInsert) {
    Marketing_Attribute__c testMA = new Marketing_Attribute__c(Application__c=appID, High__c='RETAIL', Medium__c='BHPH');
    if (isInsert) insert testMA;
    return testMA;
  }

    public static List<Monthly_Reporting__c> createMonthlyReportings( Integer numRecords, Id contractId, Boolean doInsert )
    {
        List<Monthly_Reporting__c> testReportings = new List<Monthly_Reporting__c>();
        for( Integer index = 0; index < numRecords; index++ )
        {
            Monthly_Reporting__c newReporting = new Monthly_Reporting__c();
            newReporting.Contract__c = contractId;
            testReportings.add( newReporting );
        }
        if( doInsert )
        {
            insert testReportings;
        }
        return testReportings;
    }

    public static List<Proof_of_Insurance__c> createPOIs( Integer numOfPOI, Id contractId, Boolean doInsert ){
      List<Proof_of_Insurance__c> testPOIs = new List<Proof_of_Insurance__c>();
        for( Integer i = 0; i < numOfPOI; i++){
          Proof_of_Insurance__c newPOI = new Proof_of_Insurance__c();
          newPOI.Contract__c = contractId;
          testPOIs.add(newPOI);
        }

        if( doInsert ){
          insert testPOIs;
        }
        return testPOIs;
    }

    public static List<Contact> createContacts(Integer numOfCont, Boolean doInsert){
      List<Contact> contacts = new List<Contact>();
      for(Integer i=0; i<numOfCont; i++){
        contacts.add(new Contact(
                        LastName='Test'+ i));
      }
      if(doInsert){
        insert contacts;
      }
      return contacts;
    }

   /**
   * @author Michael Hendy
   * @date 08/21/2013
   * @description Determines if the pagemessages contains a certain string
   * @param String messageNeedle : the string we will search for in the pagemessages
   * @return Boolean : true if found, false otherwise
   */

   public static Boolean pageMessageContains(String messageNeedle)
   {
           if( ApexPages.getMessages().size() > 0 )
           {
                   for (ApexPages.Message message : ApexPages.getMessages() ){

                       if(message.getSummary().contains(messageNeedle))
                               return true;
                   }
           }

           return false;
   }

   static Integer purchaseCounter=0;
   public static List<Purchase__c> createPurchases(Integer numToInsert,Boolean doInsert){
    List<Purchase__c> purchases = new List<Purchase__c>();
    for(Integer i=0; i<numToInsert; i++){
      purchases.add(new Purchase__c(Name = 'JNKCV54E33M212906', 
                                    Vehicle_ID__c = '1234567', 
                                    Source_ID__c=''+ (purchaseCounter++), 
                                    Handles_Payment__c = 'Y', 
                                    Actual_Pickup__c = Date.today(), 
                                    Transport_Type__c = 2, 
                                    Transport_Preference__c = 'OPENLANE Arranged', 
                                    sale_Class__c = 'Closed - Grounding Dealer', 
                                    Payment_Method__c='test'));
    }
    if(doInsert){
      insert purchases;
    }
    return purchases;
   }

   private static Integer offsetUser=0;

    public static List<User> createUsers(String userName, String profileName, Integer size, Boolean doInsert)
    {
        List<User>allUsers = new List<User>();

        String profileId;
        try
        {
            profileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id;
        }
        catch(Exception ex)
        {
            System.debug(ex);
            System.assert(false, 'No profile exists with name'+ profileName);
        }

        for( Integer i = 0; i < size; i++ )
        {
            User testUser = new User();

            testUser.LastName     = 'test' + UserName + offsetUser;
            testUser.Alias        = UserName+offsetUser;
            testUser.Country      = 'USA';
            testUser.Email        = UserName+offsetUser+'@kcura.com';
            testUser.Username     = UserName+offsetUser+'@test.com';
            testUser.CommunityNickname  = 'a'+UserName+offsetUser;
            testUser.TimeZoneSidKey   = 'America/New_York';
            testUser.LocaleSidKey   = 'en_US';
            testUser.EmailEncodingKey = 'ISO-8859-1';
            testUser.ProfileId      = profileId;
            testUser.LanguageLocaleKey  = 'en_US';
            testUser.IsActive     = true;

            allUsers.add(testUser);
            offsetUser++;
        }

        if( doInsert )
        {
          insert allUsers;
        }

        return allUsers;
    }

   private static Integer idOffset=0;
   public static Id getDummyId(SObjectType objType){
      String idPrefix = objType.getDescribe().getKeyPrefix();
      String idSuffix = String.valueOf( idOffset++ ).leftPad(12);
      idSuffix = idSuffix.replace( ' ', '0' );
      Id dummyId= (Id) (idPrefix + idSuffix);
      return dummyId;
   }
}