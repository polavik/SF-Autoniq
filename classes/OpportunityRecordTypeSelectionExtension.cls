/*
(c) 2016 Appirio, Inc.

Apex Class Name: OpportunityRecordTypeSelectionExtension

22nd October 2016   Arvind Thakur   Original (Task # T-549711) - Please see the task description for more details.
22nd Movember 2016 Arvind Thakur    Modified (Issue # I-244819) - Add Account population
22nd Movember 2016 Arvind Thakur    Modified (Issue # I-244286) - Add Account population
*/
public with sharing class OpportunityRecordTypeSelectionExtension {
  
    //Public Data Members
    public String selectedOpportunityRecordType {get;set;}
    public String redirectId {get;set;}
    public List<SelectOption> opportunityRecordTypes {get;set;}
    public Map<String, String> recordTypeDescription {get;set;}
    public Opportunity opp {get;set;}
    public Boolean isExistingOpp {get;set;}
    public Boolean salesforceOnePage {get;set;}
    
    //Private Data Members
    private Id parentAccountId;
    private String parentAccountName;
    private Map<String,String> recordTypeIdNameMap;
 
    //Class Constructor
    public opportunityRecordTypeSelectionExtension(ApexPages.StandardSetController stdController){
        
        //This is for SF1
        if(UserInfo.getUiTheme() == 'Theme4t') {
            salesforceOnePage = true;
        }else {
            salesforceOnePage = false;   
        }
        
        parentAccountId = ApexPages.currentPage().getParameters().get('accountId');
        parentAccountName = ApexPages.currentPage().getParameters().get('AccountName');
        opportunityRecordTypes = new List<SelectOption>();
        recordTypeIdNameMap = new Map<String, String>();
        recordTypeDescription = new Map<String, String>();
        opp = new Opportunity();
        isExistingOpp  = false;
        
        //Fetch Record Types for Opportunity sObject
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
     
        //Create select option list of Opportunity record types 
        selectedOpportunityRecordType = rtMapByName.values().get(0).getRecordTypeId();
        for(Schema.RecordTypeInfo recordTypeInfo : rtMapByName.values()){           
            if(recordTypeInfo.getName() != 'Master' && recordTypeInfo.isAvailable()){
                opportunityRecordTypes.add(new SelectOption(recordTypeInfo.getRecordTypeId(), recordTypeInfo.getName()));
                recordTypeIdNameMap.put(recordTypeInfo.getRecordTypeId(), recordTypeInfo.getName());
                
                if(opp.RecordTypeId == null){
                    opp.RecordTypeId = recordTypeInfo.getRecordTypeId();
                }
            }
        }
        
        for(Opportunity o: [Select Id, Name From Opportunity where RecordTypeId =: selectedOpportunityRecordType AND AccountId =:parentAccountId AND Type = 'Inlane Selling']){
            isExistingOpp = true;
        }
        
        for(RecordType rt : [SELECT Id, Name, Description FROM RecordType WHERE Id IN:recordTypeIdNameMap.keySet()]) {
            if(!String.isBlank(rt.Description)) {
                recordTypeDescription.put(rt.Name, rt.Description);
            }else {
                recordTypeDescription.put(rt.Name, '');
            }
            
        }
        
  }
  
    //This function will redirect the user to Standard/Custom VF Page with record type id and name
    public PageReference selectRecordType(){
        String opportunityCloseData = system.today().addDays(45).format();
        Date opportunityCloseDate = System.Today() + 45;
        String recordTypeName = recordTypeIdNameMap.get(selectedOpportunityRecordType);
    
        
        if(salesforceOnePage) {
            Opportunity sf1Opp = new Opportunity();
            sf1Opp.RecordTypeId = selectedOpportunityRecordType;
            sf1Opp.AccountId = parentAccountId;
            sf1Opp.CloseDate = opportunityCloseDate;
            if(recordTypeName == 'ADESA DST CLOSE') {
                sf1Opp.Name = parentAccountName + ' ' + recordTypeName;
                sf1Opp.StageName = 'C-Customer Identification';
                sf1Opp.Type = 'Inlane Selling';
            }
            insert sf1Opp;
            redirectId = sf1Opp.Id;
            return null;
            
          
            
        }
           else {  
            PageReference ref =  new PageReference('/006/e');
            ref.getParameters().put('retURL', parentAccountId);
            ref.getParameters().put('RecordType', selectedOpportunityRecordType);
            ref.getParameters().put('RecordTypeName', recordTypeName);
            ref.getParameters().put('ent', 'Opportunity');
            ref.getParameters().put('opp4', parentAccountName);
            ref.getParameters().put('opp4_lkid', parentAccountId);
            ref.getParameters().put('opp9', opportunityCloseData);
            ref.getParameters().put(Label.Opportunity_Projected_Close_Date_Field_Id, opportunityCloseData);
            if(recordTypeName == 'ADESA DST CLOSE') {
                ref.getParameters().put('opp3', parentAccountName + ' ' + recordTypeName);
                ref.getParameters().put('opp11', 'C-Customer Identification');
            }
            return ref;
        }
        
    }
    
    public void updateOppRecordType(){
        isExistingOpp = false;
        opp.RecordTypeId = selectedOpportunityRecordType;
    }
  
  //This function will cancel the action and redirect to Opportunity list view
    public PageReference cancel(){
        return new PageReference('/' + parentAccountId);
    }
}