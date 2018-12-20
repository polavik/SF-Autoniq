trigger MonthlyReporting on Monthly_Reporting__c (after insert, after update) {
    if(Trigger.isAfter){
        List<Monthly_Reporting__c> filteredList = MonthlyReportingServices.filterReportForCompleted(Trigger.new);
        if(!filteredList.isEmpty()){
            // Automatically generate Reports when one is completed
            MonthlyReportingServices.insertReports(MonthlyReportingServices.createBufferReports(filteredList));
        }
    }
}