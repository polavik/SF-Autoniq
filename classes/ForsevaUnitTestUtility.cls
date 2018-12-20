/**
* Copyright 2013-2014 Forseva, LLC. All rights reserved.
*/
public with sharing class ForsevaUnitTestUtility {

    // returns accounts, opportunities, applications, contacts
    public static Map<Schema.SObjectType,List<SObject>> initializeTestData() {

        ScoringManager.resetScoringFactors();           
        Map<Schema.SObjectType,List<SObject>> oMap = new Map<Schema.SObjectType,List<SObject>>();

        Account a1 = createAccount('Test Account 1', false);
        Account a2 = createAccount('Test Account 2', false);
        List<Account> aList = new List<Account>{a1,a2};
        insert aList;
        oMap.put(Account.SObjectType, aList);        

        Opportunity o1 = createOpportunity(a1.Id, 'Oppo1', false);
        Opportunity o2 = createOpportunity(a1.Id, 'Oppo2', false);
        List<Opportunity> oList = new List<Opportunity>{o1,o2};
        insert oList;
        oMap.put(Opportunity.SObjectType, oList);        

        Application__c app1 = createApplication(o1.Id, 'Test Application 1', false);
        Application__c app2 = createApplication(o2.Id, 'Test Application 2', false);
        List<Application__c> appList = new List<Application__c>{app1,app2};
        insert appList;
        oMap.put(Application__c.SObjectType, appList);

        Contact c1 = createContact('George', 'Smiley', a1.Id, false);
        Contact c2 = createContact('Percy', 'Alleline', a1.Id, false);
        Contact c3 = createContact('Roy', 'Bland', a1.Id, false);
        List<Contact> cList = new List<Contact>{c1,c2,c3};
        insert cList;
        oMap.put(Contact.SObjectType, cList);

        insert new List<Application_Account_Role__c> {
            new Application_Account_Role__c(Business_Name__c = 'xxxxx', Application__c = app1.Id, Account__c = a1.Id, Primary__c = true, Entity_Type__c = 'LLP'),
            new Application_Account_Role__c(Business_Name__c = 'yyyyy', Application__c = app1.Id, Account__c = a2.Id)
        };
        insert new List<Application_Contact_Role__c> {
            new Application_Contact_Role__c(Application__c = app1.Id, Contact__c = c1.Id, Relationship__c = 'Guarantor'),
            new Application_Contact_Role__c(Application__c = app1.Id, Contact__c = c2.Id, Relationship__c = 'Guarantor')
        };
        
        return oMap;
    }

    public static Account createAccount(String name, Boolean insertRecord) {
    
        Account a = new Account(Name = name);
        a.Dealer_Type_Dealer_License_Type__c = 'LLC';
        if(insertRecord) {
            insert a;
        }
        return a;
    }

    public static Opportunity createOpportunity(Id accountId, String name, Boolean insertRecord) {

        Opportunity o = new Opportunity();
        o.AccountId = accountId;
        o.Name = name;
        o.AFC_Branch__c = 'Atlanta South';
        o.Type = 'New Application Gold';
        o.Credit_Limit_Requested__c = 10000;
        o.Opportunity_Product_Type__c = 'RV';
        o.StageName = 'L-Confirm Customers Need';
        o.CloseDate = Date.today().addDays(30);
        if(insertRecord) {
            insert o;
        }
        return o;
    }

    public static Application__c createApplication(Id opportunityId, String name, Boolean insertRecord) {
        User testUser = TestServices.createTestUser('user1@afc.com','Shull','Atlanta South','Credit',true);
        User testCTUser = TestServices.createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);
        User testUser1 = TestServices.createTestUser('user3@afc.com','Shull','Atlanta South','CT Processing',true);
        User testCTUser1 = TestServices.createTestUser('user4@afc.com','Shull','Indianapolis','Credit',true);
        Application__c a = new Application__c(Name = name);
        a.Opportunity__c = opportunityId;
        a.AFC_Region__c = 'Shull';
        if(insertRecord) {
            insert a;
        }
        return a;    
    }

    public static Dealer_Questionnaire__c createDealerQuestionnaire(Id applicationId, Boolean insertRecord) {

        Dealer_Questionnaire__c d = new Dealer_Questionnaire__c();
        d.Application__c = applicationId;
        d.Auction_1__c = 'ADESA';
        d.Experience_in_Automotive_Industry__c = 1;
        if(insertRecord) {
            insert d;
        }
        return d;        
    }

    public static ApplicationScoring__c createApplicationScoring(Id applicationId, Boolean insertRecord) {
        
        ApplicationScoring__c a = new ApplicationScoring__c();
        a.Application__c = applicationId;
        if(insertRecord) {
            insert a;
        }
        return a;        
    }

    public static Contact createContact(String firstName, String lastName, Id accountId, Boolean insertRecord) {
    
        Contact c = new Contact(FirstName = firstName, LastName = lastName, AccountId = accountId);
        c.Previous_Account_Guarantor_Search__c = ScoringManager.NEGATIVE;
        if(insertRecord) {
            insert c;
        }
        return c;            
    }
    
}

// EOF