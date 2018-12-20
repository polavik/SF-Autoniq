global class ExistingTaskLeadCount implements Database.Batchable<sObject>
       {
           
        global final String Query;
        
        Map<Id, List<Task>> mapAcctIdTaskList = new Map<Id, List<Task>>();
        Map<Id, List<Task>> mapAcctIdDelTaskList = new Map<Id, List<Task>>();
        Set<Id> AcctIds = new Set<Id>();    
        List<Account> listAcct = new List<Account>();
        List<Lead> listlead= new List<Lead>();
        Set<Id> leadids= new Set<Id>();  
        

            global ExistingTaskLeadCount ()
            {
            id ids='001A000000z1uEHIAY';
            query ='select id, whoid, accountid from task where whoid!=null';// where accountid =\'' + ids + '\'';
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
               if(String.isNotBlank(Tas.whoid)) {
                    if(!mapAcctIdTaskList.containsKey(Tas.whoid)) {
                        mapAcctIdTaskList.put(Tas.whoid, new List<Task>());
                    }
                    mapAcctIdTaskList.get(Tas.whoid).add(Tas); 
                    leadids.add(Tas.whoid);
                }   
        }
 try
    {
        if(leadids.size() > 0) {
        //BEGIN : Task T-560440 - Inculded IAA Remarketing Record Type in IAAMigrate ORG]
            listLead = [SELECT Id, No_Of_Activities_Events__c,(SELECT whoid from ActivityHistories) FROM Lead WHERE Id IN : leadids and recordtype.name='IAA Remarketing'];
        //END: Task T-560440 - Inculded IAA Remarketing Record Type in IAAMigrate ORG]  
            for(Lead Lea : listLead) {
                 Integer noOfTasks = 0;
                if(mapAcctIdTaskList.containsKey(lea.Id)) {
                    noOfTasks += mapAcctIdTaskList.get(lea.Id).size();// + integer.valueOf(lea.No_Of_Activities_Events__c);
                }
                
                lea.No_Of_Activities_Events__c= noOfTasks ;
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
           // system.debug('finsh:'+noOfTasks);
            }
       
       }