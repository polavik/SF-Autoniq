public with sharing class BusinessPlanGeneratorController{

    public class BranchSelectionWrapper{
        public AFC_Branch__c afcBranch{get;set;}
        public boolean selected{get;set;}
    }

    public String businessPlanYear{get;set;}
    public List<SelectOption> businessPlanYearOptions{get;set;}
    public List<AFC_Branch__c> plannedBranches{get;set;}
    public List<BranchSelectionWrapper> unplannedBranches{get;set;}
    public List<AFC_Business_Plan_Goal__c> businessPlanGoals{get;set;}
    
    public BusinessPlanGeneratorController(){
        DateTime dt = System.now().addYears(-1);
        businessPlanYearOptions = new List<SelectOption>();
        businessPlanYearOptions.add(new SelectOption(dt.format('YYYY'),dt.format('YYYY')));
        dt = dt.addYears(1);
        businessPlanYearOptions.add(new SelectOption(dt.format('YYYY'),dt.format('YYYY')));
        businessPlanYear = dt.format('YYYY');
        dt = dt.addYears(1);
        businessPlanYearOptions.add(new SelectOption(dt.format('YYYY'),dt.format('YYYY')));

        plannedBranches = new List<AFC_Branch__c>();
        unplannedBranches = new List<BranchSelectionWrapper>();

        loadBusinessPlanGoals(businessPlanYear);
        loadBusinessPlans(businessPlanYear);
    }

    public PageReference updatePlanYear(){
        loadBusinessPlanGoals(businessPlanYear);
        loadBusinessPlans(businessPlanYear);
        return new PageReference('/apex/businessplangenerator');
    }
    
    public PageReference generateBusinessPlans(){
        List<AFC_Business_Plan__c> newBusinessPlans = new List<AFC_Business_Plan__c>();
        for(BranchSelectionWrapper bw : unplannedBranches){
            if(bw.selected){
                newBusinessPlans.add(new AFC_Business_Plan__c(Year__c=businessPlanYear,AFC_Branch__c=bw.afcBranch.id,status__c='New',
                                        Name=businessPlanYear+' '+bw.afcBranch.Name+' Business Plan'));
            }
        }
        insert newBusinessPlans;

        List<AFC_Goal__c> goals = new List<AFC_Goal__c>();
        for(AFC_Business_Plan__c bp : newBusinessPlans){
            for(AFC_Business_Plan_Goal__c bpg : businessPlanGoals){
                goals.add(new AFC_Goal__c(AFC_Business_Plan__c = bp.id,Name=bpg.Name,Status__c='New',Level__c=bpg.Default_Level__c));
            }
        }
        insert goals;
        loadBusinessPlans(businessPlanYear);
        return null;
    }

    // Right now, this only gets branch goals...to be expanded later.
    private void loadBusinessPlanGoals(String businessPlanYear){
        List<AFC_Business_Plan_Goal__c> goals = [select id, name, Default_Level__c from AFC_Business_Plan_Goal__c where year__c = :businessPlanYear and active__c = true and branch_goal__c = true];
        businessPlanGoals = goals;
        if(businessPlanGoals == null || businessPlanGoals.size() == 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'No Business Plan Goals have been defined for '+businessPlanYear));            
        }
    }

    private void loadBusinessPlans(String businessPlanYear){
        plannedBranches.clear();
        unplannedBranches.clear();

        List<AFC_Branch__c> afcBranchList = [select id, name, Branch_Manager_1__c,(select id, name,AFC_Goals__c,Status__c,LastModifiedDate from AFC_Business_Plans__r where Year__c = :businessPlanYear limit 1) from AFC_Branch__c order by name];
        for(AFC_Branch__c branch : afcBranchList){
            if(branch.AFC_Business_Plans__r == null || branch.AFC_Business_Plans__r.size() == 0){
                BranchSelectionWrapper bw = new BranchSelectionWrapper();
                bw.afcBranch = branch;
                bw.selected = false;
                unplannedBranches.add(bw);
            } else {
                plannedBranches.add(branch);
            }
        }        
        if(unplannedBranches.size() == 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'All Business Plans have been created for '+businessPlanYear));            
        }
    }
}