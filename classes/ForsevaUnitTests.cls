/**
* Copyright 2013-2014 Forseva, LLC. All rights reserved.
*/
@isTest
private class ForsevaUnitTests {

@testSetup 
static void setTestData() {
    
    //List<forseva1__CreditPolicy__c> ListfspolCheck =[ select Id from forseva1__CreditPolicy__c];
    //if(ListfspolCheck.size() == 0)
    //{
    
    List<forseva1__CreditPolicy__c> Listfspol = new List<forseva1__CreditPolicy__c>();
    forseva1__CreditPolicy__c fs1 = new forseva1__CreditPolicy__c();
    fs1.Name ='Equifax';
    fs1.forseva1__First_Credit_Review_Product__c ='Equifax Commercial Credit';
    fs1.forseva1__First_Prequalification_Product__c ='Equifax Commercial Credit';
    fs1.forseva1__First_Verification_Product__c ='Equifax Commercial Credit';
    fs1.forseva1__Default_Policy__c = true;
    Listfspol.Add(fs1);
    
    forseva1__CreditPolicy__c fs2 = new forseva1__CreditPolicy__c();
    fs2.Name ='Experian';
    fs2.forseva1__First_Credit_Review_Product__c ='Experian Business Profile';
    fs2.forseva1__First_Prequalification_Product__c ='Experian Business Profile';
    fs2.forseva1__First_Verification_Product__c ='Experian Business Summary';
    fs2.forseva1__Default_Policy__c = false;
    Listfspol.Add(fs2);
    
    forseva1__CreditPolicy__c fs3 = new forseva1__CreditPolicy__c();
    fs3.Name ='TransUnion';
    fs3.forseva1__First_Credit_Review_Product__c ='Experian Commercial Credit';
    fs3.forseva1__First_Prequalification_Product__c ='Experian Commercial Credit';
    fs3.forseva1__First_Verification_Product__c ='Equifax Commercial Credit';
    fs3.forseva1__Default_Policy__c = false;
    Listfspol.Add(fs3);
    
    insert Listfspol;
    
    //List<forseva1__DataProvider__c> ListfsDPCheck = [SELECT Id FROM forseva1__DataProvider__c];

        //if(ListfsDPCheck.Size() == 0)
        //{
            List<forseva1__DataProvider__c> ListfsDP = new List<forseva1__DataProvider__c>();
            
            forseva1__DataProvider__c fsDP1 = new forseva1__DataProvider__c();
            fsDP1.Name = 'LexisNexis';
            fsDP1.forseva1__Password__c='Test1' ;
            fsDP1.forseva1__Service_Timeout__c= 60;
            fsDP1.forseva1__Service_URL__c = 'https://test.test.com';
            fsDP1.forseva1__User_Id__c = 'Test Id'; 
            ListfsDP.Add(fsDP1);
            
            forseva1__DataProvider__c fsDP2 = new forseva1__DataProvider__c();
            fsDP2.Name = 'Equifax Consumer';
            fsDP2.forseva1__Password__c='Test3' ;
            fsDP2.forseva1__Service_Timeout__c= 60;
            fsDP2.forseva1__Service_URL__c = 'https://test.test.com';
            fsDP2.forseva1__User_Id__c = 'Test Id3';    
            fsDP2.forseva1__Subscriber_Code__c = 'TNTI.1564390';  
            ListfsDP.Add(fsDP2);
            
            forseva1__DataProvider__c fsDP3 = new forseva1__DataProvider__c();
            fsDP3.Name = 'Experian Consumer';
            fsDP3.forseva1__Password__c='Test3' ;
            fsDP3.forseva1__Service_Timeout__c= 60;
            fsDP3.forseva1__Service_URL__c = 'https://test.test.com';
            fsDP3.forseva1__User_Id__c = 'Test Id3'; 
            fsDP3.forseva1__Subscriber_Code__c = 'TNTI.1564390';   
            ListfsDP.Add(fsDP3);
            
            forseva1__DataProvider__c fsDP4 = new forseva1__DataProvider__c();
            fsDP4.Name = 'TransUnion';
            fsDP4.forseva1__Password__c='Test4' ;
            fsDP4.forseva1__Service_Timeout__c= 60;
            fsDP4.forseva1__Service_URL__c = 'https://test.test.com';
            fsDP4.forseva1__User_Id__c = 'Test Id4';    
            ListfsDP.Add(fsDP4);
            
            Insert ListfsDP;            
            
            List<forseva1__DataProviderProduct__c> ListfsDPP = new List<forseva1__DataProviderProduct__c>();
            forseva1__DataProviderProduct__c fsdpp1 = new forseva1__DataProviderProduct__c();
            fsdpp1.Name = 'Transunion Consumer Credit';
            fsdpp1.forseva1__Data_Provider__c = fsDP4.Id;
            fsdpp1.forseva1__Days_Valid__c = 30;
            ListfsDPP.Add(fsdpp1);
            
            forseva1__DataProviderProduct__c fsdpp2 = new forseva1__DataProviderProduct__c();
            fsdpp2.Name = 'Experian Consumer Credit';
            fsdpp2.forseva1__Data_Provider__c = fsDP3.Id;
            fsdpp2.forseva1__Days_Valid__c = 30;
            ListfsDPP.Add(fsdpp2);
            
            forseva1__DataProviderProduct__c fsdpp3 = new forseva1__DataProviderProduct__c();
            fsdpp3.Name = 'Equifax Consumer Credit';
            fsdpp3.forseva1__Data_Provider__c = fsDP2.Id;
            fsdpp3.forseva1__Days_Valid__c = 30;
            ListfsDPP.Add(fsdpp3);
            
            Insert ListfsDPP;       
        
        //}
    
    //} 
}

    static testMethod void testForsevaUnitTestUtility() {
    
        Test.startTest();
        
        ForsevaUnitTestUtility.initializeTestData();
        Account a = ForsevaUnitTestUtility.createAccount('test', true);
        Opportunity o = ForsevaUnitTestUtility.createOpportunity(a.Id, 'test', true);
        Application__c app = ForsevaUnitTestUtility.createApplication(o.Id, 'test', true);
        Dealer_Questionnaire__c dq = ForsevaUnitTestUtility.createDealerQuestionnaire(app.Id, true);
        ApplicationScoring__c appscr = ForsevaUnitTestUtility.createApplicationScoring(app.Id, true);
        Contact c = ForsevaUnitTestUtility.createContact('test', 'test', a.Id, true);        
        
        Integer aCounter = [select count() from Account];
        Integer appCounter = [select count() from Application__c];
        Integer cCounter = [select count() from Contact];
        System.assertEquals(3, aCounter, 'testForsevaUnitTestUtility() failed');
        System.assertEquals(3, appCounter, 'testForsevaUnitTestUtility() failed');
        System.assertEquals(4, cCounter, 'testForsevaUnitTestUtility() failed');
        
        Test.stopTest();
    }

    static testMethod void testControllerBase() {

        Map<Schema.SObjectType,List<SObject>> oMap = ForsevaUnitTestUtility.initializeTestData();
        Test.startTest();

        ApexPages.PageReference p = Page.ApplicationScoringNavigation;
        
        ControllerBase cb = new ControllerBase();
        cb.addSuccessMessage('1');
        cb.addInfoMessage('2');
        cb.addWarningMessage('3');
        cb.addErrorMessage('4');
        
        try {
            Integer i = 6/(3-3);
        }
        catch(Exception e) {
            cb.handleException(e);
        }        
        
        Integer messageCount = ApexPages.getMessages().size();
        System.assertEquals(5, messageCount, 'testControllerBase() failed');
        
        Test.stopTest();
    }

    static testMethod void testDBUtility1() {
    
        Map<Schema.SObjectType,List<SObject>> oMap = ForsevaUnitTestUtility.initializeTestData();
        Test.startTest();

        Account a1 = (Account)oMap.get(Account.SObjectType)[0];
        Account a2 = (Account)DBUtility.getObjectWithAllFields(a1.Id, Account.SObjectType);
        System.assertEquals(a1.Name, a2.Name, 'testDBUtility1() failed');
        a2 = (Account)oMap.get(Account.SObjectType)[1];

        Application__c app1 = (Application__c)oMap.get(Application__c.SObjectType)[0];
        ApplicationScoring__c appscr1 = ForsevaUnitTestUtility.createApplicationScoring(app1.Id, true);
        Application__c app2 = (Application__c)oMap.get(Application__c.SObjectType)[1];
        Dealer_Questionnaire__c dq1 = ForsevaUnitTestUtility.createDealerQuestionnaire(app1.Id, true);

        Account a3 = DBUtility.getOwningAccount(app1);
        System.assertEquals(a1.Id, a3.Id, 'testDBUtility1() failed');
        Account a4 = DBUtility.getOwningAccount(new Application__c());
        System.assertEquals(null, a4, 'testDBUtility1() failed');

        Account a5 = DBUtility.getOwningAccount(appscr1);
        System.assertEquals(a1.Id, a5.Id, 'testDBUtility1() failed');
        Account a6 = DBUtility.getOwningAccount(new ApplicationScoring__c());
        System.assertEquals(null, a6, 'testDBUtility1() failed');
        
        List<Account> aList = DBUtility.getRelatedAccounts(app1.Id);
        System.assertEquals(2, aList.size(), 'testDBUtility1() failed');
        aList = DBUtility.getRelatedAccounts(app2.Id);
        System.assertEquals(0, aList.size(), 'testDBUtility1() failed');
        
        List<Contact> cList = DBUtility.getRelatedContacts(app1.Id);
        System.assertEquals(2, cList.size(), 'testDBUtility1() failed');
        cList = DBUtility.getRelatedContacts(app2.Id);
        System.assertEquals(0, cList.size(), 'testDBUtility1() failed');

        cList = DBUtility.getRelatedAccountContacts(a1.Id);
        System.assertEquals(3, cList.size(), 'testDBUtility1() failed');
        cList = DBUtility.getRelatedAccountContacts(a2.Id);
        System.assertEquals(0, cList.size(), 'testDBUtility1() failed');

        Dealer_Questionnaire__c dq2 = DBUtility.getRelatedDealerQuestionnaire(app1.Id);
        System.assertEquals(dq1.Id, dq2.Id, 'testDBUtility1() failed');
        dq2 = DBUtility.getRelatedDealerQuestionnaire(null);
        System.assertEquals(null, dq2, 'testDBUtility1() failed');

        UserContext__c uc = DBUtility.getUserContext();
        uc.Current_Application_Id__c = app1.Id;
        upsert uc;
        uc = DBUtility.getUserContext();
        System.assertEquals(uc.Current_Application_Id__c, String.valueOf(app1.Id), 'testDBUtility1() failed');

        Map<String,List<ApplicationScoringFactor__c>> asfList1 = DBUtility.getScoringFactors(ScoringManager.LTE_75K);
        Map<String,List<ApplicationScoringFactor__c>> asfList2 = DBUtility.getScoringFactors(ScoringManager.GT_75K);
        System.assertEquals(7, asfList1.size(), 'testDBUtility1() failed');
        System.assertEquals(7, asfList2.size(), 'testDBUtility1() failed');
       
        System.assertEquals('LLP', DBUtility.getBusinessType(app1.Id), 'testDBUtility1() failed'); 
       
        //--------------------------------------       
       
        //String worst1 = DBUtility.getWorstPreviousExperience(app1.Id);
        //String worst2 = DBUtility.getWorstPreviousExperience(app2.Id);
        //System.assertEquals(ScoringManager.NEGATIVE, worst1, 'testDBUtility1() failed');        
        //System.assertEquals(null, worst2, 'testDBUtility1() failed');

        String colName = DBUtility.getNameForLabel(Account.SObjectType, 'Account Name');
        System.assertEquals('Name', colName, 'testDBUtility1() failed'); 
        
        DBUtility.createEmptyTURecords(a1.Id, app1.Id, appscr1.Id);
        Integer tuCounter = [select count() from forseva1__TransunionConsumer__c where Application_Scoring__c = :appscr1.Id];
        System.assertEquals(2, tuCounter, 'testDBUtility1() failed');        
        
        System.assertEquals(Date.newInstance(2000,01,01), DBUtility.efxToDate('01/01/2000'), 'testDBUtility1() failed');        
        System.assertEquals(Date.newInstance(2000,01,01), DBUtility.efxToDate('00/00/2000'), 'testDBUtility1() failed');        
        System.assertEquals(Date.newInstance(2013,12,31), DBUtility.efxToDate('12/31/2013'), 'testDBUtility1() failed');         
        System.assertEquals(Date.newInstance(2013,02,28), DBUtility.efxToDate('02/28/2013'), 'testDBUtility1() failed');        
        System.assertEquals(Date.newInstance(2013,02,28), DBUtility.efxToDate('02/30/2013'), 'testDBUtility1() failed');        
        System.assertEquals(Date.newInstance(2013,02,28), DBUtility.efxToDate('02/31/2013'), 'testDBUtility1() failed');         

        System.assertEquals(Date.newInstance(2000,01,01), DBUtility.expToDate('0100'), 'testDBUtility1() failed');
        System.assertEquals(Date.newInstance(2002,03,30), DBUtility.expToDate('033002'), 'testDBUtility1() failed'); 
        System.assertEquals(Date.newInstance(1995,06,01), DBUtility.expToDate('0695'), 'testDBUtility1() failed');
        System.assertEquals(Date.newInstance(1991,05,01), DBUtility.expToDate('0591'), 'testDBUtility1() failed');
        System.assertEquals(Date.newInstance(1995,07,01), DBUtility.expToDate('070195'), 'testDBUtility1() failed');
        System.assertEquals(null, DBUtility.expToDate('null'), 'testDBUtility1() failed');
        System.assertEquals(null, DBUtility.expToDate(null), 'testDBUtility1() failed');
        System.assertEquals(Date.newInstance(2001,12,01), DBUtility.expToDate('1201'), 'testDBUtility1() failed');
        System.assertEquals(Date.newInstance(2002,12,17), DBUtility.expToDate('121702'), 'testDBUtility1() failed');

        //--------------------------------------

        forseva1__EquifaxConsumer__c efx1 = new forseva1__EquifaxConsumer__c();
        efx1.forseva1__Account__c = a1.Id;     
        efx1.Application_Scoring__c = appscr1.Id;
        insert efx1;           
        List<forseva1__EquifaxConsumer__c> efxList1 = DBUtility.getEfxReports(appscr1.Id);
        System.assertEquals(1, efxList1.size(), 'testDBUtility1() failed');

        forseva1__ExperianConsumer__c exp1 = new forseva1__ExperianConsumer__c();
        exp1.forseva1__Account__c = a1.Id;     
        exp1.Application_Scoring__c = appscr1.Id;
        insert exp1;           
        List<forseva1__ExperianConsumer__c> expList1 = DBUtility.getExpReports(appscr1.Id);
        System.assertEquals(1, expList1.size(), 'testDBUtility1() failed');

        forseva1__TransunionConsumer__c tu1 = new forseva1__TransunionConsumer__c();
        tu1.forseva1__Account__c = a1.Id;     
        tu1.Application_Scoring__c = appscr1.Id;
        insert tu1;           
        List<forseva1__TransunionConsumer__c> tuList1 = DBUtility.getTuReports(appscr1.Id);
        System.assertEquals(3, tuList1.size(), 'testDBUtility1() failed');

        forseva1__LexisNexisReport__c ln1 = new forseva1__LexisNexisReport__c();
        ln1.forseva1__Account__c = a1.Id;     
        ln1.Application_Scoring__c = appscr1.Id;
        ln1.forseva1__Report_Type__c = DBUtility.UCC_FILING_SEARCH;
        insert ln1;           
        List<forseva1__LexisNexisReport__c> lnList1 = DBUtility.getLnReports(appscr1.Id);
        System.assertEquals(1, lnList1.size(), 'testDBUtility1() failed');

        List<Attachment> attList = [select Id from Attachment where ParentId = :ln1.Id];
        delete attList;
        StaticResource sr = [select Id, Name, Body from StaticResource where Name = 'LexisNexisUCCReportExample'];
		String parsedContent = parseAndUpdateExpDates(sr,'UCC Filing Search.xml' );
		
        Attachment att1 = new Attachment();
        att1.Body =  Blob.valueOf(parsedContent);
        att1.Name = 'UCC Filing Search.xml';
        att1.ContentType = 'text/xml';
        att1.ParentId = ln1.Id;
        insert att1;        
        DBUtility.parseLexisNexisReportFields(ln1.Id);   // asynchronous

        //--------------------------------------

        Test.stopTest();    
        
        ln1 = [select Id, Number_of_Existing_UCC_Filings__c from forseva1__LexisNexisReport__c where Id = :ln1.Id];
        System.assertEquals(3, ln1.Number_of_Existing_UCC_Filings__c, 'testDBUtility1() failed');
    }


    @isTest static void testDBUtility2() {
    
        Map<Schema.SObjectType,List<SObject>> oMap = ForsevaUnitTestUtility.initializeTestData();
        Test.startTest();

        Account a1 = (Account)oMap.get(Account.SObjectType)[0];
        DBUtility.setCreditPolicy(a1.Id, 'Equifax');
        DBUtility.setCreditPolicy(a1.Id, 'Experian');
        DBUtility.setCreditPolicy(a1.Id, 'TransUnion');

        forseva1__CreditPolicy__c cp = [select Id, Name from forseva1__CreditPolicy__c where Id in (select forseva1__Credit_Policy__c from Account where Id = :a1.Id)];
        System.assertEquals('TransUnion', cp.Name, 'testDBUtility2() failed');

        Test.stopTest();
    }

    static testMethod void testPersonWS() {
    
        Test.startTest();    
        PersonWS p = new PersonWS();        
        p.NamePrefix = 'Mr';
        p.FirstName = 'George';
        p.MiddleName = 'Sebastian';
        p.LastName = 'Smiley';
        p.GenerationSuffix = 'Jr';
        p.SalutationSuffix = 'MD';    
        p.UnparsedAddress = '1000 N. State Ave W.';
        p.AddressNumber = '1000';
        p.StreetName = 'State';
        p.StreetPreDirection = 'N';
        p.StreetPostDirection = 'W';
        p.StreetType = 'AV';
        p.UnitNumber = '#301';    
        p.Phone = '3124449999';     
        p.City = 'Chicago';
        p.State = 'IL';
        p.PostalCode = '60606';    
        p.SSN = '222334444';
        p.DateOfBirth = Date.today();
        p.Age = 49;    
        p.personId = null;            
        Test.stopTest();
    }

    @isTest static void testCreditPersonsWSEquifax1() {

        Map<Schema.SObjectType,List<SObject>> oMap = ForsevaUnitTestUtility.initializeTestData();
        Account a1 = (Account)oMap.get(Account.SObjectType)[0];
        Contact c1 = (Contact)oMap.get(Contact.SObjectType)[0];
        Application__c app = (Application__c)oMap.get(Application__c.SObjectType)[0];        
        ApplicationScoring__c appscr = ForsevaUnitTestUtility.createApplicationScoring(app.Id, true);                
        
        Test.startTest();
        
        UserContext__c uc = DBUtility.getUserContext();
        uc.Current_Application_Id__c = app.Id;
        uc.Current_Application_Scoring_Id__c = appscr.Id;
        upsert uc;
        
        List<PersonWS> pList1 = CreditPersonsWS.getCreditSubject(a1.Id);
        System.assertEquals(2, pList1.size(), 'testCreditPersonsWSEquifax1() failed');        
        List<PersonWS> pList2 = CreditPersonsWS.getCreditSubjectUsingParameterString('accountId:' + a1.Id);
        System.assertEquals(2, pList2.size(), 'testCreditPersonsWSEquifax1() failed');
        System.assertEquals(pList1[0].LastName, pList2[0].LastName, 'testCreditPersonsWSEquifax1() failed');       
        
        List<String> parmList = CreditPersonsWS.getCreditBureauRequestParameters('accountId:' + a1.Id + ',bureau:' + DBUtility.EQUIFAX);
        System.assertEquals(true, parmList.size() >= 2, 'testCreditPersonsWSEquifax1() failed');
        
        StaticResource sr = [select Id, Name, Body from StaticResource where Name = 'EquifaxConsumerReportExample'];
        String xmlString = sr.Body.toString();        
        String theReport = CreditPersonsWS.parseAndScore('Equifax Consumer', a1.Id, c1.Id, ('accountId:' + a1.Id), xmlString);        
        
        Test.stopTest();
    }

    @isTest static void testCreditPersonsWSExperian1() {

        Map<Schema.SObjectType,List<SObject>> oMap = ForsevaUnitTestUtility.initializeTestData();
        Account a1 = (Account)oMap.get(Account.SObjectType)[0];
        Contact c1 = (Contact)oMap.get(Contact.SObjectType)[0];
        Application__c app = (Application__c)oMap.get(Application__c.SObjectType)[0];        
        ApplicationScoring__c appscr = ForsevaUnitTestUtility.createApplicationScoring(app.Id, true);                
        
        Test.startTest();
        
        UserContext__c uc = DBUtility.getUserContext();
        uc.Current_Application_Id__c = app.Id;
        uc.Current_Application_Scoring_Id__c = appscr.Id;
        upsert uc;
        
        List<PersonWS> pList1 = CreditPersonsWS.getCreditSubject(a1.Id);
        System.assertEquals(2, pList1.size(), 'testCreditPersonsWSExperian1() failed');        
        List<PersonWS> pList2 = CreditPersonsWS.getCreditSubjectUsingParameterString('accountId:' + a1.Id);
        System.assertEquals(2, pList2.size(), 'testCreditPersonsWSExperian1() failed');
        System.assertEquals(pList1[0].LastName, pList2[0].LastName, 'testCreditPersonsWSExperian1() failed');       
        
        List<String> parmList = CreditPersonsWS.getCreditBureauRequestParameters('accountId:' + a1.Id + ',bureau:' + DBUtility.EXPERIAN);
        System.assertEquals(true, parmList.size() >= 2, 'testCreditPersonsWSEquifax1() failed');
        
        StaticResource sr = [select Id, Name, Body from StaticResource where Name = 'ExperianConsumerReportExample'];
        String xmlString = sr.Body.toString();        
        String theReport = CreditPersonsWS.parseAndScore('Experian Consumer', a1.Id, c1.Id, ('accountId:' + a1.Id), xmlString);        
        
        Test.stopTest();
    }

    @isTest static void testCreditPersonsWSTransUnion1() {

        Map<Schema.SObjectType,List<SObject>> oMap = ForsevaUnitTestUtility.initializeTestData();
        Account a1 = (Account)oMap.get(Account.SObjectType)[0];
        Contact c1 = (Contact)oMap.get(Contact.SObjectType)[0];
        Application__c app = (Application__c)oMap.get(Application__c.SObjectType)[0];        
        ApplicationScoring__c appscr = ForsevaUnitTestUtility.createApplicationScoring(app.Id, true);                
        
        Test.startTest();
        
        UserContext__c uc = DBUtility.getUserContext();
        uc.Current_Application_Id__c = app.Id;
        uc.Current_Application_Scoring_Id__c = appscr.Id;
        upsert uc;
        
        List<PersonWS> pList1 = CreditPersonsWS.getCreditSubject(a1.Id);
        System.assertEquals(2, pList1.size(), 'testCreditPersonsWSTransUnion1() failed');        
        List<PersonWS> pList2 = CreditPersonsWS.getCreditSubjectUsingParameterString('accountId:' + a1.Id);
        System.assertEquals(2, pList2.size(), 'testCreditPersonsWSTransUnion1() failed');
        System.assertEquals(pList1[0].LastName, pList2[0].LastName, 'testCreditPersonsWSTransUnion1() failed');       
        
        List<String> parmList = CreditPersonsWS.getCreditBureauRequestParameters('accountId:' + a1.Id + ',bureau:' + DBUtility.TRANSUNION);
        System.assertEquals(true, parmList.size() >= 1, 'testCreditPersonsWSTransUnion1() failed');
        
        StaticResource sr = [select Id, Name, Body from StaticResource where Name = 'ExperianConsumerReportExample'];   // fix eventually
        String xmlString = sr.Body.toString();        
        String theReport = CreditPersonsWS.parseAndScore('TransUnion', a1.Id, c1.Id, ('accountId:' + a1.Id), xmlString);        
        
        Test.stopTest();
    }

    // quick smoke test
    static testMethod void testScoringManager1() {    
        
        Map<Schema.SObjectType,List<SObject>> oMap = ForsevaUnitTestUtility.initializeTestData();
        Account a1 = (Account)oMap.get(Account.SObjectType)[0];
        Application__c app1 = (Application__c)oMap.get(Application__c.SObjectType)[0];

        Dealer_Questionnaire__c dq1 = ForsevaUnitTestUtility.createDealerQuestionnaire(app1.Id, true);        
        ApplicationScoring__c appscr1 = ForsevaUnitTestUtility.createApplicationScoring(app1.Id, true);
        
        Test.startTest();

        ScoringManager.resetScoringFactors();
        Integer counter1 = [select count() from ApplicationScoringFactor__c];
        System.assertEquals(68, counter1, 'testScoringManager1() failed');

        ScoringManager sm1 = new ScoringManager(appscr1);
        sm1.score();

        appscr1 = (ApplicationScoring__c)DBUtility.getObjectWithAllFields(appscr1.Id, ApplicationScoring__c.SOBjectType);
        System.assertEquals(2, appscr1.Total_Score__c, 'testScoringManager1() failed'); 

        Test.stopTest();    
    }

    // detailed public/private method test for LTE_75K scorecard
    static testMethod void testScoringManager2() {        
        
        Map<Schema.SObjectType,List<SObject>> oMap = ForsevaUnitTestUtility.initializeTestData();
        Account a1 = (Account)oMap.get(Account.SObjectType)[0];
        a1.Previous__c = ScoringManager.NEGATIVE;
        a1.Dealer_Type_Dealer_License_Type__c = 'LLP';
        update a1;
        Contact c1 = (Contact)oMap.get(Contact.SObjectType)[0];
        Opportunity oppo1 = (Opportunity)oMap.get(Opportunity.SObjectType)[0];
        oppo1.Credit_Limit_Requested__c = 50000;
        update oppo1;
        Application__c app1 = (Application__c)oMap.get(Application__c.SObjectType)[0];
        app1.Lot_Ownership__c = 'Own';
        update app1;

        Dealer_Questionnaire__c dq1 = ForsevaUnitTestUtility.createDealerQuestionnaire(app1.Id, false);
        dq1.Auction_1__c = 'ADESA';
        dq1.Auction_2__c = 'ADESA';
        dq1.Experience_in_Automotive_Industry__c = 1;
        dq1.How_Many_Units_are_on_the_Lot_Currently__c = 5;
        insert dq1;        
        ApplicationScoring__c appscr1 = ForsevaUnitTestUtility.createApplicationScoring(app1.Id, true);
        appscr1 = (ApplicationScoring__c)DBUtility.getObjectWithAllFields(appscr1.Id, ApplicationScoring__c.SObjectType);

        forseva1__EquifaxConsumer__c efx1 = new forseva1__EquifaxConsumer__c(forseva1__Account__c = a1.Id);
        efx1.forseva1__Contact__c = c1.Id;
        efx1.Application_Scoring__c = appscr1.Id;
        efx1.forseva1__eqScrBeacon__c = 500;
        efx1.Maximum_High_Credit__c = 5000;
        efx1.Years_on_File__c = 10;
        efx1.Late_Payment_Count__c = 20;
        
        forseva1__EquifaxConsumer__c efx2 = new forseva1__EquifaxConsumer__c(forseva1__Account__c = a1.Id);
        efx2.forseva1__Contact__c = c1.Id;
        efx2.Application_Scoring__c = appscr1.Id;
        efx2.forseva1__eqScrBeacon__c = 600;
        efx2.Maximum_High_Credit__c = 10000;
        efx2.Years_on_File__c = 30;
        efx2.Late_Payment_Count__c = 40;

        forseva1__ExperianConsumer__c exp1 = new forseva1__ExperianConsumer__c(forseva1__Account__c = a1.Id);
        exp1.forseva1__Contact__c = c1.Id;
        exp1.Application_Scoring__c = appscr1.Id;
        exp1.FICO_Score__c = 700;
        exp1.Maximum_High_Credit__c = 10000;
        exp1.Years_on_File__c = 30;
        exp1.Late_Payment_Count__c = 40;

        forseva1__TransunionConsumer__c tu1 = new forseva1__TransunionConsumer__c(forseva1__Account__c = a1.Id);
        tu1.forseva1__Contact__c = c1.Id;
        tu1.Application_Scoring__c = appscr1.Id;
        tu1.FICO_Score__c = 500;
        tu1.Maximum_High_Credit__c = 20000;
        tu1.Years_on_File__c = 30;
        tu1.Late_Payment_Count__c = 40;

        forseva1__LexisNexisReport__c ln1 = new forseva1__LexisNexisReport__c(forseva1__Account__c = a1.Id);
        ln1.Application_Scoring__c = appscr1.Id;
        ln1.forseva1__Report_Type__c = 'UCC Filing Search';
        ln1.Number_of_Existing_UCC_Filings__c = 11;

        forseva1__LexisNexisReport__c ln2 = new forseva1__LexisNexisReport__c(forseva1__Account__c = a1.Id);
        ln2.Application_Scoring__c = appscr1.Id;
        ln2.forseva1__Report_Type__c = 'UCC Filing Search';
        ln2.Number_of_Existing_UCC_Filings__c = 15;
        
        insert new List<SObject>{efx1,efx2,exp1,tu1,ln1,ln2};                
        
        Test.startTest();
        
        ScoringManager sm1 = new ScoringManager(appscr1);
 
        appscr1.Scoring_Calculation_Status__c = ''; 
        sm1.addStatusMessage('go');
        sm1.addStatusMessage('bears');        
        System.assertEquals('(1) go.\n(2) bears.\n', appscr1.Scoring_Calculation_Status__c, 'testScoringManager2() failed'); 
 
        sm1.assignScorecard();
        System.assertEquals(ScoringManager.LTE_75K, appscr1.Scorecard__c, 'testScoringManager2() failed');

        sm1.stageScoringInputs();
        System.assertEquals(575, appscr1.Guarantor_Credit_Score__c, 'testScoringManager2() failed');
        System.assertEquals(20000, appscr1.High_Credit_Amount__c, 'testScoringManager2() failed');
        System.assertEquals(25, appscr1.Years_in_Bureau__c, 'testScoringManager2() failed');
        System.assertEquals(140, appscr1.Late_Payments__c, 'testScoringManager2() failed');
        System.assertEquals('Own', appscr1.Lot_Ownership__c, 'testScoringManager2() failed');        
        System.assertEquals(2, appscr1.Number_of_Auction_References__c, 'testScoringManager2() failed');
        System.assertEquals(ScoringManager.NEGATIVE, appscr1.Previous_Account_Guarantor_Search__c, 'testScoringManager2() failed');
        System.assertEquals(1, appscr1.Years_of_Experience_in_Auto_Business__c, 'testScoringManager2() failed');
        System.assertEquals('LLP', appscr1.Business_Type__c, 'testScoringManager2() failed');        
        System.assertEquals(26, appscr1.Number_of_Existing_UCC_Filings__c, 'testScoringManager2() failed');
        System.assertEquals(5, appscr1.Number_of_Units_Currently_on_Lot__c, 'testScoringManager2() failed');

        Decimal totalScore = sm1.calculateTotalScore();
        System.assertEquals(95, totalScore, 'testScoringManager2() failed');
 
        List<ApplicationScoringAdverseAction__c> letters = [select Id from ApplicationScoringAdverseAction__c where Application_Scoring__c = :appscr1.Id];
        System.assertEquals(0, letters.size(),  'testScoringManager2() failed');
        sm1.score();
        letters = [select Id from ApplicationScoringAdverseAction__c where Application_Scoring__c = :appscr1.Id];
        System.assertEquals(4, letters.size(),  'testScoringManager2() failed');
 
        Test.stopTest();    
    }

    // detailed public/private method test for GT_75K scorecard
    static testMethod void testScoringManager3() {        
        
        Map<Schema.SObjectType,List<SObject>> oMap = ForsevaUnitTestUtility.initializeTestData();
        Account a1 = (Account)oMap.get(Account.SObjectType)[0];
        a1.Previous__c = ScoringManager.NEGATIVE;
        a1.Dealer_Type_Dealer_License_Type__c = 'LLC';
        update a1;
        Contact c1 = (Contact)oMap.get(Contact.SObjectType)[0];        
        Opportunity oppo1 = (Opportunity)oMap.get(Opportunity.SObjectType)[0];
        oppo1.Credit_Limit_Requested__c = 100000;
        update oppo1;
        Application__c app1 = (Application__c)oMap.get(Application__c.SObjectType)[0];
        app1.Lot_Ownership__c = 'Lease';
        update app1;

        Dealer_Questionnaire__c dq1 = ForsevaUnitTestUtility.createDealerQuestionnaire(app1.Id, false);
        dq1.Auction_1__c = 'ADESA';        
        dq1.Experience_in_Automotive_Industry__c = 2;
        dq1.How_Many_Units_are_on_the_Lot_Currently__c = 10;
        insert dq1;                
        ApplicationScoring__c appscr1 = ForsevaUnitTestUtility.createApplicationScoring(app1.Id, true);
        appscr1 = (ApplicationScoring__c)DBUtility.getObjectWithAllFields(appscr1.Id, ApplicationScoring__c.SObjectType);

        forseva1__EquifaxConsumer__c efx1 = new forseva1__EquifaxConsumer__c(forseva1__Account__c = a1.Id);
        efx1.forseva1__Contact__c = c1.Id;
        efx1.Application_Scoring__c = appscr1.Id;
        efx1.forseva1__eqScrBeacon__c = 500;
        efx1.Maximum_High_Credit__c = 5000;
        efx1.Years_on_File__c = 10;
        efx1.Late_Payment_Count__c = 20;
        
        forseva1__EquifaxConsumer__c efx2 = new forseva1__EquifaxConsumer__c(forseva1__Account__c = a1.Id);
        efx2.forseva1__Contact__c = c1.Id;
        efx2.Application_Scoring__c = appscr1.Id;
        efx2.forseva1__eqScrBeacon__c = 600;
        efx2.Maximum_High_Credit__c = 10000;
        efx2.Years_on_File__c = 30;
        efx2.Late_Payment_Count__c = 40;
        
        forseva1__LexisNexisReport__c ln1 = new forseva1__LexisNexisReport__c(forseva1__Account__c = a1.Id);
        ln1.Application_Scoring__c = appscr1.Id;
        ln1.forseva1__Report_Type__c = 'UCC Filing Search';
        ln1.Number_of_Existing_UCC_Filings__c = 11;

        forseva1__LexisNexisReport__c ln2 = new forseva1__LexisNexisReport__c(forseva1__Account__c = a1.Id);
        ln2.Application_Scoring__c = appscr1.Id;
        ln2.forseva1__Report_Type__c = 'UCC Filing Search';
        ln2.Number_of_Existing_UCC_Filings__c = 15;
        
        insert new List<SObject>{efx1,efx2,ln1,ln2};                
                                
        Test.startTest();

        ScoringManager sm1 = new ScoringManager(appscr1);

        appscr1.Scoring_Calculation_Status__c = '';
        sm1.addStatusMessage('go');
        sm1.addStatusMessage('bears');        
        System.assertEquals('(1) go.\n(2) bears.\n', appscr1.Scoring_Calculation_Status__c, 'testScoringManager3() failed'); 
 
        sm1.assignScorecard();
        System.assertEquals(ScoringManager.GT_75K, appscr1.Scorecard__c, 'testScoringManager3() failed');

        sm1.stageScoringInputs();
        System.assertEquals(550, appscr1.Guarantor_Credit_Score__c, 'testScoringManager3() failed');
        System.assertEquals(10000, appscr1.High_Credit_Amount__c, 'testScoringManager3() failed');
        System.assertEquals(20, appscr1.Years_in_Bureau__c, 'testScoringManager3() failed');
        System.assertEquals(60, appscr1.Late_Payments__c, 'testScoringManager3() failed');
        System.assertEquals('Lease', appscr1.Lot_Ownership__c, 'testScoringManager3() failed');
        System.assertEquals(1, appscr1.Number_of_Auction_References__c, 'testScoringManager3() failed');        
        System.assertEquals(ScoringManager.NEGATIVE, appscr1.Previous_Account_Guarantor_Search__c, 'testScoringManager3() failed');        
        System.assertEquals(2, appscr1.Years_of_Experience_in_Auto_Business__c, 'testScoringManager3() failed');
        System.assertEquals('LLP', appscr1.Business_Type__c, 'testScoringManager3() failed');
        System.assertEquals(26, appscr1.Number_of_Existing_UCC_Filings__c, 'testScoringManager3() failed');        
        System.assertEquals(10, appscr1.Number_of_Units_Currently_on_Lot__c, 'testScoringManager3() failed');

        Decimal totalScore = sm1.calculateTotalScore();
        System.assertEquals(22, totalScore, 'testScoringManager3() failed');

        Test.stopTest();    
    }

    static testMethod void testNewScoreController1() {

        Map<Schema.SObjectType,List<SObject>> oMap = ForsevaUnitTestUtility.initializeTestData();
        Application__c app = (Application__c)oMap.get(Application__c.SObjectType)[0];                
        Test.startTest();

        ApexPages.PageReference p1 = Page.NewScore;
        Test.setCurrentPage(p1);
        ApexPages.StandardController sc1 = new ApexPages.StandardController(app);
        NewScoreController nsc1 = new NewScoreController(sc1);
        
        ApexPages.PageReference p2 = nsc1.navigateToNewApplicationScoring();
        System.assert(p2 != null, 'testNewScoreController1() failed');
        
        Test.stopTest();
    }

    @isTest static void testApplicationScoringNavigationController1() {

        Map<Schema.SObjectType,List<SObject>> oMap = ForsevaUnitTestUtility.initializeTestData();
        Application__c app = (Application__c)oMap.get(Application__c.SObjectType)[0];        
        ApplicationScoring__c appscr = ForsevaUnitTestUtility.createApplicationScoring(app.Id, true);        
        Test.startTest();

        ApexPages.PageReference p1 = Page.ApplicationScoringNavigation;
        Test.setCurrentPage(p1);
        ApexPages.StandardController sc1 = new ApexPages.StandardController(appscr);
        Id applicationScoreId = sc1.getId();
        ApplicationScoringNavigationController c1 = new ApplicationScoringNavigationController(sc1);
        
        ApexPages.currentPage().getParameters().put('dest', 'Equifax');
        ApexPages.PageReference p2 = c1.navigateToNextPage();
        System.assert(p2.getUrl().contains('consumercreditreportrequest'), 'testApplicationScoringNavigationController1() failed');

        ApexPages.currentPage().getParameters().put('dest', 'Experian');
        p2 = c1.navigateToNextPage();
        System.assert(p2.getUrl().contains('consumercreditreportrequest'), 'testApplicationScoringNavigationController1() failed');

        ApexPages.currentPage().getParameters().put('dest', 'TransUnion');
        p2 = c1.navigateToNextPage();
        System.assert(p2.getUrl().contains(''+applicationScoreId), 'testApplicationScoringNavigationController1() failed');

        ApexPages.currentPage().getParameters().put('dest', 'LexisNexis');
        p2 = c1.navigateToNextPage();
        System.assert(p2.getUrl().contains('lexisnexis'), 'testApplicationScoringNavigationController1() failed');

        ApexPages.currentPage().getParameters().put('dest', 'TotalScore');
        p2 = c1.navigateToNextPage();
        System.assert(p2.getUrl().contains(applicationScoreId), 'testApplicationScoringNavigationController1() failed');

        ApexPages.currentPage().getParameters().put('dest', null);
        p2 = c1.navigateToNextPage();
        System.assert(p2.getUrl().contains(applicationScoreId), 'testApplicationScoringNavigationController1() failed');
        
        Test.stopTest();        
    }

    @isTest static void testLexisNexisController1() {

        Map<Schema.SObjectType,List<SObject>> oMap = ForsevaUnitTestUtility.initializeTestData();
        Account a1 = (Account)oMap.get(Account.SObjectType)[0];
        Account a2 = (Account)oMap.get(Account.SObjectType)[1];
        Contact con1 = (Contact)oMap.get(Contact.SObjectType)[0];        
        Contact con2 = (Contact)oMap.get(Contact.SObjectType)[1];
        Application__c app1 = (Application__c)oMap.get(Application__c.SObjectType)[0];        
        ApplicationScoring__c appscr1 = ForsevaUnitTestUtility.createApplicationScoring(app1.Id, true);        
        Test.startTest();

        ApexPages.PageReference p1 = Page.LexisNexis;
        p1.getParameters().put('Id',appscr1.Id);
        Test.setCurrentPage(p1);
        LexisNexisController c1 = new LexisNexisController();

        ApplicationScoring__c appscr2 = c1.getScore();
        System.assertEquals(appscr1.Id, appscr2.Id, 'LexisNexisController1() failed');

        List<LexisNexisController.ContactSelection> cList = c1.getRelatedContacts();
        System.assertEquals(2, cList.size(), 'LexisNexisController1() failed');
        System.assertEquals(true, cList[0].getSelected(), 'LexisNexisController1() failed');        
        List<LexisNexisController.AccountSelection> aList = c1.getRelatedAccounts();
        System.assertEquals(2, aList.size(), 'LexisNexisController1() failed');        
        System.assertEquals(true, aList[0].getSelected(), 'LexisNexisController1() failed');        

        System.assertEquals(4, c1.getReportTypeChoices().size(), 'LexisNexisController1() failed');
        System.assertEquals(DBUtility.COMPREHENSIVE_PERSON_REPORT, c1.getCurrentReportType(), 'LexisNexisController1() failed');
        System.assertEquals(true, c1.getIsContactPanelActive(), 'LexisNexisController1() failed');
        System.assertEquals(false, c1.getIsDone(), 'LexisNexisController1() failed');

        c1.setCurrentReportType(DBUtility.COMPREHENSIVE_PERSON_REPORT);
        c1.reportTypeChosen();
        c1.getNextReport();
        
        c1.setCurrentReportType(DBUtility.ENHANCED_BUSINESS_REPORT);
        c1.reportTypeChosen();
        c1.getNextReport();

        c1.setCurrentReportType(DBUtility.UCC_FILING_SEARCH);
        c1.reportTypeChosen();
        c1.getNextReport();

        c1.setCurrentReportType(DBUtility.CORPORATE_FILING_SEARCH);
        c1.reportTypeChosen();
        c1.getNextReport();

        p1 = c1.doCancel();
        System.assert(p1 != null, 'LexisNexisController1() failed');

        Test.stopTest();
    }

    @isTest static void testLexisNexisLOSController1() {

        Map<Schema.SObjectType,List<SObject>> oMap = ForsevaUnitTestUtility.initializeTestData();
        Account a1 = (Account)oMap.get(Account.SObjectType)[0];
        Account a2 = (Account)oMap.get(Account.SObjectType)[1];
        Contact con1 = (Contact)oMap.get(Contact.SObjectType)[0];        
        Contact con2 = (Contact)oMap.get(Contact.SObjectType)[1];
        Application__c app1 = (Application__c)oMap.get(Application__c.SObjectType)[0];        
        ApplicationScoring__c appscr1 = ForsevaUnitTestUtility.createApplicationScoring(app1.Id, true);        
        Test.startTest();

        ApexPages.PageReference p1 = Page.LexisNexisLOS;
        p1.getParameters().put('Id',appscr1.Id);
        Test.setCurrentPage(p1);
        
        LexisNexisLOSController c1 = new LexisNexisLOSController();
        
        ApplicationScoring__c asc1 = c1.getScore();
        System.assertEquals(appscr1.Id, asc1.Id, 'LexisNexisLOSController1() failed');
        
        Account currentAccount = c1.getCurrentAccount();
        System.assertEquals(a1.Id, currentAccount.Id, 'LexisNexisLOSController1() failed');
        
        List<forseva1.CompanyLookupResultGlobal> clrList = c1.getListOfSimilars();
        System.assertEquals(38, clrList.size(), 'LexisNexisLOSController1() failed');
        
        ApexPages.PageReference p2 = c1.conditionalBypass();
        System.assertEquals(null, p2, 'LexisNexisLOSController1() failed');
        
        ApexPages.currentPage().getParameters().put('companyId','12345');
        p2 = c1.processSelection();
        System.assertNotEquals(null, p2, 'LexisNexisLOSController1() failed');        
        
        p2 = c1.doSkip();
        System.assertNotEquals(null, p2, 'LexisNexisLOSController1() failed');

        ApexPages.currentPage().getParameters().put('companyId','12345');
        p2 = c1.processSelection();
        System.assertNotEquals(null, p2, 'LexisNexisLOSController1() failed');        
        
        p2 = c1.doSkip();
        System.assertNotEquals(null, p2, 'LexisNexisLOSController1() failed');
        
        p2 = c1.doCancel();
        System.assertNotEquals(null, p2, 'LexisNexisLOSController1() failed');

        a1 = [select Id, LexisNexis_Id__c from Account where Id = :a1.Id];
        System.assertEquals('12345', a1.LexisNexis_Id__c, 'LexisNexisLOSController1() failed');

        Test.stopTest();
    }

    static testMethod void testTriggers1() {

        Map<Schema.SObjectType,List<SObject>> oMap = ForsevaUnitTestUtility.initializeTestData();
        Account a1 = (Account)oMap.get(Account.SObjectType)[0];
        Application__c app1 = (Application__c)oMap.get(Application__c.SObjectType)[0];                
        Test.startTest();
        
        ApplicationScoring__c appscr1 = ForsevaUnitTestUtility.createApplicationScoring(app1.Id, true);
        appscr1 = [select Id, Name from ApplicationScoring__c where Id = :appscr1.Id];
        System.assert(appscr1.Name.contains(app1.Name), 'testTriggers1() failed');

        // with user context

        UserContext__c uc = DBUtility.getUserContext();
        uc.Current_Application_Id__c = app1.Id;
        uc.Current_Application_Scoring_Id__c = appscr1.Id;
        upsert uc;

        forseva1__EquifaxConsumer__c r1 = new forseva1__EquifaxConsumer__c(forseva1__Account__c = a1.Id);
        forseva1__ExperianConsumer__c r2 = new forseva1__ExperianConsumer__c(forseva1__Account__c = a1.Id);
        forseva1__TransunionConsumer__c r3 = new forseva1__TransunionConsumer__c(forseva1__Account__c = a1.Id);
        forseva1__LexisNexisReport__c r4 = new forseva1__LexisNexisReport__c(forseva1__Account__c = a1.Id, forseva1__Report_Type__c = 'Enhanced Business Report');
        insert new List<SObject>{r1,r2,r3,r4};        
        
        r1 = [select Id, Application_Scoring__c from forseva1__EquifaxConsumer__c where Id = :r1.Id];
        r2 = [select Id, Application_Scoring__c from forseva1__ExperianConsumer__c where Id = :r2.Id];
        r3 = [select Id, Application_Scoring__c from forseva1__TransunionConsumer__c where Id = :r3.Id];
        r4 = [select Id, Application_Scoring__c from forseva1__LexisNexisReport__c where Id = :r4.Id];
        
        System.assertEquals(appscr1.Id, r1.Application_Scoring__c, 'testTriggers1() failed');
        System.assertEquals(appscr1.Id, r2.Application_Scoring__c, 'testTriggers1() failed');
        System.assertEquals(appscr1.Id, r3.Application_Scoring__c, 'testTriggers1() failed');
        System.assertEquals(appscr1.Id, r4.Application_Scoring__c, 'testTriggers1() failed');

        // without user context

        uc.Current_Application_Id__c = null;
        uc.Current_Application_Scoring_Id__c = null;
        upsert uc;

        r1 = new forseva1__EquifaxConsumer__c(forseva1__Account__c = a1.Id);
        r2 = new forseva1__ExperianConsumer__c(forseva1__Account__c = a1.Id);
        r3 = new forseva1__TransunionConsumer__c(forseva1__Account__c = a1.Id);
        r4 = new forseva1__LexisNexisReport__c(forseva1__Account__c = a1.Id, forseva1__Report_Type__c = 'Enhanced Business Report');
        insert new List<SObject>{r1,r2,r3,r4};        
        
        r1 = [select Id, Application_Scoring__c from forseva1__EquifaxConsumer__c where Id = :r1.Id];
        r2 = [select Id, Application_Scoring__c from forseva1__ExperianConsumer__c where Id = :r2.Id];
        r3 = [select Id, Application_Scoring__c from forseva1__TransunionConsumer__c where Id = :r3.Id];
        r4 = [select Id, Application_Scoring__c from forseva1__LexisNexisReport__c where Id = :r4.Id];
        
        System.assertEquals(null, r1.Application_Scoring__c, 'testTriggers1() failed');
        System.assertEquals(null, r2.Application_Scoring__c, 'testTriggers1() failed');
        System.assertEquals(null, r3.Application_Scoring__c, 'testTriggers1() failed');
        System.assertEquals(null, r4.Application_Scoring__c, 'testTriggers1() failed');

        Test.stopTest();        
    }

    
     private static String parseAndUpdateExpDates(StaticResource att,String attachmentName ) {

        Date todayDate = Date.today();
        String ns = 'http://webservices.seisint.com/WsAccurint';
            DOM.Document doc = new DOM.Document();
            doc.load(att.Body.toString());
            Dom.XmlNode Root = doc.getRootElement();
            Dom.XmlNode Body = Root.getChildElements()[0];  
            //system.debug('---------------- Body  before ' + doc.toXmlString());
             // start UCC_FILING_SEARCH 
			if(attachmentName.contains(DBUtility.UCC_FILING_SEARCH)) 
            {
			    Dom.XmlNode UCCSearch2ResponseEx = Body.getChildElement('UCCSearch2ResponseEx', ns);
                Dom.XmlNode response = UCCSearch2ResponseEx.getChildElement('response', ns);
                Dom.XmlNode Records = response.getChildElement('Records', ns);
                Integer i = 1;
                if(Records != null)
                {
                    for(Dom.XmlNode Record : Records.getChildElements()) 
                    {
                        Dom.XmlNode Filings = Record.getChildElement('Filings', ns);
                        if(Filings == null)  continue;
                        for(Dom.XmlNode Filing : Filings.getChildElements()) 
                        {
                            Dom.XmlNode ExpirationDate = Filing.getChildElement('ExpirationDate', ns);
                            if(ExpirationDate == null) break;
                            Date dt = Date.today().addYears(i);
                            Dom.XmlNode Year = ExpirationDate.getChildElement('Year', ns);
                            ExpirationDate.removeChild(Year);
                            Year = ExpirationDate.addChildElement('Year', ns, null);
                            Year.addTextNode(string.valueof(dt.year()));

                    	} 
                         i++;
                	}
                 }
              }    // end UCC_FILING_SEARCH      
         	//system.debug('---------------- Body After' + doc.toXmlString());
        	return doc.toXmlString();
    	} // end of  parseAndUpdateExpDates   
    
    
}

// EOF