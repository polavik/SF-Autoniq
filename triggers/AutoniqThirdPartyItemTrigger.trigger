trigger AutoniqThirdPartyItemTrigger on Autoniq_Third_Party_Item__c (after insert, after update) {
    AutoniqThirdPartyItemTriggerHandler.updateAutoniqThirdPartyItem(trigger.newMap.keySet());
}