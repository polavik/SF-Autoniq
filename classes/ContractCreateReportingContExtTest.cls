@isTest
private class ContractCreateReportingContExtTest
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
    static ContractCreateReportingContExt customController;

    static void setup()
    {
        Test.setMock( HttpCalloutMock.class, new MockCallout() );

        testContract = TestServices.insert_AFCContract();
        standardController = new ApexPages.StandardController( testContract );
    }

        static testMethod void getExistingRecords(){
        final String FILTER_FIELD_NAME='Start_Date__c';
        final Date FILTER_FIELD_VALUE=Date.today();
        final Integer NUM_FILTERED_RECORDS=5;
        setup();

        customController = new ContractCreateReportingContExt( standardController );

        List<Monthly_Reporting__c> recordsToReturn = TestServices.createMonthlyReportings( NUM_FILTERED_RECORDS, testContract.Id, false );
        List<Monthly_Reporting__c> recordsToFilter = TestServices.createMonthlyReportings( NUM_FILTERED_RECORDS, testContract.Id, false );
        for(Monthly_Reporting__c record : recordsToReturn){
            record.put(FILTER_FIELD_NAME, FILTER_FIELD_VALUE);
        }

        List<Monthly_Reporting__c> allRecords = new List<Monthly_Reporting__c>(recordsToReturn);
        allRecords.addAll(recordsToFilter);

        insert allRecords;

        ContractCreateReportingContExt.filterFields = new Set<String>{FILTER_FIELD_NAME};
        ContractCreateReportingContExt.tableFields = new Set<String>{'Name'};
        customController.proxyFilterMonthlyReporting.put(FILTER_FIELD_NAME, FILTER_FIELD_VALUE);

        Test.startTest();
            List<Monthly_Reporting__c> actualRecords = customController.getExistingRecords();
        Test.stopTest();

        System.assert(ApexPages.getMessages().isEmpty(), 'There shouldnt be any errors on the page: ' + ApexPages.getMessages());
        System.assertEquals(recordsToReturn.size(), actualRecords.size(), 'The correct number of records was retrieved');
        System.assertEquals(Pluck.ids(recordsToReturn), Pluck.ids(actualRecords), 'The correct records were retrieved');
        System.assertEquals(Pluck.ids(recordsToReturn), customController.recordsToDeleteMap.keySet(), 'The correct records were added to the selected map');
    }

    static testMethod void deleteSelected(){
        final Integer NUM_DELETED_RECORDS=5;
        setup();

        List<Monthly_Reporting__c> recordsToDelete = TestServices.createMonthlyReportings( NUM_DELETED_RECORDS, testContract.Id, false );
        List<Monthly_Reporting__c> recordsToFilter = TestServices.createMonthlyReportings( NUM_DELETED_RECORDS, testContract.Id, false );
        List<Monthly_Reporting__c> allRecords = new List<Monthly_Reporting__c>(recordsToDelete);
        allRecords.addAll(recordsToFilter);
        insert allRecords;

        customController = new ContractCreateReportingContExt( standardController );
        customController.getExistingRecords();
        
        for(Monthly_Reporting__c record : recordsToDelete){
            customController.recordsToDeleteMap.put(record.Id, true);
        }

        Test.startTest();
            customController.deleteSelected();
        Test.stopTest();

        List<Monthly_Reporting__c> remainingRecords = [SELECT Id from Monthly_Reporting__c];

        System.assert(ApexPages.getMessages().isEmpty(), 'There shouldnt be any errors on the page: ' + ApexPages.getMessages());
        System.assertEquals(recordsToFilter.size(), remainingRecords.size(), 'The correct number of records was deleted');
        System.assertEquals(Pluck.ids(recordsToFilter), Pluck.ids(recordsToFilter), 'The correct records were deleted');
    }

    static testMethod void generateRecords_Monthly(){

        final Date TARGET_DATE = Date.today();
        final Integer NUMBER_RECORDS=5;
        setup();

        customController = new ContractCreateReportingContExt( standardController );
        customController.proxyMonthlyReporting.Frequency_of_Schedule__c = 'Monthly';
        customController.numberOfRecords = NUMBER_RECORDS;

        Test.startTest();

            customController.proxyMonthlyReporting.Start_Date__c = TARGET_DATE;
            customController.generateRecords();

        Test.stopTest();

        // Need to get the next 20th date, since there's no way to set System date for testing purposes
        Date startDate = TARGET_DATE;
        Integer daysBetween20th = 20 - startDate.day();
        startDate = startDate.addDays( daysBetween20th );
        if( daysBetween20th < 0 )
        {
            startDate = startDate.addMonths( 1 );
        }

        System.assertEquals(NUMBER_RECORDS, customController.generatedRecords.size(), 'Number of records generated should be length of schedule times records per year');
        for(Integer i = 0; i < customController.generatedRecords.size(); i++){
            System.assertEquals(startDate, customController.generatedRecords[i].Due_Date__c, 'Unexpected start date on record');
            startDate = startDate.addMonths(1);
        }
    }

    static testMethod void createRecords()
    {
        final Integer NUM_REPORTINGS = 4;
        setup();

        customController = new ContractCreateReportingContExt( standardController );
        customController.generatedRecords = TestServices.createMonthlyReportings( NUM_REPORTINGS, testContract.Id, false );

        Test.startTest();

            //invalidate a record
            customController.generatedRecords[0].Contract__c = null;
            ApexPages.PageReference errorRef = customController.createRecords();
            System.assertEquals( null, errorRef, 'Null should have been returned upon error when creating records' );

            customController.generatedRecords[0].Contract__c = testContract.Id;
            ApexPages.PageReference successRef = customController.createRecords();

        Test.stopTest();

        System.assertEquals( standardController.view().getUrl(), successRef.getUrl(), 'A successful creation should have returned a pagereference to the contract' );
        List<Monthly_Reporting__c> createdReportings = [ SELECT Id, Contract__c FROM Monthly_Reporting__c ];
        System.assertEquals( NUM_REPORTINGS, createdReportings.size(), 'There should be as many Monthly Reporting records retrieved as were created' );
        for( Monthly_Reporting__c aReporting : createdReportings )
        {
            System.assertEquals( testContract.Id, aReporting.Contract__c, 'Every Monthly Reporting should look up to the Contract specified on the page' );
        }
    }
}