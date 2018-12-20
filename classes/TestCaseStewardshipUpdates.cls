@isTest
public with sharing class TestCaseStewardshipUpdates {
    public TestCaseStewardshipUpdates() {    
    }

    static testMethod void testInsertFirstStewardshipCase(){
        Account a = new Account(Name='Test Account', MDM_Refresh_Date__c=System.now());
        insert a;

        Test.startTest();
            StewardshipHelper.createLocalAccountIntegrationCases(new List<Id>{a.id});
        Test.stopTest();
        Account a2 = [select id, In_Stewardship__c from Account where id = :a.id limit 1];
        System.assert(a2.In_Stewardship__c);
    }

    static testMethod void testOneCaseTypePerRecord(){
        Account a = new Account(Name='Test Account', MDM_Refresh_Date__c=System.now());
        insert a;

        Test.startTest();
            StewardshipHelper.createLocalAccountIntegrationCases(new List<Id>{a.id});
            StewardshipHelper.createLocalAccountIntegrationCases(new List<Id>{a.id});
        Test.stopTest();
        Account a2 = [select id, In_Stewardship__c from Account where id = :a.id limit 1];
        // The Account is In Stewardship
        System.assert(a2.In_Stewardship__c);
        // Only one Open LocalAccountIntegration Case will be created
        List<Case> caseList = [select id from Case where AccountId = :a.id];
        System.assertEquals(1,caseList.size());
    }

    static testMethod void testMultipleCasesPerRecord(){
        Account a = new Account(Name='Test Account', MDM_Refresh_Date__c=System.now());
        insert a;

        Test.startTest();
            StewardshipHelper.createLocalAccountIntegrationCases(new List<Id>{a.id});
            StewardshipHelper.createLocalAccountIntegrationCases(new List<Id>{a.id});
            StewardshipHelper.createKeyFieldDeletionCase(a.Id, new Set<String>{'Integration_Id__c'});
        Test.stopTest();
        Account a2 = [select id, In_Stewardship__c from Account where id = :a.id limit 1];
        // The Account is In Stewardship
        System.assert(a2.In_Stewardship__c);
        // Two Stewardship Cases are created because they are of different types
        List<Case> caseList = [select id from Case where AccountId = :a.id];
        System.assertEquals(2,caseList.size());
    }

    static testMethod void testDeleteStewardshipCase(){
        Account a = new Account(Name='Test Account', MDM_Refresh_Date__c=System.now());
        insert a;

        Test.startTest();
            StewardshipHelper.createLocalAccountIntegrationCases(new List<Id>{a.id});
            delete [select id from Case limit 1];
        Test.stopTest();
        Account a4 = [select id, In_Stewardship__c from Account where id = :a.id limit 1];
        System.assert(!a4.In_Stewardship__c);
    } 

    static testMethod void testDeleteOneStewardshipCase(){
        Account a = new Account(Name='Test Account', MDM_Refresh_Date__c=System.now());
        insert a;

        Test.startTest();
            StewardshipHelper.createLocalAccountIntegrationCases(new List<Id>{a.id});
            StewardshipHelper.createKeyFieldDeletionCase(a.id,new Set<String>{'Integration_Id__c'});
            delete [select id from Case limit 1];
        Test.stopTest();
        Account a4 = [select id, In_Stewardship__c from Account where id = :a.id limit 1];
        System.assert(a4.In_Stewardship__c);
    } 

    static testMethod void testCloseStewardshipCase(){
        Account a = new Account(Name='Test Account', MDM_Refresh_Date__c=System.now());
        insert a;

        Test.startTest();
            StewardshipHelper.createLocalAccountIntegrationCases(new List<Id>{a.id});
            Case c = [select id, status from Case limit 1];
            c.status = 'Closed';
            update c;
        Test.stopTest();
        Account a2 = [select id, In_Stewardship__c from Account where id = :a.id limit 1];
        System.assert(!a2.In_Stewardship__c);
    }
}