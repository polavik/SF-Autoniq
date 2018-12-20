/**
  * Apex Class: EdgeforceSubTeamControllerTest
  * Description: Test class for EFISubTeamController
  * Created By: Jim Cook
  * Created Date: Sept. 8, 2016
*/
@isTest
public with sharing class EFISubTeamControllerTest {
  static testmethod void subTeamControllerTest(){
    Intranet_Content_Buckets__c bucket = IntranetTestUtility.createContentBucket(
      'TestTeam', 'All Intranet Users', 'All Intranet Users', true
    );

    Intranet_Content__c team1 = IntranetTestUtility.createIntranetContent(
      'Sub Team RT',
      null,
      'TestTeam',
      false
    );
    team1.Status__c = 'Published';
    team1.Content_Bucket__c = bucket.Id;
    insert team1;

    Intranet_Content_Version__c intraContVer1 = IntranetTestUtility.createContentVersion(team1.Id, true);

    Tags__c tag = IntranetTestUtility.createTag('TestTeam', true);
    IntranetTestUtility.createContentTag(team1.Id, tag.Id, true);

    Intranet_Content__c sTeam = IntranetTestUtility.createIntranetContent(
      EdgeForceIntranetContentController.RECORDTYPE_SUB_TEAM,
      null,
      'Sub Team 1',
      false);
    sTeam.Status__c = 'Published';
    sTeam.Content_Bucket__c = bucket.Id;
    insert sTeam;

    Intranet_Content_Version__c sTeamVer = IntranetTestUtility.createContentVersion(sTeam.Id, true);
    IntranetTestUtility.createContentTag(sTeam.Id, tag.Id, true);

    PageReference pageRef = Page.KAR_Team;
    Test.setCurrentPage(pageRef);  
    pageRef.getParameters().put('name','TestTeam');  

    EFISubTeamController controller = new EFISubTeamController();
    system.assertNotEquals(controller,null);
    //system.assertNotEquals(controller.aboutUsList.size(),0);
  }
}