public class TaskTriggerHandler {
    
    private static final String ADESA_DST_CLOSE_RT = 'ADESA_DST_CLOSE';
    private static List<String> DISCARDED_STAGE;
    static {
        DISCARDED_STAGE = new List<String>();
        DISCARDED_STAGE.add('Closed Won');
        DISCARDED_STAGE.add('Closed Lost');
        DISCARDED_STAGE.add('Closed Not Qualified');
    }
    
    
    
    public static void onBeforeInsert(List<Task> newList) {
        List<Task> taskToProcess = new List<Task>();
        List<Id> opportunityIds = new List<Id>();
        Map<Id, List<Task>> OpportunityTaskMap = new Map<Id, List<Task>>();
        for(Task newTasks : newList) {
            
            if(String.valueOf(newTasks.WhatId) != null && String.valueOf(newTasks.WhatId).startsWith('006')) {
                taskToProcess.add(newTasks);
                opportunityIds.add(newTasks.WhatId);
                if(!OpportunityTaskMap.containsKey(newTasks.WhatId)) {
                    OpportunityTaskMap.put(newTasks.WhatId, new List<Task>());
                }
                
                List<Task> oldTaskList = OpportunityTaskMap.get(newTasks.WhatId);
                oldTaskList.add(newTasks);
                OpportunityTaskMap.put(newTasks.WhatId, oldTaskList);
            }
        }
        
        if(!taskToProcess.isEmpty()) {
            processTasksToUpdateOpportunity(OpportunityTaskMap, taskToProcess, opportunityIds);
        }
    }
    
    private static void processTasksToUpdateOpportunity(Map<Id, List<Task>> OpportunityTaskMap, List<Task> opportunityTasks, List<Id> opportunityIds) {
        
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        Map<Id, Opportunity> finalOppId = new Map<Id, Opportunity>();
        Map<Id, Event> existingEventonOpportunity = new Map<Id, Event>();
        for(Opportunity thisOpportunity : [SELECT Id, Days_To_Contact__c, createdDate FROM Opportunity WHERE RecordType.DeveloperName =: ADESA_DST_CLOSE_RT
                                                                                        AND StageName NOT IN: DISCARDED_STAGE
                                                                                        AND Days_To_Contact__c = null
                                                                                        AND Id IN :opportunityIds]) {
            finalOppId.put(thisOpportunity.Id, thisOpportunity);
                                                
        }
        
        if(!finalOppId.isEmpty()) {
        
            for(Task thisTask : [SELECT Id, WhatId FROM Task WHERE WhatId IN :finalOppId.KeySet()]) {
                List<Task> oldTaskList = OpportunityTaskMap.get(thisTask.WhatId);
                oldTaskList.add(thisTask);
                OpportunityTaskMap.put(thisTask.WhatId, oldTaskList);
            }
            
            for(Event thisEvent : [SELECT Id, WhatId FROM Event WHERE WhatId IN :finalOppId.KeySet()]) {
                existingEventonOpportunity.put(thisEvent.WhatId, thisEvent);
            }
            
            for(Id oppId : OpportunityTaskMap.keySet()) {
                if(OpportunityTaskMap.get(oppId).size() == 1 && !existingEventonOpportunity.containsKey(oppId)) {
                    Opportunity currentOpp = finalOppId.get(oppId);
                    DateTime dt = finalOppId.get(oppId).createdDate;
                    Date opportunityCreatedDate = date.newinstance(dT.year(), dT.month(), dT.day());
                    currentOpp.Days_To_Contact__c = opportunityCreatedDate.daysBetween(System.Today());
                    oppToUpdate.add(currentOpp);
                }
            }
        
        }
        
        if(!oppToUpdate.isEmpty()) {
            try {
                update oppToUpdate;
            }catch(Exception ex) {
                system.debug('Exception :: '  + ex.getMessage());
            }
        }
        
    }
}