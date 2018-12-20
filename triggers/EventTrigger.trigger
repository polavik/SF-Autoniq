trigger EventTrigger on Event (before Insert) {
    if(trigger.isBefore && trigger.isInsert) {
        EventTriggerHandler.onBeforeInsert(trigger.new);
    }
}