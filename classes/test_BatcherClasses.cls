@isTest
private class test_BatcherClasses
{
   static testmethod void test1() 
   {
       Id profileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id;
       User bigboss = new User
       (
           Alias='test1',Email='test1@test.com',EmailEncodingKey='UTF-8',LastName='Testing',LanguageLocaleKey='en_US',LocaleSidKey='en_US',
           ProfileId=profileId,TimeZoneSidKey='America/Los_Angeles', UserName='test1@test.com.afctest'
       );
       insert bigboss;
       User boss = new User
       (
           Alias='test2',Email='test2@test.com',EmailEncodingKey='UTF-8',LastName='Testing',LanguageLocaleKey='en_US',LocaleSidKey='en_US',
           ProfileId=profileId,TimeZoneSidKey='America/Los_Angeles', UserName='test2@test.com.afctest', ManagerId = bigboss.Id
       );
       insert boss;
       User emp = new User
       (
           Alias='test3',Email='test3@test.com',EmailEncodingKey='UTF-8',LastName='Testing',LanguageLocaleKey='en_US',LocaleSidKey='en_US',
           ProfileId=profileId,TimeZoneSidKey='America/Los_Angeles', UserName='test3@test.com.afctest', ManagerId = boss.Id
       );
       insert emp;
       Id rtOId = [SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND Name = 'AFC New Business' LIMIT 1].Id;
       Id rtTId = [SELECT Id FROM RecordType WHERE sObjectType = 'Task' AND Name = 'AFC BDC' LIMIT 1].Id;
       Id rtAId = [SELECT Id FROM RecordType WHERE sObjectType = 'Application__c' AND Name = 'New Application' LIMIT 1].Id;
       Opportunity o1 = new Opportunity(Stage_Update__c = Date.today()-14, Last_Activity_Datetime__c = Date.today()-14, RecordTypeId = rtOId, StageName = 'Open', OwnerId = emp.Id, Name='opp', CloseDate = Date.today(), Type = 'Gold');
       Opportunity o2 = new Opportunity(Stage_Update__c = Date.today()-28, Last_Activity_Datetime__c = Date.today()-28, RecordTypeId = rtOId, StageName = 'Open', OwnerId = emp.Id, Name='opp', CloseDate = Date.today());
       Opportunity o3 = new Opportunity(Stage_Update__c = Date.today()-45, Last_Activity_Datetime__c = Date.today()-45, RecordTypeId = rtOId, StageName = 'Open', OwnerId = emp.Id, Name='opp', CloseDate = Date.today());
       insert o1;
       insert o2;
       insert o3;
       Task t1 = new Task(RecordTypeId = rtTId, ActivityDate = Date.today()-1, OwnerId = emp.Id);
       Task t2 = new Task(RecordTypeId = rtTId, ActivityDate = Date.today()-3, OwnerId = emp.Id);
       Task t3 = new Task(RecordTypeId = rtTId, ActivityDate = Date.today()-7, OwnerId = emp.Id);
       Task t4 = new Task(RecordTypeId = rtTId, ActivityDate = Date.today()-30, OwnerId = emp.Id);
       Task t5 = new Task(RecordTypeId = rtTId, ActivityDate = Date.today()-45, OwnerId = emp.Id);
       insert t1;
       insert t2;
       insert t3;
       insert t4;
       insert t5;
       Application__c a1 = new Application__c(Opportunity__c = o1.Id, RecordTypeId = rtAId, Credit_Amount__c = 500001, Application_Stage__c = 'Relook', AFC_Region__c = 'Andrews', AFC_Branch_Old__c = 'Test');
       Application__c a2 = new Application__c(Opportunity__c = o1.Id, RecordTypeId = rtAId, Credit_Amount__c = 500001, Application_Stage__c = 'Relook', AFC_Region__c = 'Andrews', AFC_Branch_Old__c = 'Test');
       list<Application__c> apps = new list<Application__c>();
       apps.add(a1);
       apps.add(a2);
       insert apps;
       Checklist__c c1 = new Checklist__c(Application__c = apps[0].Id);
       insert c1;
       Checklist_Item__c ci1 = new Checklist_Item__c(Owner__c = emp.Id, Checklist__c = c1.Id, Exclude__c = false, Item_Status__c = 'Returned to Branch', Age_Test__c = 3, Primary_Return_Reason__c = 'Incomplete');
       Checklist_Item__c ci2 = new Checklist_Item__c(Owner__c = emp.Id, Checklist__c = c1.Id, Exclude__c = false, Item_Status__c = 'Returned to Branch', Age_Test__c = 7, Primary_Return_Reason__c = 'Incomplete');
       Checklist_Item__c ci3 = new Checklist_Item__c(Owner__c = emp.Id, Checklist__c = c1.Id, Exclude__c = false, Item_Status__c = 'Returned to Branch', Age_Test__c = 14, Primary_Return_Reason__c = 'Incomplete');
       insert ci1;
       insert ci2;
       insert ci3;
       String emailTemplateId = [SELECT Id FROM EmailTemplate LIMIT 1].Id;
       /*
       Vf_Templates__c vft = new Vf_Templates__c
       (
           OP_Employee_First__c = 'Opp_Employee_First_Notification', 
           OP_Employee_Second__c = 'Opp_Employee_Second_Notification', 
           OP_Employee_Third__c = 'Opp_Employee_Third_Notification', 
           OP_Manager_First__c = 'Opp_Manager_First_Notification', 
           OP_Manager_Second__c = 'Opp_Manager_Second_Notification', 
           OP_SManager_First__c = 'Opp_Secondary_Manger_First_Notification',
           EmployeeFirst__c = 'Opp_Secondary_Manger_First_Notification',
           Employeesecond__c = 'Opp_Secondary_Manger_First_Notification',
           Employeethird__c = 'Opp_Secondary_Manger_First_Notification',
           EmployeeFinal__c = 'Opp_Secondary_Manger_First_Notification',
           ManagerFirst__c = 'Opp_Secondary_Manger_First_Notification',
           ManagerSecond__c = 'Opp_Secondary_Manger_First_Notification',
           ManagerFinal__c = 'Opp_Secondary_Manger_First_Notification',
           SecondmanagerFirst__c = 'Opp_Secondary_Manger_First_Notification',
           SecondmanagerFinal__c = 'Opp_Secondary_Manger_First_Notification',
           CheckItem_Template__c = 'Opp_Secondary_Manger_First_Notification',
           CL_Employee_First__c = 'Opp_Secondary_Manger_First_Notification',
           CL_Employee_Second__c = 'Opp_Secondary_Manger_First_Notification',
           CL_Employee_Third__c = 'Opp_Secondary_Manger_First_Notification',
           CL_Manager_First__c = 'Opp_Secondary_Manger_First_Notification',
           CL_Manager_Second__c = 'Opp_Secondary_Manger_First_Notification',
           CL_Secondary_Manager_First__c = 'Opp_Secondary_Manger_First_Notification'
       );
       */
       Vf_Templates__c vft = new Vf_Templates__c
       (
           OP_Employee_First__c = emailTemplateId, 
           OP_Employee_Second__c = emailTemplateId, 
           OP_Employee_Third__c = emailTemplateId, 
           OP_Manager_First__c = emailTemplateId, 
           OP_Manager_Second__c = emailTemplateId, 
           OP_SManager_First__c = emailTemplateId, 
           EmployeeFirst__c = emailTemplateId,
           Employeesecond__c = emailTemplateId,
           Employeethird__c = emailTemplateId,
           EmployeeFinal__c = emailTemplateId,
           ManagerFirst__c = emailTemplateId,
           ManagerSecond__c = emailTemplateId,
           ManagerFinal__c = emailTemplateId,
           SecondmanagerFirst__c = emailTemplateId,
           SecondmanagerFinal__c = emailTemplateId
       );
       insert vft;
       Test.startTest();
       System.runAs(emp)
       {
           Schedulable_All_Emails sae = new Schedulable_All_Emails();
           String sch = '0 0 23 * * ?';
           system.schedule('Test SAE', sch, sae);
           Batcher_Opportunity_Emails boe = new Batcher_Opportunity_Emails();
           Database.executeBatch(boe);
           Batcher_Task_Emails bte = new Batcher_Task_Emails();
           Database.executeBatch(bte);
          // Batcher_checkList_Emails bce = new Batcher_checkList_Emails();
          // Database.executeBatch(bce);
           Opportunity_Email_Notifications oen = new Opportunity_Email_Notifications();
           oen.UId = emp.Id;
           String s = oen.getBaseUrl();
           list<Opportunity> lstO = oen.getOpp_data();
           lstO = oen.getOpp_Manager_data();
           lstO = oen.getOpp_SecondaryManager_data();
           Task_Email_Notifications ten = new Task_Email_Notifications();
           ten.UId = emp.Id;
           ten.noDays = 3;
           s = ten.getBaseUrl();
           list<Task> lstT = ten.getTask_data();
           lstT = ten.getTask_Manager_data();
           lstT = ten.getTask_SecondaryManager_data();
           ten.UId = boss.Id;
           lstT = ten.getTask_data();
           lstT = ten.getTask_Manager_data();
           lstT = ten.getTask_SecondaryManager_data();
           ten.UId = bigboss.Id;
           lstT = ten.getTask_data();
           lstT = ten.getTask_Manager_data();
           lstT = ten.getTask_SecondaryManager_data();
          /*
 CheckList_Email_Notifications cen = new CheckList_Email_Notifications();
           cen.UId = emp.Id;
           cen.noDays = 3;
           s = cen.getBaseUrl();
           list<Checklist_Item__c> lstC = cen.getCL_data();
           lstC = cen.getCL_Manager_data();
           lstC = cen.getCL_SecondaryManager_data();
*/
       }
   }
}