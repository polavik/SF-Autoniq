@isTest
private class TestMarketingAttributeServices {
    static Opportunity testOpp;
    static User region1CreditUser;
    //static User region1PlatinumCreditUser; /* Added for class consistency by Eric Whipple on 1/21/16 - Removed changes on 15-March-2016 */
    static User region1ContractUser;
    static Application__c theApp;

    static void setup() {
        testOpp = TestServices.createTestOpportunity('Test Opp', 'Andrews', 'AFC Cad International', true);
        region1CreditUser = TestServices.createTestUser('bluewolf@test.test.test', 'none', 'AFC Cad International', 'Credit', false);
        region1CreditUser.AFC_Region_Responsible__c = 'Andrews';
        region1CreditUser.Credit_Type__c = 'Gold';
        insert region1CreditUser;
        /* Update by Eric Whipple on 1/21/16 due to failing tests - Because different testers may generate different 
            Application.Application_Level__c values, we create a second Credit user with a Platinum Credit_Type__c 
            (the default for this Test class is "Gold").  This way, there is exactly one credit user for both types, which supports current testing. 
            I had to purposely mismatch the region...otherwise the createTestUser method would have just returned me the first user I created. - Removed changes on 15-March-2016*/ 

        //region1PlatinumCreditUser = TestServices.createTestUser('galvin@test.test.test', 'none', 'AFC Cad International', 'Credit', false);
        //region1PlatinumCreditUser.AFC_Region_Responsible__c = 'Andrews';
        //region1PlatinumCreditUser.Credit_Type__c = 'Platinum';
        //insert region1PlatinumCreditUser;
        
        /* End Eric Whipple 1/21/16 Update - Removed changes on 15-March-2016*/

        region1ContractUser = TestServices.createTestUser('bluewol2@test.test.test', 'Andrews', 'AFC Cad International', 'CT Processing', true);
        theApp = TestServices.createTestApplication(testOpp.Id, 'Andrews', true);
    }

    static Marketing_Attribute__c insertNP() {
        Marketing_Attribute__c ma_NP = TestServices.createMarketingAttribute(theApp.Id, false);
        ma_NP.Primary__c = false;
        insert ma_NP;
        return ma_NP;
    }

    static Marketing_Attribute__c insertP() {
        Marketing_Attribute__c ma_P = TestServices.createMarketingAttribute(theApp.Id, false);
        ma_P.Primary__c = true;
        try {
            insert ma_P;
        } catch (DmlException e) {

        }
        return ma_P;
    }

    static Marketing_Attribute__c flipMA(Marketing_Attribute__c ma) {
        ma.Primary__c = !ma.Primary__c;
        try {
            update ma;
        } catch (DmlException e) {
            
        }
        return ma;
    }


    static void assertApplicationCorrectness(Boolean exp, Integer size, String err) {
        Application__c q_app = [SELECT Id, Ready_For_Submission__c FROM Application__c WHERE Id =:theApp.Id][0];
        System.debug('^^^APP in Assert : ' + q_app);
        Integer maCount = [SELECT COUNT() FROM Marketing_Attribute__c WHERE Application__c =:theApp.Id];
        if (String.isNotBlank(err)) 
            TestServices.pageMessageContains(err);
        else 
            System.assertEquals(0, ApexPages.getMessages().size());
        System.assertEquals(size, maCount);
        System.assertEquals(exp, q_app.Ready_For_Submission__c);
        ApexPages.getMessages().clear();
    }
    
    /** LEGEND **
    * p  = Marketing Attribute with Primary__c set to true
    * np = Marketing Attribute with Primary__c set to false
    **************/
    static testMethod void testSingularAddsAndRemoves() {
        setup();
        Test.startTest();
            Marketing_Attribute__c np =     insertNP();
                                            assertApplicationCorrectness(false, 1, '');
            Marketing_Attribute__c p =      insertP();
                                            assertApplicationCorrectness(true, 2, '');
                                            delete p;
            Marketing_Attribute__c np2 =    insertNP();
                                            assertApplicationCorrectness(false, 2, '');
                                            delete np2;
            p =                             flipMA(np);
                                            assertApplicationCorrectness(true, 1, '');
                                            insertP();
                                            assertApplicationCorrectness(true, 1, MarketingAttributeServices.PRIMARY_EXISTS_ERROR_MSG);
                                            insertNP();
                                            assertApplicationCorrectness(true, 2, MarketingAttributeServices.PRIMARY_EXISTS_ERROR_MSG);
        Test.stopTest();
    }
    
    static testMethod void testSingularUpdates() {
        setup();
        Test.startTest();
            Marketing_Attribute__c np =     insertNP();
            Marketing_Attribute__c p =      insertP();
                                            assertApplicationCorrectness(true, 2, '');
            Marketing_Attribute__c np2 =    flipMA(p);
                                            assertApplicationCorrectness(false, 2, '');
            p =                             flipMA(np2);
                                            assertApplicationCorrectness(true, 2, '');
            Marketing_Attribute__c p2 =     flipMA(np);
                                            assertApplicationCorrectness(true, 2, MarketingAttributeServices.PRIMARY_EXISTS_ERROR_MSG);
        Test.stopTest();
    }

    static testMethod void filterMarketingAttributes() {
        setup();

        List<Marketing_Attribute__c> maList = new List<Marketing_Attribute__c>();
        for(Integer i = 0; i < 10; i++){
            maList.add(TestServices.createMarketingAttribute(theApp.Id, false));
        }
        Test.startTest();
            insert maList;
            Boolean isFilteredOut = MarketingAttributeServices.filterMarketingAttributes(maList);
            System.assert(isFilteredOut, 'List without primary should have been filtered out.');

            maList[0].Primary__c = true;
            update maList;
            isFilteredOut = MarketingAttributeServices.filterMarketingAttributes(maList);
            System.assert(!isFilteredOut, 'List with primary should not be filtered');
        Test.stopTest();
    }

    static List<Marketing_Attribute__c> generateAttributes(Id appId, Integer numOfPrimaries, Integer numOfNonPrimaries) {
        List<Marketing_Attribute__c> allMAs = new List<Marketing_Attribute__c>();
        for (Integer i=0; i < numOfPrimaries; i++) {
            Marketing_Attribute__c ma = TestServices.createMarketingAttribute(appId, false);
            ma.Primary__c = true;
            allMAs.add(ma);
        } 
        for (Integer i=0; i< numOfNonPrimaries; i++) {
            Marketing_Attribute__c ma = TestServices.createMarketingAttribute(appId, false);
            ma.Primary__c = false;
            allMAs.add(ma);
        }
        insert allMAs;
        return allMAs;
    }

    static testMethod void processMarketingAttributes(){
        setup();
        Application__c validFalseApp = TestServices.createTestApplication(testOpp.Id, 'Andrews', true);
        Application__c validTrueApp = TestServices.createTestApplication(testOpp.Id, 'Andrews', true); 
        Application__c invalidApp = TestServices.createTestApplication(testOpp.Id, 'Andrews', true);

        List<Marketing_Attribute__c> maList1 = generateAttributes(validFalseApp.Id, 0, 10);
        List<Marketing_Attribute__c> maList2 = generateAttributes(validTrueApp.Id, 1, 10);

        Map<Id, List<Marketing_Attribute__c>> inputMap = new Map<Id, List<Marketing_Attribute__c>>();
        inputMap.put(validFalseApp.Id, maList1);
        inputMap.put(validTrueApp.Id, maList2);

        Test.startTest();
            List<Application__c> actual_appsToUpdate =  MarketingAttributeServices.processMarketingAttributes(inputMap);
        Test.stopTest();

        System.assertEquals(2, actual_appsToUpdate.size(), 'Only applications with 1 or 0 primary attributes should be updated');
        for (Application__c actual_app : actual_appsToUpdate) {
            if (actual_app.Id == validTrueApp.Id) 
                System.assertEquals(true, actual_app.Ready_For_Submission__c, 'Application with 1 primary attribute should be ready for submission');
            else if (actual_app.Id == validFalseApp.Id) 
                System.assertEquals(false, actual_app.Ready_For_Submission__c, 'Application with no primary attributes should not be ready for submission');
            else System.assert(false, 'Only valid applications should be returned');
        }
    }

    static testMethod void updateApplications_errorTest() {
        setup();
        Application__c appWithoutError = TestServices.createTestApplication(testOpp.Id, 'Andrews', true);
        Application__c appWithError = TestServices.createTestApplication(testOpp.Id, 'Andrews', true); 

        List<Marketing_Attribute__c> maList1 = generateAttributes(appWithoutError.Id, 0, 10);
        List<Marketing_Attribute__c> maList2 = generateAttributes(appWithError.Id, 0, 10);
        appWithError.Id = 'a0A18000000Dxxx';
        appWithoutError.Id = 'a0A18000000Dxxy';

        Map<Id, List<Marketing_Attribute__c>> appToMAs = new Map<Id, List<Marketing_Attribute__c>>();
        appToMAs.put(appWithoutError.Id, maList1);
        appToMAs.put(appWithError.Id, maList2);


        List<Application__c> inputApps = new List<Application__c>{appWithoutError, appWithError};

        Test.startTest();
            MarketingAttributeServices.updateApplications(inputApps, appToMAs);
        Test.stopTest();

        System.assert(TestServices.pageMessageContains('invalid cross reference id'), 
            'Update should purposefully fail and error should be caught. Error: ' + ApexPages.getMessages()[0].getSummary());
    }   
}