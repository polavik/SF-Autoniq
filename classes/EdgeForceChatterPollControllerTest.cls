/**
  * Apex Class: EdgeForceChatterPollControllerTest
  * Description: Test class for EdgeForceChatterPollController
  * Created By: Matt Salpietro
  * Created Date: Feb 10, 2016
*/
@isTest(SeeAllData=true)
private class EdgeForceChatterPollControllerTest{

  private static testmethod void pollComponentControllerTest(){
		CollaborationGroup testGroup = IntranetTestUtility.createGroup(true,'TestGroupChatterPoll');

		ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
		ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
		ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
		ConnectApi.FeedElementCapabilitiesInput feedElementCapabilitiesInput = new ConnectApi.FeedElementCapabilitiesInput();
		ConnectApi.PollCapabilityInput pollInput = new ConnectApi.PollCapabilityInput();

		textSegmentInput.text = 'Test Poll 1';
		messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
		messageBodyInput.messageSegments.add(textSegmentInput);

		pollInput.choices = new List<String>{'Choice1','Choice2','Choice3'};
		feedElementCapabilitiesInput.poll = pollInput;

		feedItemInput.body = messageBodyInput;
		feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
		feedItemInput.capabilities = feedElementCapabilitiesInput;
		feedItemInput.subjectId = testGroup.Id;

		ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput, null);

    Intranet_Content__c pollConfig = IntranetTestUtility.createIntranetContent('Intranet Poll', null, 'Home Page Poll', false);
    pollConfig.Value__c = testGroup.Name;
    insert pollConfig;
    
    Intranet_Content_Version__c version = IntranetTestUtility.createContentVersion(pollConfig.Id, false);
    version.Value__c = pollConfig.Value__c;
    insert version;

    Tags__c homeTag = IntranetTestUtility.createTag('TestPage1', true);
    IntranetTestUtility.createContentTag(pollConfig.Id, homeTag.Id, true);

    PageReference pageRef = Page.KAR_Team;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('Name', 'TestPage1');

    Test.startTest();
	    EdgeForceChatterPollController conObj = new EdgeForceChatterPollController();
	    system.assertNotEquals(null, conObj.pollPost);
	    EdgeForceChatterPollController.PollChoice firstChoice = conObj.pollChoices.get(new List<Id>(conObj.pollChoices.keySet())[0]);
	    system.assertEquals(pollInput.choices[0],firstChoice.choiceText);
	    conObj.selectedChoice = firstChoice.choiceId;
	    conObj.submit();
    Test.stopTest();
  }
}