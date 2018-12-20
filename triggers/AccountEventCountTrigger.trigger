//***********************************************************************************************************************************//
// Created by: John Britto S [jbritto]
// Created Date: 07-22-2016
// Description: 
// User Story 183008:Remarketing - New field to Count Activities on an Account
// User Story 183885:Remarketing - New field to Count Activities on an Lead
//***********************************************************************************************************************************//
trigger AccountEventCountTrigger on Event(after insert,after update, after delete,after undelete)
{
    Map<Id, List<Event>> mapAcctIdEventList = new Map<Id, List<Event>>();
    Map<Id, List<Event>> mapAcctIdDelEventList = new Map<Id, List<Event>>();
    Set<Id> AcctIds = new Set<Id>();    
    List<Account> listAcct = new List<Account>();
    
    List<Lead> listlead= new List<Lead>();
    Set<Id> leadids= new Set<Id>();  
    
    // BEGIN: S-444338, T-565302 - Added to check EVENT recordtype - IAA Remarketing Event
    Map<ID,Schema.RecordTypeInfo> rt_Map = Event.sObjectType.getDescribe().getRecordTypeInfosById();
        
    try
    {
        //When EVENT is inserted
        if(trigger.isInsert) {
            for(Event Even : trigger.New) {
            // BEGIN: S-444338, T-565302 - Added to check EVENT recordtype - IAA Remarketing Event
            if (rt_map.get(Even.recordTypeID).getName().containsIgnoreCase('IAA Remarketing Event'))
            // End: S-444338, T-565302 - Added to check EVENt recordtype - IAA Remarketing Event
            {
                if(String.isNotBlank(Even.AccountId)) {
                    if(!mapAcctIdEventList.containsKey(Even.AccountId)) {
                        mapAcctIdEventList.put(Even.AccountId, new List<Event>());
                    }
                    mapAcctIdEventList.get(Even.AccountId).add(Even); 
                    AcctIds.add(Even.AccountId);
                } else if(String.isNotBlank(Even.whoid)) {
                    if(!mapAcctIdEventList.containsKey(Even.whoid)) {
                        mapAcctIdEventList.put(Even.whoid, new List<Event>());
                    }
                    mapAcctIdEventList.get(Even.whoid).add(Even); 
                    leadids.add(Even.whoid);
            }  
        }
        }
        }
            
        //when EVENT is updated
        if(trigger.isUpdate) {
            for(Event Even : trigger.New) {
            // BEGIN: S-444338, T-565302 - Added to check EVENT recordtype - IAA Remarketing Event
            if (rt_map.get(Even.recordTypeID).getName().containsIgnoreCase('IAA Remarketing Event'))
            // End: S-444338, T-565302 - Added to check EVENt recordtype - IAA Remarketing Event
            {
                if(String.isNotBlank(Even.AccountId) && Even.AccountId != trigger.oldMap.get(Even.Id).AccountId) {
                    if(!mapAcctIdEventList.containsKey(Even.AccountId)){
                        mapAcctIdEventList.put(Even.AccountId, new List<Event>());
                    }
                    mapAcctIdEventList.get(Even.AccountId).add(Even); 
                    AcctIds.add(Even.AccountId);
                    
                } else if(String.isBlank(Even.AccountId) && String.isNotBlank(trigger.oldMap.get(Even.Id).AccountId)) {
                    if(!mapAcctIdDelEventList.containsKey(Even.AccountId)){
                        mapAcctIdDelEventList.put(Even.AccountId, new List<Event>());
                    }
                    mapAcctIdDelEventList.get(Even.AccountId).add(Even);   
                    AcctIds.add(trigger.oldMap.get(Even.Id).AccountId);
                }
          else if (String.isNotBlank(even.whoid) && even.whoid!= trigger.oldMap.get(even.Id).whoid) {
                    if(!mapAcctIdEventList.containsKey(even.whoid)){
                        mapAcctIdEventList.put(even.whoid, new List<event>());
                    }
                    mapAcctIdEventList.get(even.whoid).add(even); 
                    leadids.add(even.whoid);
                    
                } else if(String.isBlank(even.whoid) && String.isNotBlank(trigger.oldMap.get(even.Id).whoid)) {
                    if(!mapAcctIdDelEventList.containsKey(even.whoid)){
                        mapAcctIdDelEventList.put(even.whoid, new List<event>());
                    }
                    mapAcctIdDelEventList.get(even.whoid).add(even);   
                    leadids.add(trigger.oldMap.get(even.Id).whoid);
                }
            }  
          }  
        }      
        
        //When EVENT is restored from Recycle bin
        if(trigger.isUndelete) {
            for(Event Even : trigger.New) {
            // BEGIN: S-444338, T-565302 - Added to check EVENT recordtype - IAA Remarketing Event
              if (rt_map.get(Even.recordTypeID).getName().containsIgnoreCase('IAA Remarketing Event'))
            // End: S-444338, T-565302 - Added to check EVENt recordtype - IAA Remarketing Event
            {
                if(String.isNotBlank(Even.AccountId)){
                    if(!mapAcctIdEventList.containsKey(Even.AccountId)){
                        mapAcctIdEventList.put(Even.AccountId, new List<Event>());
                    }
                    mapAcctIdEventList.get(Even.AccountId).add(Even);     
                    AcctIds.add(Even.AccountId);
                } else if(String.isNotBlank(Even.whoid)){
                    if(!mapAcctIdEventList.containsKey(Even.whoid)){
                        mapAcctIdEventList.put(Even.whoid, new List<Event>());
                    }
                    mapAcctIdEventList.get(Even.whoid).add(Even);     
                    leadids.add(Even.whoid);
                }
            }  
        }
        }
        
        //When EVENT is Deleted
        if(trigger.isDelete) {
            for(Event Even : trigger.Old) {
            // BEGIN: S-444338, T-565302 - Added to check EVENT recordtype - IAA Remarketing Event
             if (rt_map.get(Even.recordTypeID).getName().containsIgnoreCase('IAA Remarketing Event'))
            // End: S-444338, T-565302 - Added to check EVENt recordtype - IAA Remarketing Event
            {
                if(String.isNotBlank(Even.AccountId)){
                    if(!mapAcctIdDelEventList.containsKey(Even.AccountId)){
                        mapAcctIdDelEventList.put(Even.AccountId, new List<Event>());
                    }
                    mapAcctIdDelEventList.get(Even.AccountId).add(Even);    
                    AcctIds.add(Even.AccountId); 
                    
                } else if(String.isNotBlank(Even.whoid)){
                    if(!mapAcctIdDelEventList.containsKey(Even.whoid)){
                        mapAcctIdDelEventList.put(Even.whoid, new List<Event>());
                    }
                    mapAcctIdDelEventList.get(Even.whoid).add(Even);    
                    leadids.add(Even.whoid); 
            }  
        }   
        }
        }
        
    }Catch(system.nullpointerexception NE)    
     {
     system.debug('Error on Trigger events on No. of Events for an Account: '+ NE.getmessage());
     } 
    
    //*********************************************BEGIN:  Update No of Activities/Events field in Account object**********************************************//
    try
    {
        if(AcctIds.size() > 0) {
            // BEGIN: S-444338, T-565302 - Added to check Account recordtype - Remarketing
            listAcct = [SELECT Id, No_Of_Activities_Events__c FROM Account WHERE Id IN : AcctIds and IAARecordTypes__c='IAA Remarketing'];
            // END: S-444338, T-565302 - Added to check Account recordtype - Remarketing
            
            for(Account acct : listAcct) {
                Integer noOfEvents = 0;
                if(mapAcctIdEventList.containsKey(acct.Id)) {
                    noOfEvents += mapAcctIdEventList.get(acct.Id).size();
                }
                if(mapAcctIdDelEventList.containsKey(acct.Id)) {
                    noOfEvents -= mapAcctIdDelEventList.get(acct.Id).size();
                }
                acct.No_Of_Activities_Events__c= acct.No_Of_Activities_Events__c == null ? noOfEvents : (acct.No_Of_Activities_Events__c + noOfEvents);
            }
            
            update listAcct;    
        }
     }Catch(DMLException DM)    
     {
     system.debug('Error on while updating No. of Events for an Account: '+ DM.getmessage());
     }
    //*********************************************END:  Update No of Activities/Events field in Account object**********************************************//
     
     
    //*********************************************BEGIN:Update No. of Activities/Events field in LEAD Object*****************************************//   
    try
    {
        if(leadids.size() > 0) {
            // BEGIN: S-444338, T-565302 - Added to check LEAD recordtype - IAA Remarketing
            listLead = [SELECT Id, No_Of_Activities_Events__c FROM Lead WHERE Id IN : leadids and recordtype.name='IAA Remarketing'];
            // END: S-444338, T-565302 - Added to check LEAD recordtype - IAA Remarketing
            
            for(Lead Lea : listLead) {
                Integer noOfTasks = 0;
                if(mapAcctIdEventList.containsKey(lea.Id)) {
                    noOfTasks += mapAcctIdEventList.get(lea.Id).size();
                }
                if(mapAcctIdDelEventList.containsKey(lea.Id)) {
                    noOfTasks -= mapAcctIdDelEventList.get(lea.Id).size();
                }
                lea.No_Of_Activities_Events__c= lea.No_Of_Activities_Events__c == null ? noOfTasks : (lea.No_Of_Activities_Events__c + noOfTasks);
            }
            
            update listLead;    
        }
     }Catch(DMLException DM)    
     {
     system.debug('Error on while updating No. of Activities for an LEAD: '+ DM.getmessage());
     }  
     //*********************************************END:Update No. of Activities/Events field in LEAD Object*****************************************//    
       
}