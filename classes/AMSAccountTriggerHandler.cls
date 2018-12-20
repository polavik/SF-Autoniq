public with sharing class AMSAccountTriggerHandler extends TriggerHandler{
  /*public static boolean bMDMCall = true;// flag who controlls the concurrency

    private static Map<Id,AMS_Account__c> triggerOldMap;
    private static Map<Id,AMS_Account__c> triggerNewMap;
    private static List<AMS_Account__c> triggerNew;
    private static List<AMS_Account__c> triggerOld;

  protected override void setup(){
        triggerOldMap = (Trigger.oldMap != null ? (Map<Id,AMS_Account__c>) Trigger.oldMap : null );
        triggerNewMap = (Trigger.newMap != null ? (Map<Id,AMS_Account__c>) Trigger.newMap : null );
        triggerOld  = (Trigger.old != null ? (List<AMS_Account__c>) Trigger.old : null );
        triggerNew = (Trigger.new != null ? (List<AMS_Account__c>) Trigger.new : null );
  }


    protected override void doBefore(){
        if (Trigger.isInsert || Trigger.isUpdate) {
            AccountTriggerUpdateFieldsByTerritory.amsAccountUpdateFieldsByTerritoryMethod(triggerNew);
        } //endof if(Trigger.isInsert || Trigger.isUpdate)

    } // endof doBefore()

  protected override void beforeInsert(){
    // TODO: remove with old mdm
    new MatchingEnterpriseAccount().Implementation(Trigger.new);
  }

  protected override void beforeUpdate(){
    // TODO: remove with old mdm
    new MatchingEnterpriseAccount().Implementation(Trigger.new);
    AMSAccountTriggerHelper.updatePurchase((Map<Id, AMS_Account__c>)Trigger.newMap,(Map<Id, AMS_Account__c>)Trigger.oldMap);
  }

  protected override void doAfter(){
    if(Trigger.isInsert && !System.isFuture() && !System.isBatch() && !Test.isRunningTest()) {
      AMSAccountTriggerHelper.checkBESforNewAmsAccounts(triggerNew);
    }
    if(Trigger.isUpdate && !System.isFuture() && !System.isBatch() && !Test.isRunningTest()) {
      AMSAccountTriggerHelper.checkBESforUpdatedAmsAccounts(triggerNew, triggerOldMap);
    }

    if(trigger.isUpdate || trigger.isInsert){
      // TODO: remove with old mdm
      if(bMDMCall && !System.isFuture() && !System.isBatch()){
        AMSAccountTriggerHelper.callMDMQuequeable((List<AMS_Account__c>)Trigger.new);
      }
      AMSAccountTriggerHelper.createBusinessUnit((List<AMS_Account__c>)Trigger.new);
    }
  }
  */
}