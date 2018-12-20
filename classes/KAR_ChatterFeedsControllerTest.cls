/**
  * Apex Class: KAR_ChatterFeedsControllerTest
  * Description: Test class for KAR_ChatterFeedsController
  * Created By: Matt Salpietro
  * Created Date: 11 Feb, 2016
*/
@isTest
public class KAR_ChatterFeedsControllerTest {
    static testmethod void ChatterComponentControllerTest(){
    	CollaborationGroup testGroup = IntranetTestUtility.createGroup(true);
    	Topic topic = new Topic(Name = 'Topic1');
    	insert topic;

   		Tags__c tag = IntranetTestUtility.createTag('Home', true);

   		List<Intranet_Content__c> feeds = new List<Intranet_Content__c>();
        Intranet_Content__c article1 = IntranetTestUtility.createIntranetContent('Chatter Feed', 'AdvancedTextPost', 'Test Feed 1', false);
        article1.Sequence__c = '1';
        article1.Value__c = testGroup.Name;
        article1.Status__c = 'Published';
        feeds.add(article1);

        Intranet_Content__c article2 = IntranetTestUtility.createIntranetContent('Chatter Feed', null, 'Test Feed 2', false);
        article2.Sequence__c = '2';
        article2.Value__c = '#'+topic.Name;
        article2.Status__c = 'Published';
        feeds.add(article2);

        Intranet_Content__c article3 = IntranetTestUtility.createIntranetContent('Chatter Feed', null, 'Test Feed 3', false);
        article3.Sequence__c = '3';
        article3.Value__c = '@'+UserInfo.getName();
        article3.Status__c = 'Published';
        feeds.add(article3);

        insert feeds;
        
        List<Intranet_Content_Version__c> feedVersions = new List<Intranet_Content_Version__c>();
        List<Intranet_Content_Tags__c> contentTags = new List<Intranet_Content_Tags__c>();
        for(Intranet_Content__c feed : feeds){
        	feedVersions.add(IntranetTestUtility.createContentVersion(feed.Id, false));
        	contentTags.add(IntranetTestUtility.createContentTag(feed.Id, tag.Id, false));
        }
        insert feedVersions;
        insert contentTags;
        
        ApexPages.currentPage().getParameters().put( 'name', 'testpage' );
        
        KAR_ChatterFeedsController conObj = new KAR_ChatterFeedsController();
        conObj.setFeeds();
        //system.assertEquals(conObj.feedMap.size(), 3);
        //system.assertEquals(conObj.feedMap.values()[0].feedName, conObj.feedName);
    }
}