public with sharing class QuickAppController {
    static final Integer PAGE_SIZE = 10;
    @TestVisible private Id selectedAccountId, selectedContactId;

    public String stage { get; set; }
    public String selectedAccountIdStr { get; set; }
    public Account selectedAccount { get; set; }
    public String selectedContactIdStr { get; set; }
    public Contact selectedContact { get; set; }

    public String accountName { get; set; }
    public String dealerID { get; set; }
    public String dealerLN { get; set; }
    public String contactSIN { get; set; }

    @testvisible ApexPages.StandardSetController accountSetController, contactSetController;

    public QuickAppController() {
        stage = 'search';
        filterAccounts(null, null, null);
    }

    public List<Account> accounts {
        get {
            accounts = accountSetController.getRecords();
            return accounts;
        }
        private set;
    }

    public List<Contact> contacts {
        get {
            contacts = contactSetController.getRecords();
            return contacts;
        }
        private set;
    }

    public List<FieldSetMember> accountFields {
        get {
            if (accountFields == null) {
                accountFields = SOBjectType.Account.FieldSets.QuickAppFields.getFields();
            }

            return accountFields;
        }
        private set;
    }

    public List<FieldSetMember> contactFields {
        get {
            if (contactFields == null) {
                contactFields = SOBjectType.Contact.FieldSets.QuickAppFields.getFields();
            }

            return contactFields;
        }
        private set;
    }

    public List<String> accountFieldNames {
        get {
            if (accountFieldNames == null) {
                accountFieldNames = new List<String>();

                for (FieldSetMember field : accountFields) {
                    accountFieldNames.add(field.getFieldPath());
                }
            }

            return accountFieldNames;
        }
        private set;
    }

    public List<String> contactFieldNames {
        get {
            if (contactFieldNames == null) {
                contactFieldNames = new List<String>();

                for (FieldSetMember field : contactFields) {
                    contactFieldNames.add(field.getFieldPath());
                }
            }

            return contactFieldNames;
        }
        private set;
    }

    public void filterAccounts() {
        filterAccounts(accountName, dealerID, dealerLN);
    }

    public void filterAccounts(String name, String dealerId, String licenseNumber) {
        if ((dealerId == null || String.isEmpty(dealerId)) && (licenseNumber == null || String.isEmpty(licenseNumber)) && (name == null || String.isEmpty(name)))
            accountSetController = new ApexPages.StandardSetController(new List<Account>());
        else
        {
            String query = '';

            query += 'SELECT ';
            query += String.join(accountFieldNames, ', ');
            query += ' FROM Account ';

            List<String> conditions = new List<String>();
            if (name != null && name.length() > 0) {
                conditions.add('Name LIKE \'%' + String.escapeSingleQuotes(name) + '%\'');
            }
            if (dealerId != null && dealerId.length() > 0) {
                conditions.add('AFC_Dealer_ID__c LIKE \'%' + String.escapeSingleQuotes(dealerId) + '%\'');
            }
            if (licenseNumber != null && licenseNumber.length() > 0) {
                conditions.add('Dealer_License_Number__c LIKE \'%' + String.escapeSingleQuotes(licenseNumber) + '%\'');
            }

            if (conditions.size() > 0) {
                query += 'WHERE (';
                query += String.join(conditions, ') OR (');
                query += ') ';
            }

            query += 'ORDER BY Name LIMIT 5000';

            accountSetController = new ApexPages.StandardSetController(Database.getQueryLocator(query));
            accountSetController.setPageSize(PAGE_SIZE);
        }
    }

    public void filterContacts() {
        filterContacts(contactSIN);
    }

    public void filterContacts(String sin) {
        if (sin == null || String.isEmpty(sin))
            contactSetController = new ApexPages.StandardSetController(new List<Contact>());
        else
        {
            String query = '';

            query += 'SELECT ';
            query += String.join(contactFieldNames, ', ');
            query += ' FROM Contact';
            query += ' WHERE AccountId = \'' + String.escapeSingleQuotes(selectedAccountId) + '\'';

            List<String> conditions = new List<String>();
            if (sin != null && sin.length() > 0) {
                conditions.add('SSN__c LIKE \'%' + String.escapeSingleQuotes(sin) + '%\'');
            }

            if (conditions.size() > 0) {
                query += 'AND (';
                query += String.join(conditions, ') AND (');
                query += ') ';
            }

            query += ' ORDER BY Name LIMIT 5000';

            contactSetController = new ApexPages.StandardSetController(Database.getQueryLocator(query));
            contactSetController.setPageSize(PAGE_SIZE);
        }
    }

    public void selectSearch() {
        stage = 'account';
    }

    public void selectSearchContact() {
        stage = 'contact';
    }

    public void selectAccount() {
        stage = 'contactprompt';
        try {
            selectedAccountId = selectedAccountIdStr;
            filterContacts();
            selectedAccount = [SELECT Id, Name FROM Account WHERE Id = :selectedAccountId LIMIT 1];
        } 
        catch (StringException ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }

    public void selectContact() {
        stage = 'final';
        try {
            selectedContactId = selectedContactIdStr;
            selectedContact = [SELECT Id, Name FROM Contact WHERE Id = :selectedContactId LIMIT 1];
        } 
        catch (StringException ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }

    public PageReference sendToFlow() {
        PageReference flowPage = new PageReference('/flow/Quick_Application');
        flowPage.getParameters().put('varAccountId', selectedAccountId);
        flowPage.getParameters().put('varContactId', selectedContactId);
        //flowPage.getParameters().put('varDLN', dealerLN);
        return flowPage;
    }
}