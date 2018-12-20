@isTest
private class TestProofOfInsuranceServices {
    public class MockCallout implements HttpCalloutMock
    {
        public HttpResponse respond( HttpRequest req )
        {
            HttpResponse theResponse = new HttpResponse();
            return theResponse;
        }
    }

    static AFC_Contracts__c contract;
    static List<Proof_of_Insurance__c> pois;
    static Date startDate;

    static void setupContract(){
        startDate = Date.Today();

        Test.setMock(HttpCalloutMock.class, new MockCallout() );
        contract = TestServices.insert_AFCContract();

        ProofOfInsuranceServices.POIFields = new Set<String>{'Dealer_Compliance__c', 'Insurance_Certificate__c'};
    }

    // Tests that a completed POI with no following POI is properly inserted
    static testMethod void testTrigger_updateAdd(){
        setupContract();

        Proof_of_Insurance__c poi = TestServices.createPOIs(1, contract.Id, false)[0];
        poi.Status__c = ProofOfInsuranceServices.NOT_STARTED_STRING;
        poi.Due_Date__c = startDate.addYears(1);
        poi.Frequency_of_Schedule__c = 'Annual';
        insert poi;

        Test.startTest();
        poi.Status__c = ProofOfInsuranceServices.COMPLETED_STRING;
        update poi;
        Test.stopTest();

        List<Proof_of_Insurance__c> dbResults = [SELECT Id, Due_Date__c, Frequency_of_Schedule__c, Contract__c, Status__c
                                                 FROM Proof_of_Insurance__c
                                                 WHERE Contract__c = :contract.Id AND Id != :poi.Id];
        System.assertEquals(1, dbResults.size(), 'Unexpected number of POIs found');
        System.assertEquals(startDate.addYears(2), dbResults[0].Due_Date__c);
    }

    // Tests that a completed POI with an existing following POI is skipped
    static testMethod void testTrigger_updateSkip(){
        setupContract();

        List<Proof_of_Insurance__c> poiList = TestServices.createPOIs(2, contract.Id, false);
        for(Integer i = 0; i < poiList.size(); i++){
            poiList[i].Status__c = ProofOfInsuranceServices.NOT_STARTED_STRING;
            poiList[i].Due_Date__c = startDate.addYears(i);
            poiList[i].Frequency_of_Schedule__c = 'Annual';
            for(String field : ProofOfInsuranceServices.POIFields){
                poiList[i].put(field, false);
            }
        }
        insert poiList;

        Test.startTest();
        poiList[0].Status__c = ProofOfInsuranceServices.COMPLETED_STRING;
        update poiList[0];
        Test.stopTest();

        List<Proof_of_Insurance__c> dbResults = [SELECT Id, Due_Date__c, Frequency_of_Schedule__c, Contract__c, Status__c
                                                 FROM Proof_of_Insurance__c
                                                 WHERE Contract__c = :contract.Id AND Id != :poiList[0].Id];
        System.assertEquals(1, dbResults.size(), 'Unexpected number of POIs found');
        System.assertEquals(poiList[1].Id, dbResults[0].Id);
    }

    // Tests that a completed POI inserted gets a following POI added
    static testMethod void testTrigger_insert(){
        setupContract();

        Proof_of_Insurance__c poi = TestServices.createPOIs(1, contract.Id, false)[0];
        poi.Status__c = ProofOfInsuranceServices.COMPLETED_STRING;
        poi.Due_Date__c = startDate.addYears(1);
        poi.Frequency_of_Schedule__c = 'Annual';

        Test.startTest();
        insert poi;
        Test.stopTest();

        List<Proof_of_Insurance__c> dbResults = [SELECT Id, Due_Date__c, Frequency_of_Schedule__c, Contract__c, Status__c
                                                 FROM Proof_of_Insurance__c
                                                 WHERE Contract__c = :contract.Id AND Id != :poi.Id];
        System.assertEquals(1, dbResults.size(), 'Unexpected number of POIs found');
        System.assertEquals(startDate.addYears(2), dbResults[0].Due_Date__c);
    }

    static testMethod void getContractToPOIs(){
        setupContract();

        List<Proof_of_Insurance__c> poiList = TestServices.createPOIs(5, contract.Id, false);
        for(Integer i = 0; i < poiList.size(); i++){
            poiList[i].Due_Date__c = startDate.addYears(i + 1);
        }
        poiList[0].Due_Date__c = startDate.addYears(-1);
        insert poiList;

        Test.startTest();
        Map<Id, List<Proof_of_Insurance__c>> resultMap = ProofOfInsuranceServices.getContractToPOIs(new Set<Id>{contract.Id});
        Test.stopTest();

        Set<Id> expectedPOIIds = new Set<Id>{poiList[1].Id, poiList[2].Id, poiList[3].Id, poiList[4].Id};
        System.assertNotEquals(null, resultMap.get(contract.Id));
        System.assertEquals(expectedPOIIds.size(), resultMap.get(contract.Id).size(), 'Unexpected number of POIs found');
        System.assertEquals(expectedPOIIds, Pluck.ids(resultMap.get(contract.Id)));
    }

    static testMethod void filterPOIForCompleted(){
        setupContract();

        final Integer POI_COUNT = 5;

        List<Proof_of_Insurance__c> poiList = TestServices.createPOIs(POI_COUNT, contract.Id, false);
        for(Integer i = 0; i < poiList.size(); i++){
            if(Math.mod(i, 2) == 0){
                poiList[i].Status__c = ProofOfInsuranceServices.COMPLETED_STRING;
            } else {
                poiList[i].Status__c = ProofOfInsuranceServices.NOT_STARTED_STRING;
            }
        }

        Test.startTest();
        List<Proof_of_Insurance__c> filteredList = ProofOfInsuranceServices.filterPOIForCompleted(poiList);
        Test.stopTest();

        System.assertEquals(POI_COUNT - (Integer)(POI_COUNT/2), filteredList.size());
        for(Proof_of_Insurance__c poi : filteredList){
            System.assertEquals(ProofOfInsuranceServices.COMPLETED_STRING, poi.Status__c);
        }
    }

    static testMethod void clonePOI(){
        setupContract();

        Proof_of_Insurance__c origPOI = TestServices.createPOIs(1, contract.Id, false)[0];
        origPOI.Due_Date__c = startDate.addMonths(1);
        origPOI.Status__c = ProofOfInsuranceServices.NOT_STARTED_STRING;
        origPOI.Frequency_of_Schedule__c = 'Monthly';
        origPOI.Dealer_Compliance__c = false;
        origPOI.Insurance_Certificate__c = true;
        origPOI.Sent_to_Dealer__c = false;
        origPOI.VIP_Insurance__c = 'No';

        Test.startTest();
        Proof_of_Insurance__c resultPOI = ProofOfInsuranceServices.clonePOI(origPOI, startDate.addMonths(2));
        Test.stopTest();

        System.assertNotEquals(null, resultPOI);
        System.assertEquals(startDate.addMonths(2), resultPOI.Due_Date__c);
        System.assertEquals(origPOI.Contract__c, resultPOI.Contract__c);
        System.assertEquals(ProofOfInsuranceServices.NOT_STARTED_STRING, resultPOI.Status__c);
        System.assertEquals(origPOI.Frequency_of_Schedule__c, resultPOI.Frequency_of_Schedule__c);
        System.assertEquals(origPOI.Dealer_Compliance__c, resultPOI.Dealer_Compliance__c);
        System.assertEquals(origPOI.Insurance_Certificate__c, resultPOI.Insurance_Certificate__c);
    }

    static testMethod void createBufferPOIs_NonMonthly(){
        setupContract();

        List<Proof_of_Insurance__c> poiList = TestServices.createPOIs(1, contract.Id, false);
        poiList[0].Status__c = ProofOfInsuranceServices.COMPLETED_STRING;
        poiList[0].Frequency_of_Schedule__c = 'Annual';
        poiList[0].Due_Date__c = startDate.addYears(1);

        Test.startTest();
        List<ProofOfInsuranceServices.POIWrapper> resultPOIList = ProofOfInsuranceServices.createBufferPOIs(poiList);
        Test.stopTest();

        System.assertNotEquals(null, resultPOIList);
        System.assertEquals(1, resultPOIList.size());
        System.assertEquals(startDate.addYears(2), resultPOIList[0].newPOI.Due_Date__c);
    }

    static testMethod void createBufferPOIs_Monthly(){
        setupContract();
        final Date COMPLETED_DUE_DATE=startDate.addMonths(1);

        List<Proof_of_Insurance__c> poiList = TestServices.createPOIs(1, contract.Id, false);
        poiList[0].Status__c = ProofOfInsuranceServices.COMPLETED_STRING;
        poiList[0].Frequency_of_Schedule__c = 'Monthly';
        poiList[0].Due_Date__c = COMPLETED_DUE_DATE;

        Test.startTest();
        List<ProofOfInsuranceServices.POIWrapper> resultPOIList = ProofOfInsuranceServices.createBufferPOIs(poiList);
        Test.stopTest();

        System.assertNotEquals(null, resultPOIList);
        System.assertEquals(ProofOfInsuranceServices.NUMBER_OF_NEW_MONTHLY_RECORDS, resultPOIList.size());
        for(Integer i=0; i<ProofOfInsuranceServices.NUMBER_OF_NEW_MONTHLY_RECORDS; i++){
            System.assertEquals(COMPLETED_DUE_DATE.addMonths(i+1), resultPOIList[i].newPOI.Due_Date__c); 
        }
    }

    static testMethod void checkForMatch(){
        setupContract();

        List<Proof_of_Insurance__c> poiList = TestServices.createPOIs(3, contract.Id, false);
        for(Integer i = 0; i < poiList.size(); i++){
            poiList[i].Frequency_of_Schedule__c = 'Monthly';
            poiList[i].Due_Date__c = startDate.addMonths(i + 1);
            for(String field : ProofOfInsuranceServices.POIFields){
                poiList[i].put(field, false);
            }
        }

        Proof_of_Insurance__c currentPOI = TestServices.createPOIs(1, contract.Id, false)[0];
        currentPOI.Frequency_of_Schedule__c = 'Monthly';
        currentPOI.Due_Date__c = startDate.addMonths(1);
        for(String field : ProofOfInsuranceServices.POIFields){
            currentPOI.put(field, true);
        }

        Boolean result = ProofOfInsuranceServices.checkForMatch(poiList, currentPOI, startDate.addMonths(1));

        System.assert(!result, 'Match should not be found');

        for(String field : ProofOfInsuranceServices.POIFields){
            poiList[0].put(field, true);
        }

        result = ProofOfInsuranceServices.checkForMatch(poiList, currentPOI, startDate.addMonths(1));

        System.assert(result, 'Match should be found');

    }

    static testMethod void insertPOIs_pass(){
        setupContract();

        Proof_of_Insurance__c origPOI = TestServices.createPOIs(1, contract.Id, false)[0];

        origPOI.Due_Date__c = startDate;
        origPOI.Frequency_of_Schedule__c = 'Annual';
        origPOI.Status__c = ProofOfInsuranceServices.NOT_STARTED_STRING;

        insert origPOI;

        Proof_of_Insurance__c newPOI = TestServices.createPOIs(1, contract.Id, false)[0];
        newPOI.Due_Date__c = startDate.addYears(1);
        newPOI.Frequency_of_Schedule__c = 'Annual';
        newPOI.Status__c = ProofOfInsuranceServices.NOT_STARTED_STRING;

        List<ProofOfInsuranceServices.POIWrapper> wrappers = new List<ProofOfInsuranceServices.POIWrapper>();
        wrappers.add(new ProofOfInsuranceServices.POIWrapper(newPOI, origPOI));

        Test.startTest();
        ProofOfInsuranceServices.insertPOIs(wrappers);
        Test.stopTest();

        List<Proof_of_Insurance__c> dbResults = [SELECT Id, Frequency_of_Schedule__c, Status__c, Due_Date__c, Contract__c 
                                                 FROM Proof_of_Insurance__c
                                                 WHERE Contract__c =: contract.Id AND Due_Date__c =: startDate.addYears(1)];

        System.assertEquals(1, dbResults.size(), 'Unexpected number of records returned');
    }

    static testMethod void insertPOIs_fail(){
        setupContract();

        Proof_of_Insurance__c origPOI = TestServices.createPOIs(1, contract.Id, false)[0];

        origPOI.Due_Date__c = startDate;
        origPOI.Frequency_of_Schedule__c = 'Annual';
        origPOI.Status__c = ProofOfInsuranceServices.NOT_STARTED_STRING;

        insert origPOI;

        Proof_of_Insurance__c newPOI = TestServices.createPOIs(1, contract.Id, false)[0];
        newPOI.Due_Date__c = startDate.addYears(1);
        newPOI.Frequency_of_Schedule__c = 'Annual';
        newPOI.Primary_Return_Reason__c = 'Other'; // Should trip validation rule

        List<ProofOfInsuranceServices.POIWrapper> wrappers = new List<ProofOfInsuranceServices.POIWrapper>();
        wrappers.add(new ProofOfInsuranceServices.POIWrapper(newPOI, origPOI));

        Test.startTest();
        ProofOfInsuranceServices.insertPOIs(wrappers);
        Test.stopTest();

        System.assert(ApexPages.hasMessages(), 'Page should have errors');

        List<Proof_of_Insurance__c> dbResults = [SELECT Id, Frequency_of_Schedule__c, Status__c, Due_Date__c, Contract__c 
                                                 FROM Proof_of_Insurance__c
                                                 WHERE Contract__c =: contract.Id AND Due_Date__c =: startDate.addYears(1)];

        System.assertEquals(0, dbResults.size(), 'Unexpected number of records returned');
    }
}