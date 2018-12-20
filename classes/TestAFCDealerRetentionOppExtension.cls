@isTest
private with sharing class TestAFCDealerRetentionOppExtension {
    public TestAFCDealerRetentionOppExtension() {
    }

    public static testMethod void testDealerRetentionConstructor(){
        RecordType accountRt = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName = 'Dealership_Account_US' limit 1];
        RecordType opportunityRt = [Select Id From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'AFC_Dealer_Retention' limit 1];

        Profile p = [select id from profile where name='Standard User'];
        User u = new User(alias = 'u1', email='ewhipple@afc.com',emailencodingkey='UTF-8', lastname='UserLastName', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,  country='United States', CommunityNickname = 'u1',timezonesidkey='America/Los_Angeles', username='regionalmanager@autofinance.com');
        insert u;       
        AFC_Branch__c b = new AFC_Branch__c(Name='Detroit North',Branch_Manager_1__c = UserInfo.getUserId());
        insert b;
        Account a = new Account(name='Modern Apple',AFC_Dealer_ID__c='12345',AFCBranchSalesArea__c = b.Id,RecordTypeId=accountRt.id);
        insert a;
        Contact c = new Contact(firstName='Eric',lastName='Whipple',accountid=a.id);
        insert c;
        Opportunity opp = new Opportunity(name='Test Retention Opp',StageName='New',AccountId = a.id, CloseDate=System.today().addDays(30),KDSS_Data__c='1234567890');
        insert opp;

        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            AFCDealerRetentionOppExtension con = new AFCDealerRetentionOppExtension(sc);
            System.assertEquals(opp.Id,con.opp.Id);
            System.assertEquals(1,con.accountContactList.size());
            System.assertEquals('Whipple',con.accountContactList.get(0).lastName);
            System.assertEquals(null,con.rtLogACall);
        Test.stopTest();
    }

    public static testMethod void testBeginOpportunity(){
        RecordType accountRt = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName = 'Dealership_Account_US' limit 1];
        RecordType opportunityRt = [Select Id From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'AFC_Dealer_Retention' limit 1];

        Profile p = [select id from profile where name='Standard User'];
        User u = new User(alias = 'u1', email='ewhipple@afc.com',emailencodingkey='UTF-8', lastname='UserLastName', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,  country='United States', CommunityNickname = 'u1',timezonesidkey='America/Los_Angeles', username='regionalmanager@autofinance.com');
        insert u;       
        AFC_Branch__c b = new AFC_Branch__c(Name='Detroit North',Branch_Manager_1__c = UserInfo.getUserId());
        insert b;
        Account a = new Account(name='Modern Apple',AFC_Dealer_ID__c='12345',AFCBranchSalesArea__c = b.Id,RecordTypeId=accountRt.id);
        insert a;
        Contact c = new Contact(firstName='Eric',lastName='Whipple',accountid=a.id);
        insert c;
        Opportunity opp = new Opportunity(name='Test Retention Opp',StageName='New',AccountId = a.id, CloseDate=System.today().addDays(30),KDSS_Data__c='1234567890');
        insert opp;

        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            AFCDealerRetentionOppExtension con = new AFCDealerRetentionOppExtension(sc);
            con.beginOpportunity();
            Opportunity opp2 = [select id, stagename from opportunity where id = :opp.id limit 1];
            System.assertEquals('Working',opp2.stageName);
        Test.stopTest();
    }

    public static testMethod void testUpdateOpportunity(){
        RecordType accountRt = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName = 'Dealership_Account_US' limit 1];
        RecordType opportunityRt = [Select Id From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'AFC_Dealer_Retention' limit 1];
        RecordType taskRt = [Select Id From RecordType  Where SobjectType = 'Task' and DeveloperName = 'X4n1_Log_a_Call'];

        Profile p = [select id from profile where name='Standard User'];
        User u = new User(alias = 'u1', email='ewhipple@afc.com',emailencodingkey='UTF-8', lastname='UserLastName', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,  country='United States', CommunityNickname = 'u1',timezonesidkey='America/Los_Angeles', username='regionalmanager@autofinance.com');
        insert u;       
        AFC_Branch__c b = new AFC_Branch__c(Name='Detroit North',Branch_Manager_1__c = UserInfo.getUserId());
        insert b;
        Account a = new Account(name='Modern Apple',AFC_Dealer_ID__c='12345',AFCBranchSalesArea__c = b.Id,RecordTypeId=accountRt.id);
        insert a;
        Contact c = new Contact(firstName='Eric',lastName='Whipple',accountid=a.id);
        insert c;
        Opportunity opp = new Opportunity(name='Test Retention Opp',StageName='New',AccountId = a.id, CloseDate=System.today().addDays(30),KDSS_Data__c='1234567890');
        insert opp;

        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            AFCDealerRetentionOppExtension con = new AFCDealerRetentionOppExtension(sc);
            Test.setCurrentPageReference(new PageReference('Page.AFCDealerRetentionOpp'));
            ApexPages.currentPage().getParameters().put('updateData', '{"method":"Phone Call","results":"Pricing","details":"Term","nextsteps":"Line Modification","who":"'+c.id+'","notes":"This is a note."}');

            con.updateOpportunity();
            Set<String> subjectOptions = new Set<String>{'Phone Call','Email','Dealership Visit','Branch Visit','Auction Visit','No Action-PLN','No Action-Performance History'};
            for(Task t : [select id, OwnerId, subject, Who_I_spoke_with__c, Next_Step__c, Results_of_Call__c, Details_of_Call__c, whoid from Task where whatid = :opp.id and subject in :subjectOptions and RecordTypeId = :taskRt.Id limit 1]){
                //System.assertEquals(UserInfo.getUserId(),t.ownerId);
                System.assertEquals('Phone Call',t.Subject);
                System.assertEquals('Eric Whipple',t.Who_I_Spoke_With__c);
                System.assertEquals('Line Modification',t.Next_Step__c);
                System.assertEquals('Pricing - Term',t.Details_of_Call__c);
                System.assertEquals('This is a note.',t.Results_of_Call__c);
                System.assertEquals(c.Id,t.whoId);
            }
        Test.stopTest();
    }

    public static testMethod void testCloseOpportunity(){
        RecordType accountRt = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName = 'Dealership_Account_US' limit 1];
        RecordType opportunityRt = [Select Id From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'AFC_Dealer_Retention' limit 1];
        RecordType taskRt = [Select Id From RecordType  Where SobjectType = 'Task' and DeveloperName = 'X4n1_Log_a_Call'];

        Profile p = [select id from profile where name='Standard User'];
        User u = new User(alias = 'u1', email='ewhipple@afc.com',emailencodingkey='UTF-8', lastname='UserLastName', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,  country='United States', CommunityNickname = 'u1',timezonesidkey='America/Los_Angeles', username='regionalmanager@autofinance.com');
        insert u;
        AFC_Branch__c b = new AFC_Branch__c(Name='Detroit North',Branch_Manager_1__c = u.Id);
        insert b;
        Account a = new Account(name='Modern Apple',AFC_Dealer_ID__c='12345',AFCBranchSalesArea__c = b.Id,RecordTypeId=accountRt.id);
        insert a;
        Contact c = new Contact(firstName='Eric',lastName='Whipple',accountid=a.id);
        insert c;
        Opportunity opp = new Opportunity(name='Test Retention Opp',StageName='Working',AccountId = a.id, CloseDate=System.today().addDays(30),KDSS_Data__c='1234567890');
        insert opp;

        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            AFCDealerRetentionOppExtension con = new AFCDealerRetentionOppExtension(sc);
            Test.setCurrentPageReference(new PageReference('Page.AFCDealerRetentionOpp'));
            ApexPages.currentPage().getParameters().put('updateData', '{"method":"Phone Call","results":"Pricing","details":"Term","nextsteps":"Line Modification","who":"'+c.id+'","notes":"This is a note."}');

            con.closeOpportunity();
            Opportunity opp2 = [select id, stagename from opportunity where id = :opp.id limit 1];
            System.assertEquals('Completed',opp2.stageName);            
            Set<String> subjectOptions = new Set<String>{'Phone Call','Email','Dealership Visit','Branch Visit','Auction Visit','No Action-PLN','No Action-Performance History'};
            for(Task t : [select id, OwnerId, subject, Who_I_spoke_with__c, Next_Step__c, Results_of_Call__c, Details_of_Call__c, whoid from Task where whatid = :opp.id and subject in :subjectOptions and RecordTypeId = :taskRt.Id limit 1]){
            //  System.assertEquals(u.Id,t.ownerId);
                System.assertEquals('Phone Call',t.Subject);
                System.assertEquals('Eric Whipple',t.Who_I_Spoke_With__c);
                System.assertEquals('Line Modification',t.Next_Step__c);
                System.assertEquals('Pricing - Term',t.Details_of_Call__c);
                System.assertEquals('This is a note.',t.Results_of_Call__c);
                System.assertEquals(c.Id,t.whoId);
            }
        Test.stopTest();
    }
}