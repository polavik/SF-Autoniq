public with sharing class ContractCreatePOIContExt
{
    public Proof_of_Insurance__c proxyPOI { get; set; }
    public Proof_of_Insurance__c proxyFilterPOI {get; set; }
    public List<Proof_of_Insurance__c> generatedRecords { get; set; }
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
                for(FieldSetMember fsm : SObjectType.Proof_of_Insurance__c.FieldSets.Generate_POI_Fields_View.getFields()){
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
                for(FieldSetMember fsm : SObjectType.Proof_of_Insurance__c.FieldSets.Generate_POI_Fields_Filter.getFields()){
                    filterFields.add(fsm.getFieldPath());
                }
            }
            return filterFields;
        }
        set;
    }

    public ContractCreatePOIContExt( ApexPages.StandardController stdCont )
    {
        this.generatedRecords = new List<Proof_of_Insurance__c>();
        this.standardCont = stdCont;

        if(stdCont.getId() == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MISSING_CONTRACT_ERROR));
            return;
        }
        this.theContract = (AFC_Contracts__c)stdCont.getRecord();
        this.proxyPOI = new Proof_of_Insurance__c( Contract__c = this.theContract.Id );
        this.proxyFilterPOI = new Proof_of_Insurance__c( Contract__c = this.theContract.Id );
    }

    public List<Proof_of_Insurance__c> getExistingRecords(){
        List<Proof_of_Insurance__c> existingRecords = new List<Proof_of_Insurance__c>();
        recordsToDeleteMap = new Map<Id, Boolean>();
        try{
           existingRecords = (List<Proof_of_Insurance__c>) Database.query(
                            DynamicQueryUtils.getDynamicQuery('Proof_of_Insurance__c', tableFields, filterFields, proxyFilterPOI));
            for(Proof_of_Insurance__c poi : existingRecords){
                recordsToDeleteMap.put(poi.Id, false);
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }

        return existingRecords;
    }

    public void generateRecords()
    {
        if(this.numberOfRecords==null || this.proxyPOI.Frequency_Of_Schedule__c == null || this.proxyPOI.Due_Date__c == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MISSING_FIELDS_ERROR));
            return;
        }
        Date targetDate = this.proxyPOI.Due_Date__c;

        String frequency = this.proxyPOI.Frequency_Of_Schedule__c;
        if(ProofOfInsuranceServices.FREQUENCY_TO_NUMBER.containsKey( frequency )){
            this.generatedRecords = new List<Proof_of_Insurance__c>();
            for(Integer i = 0; i < numberOfRecords; i++) {
                Proof_of_Insurance__c newReport = ProofOfInsuranceServices.clonePOI(this.proxyPOI, targetDate.addMonths( ProofOfInsuranceServices.FREQUENCY_TO_NUMBER.get( frequency ) * (i + 1)));
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

    private List<Proof_of_Insurance__c> getRecordsSelectedToDelete(){
        List<Proof_of_Insurance__c> recordsToDelete= new List<Proof_of_Insurance__c>();
        for(Id poiId : recordsToDeleteMap.keySet()){
            if(recordsToDeleteMap.get(poiId)){
                recordsToDelete.add(new Proof_of_Insurance__c(Id=poiId));
            }
        }
        return recordsToDelete;
    }

    public void deleteSelected(){
        List<Proof_of_Insurance__c> recordsToDelete = getRecordsSelectedToDelete();
        try{
            delete recordsToDelete;
        }catch( System.DmlException ex ){
            ApexPages.addMessages( ex );
        }
    }
}