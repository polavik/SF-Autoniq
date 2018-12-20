/**
  * Apex Class: EFIMeetTheTeamCompControllerTest
  * Description: Test class for EFIMeetTheTeamCompController
  * Created By: Matt Salpietro
  * Created Date: Sept. 8, 2016
*/
@isTest(SeeAllData=true)
public with sharing class EFIMeetTheTeamCompControllerTest {
  static testmethod void meetTheTeamCompControllerTest(){
      
  	Intranet_Content_Buckets__c bucket = IntranetTestUtility.createContentBucket(
  		'Home', 'All Intranet Users', 'All Intranet Users', true
  	);

    Intranet_Content__c team1 = IntranetTestUtility.createIntranetContent(
    	'Team Page RT',
    	null,
    	'TestTeam',
    	false
    );
    team1.Status__c = 'Published';
    team1.Content_Bucket__c = bucket.Id;
    insert team1;
      system.debug('team1===' +team1);

    Intranet_Content_Version__c intraContVer1 = IntranetTestUtility.createContentVersion(team1.Id, true);

    Tags__c tag = IntranetTestUtility.createTag('TestTeam', true);
    IntranetTestUtility.createContentTag(team1.Id, tag.Id, true);
       system.debug('tag===' +tag);

    Intranet_Content__c teamMember = IntranetTestUtility.createIntranetContent(
    	EdgeForceIntranetContentController.RECORDTYPE_TEAM_MEMBER,
    	null,
    	'Team Member',
    	false);
    teamMember.Status__c = 'Published';
    teamMember.Content_Bucket__c = bucket.Id;
    teamMember.Sequence__c = '1';
    insert teamMember;
       system.debug('teamMember===' +teamMember);

    Intranet_Content_Version__c teamMemVer = IntranetTestUtility.createContentVersion(teamMember.Id, true);
    IntranetTestUtility.createContentTag(teamMember.Id, tag.Id, true);
	
      
		PageReference pageRef = Page.KAR_Team;
		Test.setCurrentPage(pageRef);  
		pageRef.getParameters().put('name','TestTeam');  

    EFIMeetTheTeamCompController controller = new EFIMeetTheTeamCompController();
    
    system.assertNotEquals(controller.pageId,null);
  //system.assertNotEquals(controller.teamList.size(),0);
  }
}