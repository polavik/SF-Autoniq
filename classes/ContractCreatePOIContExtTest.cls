@isTest
private class ContractCreatePOIContExtTest
{
    public class MockCallout implements HttpCalloutMock
    {
        public HttpResponse respond( HttpRequest req )
        {
            HttpResponse theResponse = new HttpResponse();
            return theResponse;
        }
    }

    static AFC_Contracts__c testContract;
    static ApexPages.StandardController standardController;
    static ContractCreatePOIContExt customController;

    static void setup()
    {
        Test.setMock( HttpCalloutMock.class, new MockCallout() );

        testContract = TestServices.insert_AFCContract();
        standardController = new ApexPages.StandardController( testContract );
    }

    static testMethod void getExistingRecords(){
        final String FILTER_FIELD_NAME='Due_Date__c';
        final Date FILTER_FIELD_VALUE=Date.today();
        final Integer NUM_FILTERED_RECORDS=5;
        setup();

        customController = new ContractCreatePOIContExt( standardController );

        List<Proof_of_Insurance__c> recordsToReturn = TestServices.createPOIs( NUM_FILTERED_RECORDS, testContract.Id, false );
        List<Proof_of_Insurance__c> recordsToFilter = TestServices.createPOIs( NUM_FILTERED_RECORDS, testContract.Id, false );
        for(Proof_of_Insurance__c record : recordsToReturn){
            record.put(FILTER_FIELD_NAME, FILTER_FIELD_VALUE);
        }

        List<Proof_of_Insurance__c> allRecords = new List<Proof_of_Insurance__c>(recordsToReturn);
        allRecords.addAll(recordsToFilter);

        insert allRecords;

        ContractCreatePOIContExt.filterFields = new Set<String>{FILTER_FIELD_NAME};
        ContractCreatePOIContExt.tableFields = new Set<String>{'Name'};
        customController.proxyFilterPOI.put(FILTER_FIELD_NAME, FILTER_FIELD_VALUE);

        Test.startTest();
            List<Proof_of_Insurance__c> actualRecords = customController.getExistingRecords();
        Test.stopTest();

        System.assert(ApexPages.getMessages().isEmpty(), 'There shouldnt be any errors on the page: ' + ApexPages.getMessages());
        System.assertEquals(recordsToReturn.size(), actualRecords.size(), 'The correct number of records was retrieved');
        System.assertEquals(Pluck.ids(recordsToReturn), Pluck.ids(actualRecords), 'The correct records were retrieved');
        System.assertEquals(Pluck.ids(recordsToReturn), customController.recordsToDeleteMap.keySet(), 'The correct records were added to the selected map');
    }

    static testMethod void deleteSelected(){
        final Integer NUM_DELETED_RECORDS=5;
        setup();

        List<Proof_of_Insurance__c> recordsToDelete = TestServices.createPOIs( NUM_DELETED_RECORDS, testContract.Id, false );
        List<Proof_of_Insurance__c> recordsToFilter = TestServices.createPOIs( NUM_DELETED_RECORDS, testContract.Id, false );
        List<Proof_of_Insurance__c> allRecords = new List<Proof_of_Insurance__c>(recordsToDelete);
        allRecords.addAll(recordsToFilter);
        insert allRecords;

        customController = new ContractCreatePOIContExt( standardController );
        customController.getExistingRecords();
        
        for(Proof_of_Insurance__c record : recordsToDelete){
            customController.recordsToDeleteMap.put(record.Id, true);
        }

        Test.startTest();
            customController.deleteSelected();
        Test.stopTest();

        List<Proof_of_Insurance__c> remainingRecords = [SELECT Id from Proof_of_Insurance__c];

        System.assert(ApexPages.getMessages().isEmpty(), 'There shouldnt be any errors on the page: ' + ApexPages.getMessages());
        System.assertEquals(recordsToFilter.size(), remainingRecords.size(), 'The correct number of records was deleted');
        System.assertEquals(Pluck.ids(recordsToFilter), Pluck.ids(recordsToFilter), 'The correct records were deleted');
    }

    static testMethod void generateRecords_Annual(){

        final Date TARGET_DATE = Date.today();
        final Integer NUMBER_RECORDS=5;
        setup();

        customController = new ContractCreatePOIContExt( standardController );
        customController.proxyPOI.Frequency_of_Schedule__c = 'Annual';
        customController.numberOfRecords = NUMBER_RECORDS;

        Date startDate = TARGET_DATE.addYears(1);

        Test.startTest();

            customController.proxyPOI.Due_Date__c = TARGET_DATE;
            customController.generateRecords();

        Test.stopTest();

        System.assertEquals(NUMBER_RECORDS, customController.generatedRecords.size(), 'Number of records generated should be length of schedule times records per year');
        for(Integer i = 0; i < customController.generatedRecords.size(); i++){
            System.assertEquals(startDate, customController.generatedRecords[i].Due_Date__c, 'Unexpected start date on record');
            startDate = startDate.addMonths(12);
        }
    }

    // Testing for edge case where the start date is set to a day that doesn't exist in other months, should adjust to pick last day of month
    // i.e.: October 31st should set the next monthly due date as November 30th, not December 1st.
    static testMethod void generateRecords_EndOfMonth(){

        final Date TARGET_DATE = Date.newInstance(2014, 10, 31);
        final Integer NUMBER_RECORDS=5;
        setup();

        customController = new ContractCreatePOIContExt( standardController );
        customController.proxyPOI.Frequency_of_Schedule__c = 'Monthly';
        customController.numberOfRecords = NUMBER_RECORDS;

        Date startDate = TARGET_DATE.addMonths(1);

        Test.startTest();

            customController.proxyPOI.Due_Date__c = TARGET_DATE;
            customController.generateRecords();

        Test.stopTest();

        System.assertEquals(NUMBER_RECORDS, customController.generatedRecords.size(), 'Should only generate one record per month for the number of records.');
        for(Integer i = 0; i < customController.generatedRecords.size(); i++){
        	System.assertEquals(TARGET_DATE.addMonths(i + 2).toStartOfMonth().addDays(-1), customController.generatedRecords[i].Due_Date__c, 'Unexpected date found, the date should be at the end of the month');
        }
    }

    static testMethod void createRecords()
    {
        final Integer NUM_REPORTINGS = 4;
        setup();

        customController = new ContractCreatePOIContExt( standardController );
        customController.generatedRecords = TestServices.createPOIs( NUM_REPORTINGS, testContract.Id, false );

        Test.startTest();

            //invalidate a record
            customController.generatedRecords[0].Contract__c = null;
            ApexPages.PageReference errorRef = customController.createRecords();
            System.assertEquals( null, errorRef, 'Null should have been returned upon error when creating records' );

            customController.generatedRecords[0].Contract__c = testContract.Id;
            ApexPages.PageReference successRef = customController.createRecords();

        Test.stopTest();

        System.assertEquals( standardController.view().getUrl(), successRef.getUrl(), 'A successful creation should have returned a pagereference to the contract' );
        List<Proof_of_Insurance__c> createdReportings = [ SELECT Id, Contract__c FROM Proof_of_Insurance__c ];
        System.assertEquals( NUM_REPORTINGS, createdReportings.size(), 'There should be as many Monthly Reporting records retrieved as were created' );
        for( Proof_of_Insurance__c aReporting : createdReportings )
        {
            System.assertEquals( testContract.Id, aReporting.Contract__c, 'Every Monthly Reporting should look up to the Contract specified on the page' );
        }
    }
}