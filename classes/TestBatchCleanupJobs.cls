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
@isTest
private class TestBatchCleanupJobs {

    static testMethod void testBatchCleanupTask() {
        // The query used by the batch job.
        String query = 'SELECT Id,CreatedDate FROM Task ';

       // Create some task items to be deleted
       //   by the batch job.
       Cleanup_Properties__c d1 = new Cleanup_Properties__c(name = 'TaskDate1', date__c='0');
       Cleanup_Properties__c d2 = new Cleanup_Properties__c(name = 'TaskDate2', date__c='0');
       insert d1;
       insert d2;
       Cleanup_Properties__c email = new Cleanup_Properties__c(name = 'Email', date__c='rli@openlane.com');
       insert email ;
       Account a = new Account(name='testAcct');       
       insert a;
       Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
       User u = new User(Alias = 'bcu', Email='standarduser@testbatchcleanup.com', 
            EmailEncodingKey='UTF-8', LastName='TestBatchCleanup', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testbatchcleanup.com');
       insert u;
       Contact con = new Contact(firstname='TestBatchCleanup', lastname='Task');
       insert con;
       Task[] tl = new List<Task>();
       for (Integer i=0;i<10;i++) {            
           Task t = new Task(
               WhatId = a.id,
        WhoId = con.id,
        Subject = 'Other',
        //task.priority= ,
        status = 'Not Started',
        description = 'New Work'
        );
           tl.add(t);
       }
       insert tl;

       Test.startTest();
       BatchCleanUpTask c = new BatchCleanUpTask();
       Database.executeBatch(c);
       Test.stopTest();

    }
    
    static testMethod void testBatchCleanupWatchlist() {        

       Cleanup_Properties__c d1 = new Cleanup_Properties__c(name = 'Watchlist', date__c='0');
       insert d1;
       Cleanup_Properties__c email = new Cleanup_Properties__c(name = 'Email', date__c='rli@openlane.com');
       insert email ;
       Vehicle_Interest__c m = new Vehicle_Interest__c();     
       insert m;       

       Test.startTest();
       BatchCleanupWatchlist c = new BatchCleanupWatchlist();
       Database.executeBatch(c);
       Test.stopTest();

    }
    
    static testMethod void testBatchCleanupVIR() {        

       Cleanup_Properties__c d1 = new Cleanup_Properties__c(name = 'VIR', date__c='0');
       insert d1;
       Cleanup_Properties__c email  = new Cleanup_Properties__c(name = 'Email', date__c='rli@openlane.com');
       insert email ;
       VIR__c v = new VIR__c(name='testVIR', Dealer_Org_Id__c = '12345', Vehicle_Id__c = '12345');     
       insert v;       

       Test.startTest();
       BatchCleanupVIR c = new BatchCleanupVIR();
       Database.executeBatch(c);
       Test.stopTest();

    }
    
       
    static testMethod void testBatchCleanupVehicle() {        

       Cleanup_Properties__c d1 = new Cleanup_Properties__c(name = 'Vehicles_NotSold_Purge_BeforeDays', date__c='0');
       insert d1;
       Cleanup_Properties__c d2 = new Cleanup_Properties__c(name = 'Vehicles_Sold_Purge_BeforeDays', date__c='0');
       insert d2;
       Cleanup_Properties__c email  = new Cleanup_Properties__c(name = 'Email', date__c='rli@openlane.com');
       insert email ;
       Asset__c v = new Asset__c(Source_Id__c='123456');     
       insert v;       

       Test.startTest();
       BatchCleanupVehicle c = new BatchCleanupVehicle();
       Database.executeBatch(c);
       Test.stopTest();

    }
    
    static testMethod void testBatchCleanupPurchase() {        

       Cleanup_Properties__c d1 = new Cleanup_Properties__c(name = 'PurchaseDate', date__c='0');
       insert d1;
       Cleanup_Properties__c email = new Cleanup_Properties__c(name = 'Email', date__c='rli@openlane.com');
       insert email ;
       Purchase__c p = new Purchase__c(Source_Id__c='123456');     
       insert p;       

       Test.startTest();
       BatchCleanupPurchase c = new BatchCleanupPurchase();
       Database.executeBatch(c);
       Test.stopTest();

    }
    
    static testMethod void testBatchCleanupAuction() {        

       Cleanup_Properties__c d1 = new Cleanup_Properties__c(name = 'Auctions_Purge_BeforeDays', date__c='0');
       insert d1;
       
       Cleanup_Properties__c email = new Cleanup_Properties__c(name = 'Email', date__c='rli@openlane.com');
       insert email ;
       
       Asset__c v = new Asset__c(Source_Id__c='123456');
       insert v;
       Auction__c a = new Auction__c(Asset__c=v.id);
       insert a;       

       Test.startTest();
       BatchCleanupAuction c = new BatchCleanupAuction();
       Database.executeBatch(c);
       Test.stopTest();

    }
    
    
    static testMethod void BatchCleanupLiveChat() {          

       Property__c p1 = new Property__c(name = 'Sandbox Suffix', property_id__c = 'sandbox.suffix');
       insert p1;
       
       Cleanup_Properties__c d1 = new Cleanup_Properties__c(name = 'Live_Chat_Expiration', date__c='90');
       insert d1;
       
       Cleanup_Properties__c email = new Cleanup_Properties__c(name = 'Live_Chat_Email', date__c='eric.hulen@adesa.com');
       insert email ;
       
       LiveChatVisitor lcv = new LiveChatVisitor(); 
       insert lcv;
       Id visitorId = lcv.Id;
       LiveChatTranscript lctUS = new LiveChatTranscript(location = 'TestBatch1', LiveChatVisitorId = visitorId, ReferrerUri='https://app.fcaccelerate.ca/jsp/login/selectSite.jsf');
       insert lctUS;
       LiveChatTranscript lctCA = new LiveChatTranscript(location = 'TestBatch2', LiveChatVisitorId = visitorId, ReferrerUri='https://fordca-app.stg.autc.com/jsp/login/selectSite.jsf');
       insert lctCA;   

       Test.startTest();
       BatchCleanupLiveChat c = new BatchCleanupLiveChat();
       Database.executeBatch(c);
       Test.stopTest();

    }
    

}