global class ExistingTaskCount implements Database.Batchable<sObject>
       {
           
        global final String Query;
        
        Map<Id, List<Task>> mapAcctIdTaskList = new Map<Id, List<Task>>();
        Map<Id, List<Task>> mapAcctIdDelTaskList = new Map<Id, List<Task>>();
        Set<Id> AcctIds = new Set<Id>();    
        List<Account> listAcct = new List<Account>();
        List<Lead> listlead= new List<Lead>();
        Set<Id> leadids= new Set<Id>();  
        

            global ExistingTaskCount ()
            {
            id ids='001A000000z1uEHIAY';
            // BEGIN: S-444338, T-565663: Add TASK Record Type condition
            string taskrecordtype ='IAA Remarketing Task';
            query ='select id, whoid, accountid from task where accountid!=null and recordtype.name=\'' +taskrecordtype +'\'';// where accountid =\'' + ids + '\'';
            // END: S-444338, T-565663: Add TASK Record Type condition
            system.debug('query:'+query);
            }

            global Database.QueryLocator start(Database.BatchableContext BC)
            {
               return DataBase.getQueryLocator(query);

            }

            global void execute(Database.BatchableContext BC,List<Task> scope)
            {
                 //
            for(Task Tas : scope) {
                if(String.isNotBlank(Tas.AccountId)) {
                    if(!mapAcctIdTaskList.containsKey(Tas.AccountId)) {
                        mapAcctIdTaskList.put(Tas.AccountId, new List<Task>());
                        system.debug('!map:'+mapAcctIdTaskList);
                    }
                    mapAcctIdTaskList.get(Tas.AccountId).add(Tas); 
                    system.debug('mapAcctIdTaskList:'+mapAcctIdTaskList);
                    AcctIds.add(Tas.AccountId);
                    system.debug('!AcctIds:'+AcctIds);
                }   
                           }   
       
//
     if(AcctIds.size() > 0) {
            // BEGIN: S-444338, T-565663: Add Account Record Type condition
            listAcct = [SELECT Id, No_Of_Activities_Events__c, (SELECT accountid from ActivityHistories) FROM Account WHERE Id IN : AcctIds and IAARecordTypes__c='IAA Remarketing'];
            // END: S-444338, T-565663: Add Account Record Type condition
            for(Account acct : listAcct) {
                Integer noOfTasks=0;
                if(mapAcctIdTaskList.containsKey(acct.Id)) {
                if(mapAcctIdTaskList.get(acct.Id).size()>=0)
                    {            
                    noOfTasks += mapAcctIdTaskList.get(acct.Id).size();// + integer.valueOf(acct.No_Of_Activities_Events__c);
                   }
                }
                
                acct.No_Of_Activities_Events__c= noOfTasks  ;
              }
            
           upsert listAcct; 
}


}
///
            global void finish(Database.BatchableContext BC)
            {
           // system.debug('finsh:'+noOfTasks);
            }
       
       }