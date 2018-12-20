global class Schedulable_All_Emails implements schedulable
{
    global void execute(SchedulableContext sc)
    {
        ID idBatchO = Database.executeBatch(new Batcher_Opportunity_Emails());
        //ID idBatchC = Database.executeBatch(new Batcher_CheckList_Emails());
        ID idBatchT = Database.executeBatch(new Batcher_Task_Emails());
    }
}