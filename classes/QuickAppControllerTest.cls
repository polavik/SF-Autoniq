@isTest
public class QuickAppControllerTest {
    static final Integer ACCOUNT_COUNT = 26;
    static final Integer CONTACT_COUNT = 51;

    static QuickAppController controller;
    static List<Account> accounts;
    static List<Account> a_accounts;
    static List<Contact> contacts;

    static void setup() {
        controller = new QuickAppController();
        accounts = new List<Account>();
        a_accounts = new List<Account>();

        List<Account> builtAccounts = new List<Account>();

        builtAccounts = new SObjectBuilder(Account.sObjectType)
            .field(Account.Name, 'A')
            .field(Account.AFC_Dealer_ID__c, 'A')
            .field(Account.Dealer_License_Number__c, 'A')
            .count(ACCOUNT_COUNT).build();
        accounts.addAll(builtAccounts);
        a_accounts.addAll(builtAccounts);

        builtAccounts = new SObjectBuilder(Account.sObjectType)
            .field(Account.Name, 'B')
            .field(Account.AFC_Dealer_ID__c, 'B')
            .field(Account.Dealer_License_Number__c, 'B')
            .count(ACCOUNT_COUNT).build();
        accounts.addAll(builtAccounts);

        builtAccounts = new SObjectBuilder(Account.sObjectType)
            .field(Account.Name, 'C')
            .field(Account.AFC_Dealer_ID__c, 'C')
            .field(Account.Dealer_License_Number__c, 'C')
            .count(ACCOUNT_COUNT).build();
        accounts.addAll(builtAccounts);

        builtAccounts = new SObjectBuilder(Account.sObjectType)
            .field(Account.Name, 'ABC')
            .field(Account.AFC_Dealer_ID__c, 'ABC')
            .field(Account.Dealer_License_Number__c, 'ABC')
            .count(ACCOUNT_COUNT).build();
        accounts.addAll(builtAccounts);
        a_accounts.addAll(builtAccounts);

        insert accounts;

        controller.selectedAccountId = accounts[0].Id;
        contacts = new SObjectBuilder(Contact.sObjectType)
            .field(contact.SSN__c, 'A')
            .field(Contact.AccountId, accounts[0].Id)
            .count(CONTACT_COUNT).build();


        insert contacts;
    }

    static testmethod void testFilterAccounts() {
        setup();

        Test.startTest();
            controller.filterAccounts(null, null, null);
        Test.stopTest();

        controller.accountSetController.setPageSize(ACCOUNT_COUNT * 4);
        system.assertEquals(new Set<Id>(), Pluck.Ids(controller.accountSetController.getRecords()), 'each account should be returned');
    }

    static testmethod void testFilterAccounts_name() {
        setup();

        Test.startTest();
            controller.filterAccounts('A', null, null);
        Test.stopTest();

        controller.accountSetController.setPageSize(ACCOUNT_COUNT * 4);
        system.assertEquals(Pluck.Ids(a_accounts), Pluck.Ids(controller.accountSetController.getRecords()), 'each A account should be returned');
    }

    static testmethod void testFilterAccounts_dealerId() {
        setup();

        Test.startTest();
            controller.filterAccounts(null, 'A', null);
        Test.stopTest();

        controller.accountSetController.setPageSize(ACCOUNT_COUNT * 4);
        system.assertEquals(Pluck.Ids(a_accounts), Pluck.Ids(controller.accountSetController.getRecords()), 'each A account should be returned');
    }

    static testmethod void testFilterAccounts_LicenseNumber() {
        setup();

        Test.startTest();
            controller.filterAccounts(null, null, 'A');
        Test.stopTest();

        controller.accountSetController.setPageSize(ACCOUNT_COUNT * 4);
        system.assertEquals(Pluck.Ids(a_accounts), Pluck.Ids(controller.accountSetController.getRecords()), 'each A account should be returned');
    }

    static testmethod void testFilterAccounts_AllFilters() {
        setup();

        Test.startTest();
            controller.filterAccounts('A', 'B', 'C');
        Test.stopTest();

        controller.accountSetController.setPageSize(ACCOUNT_COUNT * 4);
        system.assertEquals(Pluck.Ids(accounts), Pluck.Ids(controller.accountSetController.getRecords()), 'each account should be returned');
    }

    static testmethod void testFilterContacts() {
        setup();

        test.startTest();
            controller.filterContacts('A');
        Test.stopTest();

        controller.contactSetController.setPageSize(CONTACT_COUNT * 2);
        system.assertEquals(Pluck.Ids(contacts), Pluck.Ids(controller.contactSetController.getRecords()), 'each contact should be returned');
    }

    static testmethod void testSelectAccount_noContacts() {
        setup();

        test.startTest();
        	controller.selectedAccountIdStr = accounts[1].Id;
            controller.selectAccount();
        Test.stopTest();

        system.assertEquals(0, controller.contactSetController.getRecords().size(), 'there should be no contacts returned');
    }

    static testmethod void testSelectAccount() {
        setup();
        controller.selectedAccountIdStr = accounts[1].Id;

        test.startTest();
	        controller.selectedAccountIdStr = accounts[0].Id;
            controller.selectAccount();
        Test.stopTest();

        controller.contactSetController.setPageSize(CONTACT_COUNT * 2);
        system.assertEquals(new Set<Id>(), Pluck.Ids(controller.contactSetController.getRecords()), 'there should be no contacts returned');
    }

    static testmethod void testSendToFlow() {
        setup();

        Test.startTest();
        	controller.selectedContactId = contacts[0].Id;
            PageReference nextPage = controller.sendToFlow();
        Test.stopTest();

        system.assertEquals(new Set<String> { 'varAccountId', 'varContactId' }, nextPage.getParameters().keySet(), 'both parameters should be set');
        system.assertEquals(accounts[0].Id, nextPage.getParameters().get('varAccountId'), 'the account Id should be set');
        system.assertEquals(contacts[0].Id, nextPage.getParameters().get('varContactId'), 'the contact id should be set');
    }
}