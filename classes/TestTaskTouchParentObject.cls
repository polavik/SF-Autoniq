/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=false)
private class TestTaskTouchParentObject {

    static Id makeAccount() {
        Account a = new Account(Name='TestAccount');
        insert a;
        System.debug('----- TestTaskTouchParentObject_makeAccount().id=(' + a.Id + ') ');
        
        return a.Id;
    }

    static testMethod void testTaskOnAccount() {
        Id account = makeAccount();
        Task t = new Task(WhatId = account,Subject='Test',CallType='Inbound');
        insert t;

        Account l = [select Last_Activity_Datetime__c from Account where Id=:account];
        //FIXME: System.assert(l.Last_Activity_Datetime__c!=null,'Last_Activity_Datetime__c on Account should be filled');
        System.debug('----- testTaskOnAccount.task.id=(' + t.Id + ') task.Subject=' +t.Subject);
    }

    static Id makeLead() {
        Lead l = new Lead(FirstName='Test',LastName='Lead',Company='Test');
        insert l;
        System.debug('----- makeLead().id=(' + l.Id + ') ');
        return l.Id;
    }

    static testMethod void testTaskOnLead() {
        Id lead = makeLead();
        Task t = new Task(WhoId = lead,Subject='Test',CallType='Inbound');
        insert t;

        Lead l = [select Last_Activity_Datetime__c from Lead where Id=:lead];
        //FIXME: System.assert(l.Last_Activity_Datetime__c!=null,'Last_Activity_Datetime__c on Lead should be filled');
    }
    
    static Id makeContact() {
        Id account = makeAccount();
        Contact l = new Contact(FirstName='Test',LastName='Lead',AccountId=account);
        insert l;
        System.debug('----- makeContact().id=(' + l.Id + ') ');
        
        return l.Id;
    }

    static testMethod void testTaskOnContact() {
        Id newObj = makeContact();
        Task t = new Task(WhoId = newObj,Subject='Test',CallType='Inbound');
        insert t;

        Contact l = [select Last_Activity_Datetime__c from Contact where Id=:newObj];
       //FIXME: System.assert(l.Last_Activity_Datetime__c!=null,'Last_Activity_Datetime__c on Contact should be filled');
    }
    
    static Id makeOpportunity() {
        Id account = makeAccount();
        Schema.DescribeFieldResult stageDesc = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> stages = stageDesc.getPicklistValues();
        Schema.PicklistEntry firstStage = stages.get(0);
        Opportunity l = new Opportunity(Name='Test',AccountId=account,CloseDate=System.Today(),StageName=firstStage.getValue(),NextStep='w00t!');
        insert l;
        System.debug('----- makeOpportunity().id=(' + l.Id + ') ');
        return l.Id;
    }

    static testMethod void testTaskOnOpportunity() {
        Id newObj = makeOpportunity();
        Task t = new Task(WhatId = newObj,Subject='Test',CallType='Inbound');
        insert t;

        Opportunity l = [select Last_Activity_Datetime__c from Opportunity where Id=:newObj];
        // FIXME: System.assert(l.Last_Activity_Datetime__c!=null,'Last_Activity_Datetime__c on Opportunity should be filled');
    }
    
    static Id makeCampaign() {
        Campaign l = new Campaign(Name='Test');
        insert l;
        return l.Id;
    }

    static testMethod void testTaskOnCampaign() {
        Id newObj = makeCampaign();
        Task t = new Task(WhatId = newObj,Subject='Test',CallType='Inbound');
        insert t;

        Campaign l = [select Last_Activity_Datetime__c from Campaign where Id=:newObj];
        //FIXME: System.assert(l.Last_Activity_Datetime__c!=null,'Last_Activity_Datetime__c on Campaign should be filled');
    }
    
    static Id makeContract() {
        Id account = makeAccount();
        Contract l = new Contract(AccountId=account,StartDate=System.Today(),ContractTerm=12,Source_Id__c ='12345');
        //FIXME: insert l;
        insert l;
        System.debug('----- makeContract().id=(' + l.Id + ') ');
        return l.Id;
    }

    static testMethod void testTaskOnContract() {
        Id newObj = makeContract();
        Task t = new Task(WhatId = newObj,Subject='Test',CallType='Inbound');
        insert t;

       /* FIXME: Contract l = [select Last_Activity_Datetime__c from Contract where Id=:newObj];
        System.assert(l.Last_Activity_Datetime__c!=null,'Last_Activity_Datetime__c on Contract should be filled');
        */
    }
/*    
    static testMethod void testTaskOnContract2() {
        Id newObj = makeContract();
        Task t = new Task(WhatId = newObj,Subject='testTaskOnContract2',CallType='Inbound');
        insert t;
        System.debug('----- testTaskOnContract2().task-id=(' + t.Id + ') ');
        System.debug('----- testTaskOnContract2().task.WhatId=(' + t.WhatId + ') ');

    }
*/
    static testMethod void testTaskOnBscListing() {
        Asset__c a = new Asset__c(Name='VIN1234567980Test2', Source_Id__c='OL-222233331', Vehicle_Id__c ='222233331');      
        insert a;       

        Basic_Listing_Interest__c bli = new Basic_Listing_Interest__c(name='test2', Vehicle__c =a.id, Last_Activity_Datetime__c=System.now());
        insert bli;
        System.debug('----- Basic_Listing_Interest__c().bli-id=(' + bli.Id + ') ');

        Task t = new Task(WhatId = bli.id,Subject='testTaskOnBscListing',CallType='Inbound');
        insert t;
        System.debug('----- testTaskOnBscListing().task-id=(' + t.Id + ') ');
        System.debug('----- testTaskOnBscListing().task.WhatId=(' + t.WhatId + ') ');

    }

    static testMethod void testTaskOnBestOffer() {

        Account acct = new Account();
        //acct.ATC_Organization_ID__c = '123456';
        acct.Name = 'Mr Stevebobs Volvo';
        insert acct;
        
        Asset__c v = new Asset__c(vehicle_id__c='v12345', source_id__c='v12345');
        insert v;
        
        Best_Offers__c bo = new Best_Offers__c(best_offer_id__c='159022', 
                                               Buyer_organization__c=acct.id, 
                                               Seller_Organization__c=acct.id, 
                                               Vehicle__c=v.id, 
                                               offer_Status__c='Open');
        insert bo;

        Task t = new Task(WhatId = bo.id,Subject='testTaskOnBestOffer',CallType='Inbound');
        insert t;
        System.debug('----- testTaskOnBestOffer().task-id=(' + t.Id + ') ');
        System.debug('----- testTaskOnBestOffer().task.WhatId=(' + t.WhatId + ') ');

    }
    
    static testMethod void testTaskOnAuction() {

        Account acct = new Account();
        //acct.ATC_Organization_ID__c = '123456';
        acct.Name = 'Mr Stevebobs Volvo';
        insert acct;
        
        
        Asset__c v = new Asset__c(vehicle_id__c='v12345', Source_ID__c='v12345');
        insert v;
        
        Auction__c a = new Auction__c(auction_id__c='a12345', Highest_Bidder_Account__c=acct.id, Seller_Account__c=acct.id, Asset__c=v.id, if_bid_Status__c='Open');
        insert a;

        Task t = new Task(WhatId = a.id,Subject='testTaskOnAuction',CallType='Inbound');
        insert t;
        System.debug('----- testTaskOnAuction().task-id=(' + t.Id + ') ');
        System.debug('----- testTaskOnAuction().task.WhatId=(' + t.WhatId + ') ');

    }

    static testMethod void testTaskNotByCTI() {
        Id lead = makeLead();
        //No calltype
        Task t = new Task(WhoId = lead,Subject='Test');
        insert t;

        Lead l = [select Last_Activity_Datetime__c from Lead where Id=:lead];
        System.assert(l.Last_Activity_Datetime__c==null,'Last_Activity_Datetime__c on Lead should be null');
    }

    static testMethod void testMultipleTasksOnOneObject() {
        Id lead = makeLead();
        List<Task> tasks = new List<Task>();

        tasks.add(new Task(WhoId = lead,Subject='Test'));
        tasks.add(new Task(WhoId = lead,Subject='Test2'));
        insert tasks;
    }
}