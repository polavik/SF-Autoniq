// Created By: Amit SanWariya (Appirio)
// Created On: 14-Oct-2016
// Purpose: Test Class for LeadTriggerHandler
@isTest
public class LeadTriggerHandlerTest {
    
    //Test the functionality of restricting Task creation if Do_Not_Create_a_Task__c is checked
    public static testmethod void TaskDeletionTest() {
     
      Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
      User u = new User(Alias = 'standt', Email='test1234@test8989.com', 
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='test1234@test8989.comxyz');
        
            System.runAs(u) {  
        
        
        
        // Create a Lead
        Lead lead=new Lead(LastName='Doe',
                           FirstName='John',
                           Street='Street',
                           City='City',
                           State='State',
                           PostalCode='332211',
                           Country='Country',
                           Phone='9876543210',
                           Company='Company',
                           Referred_By__c='Referal',
                           Do_Not_Create_a_Task__c=true,
                           Status='Open');
        
        insert lead;                

        Test.startTest();
        
        //Convert Lead
       /* Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('New Account');*/
                
                Database.LeadConvert lc = new Database.LeadConvert();
				lc.setLeadId(Lead.id);
                lc.setDoNotCreateOpportunity(false);
				LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
				lc.setConvertedStatus(convertStatus.MasterLabel);

        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        List<Task> taskList = [SELECT Id FROM Task];
        System.assertEquals(0, taskList.size());
        
        Test.stopTest();
    }
  }
}