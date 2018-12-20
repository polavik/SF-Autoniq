public with sharing class AFCRiskListController {
    public List<ContractSummary> contractSummaryList{get;set;}
    public Map<Id,ContractSummary> contractSummaryMap{get;set;}
    public Id selectedContract{get;set;}

    // for newcase pageblock
    public AFC_Collection_Case__c newCase{get;set;}

    // for aid pageblock
    public String selectedAssess{get;set;}
    public String selectedIdentify{get;set;}
    public String selectedDevelop{get;set;}

    public String minBalance{get;set;}
    public String maxBalance{get;set;}
    public String minPriority{get;set;}
    public String maxPriority{get;set;}
    public double minDefaultRisk{get;set;}

    public AFCRiskListController(){

        AFC_Radar_Settings__c settings = AFC_Radar_Settings__c.getInstance();
        minBalance = (settings.Minimum_Balance_Filter__c != null) ? String.valueOf(settings.Minimum_Balance_Filter__c) : '';
        maxBalance = (settings.Maximum_Balance_Filter__c != null) ? String.valueOf(settings.Maximum_Balance_Filter__c) : '';
        minPriority = (settings.Minimum_Priority_Filter__c != null) ? String.valueOf(settings.Minimum_Priority_Filter__c) : '';
        maxPriority = (settings.Maximum_Priority_Filter__c != null) ? String.valueOf(settings.Maximum_Priority_Filter__c) : '';
        minDefaultRisk = (settings.Minimum_Default_Risk__c != null) ? settings.Minimum_Default_Risk__c : 0.03;

        contractSummaryList = new List<ContractSummary>();
        contractSummaryMap = new Map<Id,ContractSummary>();

        loadRiskListData();
    }

    public void refreshSummary(){
        String contractId = ApexPages.currentPage().getParameters().get('contractid');
        selectedContract = contractId;
        newCase = new AFC_Collection_Case__c(AFC_Contract__c=contractId, AFC_Case_Status__c='Open');
    }

    public PageReference createCase(){
        ContractSummary cSummary = contractSummaryMap.get(selectedContract);
        newCase.AFC_Branch_Name__c = cSummary.contract.AFC_Branch__c;
        newCase.AFC_Region__c = cSummary.contract.AFC_Region__c;
        newCase.AFC_Division__c = cSummary.contract.AFC_Division__c;
        newCase.AFC_Country__c = cSummary.contract.AFC_Country__c;
        newCase.AFC_Risk_Group__c = cSummary.contract.AFC_Risk_Group__c;
        newCase.AFC_Yield_Group__c = cSummary.contract.AFC_Yield_Group__c;
        newCase.AFC_PLN__c = cSummary.contract.PLN__c;
        newCase.AFC_Principal_OS__c = cSummary.contract.Current_Principle_Amt_Oustanding__c;
        newCase.AFC_Product_Type__c = cSummary.contract.Product_Type__c;
        newCase.AFC_Type__c = cSummary.contract.AFC_Type__c;
        insert newCase;
        
        PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
        pageRef.setRedirect(true);
        return pageRef;

       // loadRiskListData();
    }

    private void loadRiskListData(){
        contractSummaryList.clear();
        contractSummaryMap.clear();
        // Get the open collections cases (cause we want ALL of those contracts, risky or not)
        Map<String,AFC_Collection_Case__c> caseMap = new Map<String,AFC_Collection_Case__c>();
        Set<String> openCaseStatuses = new Set<String>{'Open','In Review'};
        for(AFC_Collection_Case__c collectionCase : [select id, Name, AFC_Contract__c, CreatedDate, AFC_FU_date__c, AFC_Priority__c, AFC_Assess_Comments__c, AFC_Identify__c, AFC_Develop_Plan__c, OwnerId 
                                                        from AFC_Collection_Case__c where AFC_Case_Status__c in :openCaseStatuses order by CreatedDate desc]){
            caseMap.put(collectionCase.AFC_Contract__c,collectionCase);
        }

        // Get all the contracts that are connected to the open collections cases OR that are risk (have a high AFC_Default_Risk__c value)
        List<AFC_Contracts__c> contractList = [SELECT id, Name, AFC_Branch__c, AFC_Region__c, AFC_Division__c, AFC_Country__c, Account__c, Account__r.Name, AFC_Risk_Group__c, AFC_Yield_Group__c, 
                        Current_Principle_Amt_Oustanding__c, PLN__c, Product_Type__c, AFC_Type__c, AFC_Default_Risk__c from AFC_Contracts__c 
                        where id in :caseMap.keyset() order by AFC_Default_Risk__c desc limit 1000];
        Integer contractListSize = contractList.size();
        Integer remainingContractSpots = 1000 - contractListSize;

        Set<String> activeSet = new Set<String>{'ACTIVE','DORMANT'};
        // All contracts with current AFC Collections Cases
        contractList.addAll([SELECT id, Name, AFC_Branch__c, AFC_Region__c, AFC_Division__c, AFC_Country__c, Account__c, Account__r.Name, AFC_Risk_Group__c, AFC_Yield_Group__c, 
                        Current_Principle_Amt_Oustanding__c, PLN__c, Product_Type__c, AFC_Type__c, AFC_Default_Risk__c from AFC_Contracts__c 
                        where id not in :caseMap.keyset() and ((Contract_Status__c in :activeSet) and (AFC_Default_Risk__c > :minDefaultRisk)) order by AFC_Default_Risk__c desc limit :remainingContractSpots]);

        for(AFC_Contracts__c con : contractList){

            ContractSummary cs = new ContractSummary();            
            cs.contract = con;

            AFC_Collection_Case__c summaryCase = caseMap.get(con.Id);
            if(summaryCase != null){
                cs.openCase = summaryCase;
            }

            contractSummaryList.add(cs);
            contractSummaryMap.put(con.Id,cs);
        }
    }

    public class ContractSummary{
        public transient AFC_Contracts__c contract {get;set;}
        public AFC_Collection_Case__c openCase {get;set;}
    }
}