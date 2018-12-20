trigger AutoniqAccountTrigger on Autoniq_Account__c (after insert,after update) {
AutoniqAccountTriggerHandler handler = new AutoniqAccountTriggerHandler();

  if(Trigger.isInsert && Trigger.isAfter) {
    handler.OnAfterInsert(Trigger.new);

  } else if(Trigger.isUpdate && Trigger.isAfter) { 
    handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);

  }

}