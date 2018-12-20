public class EventTriggerHandler {
    
    private static final String ADESA_DST_CLOSE_RT = 'ADESA_DST_CLOSE';
    private static List<String> DISCARDED_STAGE;
    static {
        DISCARDED_STAGE = new List<String>();
        DISCARDED_STAGE.add('Closed Won');
        DISCARDED_STAGE.add('Closed Lost');
        DISCARDED_STAGE.add('Closed Not Qualified');
    }
    
    
    
    public static void onBeforeInsert(List<Event> newList) {
        List<Event> EventToProcess = new List<Event>();
        List<Id> opportunityIds = new List<Id>();
        Map<Id, List<Event>> OpportunityEventMap = new Map<Id, List<Event>>();
        for(Event newEvents : newList) {
            
            if(String.valueOf(newEvents.WhatId) != null && String.valueOf(newEvents.WhatId).startsWith('006')) {
                EventToProcess.add(newEvents);
                opportunityIds.add(newEvents.WhatId);
                if(!OpportunityEventMap.containsKey(newEvents.WhatId)) {
                    OpportunityEventMap.put(newEvents.WhatId, new List<Event>());
                }
                
                List<Event> oldEventList = OpportunityEventMap.get(newEvents.WhatId);
                oldEventList.add(newEvents);
                OpportunityEventMap.put(newEvents.WhatId, oldEventList);
            }
        }
        
        if(!EventToProcess.isEmpty()) {
            processEventsToUpdateOpportunity(OpportunityEventMap, EventToProcess, opportunityIds);
        }
    }
    
    private static void processEventsToUpdateOpportunity(Map<Id, List<Event>> OpportunityEventMap, List<Event> opportunityEvents, List<Id> opportunityIds) {
        
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        Map<Id, Opportunity> finalOppId = new Map<Id, Opportunity>();
        //List<Task> existingTaskonOpportunity = new List<Task>();
        Map<Id, Task> existingTaskonOpportunity = new Map<Id, Task>();
        for(Opportunity thisOpportunity : [SELECT Id, Days_To_Contact__c, createdDate FROM Opportunity WHERE RecordType.DeveloperName =: ADESA_DST_CLOSE_RT
                                                                                        AND StageName NOT IN: DISCARDED_STAGE
                                                                                        AND Days_To_Contact__c = null
                                                                                        AND Id IN :opportunityIds]) {
            finalOppId.put(thisOpportunity.Id, thisOpportunity);
                                                
        }
        
        if(!finalOppId.isEmpty()) {
        
            for(Event thisEvent : [SELECT Id, WhatId FROM Event WHERE WhatId IN :finalOppId.KeySet()]) {
                List<Event> oldEventList = OpportunityEventMap.get(thisEvent.WhatId);
                oldEventList.add(thisEvent);
                OpportunityEventMap.put(thisEvent.WhatId, oldEventList);
            }
            
            for(Task thisTask : [SELECT Id, WhatId FROM Task WHERE WhatId IN :finalOppId.KeySet()]) {
                existingTaskonOpportunity.put(thisTask.WhatId, thisTask);
            }
            
            for(Id oppId : OpportunityEventMap.keySet()) {
                if(OpportunityEventMap.get(oppId).size() == 1 && !existingTaskonOpportunity.containsKey(oppId)) {
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