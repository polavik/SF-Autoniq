public with sharing class ContractCreateReportingContExt
{
    public Monthly_Reporting__c proxyMonthlyReporting { get; set; }
    public Monthly_Reporting__c proxyFilterMonthlyReporting { get; set; }
    public List<Monthly_Reporting__c> generatedRecords { get; set; }
    public Map<Id, Boolean> recordsToDeleteMap{get;set;}
    public Integer numberOfRecords{get;set;}
    private AFC_Contracts__c theContract;
    private ApexPages.StandardController standardCont;

    final String MISSING_CONTRACT_ERROR = 'Please open Page from a valid Contract';
    final String MISSING_FIELDS_ERROR = 'Please Populate all the fields before generating the records';    

    @TestVisible
    private static Set<String> tableFields{
        get{
            if(tableFields==null){
                tableFields = new Set<String>{'Name'};
                for(FieldSetMember fsm : SObjectType.Monthly_Reporting__c.FieldSets.Generate_Monthly_Reporting_Fields_View.getFields()){
                    tableFields.add(fsm.getFieldPath());
                }
            }
            return tableFields;
        }
        set;
    }

    @TestVisible
    private static Set<String> filterFields{
        get{
            if(filterFields==null){
                filterFields = new Set<String>{'Contract__c'};
                for(FieldSetMember fsm : SObjectType.Monthly_Reporting__c.FieldSets.Generate_Monthly_Reporting_Fields_Filter.getFields()){
                    filterFields.add(fsm.getFieldPath());
                }
            }
            return filterFields;
        }
        set;
    }

    public ContractCreateReportingContExt( ApexPages.StandardController stdCont )
    {
        this.generatedRecords = new List<Monthly_Reporting__c>();
        this.standardCont = stdCont;

        if(stdCont.getId() == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MISSING_CONTRACT_ERROR));
            return;
        }
        this.theContract = (AFC_Contracts__c)stdCont.getRecord();
        this.proxyMonthlyReporting = new Monthly_Reporting__c( Contract__c = this.theContract.Id );
        this.proxyFilterMonthlyReporting = new Monthly_Reporting__c( Contract__c = this.theContract.Id );
    }
    
    public List<Monthly_Reporting__c> getExistingRecords(){
        List<Monthly_Reporting__c> existingRecords = new List<Monthly_Reporting__c>();
        recordsToDeleteMap = new Map<Id, Boolean>();
        try{
           existingRecords = (List<Monthly_Reporting__c>) Database.query(
                            DynamicQueryUtils.getDynamicQuery('Monthly_Reporting__c', tableFields, filterFields, proxyFilterMonthlyReporting));
            for(Monthly_Reporting__c mr : existingRecords){
                recordsToDeleteMap.put(mr.Id, false);
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }

        return existingRecords;
    }

    public void generateRecords()
    {
        if(this.numberOfRecords==null || this.proxyMonthlyReporting.Frequency_Of_Schedule__c == null || this.proxyMonthlyReporting.Start_Date__c == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MISSING_FIELDS_ERROR));
            return;
        }

        Date targetDate = this.proxyMonthlyReporting.Start_Date__c;
        Integer daysBetween20th = 20 - targetDate.day();
        targetDate = targetDate.addDays( daysBetween20th );
        if( daysBetween20th < 0 )
        {
            targetDate = targetDate.addMonths( 1 );
        }

        String frequency = this.proxyMonthlyReporting.Frequency_Of_Schedule__c;
        if(MonthlyReportingServices.FREQUENCY_TO_NUMBER.containsKey( frequency )){
            this.generatedRecords = new List<Monthly_Reporting__c>();
            for(Integer i = 0; i < numberOfRecords; i++) {
                Monthly_Reporting__c newReport = MonthlyReportingServices.cloneReport(this.proxyMonthlyReporting, targetDate);
                targetDate = targetDate.addMonths( MonthlyReportingServices.FREQUENCY_TO_NUMBER.get( frequency ) );
                generatedRecords.add(newReport);
            }
        }
    }

    public ApexPages.PageReference createRecords()
    {
        try
        {
            insert this.generatedRecords;
            return standardCont.view();
        }
        catch( System.DmlException ex )
        {
            ApexPages.addMessages( ex );
        }
        return null;
    }

    private List<Monthly_Reporting__c> getRecordsSelectedToDelete(){
        List<Monthly_Reporting__c> recordsToDelete= new List<Monthly_Reporting__c>();
        for(Id poiId : recordsToDeleteMap.keySet()){
            if(recordsToDeleteMap.get(poiId)){
                recordsToDelete.add(new Monthly_Reporting__c(Id=poiId));
            }
        }
        return recordsToDelete;
    }

    public void deleteSelected(){
        List<Monthly_Reporting__c> recordsToDelete = getRecordsSelectedToDelete();
        try{
            delete recordsToDelete;
        }catch( System.DmlException ex ){
            ApexPages.addMessages( ex );
        }
    }
}