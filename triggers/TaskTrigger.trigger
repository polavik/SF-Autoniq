trigger TaskTrigger on Task (before Insert) {
    if(trigger.isBefore && trigger.isInsert) {
        TaskTriggerHandler.onBeforeInsert(trigger.new);
    }
}