@isTest
public class AccountActivityEventTrigger_Test{
   
   
   static testMethod void InsertTaskEventLead() {
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
        
        
        //Lead creation
        lead Leads = new Lead();
        leads.lastname='Lead Test';
        leads.company='Test LEads';
        leads.LeadSource='Tsest';
        leads.status='New';
        leads.PostalCode='95050';
        leads.Lead_Type__c='test';
        
        
        // BEGIN S-444338, T-566474 : Include Lead Recordtype
           RecordType LeadRecordTypeid = [Select Id From RecordType Where SObjectType='Lead' and Name='IAA Remarketing'];
           leads.recordtypeid =LeadRecordTypeid.id;
        // END S-444338, T-566474 : Include Lead Recordtype
        
        insert leads;
        
        // BEGIN S-444338, T-566474 : Include TASK & EVENT Recordtype
        RecordType TaskRecordTypeid = [Select Id From RecordType Where SObjectType='Task' and Name='IAA Remarketing Task'];
        RecordType EventRecordTypeid = [Select Id From RecordType Where SObjectType='Event' and Name='IAA Remarketing Event'];
        // END S-444338, T-566474 : Include TASK & EVENT Recordtype       
    //------------------------END:Account Creation---------------------------//
         
        for(Integer i=0; i<5 ;i++){
            testTask = new task(recordtypeid=TaskRecordTypeid.id,whoid=leads.id,Type='Fax',status='In Progress',priority='High',subject='Test Task for Test class', ownerid=UserInfo.getUserId());
            TaskList.add(testTask);
            
            testevent=new event(recordtypeid=EventRecordTypeid.id,whoid=leads.id,Type ='Meeting',subject =' Test Event for Test class',StartDateTime = system.today(),EndDateTime = system.today(),ownerid=UserInfo.getUserId());
            eventlist.add(testevent);
        }
        
        insert TaskList;
        insert eventlist;
      
         
        for(Task Tas : tasklist){
            Tas.priority= 'Medium';
            tas.Description='this is for an update';
            tas.status='completed';
          }
        
        for (event even: eventlist)
        {
        even.EndDateTime = system.today() +1;
        even.Description='this is for an update';
        }
        
        Test.startTest();
        update TaskList;
        update eventlist;
        Test.stopTest();    
   }     
}
   
    static testMethod void InsertTaskEvent() {
        List<Task> TaskList = new List<Task>();
        List<Event> EventList = new List<Event>();
        Task testTask;
        Event testevent;
     
   //------------------------Begin:Account Creation---------------------------//
        User u = TestData.CreateUser(1);
        insert u;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){
        IAASettings__c iaa = TestData.CreateSetting('DefaultOwnerId', u.Id);
        insert iaa;
        
        Account acct = new Account();
        acct.Name = 'TestAccount' ;
        acct.BillingStreet = 'Test Street';
        acct.BillingCity = 'Test City';
        acct.BillingState = 'NJ';
        acct.BillingPostalCode ='95050';
        acct.BillingCountry = 'USA';
        acct.OwnerId = Userinfo.getUserId();
        acct.IAARecordTypes__c='IAA Remarketing';

        insert acct;
       
        // BEGIN S-444338, T-566474 : Include TASK & EVENT Recordtype
        RecordType TaskRecordTypeid = [Select Id From RecordType Where SObjectType='Task' and Name='IAA Remarketing Task'];
        RecordType EventRecordTypeid = [Select Id From RecordType Where SObjectType='Event' and Name='IAA Remarketing Event'];
        // END S-444338, T-566474 : Include TASK & EVENT Recordtype   
        
    //------------------------END:Account Creation---------------------------//
         
        for(Integer i=0; i<5 ;i++){
            testTask = new task(recordtypeid=TaskRecordTypeid.id,whatid=acct.id,Type='Fax',status='In Progress',priority='High',subject='Test Task for Test class', ownerid=UserInfo.getUserId());
            TaskList.add(testTask);
            
            testevent=new event(recordtypeid=EventRecordTypeid.id,whatid=acct.id, Type ='Meeting',subject =' Test Event for Test class',StartDateTime = system.today(),EndDateTime = system.today(),ownerid=UserInfo.getUserId());
            //testevent=new event(whoid=leads.id,Type ='Meeting',subject =' Test Event for Test class',StartDateTime = system.today(),EndDateTime = system.today(),ownerid=UserInfo.getUserId());
            eventlist.add(testevent);
        }
        
        insert TaskList;
        insert eventlist;
      
         
        for(Task Tas : tasklist){
            Tas.priority= 'Medium';
            tas.Description='this is for an update';
            tas.status='completed';
          }
        
        for (event even: eventlist)
        {
        even.EndDateTime = system.today() +1;
        even.Description='this is for an update';
        }
        
        Test.startTest();
        update TaskList;
        update eventlist;
        Test.stopTest();
    }
    }
    
    static testMethod void DeleteTaskEventleads() {
        List<Task> TaskList = new List<Task>();
        List<Event> EventList = new List<Event>();
        Task testTask;
        Event testevent;
        
      //------------------------Begin:Account Creation---------------------------//
        User u = TestData.CreateUser(1);
        insert u;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){
        IAASettings__c iaa = TestData.CreateSetting('DefaultOwnerId', u.Id);
        insert iaa;
        
        Account acct = new Account();
        acct.Name = 'TestAccount' ;
        acct.BillingStreet = 'Test Street';
        acct.BillingCity = 'Test City';
        acct.BillingState = 'NJ';
        acct.BillingPostalCode ='95050';
        acct.BillingCountry = 'USA';
        acct.OwnerId = Userinfo.getUserId();
        acct.IAARecordTypes__c='IAA Remarketing';
        
        insert acct;
        
        //Lead creation
        lead Leads = new Lead();
        leads.lastname='Lead Test';
        leads.company='Test LEads';
        leads.LeadSource='Tsest';
        leads.status='New';
        leads.PostalCode='95050';  
        leads.Lead_Type__c='test';      
        
        // BEGIN S-444338, T-566474 : Include Lead Recordtype
           RecordType LeadRecordTypeid = [Select Id From RecordType Where SObjectType='Lead' and Name='IAA Remarketing'];
           leads.recordtypeid =LeadRecordTypeid.id;
        // END S-444338, T-566474 : Include Lead Recordtype
        
        insert leads;
        
        // BEGIN S-444338, T-566474 : Include TASK & EVENT Recordtype
        RecordType TaskRecordTypeid = [Select Id From RecordType Where SObjectType='Task' and Name='IAA Remarketing Task'];
        RecordType EventRecordTypeid = [Select Id From RecordType Where SObjectType='Event' and Name='IAA Remarketing Event'];
        // END S-444338, T-566474 : Include TASK & EVENT Recordtype   
        
    //------------------------END:Account Creation---------------------------//
         
        for(Integer i=0; i<5 ;i++){
            testTask = new task(recordtypeid=TaskRecordTypeid.id,whatid=acct.id,Type='Fax',status='In Progress',priority='High',subject='Test Task for Test class',ownerid=UserInfo.getUserId());
            testTask = new task(recordtypeid=TaskRecordTypeid.id,whoid=leads.id,Type='Fax',status='In Progress',priority='High',subject='Test Task for Test class',ownerid=UserInfo.getUserId());
            TaskList.add(testTask);
            
            testevent=new event(recordtypeid=EventRecordTypeid.id,whatid=acct.id,Type ='Meeting',subject =' Test Event for Test class',StartDateTime = system.today(),EndDateTime = system.today(),ownerid=UserInfo.getUserId());
            testevent=new event(recordtypeid=EventRecordTypeid.id,whoid=leads.id,Type ='Meeting',subject =' Test Event for Test class',StartDateTime = system.today(),EndDateTime = system.today(),ownerid=UserInfo.getUserId());
            eventlist.add(testevent);
        }
        
        
        insert TaskList;
        insert eventlist;
             
       
        Test.startTest();
        delete TaskList;
        delete eventlist;
        Test.stopTest();
    }
    }
    //
    static testMethod void DeleteTaskEvent() {
        List<Task> TaskList = new List<Task>();
        List<Event> EventList = new List<Event>();
        Task testTask;
        Event testevent;
        
      //------------------------Begin:Account Creation---------------------------//
        User u = TestData.CreateUser(1);
        insert u;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){
        IAASettings__c iaa = TestData.CreateSetting('DefaultOwnerId', u.Id);
        insert iaa;
        
        Account acct = new Account();
        acct.Name = 'TestAccount' ;
        acct.BillingStreet = 'Test Street';
        acct.BillingCity = 'Test City';
        acct.BillingState = 'NJ';
        acct.BillingPostalCode ='95050';
        acct.BillingCountry = 'USA';
        acct.OwnerId = Userinfo.getUserId();
        acct.IAARecordTypes__c='IAA Remarketing';

        insert acct;
        
        // BEGIN S-444338, T-566474 : Include TASK & EVENT Recordtype
        RecordType TaskRecordTypeid = [Select Id From RecordType Where SObjectType='Task' and Name='IAA Remarketing Task'];
        RecordType EventRecordTypeid = [Select Id From RecordType Where SObjectType='Event' and Name='IAA Remarketing Event'];
        // END S-444338, T-566474 : Include TASK & EVENT Recordtype  
        
    //------------------------END:Account Creation---------------------------//
         
        for(Integer i=0; i<5 ;i++){
            testTask = new task(recordtypeid=TaskRecordTypeid.id,whatid=acct.id,Type='Fax',status='In Progress',priority='High',subject='Test Task for Test class',ownerid=UserInfo.getUserId());
            TaskList.add(testTask);
            
            testevent=new event(recordtypeid=EventRecordTypeid.id,whatid=acct.id,Type ='Meeting',subject =' Test Event for Test class',StartDateTime = system.today(),EndDateTime = system.today(),ownerid=UserInfo.getUserId());
            eventlist.add(testevent);
        }
        
        
        insert TaskList;
        insert eventlist;
             
       
        Test.startTest();
        delete TaskList;
        delete eventlist;
        Test.stopTest();
    }
    }
    //
    static testMethod void UnDeleteTaskEventleads() {
        List<Task> TaskList = new List<Task>();
        List<Event> EventList = new List<Event>();
        Task testTask;
        Event testevent;
         
    //------------------------Begin:Account Creation---------------------------//
        User u = TestData.CreateUser(1);
        insert u;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){
        IAASettings__c iaa = TestData.CreateSetting('DefaultOwnerId', u.Id);
        insert iaa;
        
        //Lead creation
        lead Leads = new Lead();
        leads.lastname='Lead Test';
        leads.company='Test LEads';
        leads.LeadSource='Tsest';
        leads.status='New';
        leads.PostalCode='95050'; 
        leads.Lead_Type__c='test';  
        
        // BEGIN S-444338, T-566474 : Include Lead Recordtype
           RecordType LeadRecordTypeid = [Select Id From RecordType Where SObjectType='Lead' and Name='IAA Remarketing'];
           leads.recordtypeid =LeadRecordTypeid.id;
        // END S-444338, T-566474 : Include Lead Recordtype     
        
        insert leads;
        
        // BEGIN S-444338, T-566474 : Include TASK & EVENT Recordtype
        RecordType TaskRecordTypeid = [Select Id From RecordType Where SObjectType='Task' and Name='IAA Remarketing Task'];
        RecordType EventRecordTypeid = [Select Id From RecordType Where SObjectType='Event' and Name='IAA Remarketing Event'];
        // END S-444338, T-566474 : Include TASK & EVENT Recordtype  
        
    //------------------------END:Account Creation---------------------------//
    
        for(Integer i=0; i<5 ;i++){
            testTask = new task(recordtypeid=TaskRecordTypeid.id,whoid=leads.id,Type='Fax',status='In Progress',priority='High',subject='Test Task for Test class',ownerid=UserInfo.getUserId());
            TaskList.add(testTask);
            
            testevent=new event(recordtypeid=EventRecordTypeid.id,whoid=leads.id,Type ='Meeting',subject =' Test Event for Test class',StartDateTime = system.today(),EndDateTime = system.today(),ownerid=UserInfo.getUserId());
            eventlist.add(testevent);
        }
        
        
        insert TaskList;
        insert eventlist;
             
        delete TaskList;
        delete eventlist;
        
        Test.startTest();
        undelete TaskList;
        undelete eventlist;
        Test.stopTest();
    }
    }
    //
    static testMethod void UnDeleteTaskEvent() {
        List<Task> TaskList = new List<Task>();
        List<Event> EventList = new List<Event>();
        Task testTask;
        Event testevent;
         
    //------------------------Begin:Account Creation---------------------------//
        User u = TestData.CreateUser(1);
        insert u;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){
        IAASettings__c iaa = TestData.CreateSetting('DefaultOwnerId', u.Id);
        insert iaa;
        
        Account acct = new Account();
        acct.Name = 'TestAccount' ;
        acct.BillingStreet = 'Test Street';
        acct.BillingCity = 'Test City';
        acct.BillingState = 'NJ';
        acct.BillingPostalCode ='95050';
        acct.BillingCountry = 'USA';
        acct.OwnerId = Userinfo.getUserId();
        acct.IAARecordTypes__c='IAA Remarketing';
   
        insert acct;
        
        // BEGIN S-444338, T-566474 : Include TASK & EVENT Recordtype
        RecordType TaskRecordTypeid = [Select Id From RecordType Where SObjectType='Task' and Name='IAA Remarketing Task'];
        RecordType EventRecordTypeid = [Select Id From RecordType Where SObjectType='Event' and Name='IAA Remarketing Event'];
        // END S-444338, T-566474 : Include TASK & EVENT Recordtype  
        
    //------------------------END:Account Creation---------------------------//
    
        for(Integer i=0; i<5 ;i++){
            testTask = new task(recordtypeid=TaskRecordTypeid.id,whatid=acct.id,Type='Fax',status='In Progress',priority='High',subject='Test Task for Test class',ownerid=UserInfo.getUserId());
            TaskList.add(testTask);
            
            testevent=new event(recordtypeid=EventRecordTypeid.id,whatid=acct.id,Type ='Meeting',subject =' Test Event for Test class',StartDateTime = system.today(),EndDateTime = system.today(),ownerid=UserInfo.getUserId());
            eventlist.add(testevent);
        }
        
        
        insert TaskList;
        insert eventlist;
             
        delete TaskList;
        delete eventlist;
        
        Test.startTest();
        undelete TaskList;
        undelete eventlist;
        Test.stopTest();
    }
    }
    //
    }