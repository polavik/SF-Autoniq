global class ExistingeventCount implements Database.Batchable<sObject>
       {
            global final String Query;
                Map<Id, List<event>> mapAcctIdTaskList = new Map<Id, List<event>>();
    Map<Id, List<event>> mapAcctIdDelTaskList = new Map<Id, List<event>>();
Map<Id, List<Event>> mapAcctIdEventList = new Map<Id, List<Event>>();
    Map<Id, List<Event>> mapAcctIdDelEventList = new Map<Id, List<Event>>();
    Set<Id> AcctIds = new Set<Id>();    
    List<Account> listAcct = new List<Account>();
    
 List<Lead> listlead= new List<Lead>();
    Set<Id> leadids= new Set<Id>();  
    
            global ExistingeventCount ()
            {
               // BEGIN: S-444338, T-565661: Add EVENT Record Type condition
               string eventrecordtype ='IAA Remarketing Event';
               Query='select id, accountid, whoid from event where recordtype.name =\'' + eventrecordtype +'\'';
               // END: S-444338, T-565661: Add EVENT Record Type condition
            }

            global Database.QueryLocator start(Database.BatchableContext BC)
            {
               return Database.getQueryLocator(query);
            }

            global void execute(Database.BatchableContext BC,List<event> scope)
            {
                  for(Event Even : scope) {
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
            system.debug('Even.whoid:'+leadids);
                        system.debug('Even.AccountId:'+AcctIds);
        }
//
 if(AcctIds.size() > 0) {
            // BEGIN: S-444338, T-565661: Add ACCOUNT Record Type condition
            listAcct = [SELECT Id, No_Of_Activities_Events__c,(SELECT accountid from ActivityHistories) FROM Account WHERE Id IN : AcctIds and IAARecordTypes__c='IAA Remarketing'];
            // END: S-444338, T-565661: Add ACCOUNT Record Type condition
            
            for(Account acct : listAcct) {
                Integer noOfTasks = 0;
                if(mapAcctIdEventList.containsKey(acct.Id)) {
                    noOfTasks += mapAcctIdEventList.get(acct.Id).size();
                    system.debug('nooftasks:'+noOfTasks );
                }
                acct.No_Of_Activities_Events__c= acct.No_Of_Activities_Events__c == null ? noOfTasks : (acct.No_Of_Activities_Events__c + noOfTasks);
system.debug('No_Of_Activities_Events__c:'+acct.No_Of_Activities_Events__c);           
                }
            
            update listAcct; 
}

//
try
    {
        if(leadids.size() > 0) {
            listLead = [SELECT Id, No_Of_Activities_Events__c,(SELECT whoid from ActivityHistories) FROM Lead WHERE Id IN : leadids];
            
            for(Lead Lea : listLead) {
                Integer noOfTasks = 0;
                if(mapAcctIdEventList.containsKey(lea.Id)) {
                    noOfTasks += mapAcctIdEventList.get(lea.Id).size();
                }
                
                lea.No_Of_Activities_Events__c= lea.No_Of_Activities_Events__c == null ? noOfTasks : (lea.No_Of_Activities_Events__c + noOfTasks);
            }
            
            update listLead;    
        }
     }Catch(DMLException DM)    
     {
     system.debug('Error on while updating No. of Activities for an LEAD: '+ DM.getmessage());
     }  

//



}
///
            global void finish(Database.BatchableContext BC)
            {
            }
       
       }