/**
  * Apex Class: TopicAssignmentTriggerHandlerTest
  * Description: Test class for TopicAssignmentTrigger
  * Created By: Matt Salpietro
  * Created Date: February 5th 2016
*/
@isTest(SeeAllData=true)
private class TopicAssignmentTriggerHandlerTest {

	@isTest static void testTopicAssignment() {
		Intranet_Content__c config = IntranetTestUtility.createIntranetContent('Config - Recognition', null, 'Config - Recognition', false);
  	config.Value__c = 'Recognition';
  	config.Recognition_Text__c = 'ShoutOut,CoreValues';
  	insert config;

		CollaborationGroup newGroup = IntranetTestUtility.createGroup(true,'testGroup123');

		FeedItem newPost1 = new FeedItem(
			Body = 'New Post',
			ParentId = newGroup.Id
		);
		insert newPost1;

		User user = IntranetTestUtility.createUser(5, true);
		System.runAs(user){
			ConnectApi.Topics.assignTopicByName(null, newPost1.Id, 'Recognition');
		}

		FeedItem newPost2 = new FeedItem(
			Body = 'New Post',
			ParentId = newGroup.Id
		);
		insert newPost2;

		Test.startTest();
			TopicAssignmentTriggerHandler.IS_TOPIC_ASSIGNMENT_TRIGGER_EXECUTED = false;
			ConnectApi.Topics.assignTopicByName(null, newPost2.Id, 'ShoutOut');
		Test.stopTest();

		List<TopicAssignment> topicAssignments = [SELECT Id, Topic.Name
																							FROM TopicAssignment
																							WHERE EntityId = :newPost2.Id];	
		system.assertEquals(2,topicAssignments.size());
	}
	
}