public class ApplicationReassignmentController {
    @TestVisible static final Integer PAGE_SIZE=20;
    private static final String REASSIGN_SUCCESS_MESSAGE='Records reassigned successfully';

    public Application__c applicationFilters{get;set;}
    public Application__c dummyReassignedApplication{get;set;}
    public ApexPages.StandardSetController setCont{get;set;}
    public Map<Id, Boolean> applicationSelectedMap{get;set;}
    private List<String> defaultStages = new List<String>{'At Credit','At Contracting'};
    public List<SelectOption> availableApplicationTypes{
        get{
            return new List<SelectOption>{
                new SelectOption('','None'),
                new SelectOption('LN MOD','LN MOD'),
                new SelectOption('NEW APP','NEW APP'),
                new SelectOption('MODIFIED APP','MODIFIED APP')};
        }
    }   

    @TestVisible
    private static Set<String> tableFields{
        get{
            if(tableFields==null){
                tableFields = new Set<String>{'Name'};
                for(FieldSetMember fsm : SObjectType.Application__c.FieldSets.Reassignment_Table.getFields()){
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
                filterFields = new Set<String>{'Application_Type__c'};
                for(FieldSetMember fsm : SObjectType.Application__c.FieldSets.Reassignment_Filters.getFields()){
                    filterFields.add(fsm.getFieldPath());
                }
            }
            return filterFields;
        }
        set;
    }

    @TestVisible
    private static Set<String> reassignFields{
        get{
            if(reassignFields==null){
                reassignFields = new Set<String>();
                for(FieldSetMember fsm : SObjectType.Application__c.FieldSets.Reassignment_Fields.getFields()){
                    reassignFields.add(fsm.getFieldPath());
                }
            }
            return reassignFields;
        }
        set;
    }

    public ApplicationReassignmentController() {
        applicationFilters = new Application__c();
        dummyReassignedApplication = new Application__c();
        refreshResults();
    }

    public void refreshResults(){
        applicationSelectedMap = new Map<Id, Boolean>();
        try{
            String dynQ = DynamicQueryUtils.getDynamicQuery('Application__c', tableFields, filterFields, applicationFilters);
            String prep = ' WHERE ';
            if (dynQ.contains(' WHERE ')) 
                prep = ' AND ';
            dynQ += prep + ' (Application_Stage__c in :defaultStages) LIMIT 10000';
            setCont = new ApexPages.StandardSetController(Database.getQueryLocator(dynQ));
            setCont.setPageSize(PAGE_SIZE);
            addResultsToMap();
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }

    public void contNext(){
        setCont.next();
        addResultsToMap();
    }

    public void addResultsToMap(){
        for(sObject app : setCont.getRecords()){
            applicationSelectedMap.put(app.Id, false);
        }
    }

    public void reassign(){
        List<Application__c> resultsToUpdate = new List<Application__c>();
        for(Id appId : applicationSelectedMap.keySet()){
            if(applicationSelectedMap.get(appId)){
                resultsToUpdate.add(new Application__c(Id=appId));
            }
        }
        if(!resultsToUpdate.isEmpty()){
            for(String fieldName : reassignFields){
                if(dummyReassignedApplication.get(fieldName) !=null){
                    for(Application__c app : resultsToUpdate){
                        app.put(fieldName, dummyReassignedApplication.get(fieldName));
                    }
                }
            }

            try{
                update resultsToUpdate;
                refreshResults();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, REASSIGN_SUCCESS_MESSAGE));
            } catch(DmlException e){
                for(Integer i=0; i<e.getNumDml();i++){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, resultsToUpdate[e.getDmlIndex(i)].Name + ': ' + e.getDmlMessage(i)));
                }
            }
        }
    }
}