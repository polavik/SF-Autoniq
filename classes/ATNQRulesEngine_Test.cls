@isTest
private class ATNQRulesEngine_Test {
    @testSetup
    static void testSetup() {
               
        Account acct = new Account(Name = 'Test',BillingPostalCode = '12345');
        insert acct;

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Test', AccountId = acct.Id);
        insert contact;
    }

    @isTest
    static void test_parse_presplitfields() {
        Contact c = [SELECT Account.Name, Phone, FirstName FROM Contact];

        ATNQRulesEngine.Rule[] rules = ATNQRulesEngine.parse(
            c, 
            new String[] { 'Account.Name', 'Phone', 'FirstName' }, 
            new String[] { 'notnull', 'null', 'Test' }, 
            new String[] { '=', '=', '=' },
            new String[] { '', '', '' }
            );
        System.assertEquals(3, rules.size());
        System.assertEquals(true, ATNQRulesEngine.test(rules));
    }

    @isTest
    static void test_test_notalltrue() {
        ATNQRulesEngine.Rule[] rules = new ATNQRulesEngine.Rule[] {
                new ATNQRulesEngine.NullRule(null),
                new ATNQRulesEngine.NotNullRule(null)
        };

        System.assertEquals(false, ATNQRulesEngine.test(rules));
    }

    @isTest
    static void test_test_alltrue() {
        ATNQRulesEngine.Rule[] rules = new ATNQRulesEngine.Rule[] {
                new ATNQRulesEngine.NullRule(null),
                new ATNQRulesEngine.NotNullRule(1)
        };

        System.assertEquals(true, ATNQRulesEngine.test(rules));
    }

    @isTest
    static void test_nullrule_nullvalue() {
        ATNQRulesEngine.NullRule rule = new ATNQRulesEngine.NullRule(null);
        System.assertEquals(true, rule.test());
    }

    @isTest
    static void test_nullrule_0value() {
        ATNQRulesEngine.NullRule rule = new ATNQRulesEngine.NullRule(0);
        System.assertEquals(true, rule.test());
    }

    @isTest
    static void test_nullrule_nonnullvalue_number() {
        ATNQRulesEngine.NullRule rule = new ATNQRulesEngine.NullRule(1);
        System.assertEquals(false, rule.test());
    }

    @isTest
    static void test_nullrule_nonnullvalue_notnumber() {
        ATNQRulesEngine.NullRule rule = new ATNQRulesEngine.NullRule('Test');
        System.assertEquals(false, rule.test());
    }

    @isTest
    static void test_notnullrule_nullvalue() {
        ATNQRulesEngine.NotNullRule rule = new ATNQRulesEngine.NotNullRule(null);
        System.assertEquals(false, rule.test());
    }

    @isTest
    static void test_notnullrule_0value() {
        ATNQRulesEngine.NotNullRule rule = new ATNQRulesEngine.NotNullRule(0);
        System.assertEquals(false, rule.test());
    }

    @isTest
    static void test_notnullrule_nonnullvalue_number() {
        ATNQRulesEngine.NotNullRule rule = new ATNQRulesEngine.NotNullRule(1);
        System.assertEquals(true, rule.test());
    }

    @isTest
    static void test_notnullrule_nonnullvalue_notnumber() {
        ATNQRulesEngine.NotNullRule rule = new ATNQRulesEngine.NotNullRule('Test');
        System.assertEquals(true, rule.test());
    }

    @isTest
    static void test_isequalrule_equalvalues() {
        ATNQRulesEngine.IsEqualRule rule = new ATNQRulesEngine.IsEqualRule(1, 1);
        System.assertEquals(true, rule.test());
    }

    @isTest
    static void test_isequalrule_notequalvalues() {
        ATNQRulesEngine.IsEqualRule rule = new ATNQRulesEngine.IsEqualRule(1, 2);
        System.assertEquals(false, rule.test());
    }

    @isTest
    static void test_isGreaterThan() {
        ATNQRulesEngine.IsGreaterThan rule = new ATNQRulesEngine.IsGreaterThan(2, 1);
        System.assertEquals(true, rule.test());
    }

    @isTest
    static void test_isTodayWhithinDates () {
        Contact c = [SELECT Account.Name, Phone, FirstName FROM Contact];
        Account a = [SELECT Id FROM Account];
        Autoniq_Account__c atnqAct = new Autoniq_Account__c(
            No_Of_Subscriptions__c = 0, Account__c = a.Id, Name = 'test');
        insert atnqAct;

        Subscription__c subscription = new Subscription__c(
            Autoniq_Account__c = atnqAct.Id,            
            Contact__c = c.Id,
            Status__c = 'Active',
            Cancel_Date__c = system.today().addDays(30),
            Next_Bill_Date__c = system.today(),
            
            Term__c = 'Monthly' 
        );
        
        insert subscription;

        ATNQRulesEngine.Rule[] rules = ATNQRulesEngine.parse(
            subscription, 
            new String[] { 'Next_Bill_Date__c' }, 
            new String[] { 'Cancel_Date__c' }, 
            null,
            new String[] { 'Date_Range'}
            );
        System.assertEquals(1, rules.size());
        System.assertEquals(true, ATNQRulesEngine.test(rules));

    }

    @isTest
    static void test_multiValues () {
        Contact c = [SELECT Account.Name, Phone, FirstName FROM Contact];
        Account a = [SELECT Id FROM Account];
        Autoniq_Account__c atnqAct = new Autoniq_Account__c(
            No_Of_Subscriptions__c = 0, Account__c = a.Id, Name = 'test');
        insert atnqAct;

        Subscription__c subscription = new Subscription__c(
            Autoniq_Account__c = atnqAct.Id,            
            Contact__c = c.Id,
            Status__c = 'Active',
            Cancel_Date__c = system.today().addDays(30),
            Next_Bill_Date__c = system.today(),
            
            Term__c = 'Monthly' 
        );
        
        insert subscription;

        ATNQRulesEngine.Rule[] rules = ATNQRulesEngine.parse(
            subscription, 
            new String[] { 'Term__c' }, 
            new String[] { 'Monthly,Annual' }, 
            new String[] {'='},
            new String[] { ''}
            );
        System.assertEquals(1, rules.size());
        System.assertEquals(true, ATNQRulesEngine.test(rules));

    }

    @isTest
    static void test_multiValues_negative () {
        Contact c = [SELECT Account.Name, Phone, FirstName FROM Contact];
        Account a = [SELECT Id FROM Account];
        Autoniq_Account__c atnqAct = new Autoniq_Account__c(
            No_Of_Subscriptions__c = 0, Account__c = a.Id, Name = 'test');
        insert atnqAct;

        Subscription__c subscription = new Subscription__c(
            Autoniq_Account__c = atnqAct.Id,            
            Contact__c = c.Id,
            Status__c = 'Active',
            Cancel_Date__c = system.today().addDays(30),
            Next_Bill_Date__c = system.today(),
            
            Term__c = 'Monthly' 
        );
        
        insert subscription;

        ATNQRulesEngine.Rule[] rules = ATNQRulesEngine.parse(
            subscription, 
            new String[] { 'Term__c' }, 
            new String[] { 'NotMonthly,Annual' }, 
            new String[] {'='},
            new String[] { ''}
            );
        System.assertEquals(1, rules.size());
        System.assertEquals(false, ATNQRulesEngine.test(rules));

    }
}