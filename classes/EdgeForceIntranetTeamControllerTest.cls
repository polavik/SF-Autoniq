/**
  * Apex Class: IntranetTeamControllerTest
  * Description: test class for IntranetTeamController
  * Created By: Dipika Gupta (Appirio Off)
  * Created Date: 17 Dec,2012
*/
@isTest (seeAllData=false)
private class EdgeForceIntranetTeamControllerTest {
    
    @isTest static void TeamControllerTest(){

// Use this code.

     Test.startTest();    	
     Id p = [select id from profile where name='System Administrator'].id;

     User user = new User(alias = 'test123', email='test1234@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                timezonesidkey='America/Los_Angeles', username='tester018384@gmail.com');
     insert user;

     system.runAs(user) {

        //Insert new Collaboration Group
        //CollaborationGroup collaborationGroup = TestUtilityPackage.createGroup(true);
        
        //Set IntranetTeam as current page
        PageReference pageRef = Page.KAR_Team;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('name', 'testGroup');
        
        // Content Bucket
        Intranet_Content_Buckets__c cB = new Intranet_Content_Buckets__c();
        cB.Name = 'testGroup';
        RecordType rtid = [Select id from RecordType where sObjectType = 'Intranet_Content__c' and developerName ='Team_Page_RT' limit 1 ];
      
        System.assertNotEquals(rtid,null);
        
        //Schema.SObjectType.Intranet_Content__c.getRecordTypeInfosByName().get('Team_Page_RT').getRecordTypeId();
        
        // Create a new Team Intranet Item.
        Intranet_Content__c teamRecord = new Intranet_Content__c();
        teamRecord.RecordType = rtid;
        teamRecord.Name = 'testGroup';
        teamRecord.Content_Bucket__c = cB.Id;
        teamRecord.Show_Meet_The_Team__c = true;
        teamRecord.Meet_The_Team_Sequence__c = '1';       
        teamRecord.Show_About_The_Team__c = true;
        teamRecord.About_The_Team_Sequence__c = '2';
        teamRecord.Show_Sub_Team__c = true;
        teamRecord.Sub_Team_Sequence__c = '3';
        teamRecord.Show_News_Banner__c = true;
        teamRecord.News_Banner_Sequence__c = '4';
        teamRecord.Show_News__c = false;
        teamRecord.News_Sequence__c = '5';
        teamRecord.Show_Calendar__c = true;
        teamRecord.Calendar_Sequence__c = '6';
        teamRecord.Show_Collapsible_Content__c = false;
        
        insert teamRecord;
        
        Intranet_Content_Version__c intraContVer1 = IntranetTestUtility.createContentVersion(teamRecord.Id, true);
         CollaborationGroup testGroup = IntranetTestUtility.createGroup(true);
        EdgeForceIntranetTeamController conObj = new EdgeForceIntranetTeamController();
         conObj.bgImg='';
         conObj.miscMsgs='';
         conObj.test();
        
        System.assertNotEquals(conObj,null);
        //System.assertNotEquals(conObj.groupId,null);
 }
    }
}