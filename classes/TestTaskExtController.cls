@istest
private class TestTaskExtController
{
     public static testMethod void testMyController()
     {
        
        Account acct1 = new Account(Name='Test Account1',Master_Index__c='100');
        Insert acct1;   
        
        
        Task objTask = new Task();
        objTask.Subject = 'Test Task';
        Insert objTask;
        
        PageReference pageRef = Page.TaskVisualForcePage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('whatid', acct1.Id);
        ApexPages.currentPage().getParameters().put('OwnerId', UserInfo.getUserId());
        ApexPages.currentPage().getParameters().put('subject', 'Test Subject');
        ApexPages.currentPage().getParameters().put('status', 'Completed');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(objTask);        
        TaskExtController  Objcontroller = new TaskExtController(sc);
        Objcontroller.ObjTask = objTask;
        
        
        Objcontroller.save();
        Objcontroller.SaveNewTask();
        Objcontroller.SaveNewEvent();
        
        
        }
 }