trigger MA_AccountTrigger on Account (after insert, after update)
{
	/*
	Commented out by BLB on 2/5/15
	if (!MA_Futures.MA_AccountTrigger_InFuture && Limits.getFutureCalls() < Limits.getLimitFutureCalls()) {
    	MA_Futures.MA_Account_UpdateTerritoryInfo(trigger.newMap.keySet());
    }
    */
}