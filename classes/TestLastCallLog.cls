@isTest
private class TestLastCallLog{
    @isTest static void testCreateNewTask(){ 
        Account a = new Account(name = 'testTask');
        insert a;
        /* FIXME: Task t = new Task(RecordTypeId='01260000000DSvF');
        insert t;
        */

        //zip.DST_Outside_Sales_Rep__r.FirstName = 'testing';
        //upsert zip;
    }
    
}