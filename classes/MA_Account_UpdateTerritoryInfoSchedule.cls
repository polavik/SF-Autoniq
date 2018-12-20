global class MA_Account_UpdateTerritoryInfoSchedule implements Schedulable
{
	global void execute(SchedulableContext SC) 
	{
		Database.executeBatch(new MA_Account_UpdateTerritoryInfoBatchable(), 100);
	}
}