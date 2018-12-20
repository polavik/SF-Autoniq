global class StewardshipMonitor implements Schedulable {
	global void execute(SchedulableContext sc) {

		/* Check for multiple Accounts that hold the same integration id */
		Map<String,List<Id>> integrationAccountIdMap = new Map<String,List<Id>>();
		for(AggregateResult ar : [SELECT  Integration_Id__c, count(Id) FROM Account where Integration_Id__c <> null GROUP BY Integration_Id__c having count(Id) > 1 order by count(Id) desc limit 50000]){
			integrationAccountIdMap.put(String.valueOf(ar.get('Integration_Id__c')),new List<Id>());
		}
		for(Account a : [select id, Integration_Id__c from Account where Integration_Id__c in :integrationAccountIdMap.keyset()]){
			List<Id> tempList = integrationAccountIdMap.get(a.Integration_Id__c);
			tempList.add(a.id);
			integrationAccountIdMap.put(a.Integration_Id__c,tempList);
		}
		for(String integrationId : integrationAccountIdMap.keyset()){
			StewardshipHelper.createDuplicateIntegrationIdCase(integrationId, integrationAccountIdMap.get(integrationId));
		}


		/* Check for (and automatically close) "Local Account Integration" cases for Accounts that have an integration id (which may have been filled in by a nightly batch) */
		List<Case> caseList = [select id, status, accountId, Account.Integration_Id__c from Case 
								where RecordTypeId = :StewardshipHelper.stewardshipRtId and status = 'Open' and Account.Integration_Id__c != null limit 5000];
		for(Case c : caseList){
			c.status = 'Closed';
		}
		update caseList;

		/* Check for (and create Cases for) Accounts that were opened by a Stewardship user and  don't have an integration id and create a Case for them */
		List<Id> accountIdList = new List<Id>();
		for(Account a : [select id from Account where Account.Integration_Id__c = null and CreatedById = :StewardshipHelper.stewardshipUserIds limit 5000]){
			accountIdList.add(a.Id);
		}
		if(accountIdList.size() > 0){
			StewardshipHelper.createLocalAccountIntegrationCases(accountIdList);
		}
	}
}

//global class scheduledTest implements Schedulable{
//    global void execute(SchedulableContext SC) {
//        RecurringScheduleJob.startJob();   
//        String day = string.valueOf(system.now().day());
//        String month = string.valueOf(system.now().month());
//        String hour = string.valueOf(system.now().hour());
//        String minute = string.valueOf(system.now().minute() + 1);
//        String second = string.valueOf(system.now().second());
//        String year = string.valueOf(system.now().year());
        
//        String strJobName = 'Stewardship Monitor - '+ day + '_' + month + '_' + year;
//        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
//        System.schedule(strJobName, strSchedule, new scheduledTest());
//    } 
//}