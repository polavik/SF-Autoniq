/**
  * Apex Class: EFIMeetTheSubTeamCompControllerTest
  * Description: Test class for EFIMeetTheSubTeamCompController
  * Created By: Matt Salpietro
  * Created Date: Sept. 8, 2016
*/
@isTest
public with sharing class EFIMeetTheSubTeamCompControllerTest {
  static testmethod void meetTheSubTeamCompControllerTest(){
      
      
    Intranet_Content__c team1 = IntranetTestUtility.createIntranetContent(
    	'Sub Team RT',
    	null,
    	'TestTeam',
    	false
    );
    team1.Status__c = 'Published';
    insert team1;

    Intranet_Content_Version__c intraContVer1 = IntranetTestUtility.createContentVersion(team1.Id, true);

    Tags__c tag = IntranetTestUtility.createTag('TestTeam', true);
    IntranetTestUtility.createContentTag(team1.Id, tag.Id, true);

      	Intranet_Content_Buckets__c bucket = IntranetTestUtility.createContentBucket(
  		'Home', 'All Intranet Users', 'All Intranet Users', true
  	);
      
    Intranet_Content__c teamMember = IntranetTestUtility.createIntranetContent(
    	EdgeForceIntranetContentController.RECORDTYPE_TEAM_MEMBER,
    	null,
    	'Team Member',
    	false);
    teamMember.Status__c = 'Published';
    teamMember.Content_Bucket__c = bucket.Id;
    insert teamMember;

    Intranet_Content_Version__c teamMemVer = IntranetTestUtility.createContentVersion(teamMember.Id, true);
    IntranetTestUtility.createContentTag(teamMember.Id, tag.Id, true);

		PageReference pageRef = Page.KAR_SubTeam_jc;
		Test.setCurrentPage(pageRef);  
		pageRef.getParameters().put('name','TestTeam');  

    EFIMeetTheSubTeamCompController controller = new EFIMeetTheSubTeamCompController();
    system.assertNotEquals(controller.pageId,null);
//   system.assertNotEquals(controller.teamList.size(),0);
  }
}