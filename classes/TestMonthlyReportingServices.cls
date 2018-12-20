@isTest
private class TestMonthlyReportingServices {
    public class MockCallout implements HttpCalloutMock
    {
        public HttpResponse respond( HttpRequest req )
        {
            HttpResponse theResponse = new HttpResponse();
            return theResponse;
        }
    }

    static AFC_Contracts__c contract;
    static List<Monthly_Reporting__c> reports;
    static Date startDate;

    static void setupContract(){
        startDate = Date.Today();

        Test.setMock(HttpCalloutMock.class, new MockCallout() );
        contract = TestServices.insert_AFCContract();

        MonthlyReportingServices.reportFields = new Set<String>{'Financials__c', 'Bank_Statements__c', 'Sales_Numbers__c', 'Tax_Returns__c'};
    }

    // Tests that a completed report with no following report is properly inserted
    static testMethod void testTrigger_updateAdd(){
        setupContract();

        Monthly_Reporting__c report = TestServices.createMonthlyReportings(1, contract.Id, false)[0];
        report.Status__c = MonthlyReportingServices.NOT_STARTED_STRING;
        report.Due_Date__c = startDate.addYears(1);
        report.Frequency_of_Schedule__c = 'Annual';
        insert report;

        Test.startTest();
        report.Status__c = MonthlyReportingServices.COMPLETED_STRING;
        update report;
        Test.stopTest();

        List<Monthly_Reporting__c> dbResults = [SELECT Id, Due_Date__c, Frequency_of_Schedule__c, Contract__c, Status__c
                                                 FROM Monthly_Reporting__c
                                                 WHERE Contract__c = :contract.Id AND Id != :report.Id];
        System.assertEquals(1, dbResults.size(), 'Unexpected number of reports found');
        System.assertEquals(startDate.addYears(2), dbResults[0].Due_Date__c);
    }

    // Tests that a completed report with an existing following report is skipped
    static testMethod void testTrigger_updateSkip(){
        setupContract();

        List<Monthly_Reporting__c> reportList = TestServices.createMonthlyReportings(2, contract.Id, false);
        for(Integer i = 0; i < reportList.size(); i++){
            reportList[i].Status__c = MonthlyReportingServices.NOT_STARTED_STRING;
            reportList[i].Due_Date__c = startDate.addYears(i);
            reportList[i].Frequency_of_Schedule__c = 'Annual';
            for(String field : MonthlyReportingServices.reportFields){
                reportList[i].put(field, false);
            }
        }
        insert reportList;

        Test.startTest();
        reportList[0].Status__c = MonthlyReportingServices.COMPLETED_STRING;
        update reportList[0];
        Test.stopTest();

        List<Monthly_Reporting__c> dbResults = [SELECT Id, Due_Date__c, Frequency_of_Schedule__c, Contract__c, Status__c
                                                 FROM Monthly_Reporting__c
                                                 WHERE Contract__c = :contract.Id AND Id != :reportList[0].Id];
        System.assertEquals(1, dbResults.size(), 'Unexpected number of reports found');
        System.assertEquals(reportList[1].Id, dbResults[0].Id);
    }

    // Tests that a completed report inserted gets a following report added
    static testMethod void testTrigger_insert(){
        setupContract();

        Monthly_Reporting__c report = TestServices.createMonthlyReportings(1, contract.Id, false)[0];
        report.Status__c = MonthlyReportingServices.COMPLETED_STRING;
        report.Due_Date__c = startDate.addYears(1);
        report.Frequency_of_Schedule__c = 'Annual';

        Test.startTest();
        insert report;
        Test.stopTest();

        List<Monthly_Reporting__c> dbResults = [SELECT Id, Due_Date__c, Frequency_of_Schedule__c, Contract__c, Status__c
                                                 FROM Monthly_Reporting__c
                                                 WHERE Contract__c = :contract.Id AND Id != :report.Id];
        System.assertEquals(1, dbResults.size(), 'Unexpected number of reports found');
        System.assertEquals(startDate.addYears(2), dbResults[0].Due_Date__c);
    }

    static testMethod void getContractToReports(){
        setupContract();

        List<Monthly_Reporting__c> reportList = TestServices.createMonthlyReportings(5, contract.Id, false);
        for(Integer i = 0; i < reportList.size(); i++){
            reportList[i].Due_Date__c = startDate.addYears(i + 1);
        }
        reportList[0].Due_Date__c = startDate.addYears(-1);
        insert reportList;

        Test.startTest();
        Map<Id, List<Monthly_Reporting__c>> resultMap = MonthlyReportingServices.getContractToReports(new Set<Id>{contract.Id});
        Test.stopTest();

        Set<Id> expectedReportIds = new Set<Id>{reportList[1].Id, reportList[2].Id, reportList[3].Id, reportList[4].Id};
        System.assertNotEquals(null, resultMap.get(contract.Id));
        System.assertEquals(expectedReportIds.size(), resultMap.get(contract.Id).size(), 'Unexpected number of reports found');
        System.assertEquals(expectedReportIds, Pluck.ids(resultMap.get(contract.Id)));
    }

    static testMethod void filterReportForCompleted(){
        setupContract();

        final Integer REPORT_COUNT = 5;

        List<Monthly_Reporting__c> reportList = TestServices.createMonthlyReportings(REPORT_COUNT, contract.Id, false);
        for(Integer i = 0; i < reportList.size(); i++){
            if(Math.mod(i, 2) == 0){
                reportList[i].Status__c = MonthlyReportingServices.COMPLETED_STRING;
            } else {
                reportList[i].Status__c = MonthlyReportingServices.NOT_STARTED_STRING;
            }
        }

        Test.startTest();
        List<Monthly_Reporting__c> filteredList = MonthlyReportingServices.filterReportForCompleted(reportList);
        Test.stopTest();

        System.assertEquals(REPORT_COUNT - (Integer)(REPORT_COUNT/2), filteredList.size());
        for(Monthly_Reporting__c report : filteredList){
            System.assertEquals(MonthlyReportingServices.COMPLETED_STRING, report.Status__c);
        }
    }

    static testMethod void cloneReport(){
        setupContract();

        Monthly_Reporting__c origReport = TestServices.createMonthlyReportings(1, contract.Id, false)[0];
        origReport.Due_Date__c = startDate.addMonths(1);
        origReport.Status__c = MonthlyReportingServices.NOT_STARTED_STRING;
        origReport.Frequency_of_Schedule__c = 'Monthly';
        origReport.Financials__c = false;
        origReport.Bank_Statements__c = true;
        origReport.Tax_Returns__c = false;

        Test.startTest();
        Monthly_Reporting__c resultReport = MonthlyReportingServices.cloneReport(origReport, startDate.addMonths(2));
        Test.stopTest();

        System.assertNotEquals(null, resultReport);
        System.assertEquals(startDate.addMonths(2), resultReport.Due_Date__c);
        System.assertEquals(origReport.Contract__c, resultReport.Contract__c);
        System.assertEquals(MonthlyReportingServices.NOT_STARTED_STRING, resultReport.Status__c);
        System.assertEquals(origReport.Frequency_of_Schedule__c, resultReport.Frequency_of_Schedule__c);
        System.assertEquals(origReport.Financials__c, resultReport.Financials__c);
        System.assertEquals(origReport.Bank_Statements__c, resultReport.Bank_Statements__c);
        System.assertEquals(origReport.Tax_Returns__c, resultReport.Tax_Returns__c);
    }

    static testMethod void createBufferReports_NonMonthly(){
        setupContract();

        List<Monthly_Reporting__c> reportList = TestServices.createMonthlyReportings(1, contract.Id, false);
        reportList[0].Status__c = MonthlyReportingServices.COMPLETED_STRING;
        reportList[0].Frequency_of_Schedule__c = 'Annual';
        reportList[0].Due_Date__c = startDate.addYears(1);

        Test.startTest();
        List<MonthlyReportingServices.ReportWrapper> resultReportList = MonthlyReportingServices.createBufferReports(reportList);
        Test.stopTest();

        System.assertNotEquals(null, resultReportList);
        System.assertEquals(1, resultReportList.size());
        System.assertEquals(startDate.addYears(2), resultReportList[0].newReport.Due_Date__c);
    }

    static testMethod void createBufferReports_Monthly(){
        setupContract();
        final Date COMPLETED_DUE_DATE=startDate.addMonths(1);

        List<Monthly_Reporting__c> reportList = TestServices.createMonthlyReportings(1, contract.Id, false);
        reportList[0].Status__c = MonthlyReportingServices.COMPLETED_STRING;
        reportList[0].Frequency_of_Schedule__c = 'Monthly';
        reportList[0].Due_Date__c = COMPLETED_DUE_DATE;

        Test.startTest();
        List<MonthlyReportingServices.ReportWrapper> resultReportList = MonthlyReportingServices.createBufferReports(reportList);
        Test.stopTest();

        System.assertNotEquals(null, resultReportList);
        System.assertEquals(MonthlyReportingServices.NUMBER_OF_NEW_MONTHLY_RECORDS, resultReportList.size());
        for(Integer i=0; i<MonthlyReportingServices.NUMBER_OF_NEW_MONTHLY_RECORDS; i++){
            System.assertEquals(COMPLETED_DUE_DATE.addMonths(i+1), resultReportList[i].newReport.Due_Date__c);
        }
    }

    static testMethod void checkForMatch(){
        setupContract();

        List<Monthly_Reporting__c> reportList = TestServices.createMonthlyReportings(3, contract.Id, false);
        for(Integer i = 0; i < reportList.size(); i++){
            reportList[i].Frequency_of_Schedule__c = 'Monthly';
            reportList[i].Due_Date__c = startDate.addMonths(i + 1);
            for(String field : MonthlyReportingServices.reportFields){
                reportList[i].put(field, false);
            }
        }

        Monthly_Reporting__c currentReport = TestServices.createMonthlyReportings(1, contract.Id, false)[0];
        currentReport.Frequency_of_Schedule__c = 'Monthly';
        currentReport.Due_Date__c = startDate.addMonths(1);
        for(String field : MonthlyReportingServices.reportFields){
            currentReport.put(field, true);
        }

        Boolean result = MonthlyReportingServices.checkForMatch(reportList, currentReport, startDate.addMonths(1));

        System.assert(!result, 'Match should not be found');

        for(String field : MonthlyReportingServices.reportFields){
            reportList[0].put(field, true);
        }

        result = MonthlyReportingServices.checkForMatch(reportList, currentReport, startDate.addMonths(1));

        System.assert(result, 'Match should be found');

    }

    static testMethod void insertReports_pass(){
        setupContract();

        Monthly_Reporting__c origReport = TestServices.createMonthlyReportings(1, contract.Id, false)[0];

        origReport.Due_Date__c = startDate;
        origReport.Frequency_of_Schedule__c = 'Annual';
        origReport.Status__c = MonthlyReportingServices.NOT_STARTED_STRING;

        insert origReport;

        Monthly_Reporting__c newReport = TestServices.createMonthlyReportings(1, contract.Id, false)[0];
        newReport.Due_Date__c = startDate.addYears(1);
        newReport.Frequency_of_Schedule__c = 'Annual';
        newReport.Status__c = MonthlyReportingServices.NOT_STARTED_STRING;

        List<MonthlyReportingServices.ReportWrapper> wrappers = new List<MonthlyReportingServices.ReportWrapper>();
        wrappers.add(new MonthlyReportingServices.ReportWrapper(newReport, origReport));

        Test.startTest();
        MonthlyReportingServices.insertReports(wrappers);
        Test.stopTest();

        List<Monthly_Reporting__c> dbResults = [SELECT Id, Frequency_of_Schedule__c, Status__c, Due_Date__c, Contract__c 
                                                 FROM Monthly_Reporting__c
                                                 WHERE Contract__c =: contract.Id AND Due_Date__c =: startDate.addYears(1)];

        System.assertEquals(1, dbResults.size(), 'Unexpected number of records returned');
    }

    static testMethod void insertReports_fail(){
        setupContract();

        Monthly_Reporting__c origReport = TestServices.createMonthlyReportings(1, contract.Id, false)[0];

        origReport.Due_Date__c = startDate;
        origReport.Frequency_of_Schedule__c = 'Annual';
        origReport.Status__c = MonthlyReportingServices.NOT_STARTED_STRING;

        insert origReport;

        Monthly_Reporting__c newReport = TestServices.createMonthlyReportings(1, contract.Id, false)[0];
        newReport.Due_Date__c = startDate.addYears(1);
        newReport.Frequency_of_Schedule__c = 'Annual';
        newReport.Primary_Return_Reason__c = 'Other'; // Should trip validation rule

        List<MonthlyReportingServices.ReportWrapper> wrappers = new List<MonthlyReportingServices.ReportWrapper>();
        wrappers.add(new MonthlyReportingServices.ReportWrapper(newReport, origReport));

        Test.startTest();
        MonthlyReportingServices.insertReports(wrappers);
        Test.stopTest();

        System.assert(ApexPages.hasMessages(), 'Page should have errors');

        List<Monthly_Reporting__c> dbResults = [SELECT Id, Frequency_of_Schedule__c, Status__c, Due_Date__c, Contract__c 
                                                 FROM Monthly_Reporting__c
                                                 WHERE Contract__c =: contract.Id AND Due_Date__c =: startDate.addYears(1)];

        System.assertEquals(0, dbResults.size(), 'Unexpected number of records returned');
    }



     static testMethod void testImproveTestCoverage(){
        startDate = Date.Today();

        Property__c prop = TestUtility.createProperty('afccontract.restrictupdate.account.userid',userinfo.getuserid());

        Test.setMock(HttpCalloutMock.class, new MockCallout() );
        contract = TestServices.insert_AFCContract();
        Account updAcc = TestServices.getTestAccount('updateAccount');

        AFC_Contracts__c updAfcCon = [Select Id, Account__c From AFC_Contracts__c Limit 1];
        if(updAfcCon != null)
        {
            updAfcCon.Account__c = updAcc.Id;
            Update updAfcCon;
        }

        MonthlyReportingServices.reportFields = new Set<String>{'Financials__c', 'Bank_Statements__c', 'Sales_Numbers__c', 'Tax_Returns__c'};
    }

}