//***********************************************************************************************************************************//
// Created by: John Britto S [jbritto]
// Created Date: 07-22-2016
// Description: 
// User Story 183008:Remarketing - New field to Count Activities on an Account
// User Story 183885:Remarketing - New field to Count Activities on an Lead
//***********************************************************************************************************************************//
trigger AccountActivityCountTrigger on Task(after insert,after update, after delete,after undelete)
{
 
     //Declarations
    Map<Id, List<Task>> mapAcctIdTaskList = new Map<Id, List<Task>>();
    Map<Id, List<Task>> mapAcctIdDelTaskList = new Map<Id, List<Task>>();
    Set<Id> AcctIds = new Set<Id>();    
    List<Account> listAcct = new List<Account>();
        List<Lead> listlead= new List<Lead>();
     Set<Id> leadids= new Set<Id>();  
    
    Map<ID,Schema.RecordTypeInfo> rt_Map = Task.sObjectType.getDescribe().getRecordTypeInfosById();
    try
    {
        //When TASK is inserted
        if(trigger.isInsert) {
            for(Task Tas : trigger.New) {
            // BEGIN: S-444338, T-565301 - Added to check TASK recordtype - IAA Remarketing Task
            if (rt_map.get(Tas.recordTypeID).getName().containsIgnoreCase('IAA Remarketing Task'))
            // End: S-444338, T-565301 - Added to check TASK recordtype - IAA Remarketing Task
            {
                if(String.isNotBlank(Tas.AccountId)) {
                    if(!mapAcctIdTaskList.containsKey(Tas.AccountId)) {
                        mapAcctIdTaskList.put(Tas.AccountId, new List<Task>());
                    }
                    mapAcctIdTaskList.get(Tas.AccountId).add(Tas); 
                    AcctIds.add(Tas.AccountId);
                }   
            else if(String.isNotBlank(Tas.whoid)) {
                    if(!mapAcctIdTaskList.containsKey(Tas.whoid)) {
                        mapAcctIdTaskList.put(Tas.whoid, new List<Task>());
                    }
                    mapAcctIdTaskList.get(Tas.whoid).add(Tas); 
                    leadids.add(Tas.whoid);
                }   
        }
        }
        }

        
        //when TASK is updated
        if(trigger.isUpdate) {
            for(Task Tas : trigger.New) {
            // BEGIN: S-444338, T-565301 - Added to check TASK recordtype - IAA Remarketing Task
            if (rt_map.get(Tas.recordTypeID).getName().containsIgnoreCase('IAA Remarketing Task'))
            // End: S-444338, T-565301 - Added to check TASK recordtype - IAA Remarketing Task
            {
                if(String.isNotBlank(Tas.AccountId) && Tas.AccountId != trigger.oldMap.get(Tas.Id).AccountId) {
                    if(!mapAcctIdTaskList.containsKey(Tas.AccountId)){
                        mapAcctIdTaskList.put(Tas.AccountId, new List<Task>());
                    }
                    mapAcctIdTaskList.get(Tas.AccountId).add(Tas); 
                    AcctIds.add(Tas.AccountId);
                } else if(String.isBlank(Tas.AccountId) && String.isNotBlank(trigger.oldMap.get(Tas.Id).AccountId)) {
                    if(!mapAcctIdDelTaskList.containsKey(Tas.AccountId)){
                        mapAcctIdDelTaskList.put(Tas.AccountId, new List<Task>());
                    }
                    mapAcctIdDelTaskList.get(Tas.AccountId).add(Tas);   
                    AcctIds.add(trigger.oldMap.get(Tas.Id).AccountId);
                }
             else if (String.isNotBlank(Tas.whoid) && Tas.whoid!= trigger.oldMap.get(Tas.Id).whoid) {
                    if(!mapAcctIdTaskList.containsKey(Tas.whoid)){
                        mapAcctIdTaskList.put(Tas.whoid, new List<Task>());
                    }
                    mapAcctIdTaskList.get(Tas.whoid).add(Tas); 
                    leadids.add(Tas.whoid);
                } else if(String.isBlank(Tas.whoid) && String.isNotBlank(trigger.oldMap.get(Tas.Id).whoid)) {
                    if(!mapAcctIdDelTaskList.containsKey(Tas.whoid)){
                        mapAcctIdDelTaskList.put(Tas.whoid, new List<Task>());
                    }
                    mapAcctIdDelTaskList.get(Tas.whoid).add(Tas);   
                    leadids.add(trigger.oldMap.get(Tas.Id).whoid);
                }
            }  
           } 
        }
      
        //When TASK is restored from Recycle bin
        if(trigger.isUndelete) {
            for(Task Tas : trigger.New) {
            // BEGIN: S-444338, T-565301 - Added to check TASK recordtype - IAA Remarketing Task
            if (rt_map.get(Tas.recordTypeID).getName().containsIgnoreCase('IAA Remarketing Task'))
            // End: S-444338, T-565301 - Added to check TASK recordtype - IAA Remarketing Task
            {
                if(String.isNotBlank(Tas.AccountId)){
                    if(!mapAcctIdTaskList.containsKey(Tas.AccountId)){
                        mapAcctIdTaskList.put(Tas.AccountId, new List<Task>());
                    }
                    mapAcctIdTaskList.get(Tas.AccountId).add(Tas);     
                    AcctIds.add(Tas.AccountId);
                }
              else if(String.isNotBlank(Tas.whoid)){
                    if(!mapAcctIdTaskList.containsKey(Tas.whoid)){
                        mapAcctIdTaskList.put(Tas.whoid, new List<Task>());
                    }
                    mapAcctIdTaskList.get(Tas.whoid).add(Tas);     
                    leadids.add(Tas.whoid);
                }
            } 
         }
         }
        
        //When TASK is Deleted
        if(trigger.isDelete) {
            for(Task Tas : trigger.Old) {
            // BEGIN: S-444338, T-565301 - Added to check TASK recordtype - IAA Remarketing Task
            if (rt_map.get(Tas.recordTypeID).getName().containsIgnoreCase('IAA Remarketing Task'))
            // End: S-444338, T-565301 - Added to check TASK recordtype - IAA Remarketing Task
            {
                if(String.isNotBlank(Tas.AccountId)){
                    if(!mapAcctIdDelTaskList.containsKey(Tas.AccountId)){
                        mapAcctIdDelTaskList.put(Tas.AccountId, new List<Task>());
                    }
                    mapAcctIdDelTaskList.get(Tas.AccountId).add(Tas);    
                    AcctIds.add(Tas.AccountId); 
                }
             else if(String.isNotBlank(Tas.whoid)){
                    if(!mapAcctIdDelTaskList.containsKey(Tas.whoid)){
                        mapAcctIdDelTaskList.put(Tas.whoid, new List<Task>());
                    }
                    mapAcctIdDelTaskList.get(Tas.whoid).add(Tas);    
                    leadids.add(Tas.whoid); 
                }
            }
            }
            }
        
    }Catch(system.nullpointerexception NE)    
     {
     system.debug('Error on Trigger events on No. of Activities for an Account: '+ NE.getmessage());
     } 
    
    //*********************************************BEGIN: Update No of Activities/Events field in Account object*****************************************//
    try
    {
        if(AcctIds.size() > 0) {

             // BEGIN: S-444338, T-565301 - Added to check Account recordtype - Remarketing
            listAcct = [SELECT Id, No_Of_Activities_Events__c FROM Account WHERE Id IN : AcctIds and IAARecordTypes__c='IAA Remarketing'];
            // END: S-444338, T-565301 - Added to check Account recordtype - Remarketing

            for(Account acct : listAcct) {
                Integer noOfTasks = 0;
                if(mapAcctIdTaskList.containsKey(acct.Id)) {
                    noOfTasks += mapAcctIdTaskList.get(acct.Id).size();
                }
                if(mapAcctIdDelTaskList.containsKey(acct.Id)) {
                    noOfTasks -= mapAcctIdDelTaskList.get(acct.Id).size();
                }
                acct.No_Of_Activities_Events__c= acct.No_Of_Activities_Events__c == null ? noOfTasks : (acct.No_Of_Activities_Events__c + noOfTasks);
            }
            
            update listAcct;    
        }
     }Catch(DMLException DM)    
     {
     system.debug('Error on while updating No. of Activities for an Account: '+ DM.getmessage());
     } 
    //*********************************************END: Update No of Activities/Events field in Account object*****************************************//     

    //*********************************************BEGIN:Update No. of Activities/Events field in LEAD Object*****************************************//
    try
    {
        if(leadids.size() > 0) {
        
            // BEGIN: S-444338, T-565301 - Added to check LEAD recordtype - IAA Remarketing
            listLead = [SELECT Id, No_Of_Activities_Events__c FROM Lead WHERE Id IN : leadids and recordtype.name='IAA Remarketing'];
            // END: S-444338, T-565301 - Added to check LEAD recordtype - IAA Remarketing
            
            for(Lead Lea : listLead) {
                Integer noOfTasks = 0;
                if(mapAcctIdTaskList.containsKey(lea.Id)) {
                    noOfTasks += mapAcctIdTaskList.get(lea.Id).size();
                }
                if(mapAcctIdDelTaskList.containsKey(lea.Id)) {
                    noOfTasks -= mapAcctIdDelTaskList.get(lea.Id).size();
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