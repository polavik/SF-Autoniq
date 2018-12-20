trigger TopicAssignmentTrigger on TopicAssignment(After insert) 
{
    if(!TopicAssignmentTriggerHandler.IS_TOPIC_ASSIGNMENT_TRIGGER_EXECUTED)
    {
        TopicAssignmentTriggerHandler.IS_TOPIC_ASSIGNMENT_TRIGGER_EXECUTED = true;
        TopicAssignmentTriggerHandler.onAfterInsert(Trigger.new);
    }
}