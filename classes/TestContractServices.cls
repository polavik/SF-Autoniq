@isTest
private class TestContractServices {
    
    static testmethod void testGetContractShell(){
        Account account = new Account(Name = 'Test');
        insert account;
        AFC_Contract_Shell__c contractShell = new AFC_Contract_Shell__c(Master_Contract_ID__c = 12345, Account__c = account.Id);
        insert contractShell;

        Test.startTest();
        AFC_Contract_Shell__c testShell = ContractServices.getContractShell(12345);
        Test.stopTest();

        System.assertEquals(contractShell.Id, testShell.Id);
    }

    static testmethod void testGetContractShellWithInvalidMasterContractId(){
        Account account = new Account(Name = 'Test');
        insert account;
        AFC_Contract_Shell__c contractShell = new AFC_Contract_Shell__c(Master_Contract_ID__c = 12345, Account__c = account.Id);
        insert contractShell;

        Test.startTest();
        try{
            AFC_Contract_Shell__c testShell = ContractServices.getContractShell(123456);
        }catch(Exception e){
            System.assertEquals(System.Label.No_Contract_Shells_For_Master_Contract_Id, e.getMessage());
        }
        Test.stopTest();
    }

    static testmethod void testUpdateContractShellFields(){
        Account account = new Account(Name = 'Test');
        insert account;
        User testUser = TestServices.createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = TestServices.createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);
        Opportunity opp = TestServices.createTestOpportunity('Test Opp', 'Closed Won', 'Indianapolis', true);
        Application__c app = TestServices.createTestApplication(opp.Id, 'Shull', true);
        AFC_Contract_Shell__c contractShell = new AFC_Contract_Shell__c(Master_Contract_ID__c = 12345, Account__c = account.Id, Application__c = app.Id);
        insert contractShell;

        Test.startTest();
        AFC_Contract_Shell__c testShell = ContractServices.updateContractShellFields(contractShell, System.today(), 'Active');
        Test.stopTest();

        contractShell = [SELECT Received_from_Dealer__c, Contract_Status__c FROM AFC_Contract_Shell__c WHERE Id = :contractShell.Id];
        System.assertEquals(System.today(), contractShell.Received_from_Dealer__c);
        System.assertEquals('Active', contractShell.Contract_Status__c);
    }

    static testmethod void testUpdateContractShellFieldsWithBadInput(){
        Account account = new Account(Name = 'Test');
        insert account;
        AFC_Contract_Shell__c contractShell = new AFC_Contract_Shell__c(Master_Contract_ID__c = 12345, Account__c = account.Id);
        insert contractShell;

        Test.startTest();
        AFC_Contract_Shell__c testShell = ContractServices.updateContractShellFields(contractShell, null, null);
        Test.stopTest();

        contractShell = [SELECT Received_from_Dealer__c, Contract_Status__c FROM AFC_Contract_Shell__c WHERE Id = :contractShell.Id];
        System.assertEquals(null, contractShell.Received_from_Dealer__c);
        System.assertEquals(null, contractShell.Contract_Status__c);
    }

    static testmethod void testMatchActiveContracts(){
        Account account = new Account(Name = 'Test');
        insert account;
        AFC_Contract_Shell__c contractShell = new AFC_Contract_Shell__c(Master_Contract_ID__c = 12345, Account__c = account.Id, Contract_ID__c = '98765');
        insert contractShell;

        AFC_Contracts__c contract = new AFC_Contracts__c(Account__c = account.Id, Contract_ID__c = '98765', Contract_Status__c = 'Active');
        insert contract;

        Test.startTest();
        AFC_Contracts__c testContract = ContractServices.matchingActiveContracts(contractShell);
        Test.stopTest();

        System.assertNotEquals(null, testContract);
        System.assertEquals(testContract.Id, contract.Id);
    }

    static testmethod void testMatchActiveContractsWithNoMatch(){
        Account account = new Account(Name = 'Test');
        insert account;
        AFC_Contract_Shell__c contractShell = new AFC_Contract_Shell__c(Master_Contract_ID__c = 12345, Account__c = account.Id, Contract_ID__c = '98765');
        insert contractShell;

        Test.startTest();
        AFC_Contracts__c testContract = ContractServices.matchingActiveContracts(contractShell);
        Test.stopTest();

        System.assertEquals(null, testContract);
    }

    static testmethod void testMatchActiveContractsWithMultipleMatches(){
        Account account = new Account(Name = 'Test');
        insert account;
        AFC_Contract_Shell__c contractShell = new AFC_Contract_Shell__c(Master_Contract_ID__c = 12345, Account__c = account.Id, Contract_ID__c = '98765', Contract_Status__c = 'Active');
        insert contractShell;
        
        AFC_Contracts__c contract = new AFC_Contracts__c(Account__c = account.Id, Contract_ID__c = '98765', Contract_Status__c = 'Active');
        insert contract;
        AFC_Contracts__c contract2 = new AFC_Contracts__c(Account__c = account.Id, Contract_ID__c = '98766', Contract_Status__c = 'Active');
        insert contract2;

        Test.startTest();
        try{
            AFC_Contracts__c testContract = ContractServices.matchingActiveContracts(contractShell);
        }catch(Exception e){
            System.assertEquals(System.Label.multiple_active_contracts_exception, e.getMessage());
        }
        Test.stopTest();
    }

    static testmethod void testCloneContractToContractVersion(){
        Account account = new Account(Name = 'Test');
        insert account;
        AFC_Contract_Shell__c contractShell = new AFC_Contract_Shell__c(Master_Contract_ID__c = 12345, Account__c = account.Id, Contract_ID__c = '98765');
        insert contractShell;
        User testUser = TestServices.createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = TestServices.createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);
        Opportunity opp = TestServices.createTestOpportunity('Test Opp', 'Closed Won', 'Indianapolis', true);
        Application__c app = TestServices.createTestApplication(opp.Id, 'Shull', true);
        Contact aContact = new Contact(LastName = 'Test');
        insert aContact;
        AFC_Contracts__c contract = new AFC_Contracts__c(Account__c = account.Id, Contract_ID__c = '98765', Contract_Status__c = 'Active');
        insert contract;
        List<Application_Contact_Role__c> acrList = new List<Application_Contact_Role__c>();
        List<Application_Account_Role__c> aarList= new List<Application_Account_Role__c>();
        List<AFC_Contract_Terms__c> actList= new List<AFC_Contract_Terms__c>();
        Application_Contact_Role__c acr = new Application_Contact_Role__c(AFC_Contracts__c = contract.Id, Relationship__c = 'Guarantor', Application__c = app.Id, Contact__c = aContact.Id);
        acrList.add(acr);
        Application_Account_Role__c aar = new Application_Account_Role__c(AFC_Contracts__c = contract.Id, Relationship__c = 'Guarantor', Application__c = app.Id, Account__c = account.Id);
        aarList.add(aar);
        AFC_Contract_Terms__c act = new AFC_Contract_Terms__c(AFC_Contracts__c = contract.Id, Term_ID__c = 'garbage123', Term_Type__c = 'Test', Term_Name__c = 'Test', Print_On_Contract__c = '0');
        actList.add(act);
        Application_Contact_Role__c acr2 = new Application_Contact_Role__c(AFC_Contract_Shell__c = contractShell.Id, Relationship__c = 'Guarantor', Application__c = app.Id, Contact__c = aContact.Id);
        acrList.add(acr2);
        Application_Account_Role__c aar2 = new Application_Account_Role__c(AFC_Contract_Shell__c = contractShell.Id, Relationship__c = 'Guarantor', Application__c = app.Id, Account__c = account.Id);
        aarList.add(aar2);
        AFC_Contract_Terms__c act2 = new AFC_Contract_Terms__c(AFC_Contract_Shell__c = contractShell.Id, Term_ID__c = 'garbage123', Term_Type__c = 'Test', Term_Name__c = 'Test', Print_On_Contract__c = '0');
        actList.add(act2);
        insert acrList;
        insert aarList;
        insert actList;

        ContractServices.cloneContractToContractVersionAndUpdateContract(contract, contractShell);

        Test.startTest();
        //there should only be 1 contract version, the one just cloned from the contract
        Contract_Versions__c contractVersion= [SELECT Id, Contract_Status__c, AFC_Contracts__c, Account__c, Contract_ID__c FROM Contract_Versions__c LIMIT 1];
        //get all pf the junction objects to make sure that the relationships were updated correctly 
        acr = [SELECT Id, AFC_Contracts__c, Contract_Version__c FROM Application_Contact_Role__c WHERE Id = :acr.Id];
        aar = [SELECT Id, AFC_Contracts__c, Contract_Version__c FROM Application_Account_Role__c WHERE Id = :aar.Id];
        act = [SELECT Id, AFC_Contracts__c, Contract_Version__c FROM AFC_Contract_Terms__c WHERE Id = :act.Id];
        acr2 = [SELECT Id, AFC_Contracts__c, AFC_Contract_Shell__c FROM Application_Contact_Role__c WHERE Id = :acr2.Id];
        aar2 = [SELECT Id, AFC_Contracts__c, AFC_Contract_Shell__c FROM Application_Account_Role__c WHERE Id = :aar2.Id];
        act2 = [SELECT Id, AFC_Contracts__c, AFC_Contract_Shell__c FROM AFC_Contract_Terms__c WHERE Id = :act2.Id];
        Test.stopTest();

        System.assertEquals(contract.Account__c, contractVersion.Account__c);
        System.assertEquals('Amended', contractVersion.Contract_Status__c);
        System.assertEquals(contract.Id, contractVersion.AFC_Contracts__c);
        System.assertEquals(contract.Contract_ID__c, contractVersion.Contract_ID__c);

        //requery the contract object
        contract = [SELECT Id, Master_Contract_ID__c, Account__c, Contract_ID__c FROM AFC_Contracts__c WHERE Id = :contract.Id];
        //assert that the contract copied over fields from the shell
        System.assertEquals(contractShell.Master_Contract_ID__c, contract.Master_Contract_ID__c);
        //assert that only the fields that should have been copied from the shell were copied

        //make sure the junction objects from the contrwct are now related only to the versions object
        System.assertEquals(contractVersion.Id, acr.Contract_Version__c);
        System.assertEquals(contractVersion.Id, aar.Contract_Version__c);
        System.assertEquals(contractVersion.Id, act.Contract_Version__c);

        System.assertEquals(null, acr.AFC_Contracts__c);
        System.assertEquals(null, aar.AFC_Contracts__c);
        System.assertEquals(null, act.AFC_Contracts__c);

        //make sure that the junction objects from the shell are properly related to both the shell and the contract
        System.assertEquals(contractShell.Id, acr2.AFC_Contract_Shell__c);
        System.assertEquals(contractShell.Id, aar2.AFC_Contract_Shell__c);
        System.assertEquals(contractShell.Id, act2.AFC_Contract_Shell__c);

        System.assertEquals(contract.Id, acr2.AFC_Contracts__c);
        System.assertEquals(contract.Id, aar2.AFC_Contracts__c);
        System.assertEquals(contract.Id, act2.AFC_Contracts__c);

    }

    static testmethod void testCreateContractFromContractShell(){
        Account account = new Account(Name = 'Test');
        insert account;
        User testUser = TestServices.createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = TestServices.createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);
        Opportunity opp = TestServices.createTestOpportunity('Test Opp', 'Closed Won', 'Indianapolis', true);
        Application__c app = TestServices.createTestApplication(opp.Id, 'Shull', true);
        Contact aContact = new Contact(LastName = 'Test');
        insert aContact;
        AFC_Contract_Shell__c contractShell = new AFC_Contract_Shell__c(Master_Contract_ID__c = 12345, Account__c = account.Id, X14_Day_Notification__c = true, Audit_AFC_Units__c = 123);
        insert contractShell;
        Application_Contact_Role__c acr = new Application_Contact_Role__c(AFC_Contract_Shell__c = contractShell.Id, Relationship__c = 'Guarantor', Application__c = app.Id, Contact__c = aContact.Id);
        Application_Account_Role__c aar = new Application_Account_Role__c(AFC_Contract_Shell__c = contractShell.Id, Relationship__c = 'Guarantor', Application__c = app.Id, Account__c = account.Id);
        AFC_Contract_Terms__c act = new AFC_Contract_Terms__c(AFC_Contract_Shell__c = contractShell.Id, Term_ID__c = 'garbage123', Term_Type__c = 'Test', Term_Name__c = 'Test', Print_On_Contract__c = '0');
        insert acr;
        insert aar;
        insert act;

        Test.startTest();
        ContractServices.createContractFromContractShell(contractShell);
        Test.stopTest();

        AFC_Contracts__c contract = [SELECT Id, Contract_Status__c, Account__c, Contract_ID__c FROM AFC_Contracts__c LIMIT 1];


        acr = [SELECT Id, AFC_Contracts__c, AFC_Contract_Shell__c FROM Application_Contact_Role__c WHERE Id = :acr.Id];
        aar = [SELECT Id, AFC_Contracts__c, AFC_Contract_Shell__c FROM Application_Account_Role__c WHERE Id = :aar.Id];
        act = [SELECT Id, AFC_Contracts__c, AFC_Contract_Shell__c FROM AFC_Contract_Terms__c WHERE Id = :act.Id];

        System.assertEquals(contract.Account__c, contractShell.Account__c);
        System.assertEquals(contract.Contract_ID__c, contractShell.Contract_ID__c);

        System.assertEquals(contract.Id, acr.AFC_Contracts__c);
        System.assertEquals(contract.Id, aar.AFC_Contracts__c);
        System.assertEquals(contract.Id, act.AFC_Contracts__c);

        System.assertEquals(contractShell.Id, acr.AFC_Contract_Shell__c);
        System.assertEquals(contractShell.Id, aar.AFC_Contract_Shell__c);
        System.assertEquals(contractShell.Id, act.AFC_Contract_Shell__c);
    }

    static testmethod void coverageForMethodInIhubWebServices(){
        Account account = new Account(Name = 'Test');
        insert account;
        User testUser = TestServices.createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = TestServices.createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);
        Opportunity opp = TestServices.createTestOpportunity('Test Opp', 'Closed Won', 'Indianapolis', true);
        Application__c app = TestServices.createTestApplication(opp.Id, 'Shull', true);
        AFC_Contract_Shell__c contractShell = new AFC_Contract_Shell__c(Master_Contract_ID__c = 12345, Account__c = account.Id, Application__c = app.Id);
        insert contractShell;
        IHubWebServices.updateMasterContract(12345, 1, null, 1, System.today(), 'Active');
    }

    static testmethod void coverageForMethodInIhubWebServicesWithMissingContractStatus(){
        Account account = new Account(Name = 'Test');
        insert account;
        User testUser = TestServices.createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = TestServices.createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);
        Opportunity opp = TestServices.createTestOpportunity('Test Opp', 'Closed Won', 'Indianapolis', true);
        Application__c app = TestServices.createTestApplication(opp.Id, 'Shull', true);
        AFC_Contract_Shell__c contractShell = new AFC_Contract_Shell__c(Master_Contract_ID__c = 12345, Account__c = account.Id, Application__c = app.Id);
        insert contractShell;
        try{
            IHubWebServices.updateMasterContract(12345, 1, null, 1, System.today(), '');
        }catch(Exception e){
            System.assertEquals(System.Label.required_web_service_field_is_null, e.getMessage());
        }
    }

    static testmethod void coverageForMethodInIhubWebServicesWithMatchingContract(){
        Account account = new Account(Name = 'Test');
        insert account;
        User testUser = TestServices.createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = TestServices.createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);
        Opportunity opp = TestServices.createTestOpportunity('Test Opp', 'Closed Won', 'Indianapolis', true);
        Application__c app = TestServices.createTestApplication(opp.Id, 'Shull', true);
        AFC_Contracts__c contract = new AFC_Contracts__c(Account__c = account.Id, Contract_ID__c = '98765', Contract_Status__c = 'Active');
        insert contract;
        AFC_Contract_Shell__c contractShell = new AFC_Contract_Shell__c(Master_Contract_ID__c = 12345, Account__c = account.Id, Application__c = app.Id, Contract_ID__c = '98765');
        insert contractShell;
        IHubWebServices.updateMasterContract(12345, 1, null, 1, System.today(), 'Active');
    }

    static testmethod void coverageForMethodInIhubWebServicesWithContractStatusNotActive(){
        Account account = new Account(Name = 'Test');
        insert account;
        User testUser = TestServices.createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = TestServices.createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);
        Opportunity opp = TestServices.createTestOpportunity('Test Opp', 'Closed Won', 'Indianapolis', true);
        Application__c app = TestServices.createTestApplication(opp.Id, 'Shull', true);
        AFC_Contract_Shell__c contractShell = new AFC_Contract_Shell__c(Master_Contract_ID__c = 12345, Account__c = account.Id, Application__c = app.Id);
        insert contractShell;
        try{
            IHubWebServices.updateMasterContract(12345, 1, null, 1, System.today(), 'Something Else');
        }catch(Exception e){
            System.assertEquals(System.Label.contractStatus_not_Valid, e.getMessage());
        }
    }

}