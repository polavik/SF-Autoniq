global without sharing class DataConflictAudit implements Schedulable {
	global Integer threshhold = 3;
	global List<Id> accountIdList;
	global List<Id> creatorIdList;

	public DataConflictAudit() {
		accountIdList = new List<Id>();
		creatorIdList = new List<Id>();
	}

	public DataConflictAudit(List<Id> accountIdList, List<Id> creatorIdList){
		this();
		this.accountIdList = accountIdList;
		this.creatorIdList = creatorIdList;
	}


	global static void run(){
		List<Account> accountList = [select id from Account where Data_Conflict_Checked__c != true limit 4000];

		List<Id> account1 = new List<Id>();
		for(Integer i=0;i<400;i++){
			account1.add(accountList[i].Id);
		}
		List<Id> account2 = new List<Id>();
		for(Integer i=400;i<800;i++){
			account2.add(accountList[i].Id);
		}
		List<Id> account3 = new List<Id>();
		for(Integer i=800;i<1200;i++){
			account3.add(accountList[i].Id);
		}
		List<Id> account4 = new List<Id>();
		for(Integer i=1200;i<1600;i++){
			account4.add(accountList[i].Id);
		}
		List<Id> account5 = new List<Id>();
		for(Integer i=1600;i<2000;i++){
			account5.add(accountList[i].Id);
		}	
		List<Id> account6 = new List<Id>();
		for(Integer i=2000;i<2400;i++){
			account6.add(accountList[i].Id);
		}
		List<Id> account7 = new List<Id>();
		for(Integer i=2400;i<2800;i++){
			account7.add(accountList[i].Id);
		}
		List<Id> account8 = new List<Id>();
		for(Integer i=2800;i<3200;i++){
			account8.add(accountList[i].Id);
		}
		List<Id> account9 = new List<Id>();
		for(Integer i=3200;i<3600;i++){
			account9.add(accountList[i].Id);
		}
		List<Id> account10 = new List<Id>();
		for(Integer i=3600;i<4000;i++){
			account10.add(accountList[i].Id);
		}	
		DataConflictAudit job1 = new DataConflictAudit(account1,new List<Id>{'00530000006GQnC','0051300000BHK96AAH'});
		DataConflictAudit job2 = new DataConflictAudit(account2,new List<Id>{'00530000006GQnC','0051300000BHK96AAH'});
		DataConflictAudit job3 = new DataConflictAudit(account3,new List<Id>{'00530000006GQnC','0051300000BHK96AAH'});
		DataConflictAudit job4 = new DataConflictAudit(account4,new List<Id>{'00530000006GQnC','0051300000BHK96AAH'});
		DataConflictAudit job5 = new DataConflictAudit(account5,new List<Id>{'00530000006GQnC','0051300000BHK96AAH'});
		DataConflictAudit job6 = new DataConflictAudit(account6,new List<Id>{'00530000006GQnC','0051300000BHK96AAH'});
		DataConflictAudit job7 = new DataConflictAudit(account7,new List<Id>{'00530000006GQnC','0051300000BHK96AAH'});
		DataConflictAudit job8 = new DataConflictAudit(account8,new List<Id>{'00530000006GQnC','0051300000BHK96AAH'});
		DataConflictAudit job9 = new DataConflictAudit(account9,new List<Id>{'00530000006GQnC','0051300000BHK96AAH'});
		DataConflictAudit job10 = new DataConflictAudit(account10,new List<Id>{'00530000006GQnC','0051300000BHK96AAH'});

        String day = string.valueOf(system.now().day());
        String month = string.valueOf(system.now().month());
        String hour = string.valueOf(system.now().hour());
        String minute = string.valueOf(system.now().minute() + 1);
        String second = string.valueOf(system.now().second());
        String year = string.valueOf(system.now().year());
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;

        System.schedule('DataConflictAudit-1'+strSchedule, strSchedule, job1);
        System.schedule('DataConflictAudit-2'+strSchedule, strSchedule, job2);
        System.schedule('DataConflictAudit-3'+strSchedule, strSchedule, job3);
        System.schedule('DataConflictAudit-4'+strSchedule, strSchedule, job4);
        System.schedule('DataConflictAudit-5'+strSchedule, strSchedule, job5);
        System.schedule('DataConflictAudit-6'+strSchedule, strSchedule, job6);
        System.schedule('DataConflictAudit-7'+strSchedule, strSchedule, job7);
        System.schedule('DataConflictAudit-8'+strSchedule, strSchedule, job8);
        System.schedule('DataConflictAudit-9'+strSchedule, strSchedule, job9);
        System.schedule('DataConflictAudit-10'+strSchedule, strSchedule, job10);

	}

    global void execute(SchedulableContext sched){
		List<Account> accountList = [select id, name, Data_Conflict__c, Data_Conflict_Checked__c, Data_Conflict_Field__c, (select Id, AccountId, OldValue, NewValue, Field, CreatedById, CreatedDate from Histories 
	                                                where CreatedById in :creatorIdList and Field != 'Phone'  
	                                   order by CreatedDate desc limit 25) from Account where id in :accountIdList];

		for(Account a : accountList){
            // Get the local map for this Account
			Map<String,Integer> fieldChanges = new Map<String,Integer>();
			for(AccountHistory ah : a.Histories){
			   //   System.debug('*****::'+ah.CreatedDate+'-'+ah.Field+'-'+ah.OldValue+'-'+ah.NewValue);
			   if(fieldChanges.get(ah.Field) == null){
			       fieldChanges.put(ah.Field,1);
			   } else {
			       Integer currentCount = fieldChanges.get(ah.Field);
			   //    System.debug('*****| '+ah.Field+currentCount);
			       if(currentCount == threshhold - 1){
			           //result.add(a.Id);
			           a.Data_Conflict__c = true;
					   a.Data_Conflict_Field__c = ah.Field;
			       } else {
			           fieldChanges.put(ah.Field,currentCount +1);
			       }
			   }
			   
			}
			a.Data_Conflict_Checked__c = true;                                   
		}
		update accountList;
	}	
}