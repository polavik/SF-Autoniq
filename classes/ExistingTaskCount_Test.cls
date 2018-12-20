@isTest
public class ExistingTaskCount_Test {

    static testMethod void ExistingTaskEventAccount() {
        
        List<Task> TaskList = new List<Task>();
        List<Event> EventList = new List<Event>();
        Task testTask;
        Event testevent;
            
        User u = TestData.CreateUser(1);
        insert u;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){
        
        IAASettings__c tr = TestData.CreateSetting('DefaultOwnerId', u.Id);
        insert tr;
        
        Account acct = new Account();
        acct.Name = 'TestAccount' ;
        acct.BillingStreet = 'Test Street';
        acct.BillingCity = 'Test City';
        acct.BillingState = 'NJ';
        acct.BillingPostalCode ='95050';
        acct.BillingCountry = 'USA';
        acct.OwnerId = Userinfo.getUserId();
        
        // BEGIN S-444338, T-566482 : Include Account Recordtype
        acct.IAARecordTypes__c='IAA Remarketing';
        // END S-444338, T-566482 : Include Account Recordtype
        
        insert acct;
        
         // BEGIN S-444338, T-566482: Include TASK & EVENT Recordtype
         RecordType TaskRecordTypeid = [Select Id From RecordType Where SObjectType='Task' and Name='IAA Remarketing Task'];
        RecordType EventRecordTypeid = [Select Id From RecordType Where SObjectType='Event' and Name='IAA Remarketing Event'];
        // END S-444338, T-566482: Include TASK & EVENT Recordtype   
       
        
    //------------------------END:Account Creation---------------------------//
         
        for(Integer i=0; i<5 ;i++){
            testTask = new task(recordtypeid=TaskRecordTypeid.id,whatid=acct.id,Type='Fax',status='In Progress',priority='High',subject='Test Task for Test class', ownerid=UserInfo.getUserId());
            TaskList.add(testTask);
            
            testevent=new event(recordtypeid=EventRecordTypeid.id,whatid=acct.id, Type ='Meeting',subject =' Test Event for Test class',StartDateTime = system.today(),EndDateTime = system.today(),ownerid=UserInfo.getUserId());
            eventlist.add(testevent);
    }
    insert tasklist;
    insert eventlist;
    
       Test.StartTest();
           ExistingTaskCount Taskcount= new ExistingTaskCount();
           ID batchprocessid = Database.executeBatch(Taskcount);
           
           ExistingEventCount eventcount= new ExistingEventCount();
           ID batchprocessid1 = Database.executeBatch(eventcount);
        Test.StopTest();
}
}

static testMethod void ExistingTaskEventLead() {
        
        List<Task> TaskList = new List<Task>();
        List<Event> EventList = new List<Event>();
        Task testTask;
        Event testevent;
            
        User u = TestData.CreateUser(1);
        insert u;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){
        IAASettings__c iaa = TestData.CreateSetting('DefaultOwnerId', u.Id);
        insert iaa;
        
        lead Leads = new Lead();
        leads.lastname='Lead Test';
        leads.company='Test LEads';
        leads.LeadSource='Tsest';
        leads.status='New';
        leads.PostalCode='95050';
        leads.Lead_Type__c='test';
        
        // BEGIN S-444338, T-566482 : Include Lead Recordtype
        RecordType LeadRecordTypeid = [Select Id From RecordType Where SObjectType='Lead' and Name='IAA Remarketing'];
        leads.recordtypeid =LeadRecordTypeid.id;
        // END S-444338, T-566482 : Include Lead Recordtype
        
        insert leads;
        
        // BEGIN S-444338, T-566482: Include TASK & EVENT Recordtype
        RecordType TaskRecordTypeid = [Select Id From RecordType Where SObjectType='Task' and Name='IAA Remarketing Task'];
        RecordType EventRecordTypeid = [Select Id From RecordType Where SObjectType='Event' and Name='IAA Remarketing Event'];
        // END S-444338, T-566482: Include TASK & EVENT Recordtype   
    //------------------------END:Account Creation---------------------------//
         
        for(Integer i=0; i<5 ;i++){
            testTask = new task(recordtypeid=TaskRecordTypeid.id,whoid=leads.id,Type='Fax',status='In Progress',priority='High',subject='Test Task for Test class', ownerid=UserInfo.getUserId());
            TaskList.add(testTask);
            
            testevent=new event(recordtypeid=EventRecordTypeid.id,whoid=leads.id, Type ='Meeting',subject =' Test Event for Test class',StartDateTime = system.today(),EndDateTime = system.today(),ownerid=UserInfo.getUserId());
            eventlist.add(testevent);
    }
    insert tasklist;
    insert eventlist;
    
       Test.StartTest();
           ExistingTaskCount Taskcount= new ExistingTaskCount();
           ID batchprocessid = Database.executeBatch(Taskcount);
           
           ExistingEventCount eventcount= new ExistingEventCount();
           ID batchprocessid1 = Database.executeBatch(eventcount);
        Test.StopTest();
}
}

}