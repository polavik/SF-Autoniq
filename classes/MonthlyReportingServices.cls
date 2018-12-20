public with sharing class MonthlyReportingServices {
    public final static String COMPLETED_STRING = 'Complete';
    public final static String NOT_STARTED_STRING = 'Not Started';
    @testVisible final static Integer NUMBER_OF_NEW_MONTHLY_RECORDS=3;
    @testVisible final static String MONTHLY_FREQUENCY='Monthly';
    public static final Map<String, Integer> FREQUENCY_TO_NUMBER = new Map<String, Integer>{
        'Monthly'=>1, 'Quarterly'=>3, 'Semi-Annual'=>6, 'Annual'=>12
    };


    @TestVisible
    private static Set<String> reportFields{
        get{
            if(reportFields==null){
                reportFields = new Set<String>();
                for(FieldSetMember fsm : SObjectType.Monthly_Reporting__c.FieldSets.Generate_Monthly_Reporting_Fields.getFields()){
                    reportFields.add(fsm.getFieldPath());
                }
            }
            return reportFields;
        } set;
    }

    public static List<Monthly_Reporting__c> allNewReports{
        get {
            if(allNewReports == null){
                allNewReports = new List<Monthly_Reporting__c>();
            }
            return allNewReports;
        } set;
    }   

    public static Map<Id, List<Monthly_Reporting__c>> getContractToReports(Set<Id> contractIds){
        String query = 'SELECT Id, Due_Date__c, Frequency_of_Schedule__c, Contract__c, Status__c';
        for(String field : reportFields){
            query += ', ' + String.escapeSingleQuotes(field);
        }
        query += ' FROM Monthly_Reporting__c WHERE Contract__c IN :contractIds AND Due_Date__c > TODAY AND Status__c != \'' + COMPLETED_STRING + '\'';
        List<Monthly_Reporting__c> reportList = Database.query(query);
        Map<Id, List<Monthly_Reporting__c>> contractToReports = new Map<Id, List<Monthly_Reporting__c>>();
        for(Monthly_Reporting__c report : reportList){
            if(contractToReports.get(report.Contract__c) != null){
                contractToReports.get(report.Contract__c).add(report);
            } else {
                contractToReports.put(report.Contract__c, new List<Monthly_Reporting__c>{report});
            }
        }
        return contractToReports;
    }

    public static List<Monthly_Reporting__c> filterReportForCompleted(List<Monthly_Reporting__c> reportList){
        List<Monthly_Reporting__c> filteredList = new List<Monthly_Reporting__c>();
        for(Monthly_Reporting__c report : reportList){
            if(report.Status__c == COMPLETED_STRING){
                filteredList.add(report);
            }
        }
        return filteredList;
    }

    public static Monthly_Reporting__c cloneReport(Monthly_Reporting__c origReport, Date newDate){
        Monthly_Reporting__c newReport = new Monthly_Reporting__c();
        for(String field : reportFields){
            newReport.put(field, origReport.get(field));
        }
        newReport.Contract__c = origReport.Contract__c;
        newReport.Frequency_of_Schedule__c = origReport.Frequency_of_Schedule__c;
        newReport.Due_Date__c = newDate;
        newReport.Status__c = NOT_STARTED_STRING;
        return newReport;
    }

    public static List<ReportWrapper> createBufferReports(List<Monthly_Reporting__c> reportList){
        List<ReportWrapper> reportForInsert = new List<ReportWrapper>();
        Map<Id, List<Monthly_Reporting__c>> contractToReports = getContractToReports(Pluck.ids('Contract__c', reportList));
        for(Monthly_Reporting__c report : reportList){
            String freq = report.Frequency_of_Schedule__c;
            if(FREQUENCY_TO_NUMBER.get(freq) == null) {
                report.addError('Frequency of Schedule must not be null');
            }

            if(freq == MONTHLY_FREQUENCY){
                for(Integer i=1; i<=NUMBER_OF_NEW_MONTHLY_RECORDS; i++){
                    Date newDate = report.Due_Date__c.addMonths(i*FREQUENCY_TO_NUMBER.get(freq));
                    if(!checkForMatch(contractToReports.get(report.Contract__c), report, newDate)){
                        reportForInsert.add(new ReportWrapper(cloneReport(report, newDate), report));
                    }
                }
            }else{
                Date newDate = report.Due_Date__c.addMonths(FREQUENCY_TO_NUMBER.get(freq));
                if(!checkForMatch(contractToReports.get(report.Contract__c), report, newDate)){
                    reportForInsert.add(new ReportWrapper(cloneReport(report, newDate), report));
                }
            }
        }
        return reportForInsert;
    }

    @testVisible static Boolean checkForMatch(List<Monthly_Reporting__c> reports, Monthly_Reporting__c currentReport, Date newDate){
        if(reports == null) return false;
        Boolean hasMatch;
        for(Monthly_Reporting__c report : reports){
            hasMatch = report.Frequency_of_Schedule__c == currentReport.Frequency_of_Schedule__c;
            hasMatch &= report.Due_Date__c == newDate;
            for(String field : reportFields){
                hasMatch &= report.get(field) == currentReport.get(field);
            }
            if(hasMatch) break;
        }
        return hasMatch;
    }

    public static void insertReports(List<ReportWrapper> reportList){
        if(reportList.isEmpty()) return;
        try{
            insert allNewReports;
        } catch (DmlException e){
            Map<string, Monthly_Reporting__c> identifierMap = new Map<String, Monthly_Reporting__c>();
            for(ReportWrapper wrapper : reportList){
                identifierMap.put(wrapper.newReport.Contract__c + '-' + wrapper.newReport.Due_Date__c.format(), wrapper.oldReport);
            }
            for (Integer i = 0; i < e.getNumDml(); i++){
                String identifier = allNewReports[e.getDmlIndex(i)].Contract__c + '-' + allNewReports[e.getDmlIndex(i)].Due_Date__c.format();
                identifierMap.get(identifier).addError(e.getMessage());
            }
        }
    }

    public class ReportWrapper{
        public Monthly_Reporting__c newReport;
        public Monthly_Reporting__c oldReport;

        public ReportWrapper(Monthly_Reporting__c newReprt, Monthly_Reporting__c oldReprt){
            newReport = newReprt;
            oldReport = oldReprt;

            allNewReports.add(newReprt);
        }
    }
}