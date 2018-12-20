@isTest
private class Test_MA_Futures{
   static testMethod void test_MA_Account_UpdateTerritoryInfo_UseCase1(){
    MA_Futures obj01 = new MA_Futures();
    MA_Futures.MA_AccountTrigger_InFuture = false;
    MA_Futures.MA_Account_UpdateTerritoryInfo(new set<Id>());
  }
}