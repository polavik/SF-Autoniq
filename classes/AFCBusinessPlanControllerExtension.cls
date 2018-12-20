public with sharing class AFCBusinessPlanControllerExtension {
    public Id businessPlanId{get;set;}
    public AFC_Business_Plan__c businessPlan{get;set;}
    public List<AFC_Goal__c> businessPlanGoals{get;set;}
    public Map<Id,AFC_Goal_Action__c> newGoalActionsMap{get;set;}

    public AFC_Goal_Action__c newGoalAction{get;set;}
    public Id newActionGoalId{get;set;}

    // In the case where a person is responsible for more than one business plan
    public List<SelectOption> businessPlanOptions{get;set;}
    public String selectedBusinessPlan{get;set;}

    public AFCBusinessPlanControllerExtension(ApexPages.StandardController controller) {
        businessPlanId = controller.getId();
        if(businessPlanId == null){
            List<AFC_Business_Plan__c> businessPlans = [SELECT id, name from AFC_Business_Plan__c order by name]; 
                                                       // where AFC_Branch__r.Branch_Manager_1__c = :UserInfo.getUserId()];
            if(businessPlans.size() > 1){
                businessPlanOptions = new List<SelectOption>();
                businessPlanOptions.add(new SelectOption('000000000000000000','-- Please Select --',true));
                selectedBusinessPlan = businessPlanOptions[0].getValue();
                for(AFC_Business_Plan__c bp : businessPlans){
                    businessPlanOptions.add(new SelectOption(bp.id,bp.name));
                }

            } else if (businessPlans.size() == 1){
                businessPlanId = businessPlans[0].id;
            }
        }

        if(businessPlanId != null){
            loadData(businessPlanId);
            newGoalActionsMap = new Map<Id,AFC_Goal_Action__c>();
            for(AFC_Goal__c goal:businessPlanGoals){
                newGoalActionsMap.put(goal.id,new AFC_Goal_Action__c(Status__c='New',AFC_Goal__c=goal.id));
            }
        }
    }

    public PageReference addAction(){
        String goalId = Apexpages.currentPage().getParameters().get('goalid');
        AFC_Goal_Action__c newGoalAction = newGoalActionsMap.get(goalId);
        insert newGoalAction;
        loadData(businessPlanId);
        newGoalActionsMap.put(Id.valueOf(goalId),new AFC_Goal_Action__c(Status__c='New', AFC_Business_Plan__c=businessPlan.id,AFC_Goal__c=Id.valueOf(goalId)));
        newActionGoalId = null;
        return null;
    }

    public PageReference selectBusinessPlan(){
        PageReference pageRef = new PageReference('/apex/afcbusinessplan?id='+selectedBusinessPlan);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference saveAllChanges(){
        System.debug('*****inhere');
        List<AFC_Goal_Action__c> businessPlanGoalActions = new List<AFC_Goal_Action__c>();
        for(AFC_Goal__c goal : businessPlanGoals){
            businessPlanGoalActions.addAll(goal.AFC_Goal_Actions__r);
        }
        if(newActionGoalId != null){
            businessPlanGoalActions.add(newGoalActionsMap.get(newActionGoalId));
            newGoalActionsMap.put(newActionGoalId,new AFC_Goal_Action__c(Status__c='New',AFC_Goal__c=newActionGoalId));
            newActionGoalId = null;
        }
        System.debug('*****upserting '+businessPlanGoalActions.size()+' Goal Actions');
        System.debug('*****'+businessPlanGoalActions);
        upsert businessPlanGoalActions;
        loadData(businessPlanId);
        PageReference pageRef = new PageReference('/apex/afcbusinessplan?id='+businessPlan.id);
        pageRef.setRedirect(true);
        return pageRef;
//        return new PageReference('/apex/afcbusinessplan?id='+businessPlan.id);
    }

    public PageReference cancelAllChanges(){
        newActionGoalId = null;
        loadData(businessPlan.id);

        return null;
    }

    public PageReference submitForApproval(){
        // Create an approval request for the account
        try{
            update businessPlanGoals;
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(businessPlan.id);      
            req1.setSubmitterId(UserInfo.getUserId());
            Approval.process(req1);
            loadData(businessPlan.id);
            return null;        
        } catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An error has occurred updating your goal levels.'));
            return null;
        }
    }

    private void loadData(Id businessPlanId){
        businessPlan = [SELECT AFC_Goals__c, AFC_Goals_Completed__c, AFC_Branch__c, AFC_Branch__r.Name,Name, Area_Sales_Manager__c, Branch_Manager__c, Comments__c, 
                            CreatedById, CreatedDate, LastModifiedById, LastModifiedDate, Id, RecordTypeId, Status__c, Year__c 
                            from AFC_Business_Plan__c where id = :businessPlanId order by name];

        businessPlanGoals = [SELECT Goal_Actions__c, Goal_Actions_Completed__c, AFC_Business_Plan__c, Name, Achieve_Percent_Current__c, Audience__c, Comments__c, CreatedById, CreatedDate, 
                                Diversification_Percentage__c, Goal_Type__c, Is_Percentage__c, LastModifiedById, LastModifiedDate, Level__c, Id, Short_Description__c, 
                                Status__c, SystemModstamp, Unit_Amount__c,
                                (select name, Achieve_What__c, Start_Date__c,End_Date__c,AFC_Goal__c,Who_is_responsible__c,status__c,Actual_Performance__c,
                                    Success_Criteria__c,description__c,Acheived_When__c, Progress__c from AFC_Goal_Actions__r order by End_Date__c)
                                FROM AFC_Goal__c where AFC_Business_Plan__c = :businessPlanId order by Name];
    }
}