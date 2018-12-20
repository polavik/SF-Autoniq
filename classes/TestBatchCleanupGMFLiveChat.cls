@isTest
private class TestBatchCleanupGMFLiveChat {
static testMethod void BatchCleanupGMFLiveChat() {

       Cleanup_Properties__c d1 = new Cleanup_Properties__c(name = 'GMF_Live_Chat_Expiration', date__c='-1');
       insert d1;
       
       Cleanup_Properties__c email = new Cleanup_Properties__c(name = 'GMF_Live_Chat_Email', date__c='test@adesa.com');
       insert email ;
       
       Property__c prop1 = new Property__c( property_id__c='gmf.us.url', property_value__c='gmfdealersource.com' );
       Insert prop1 ;
       
       Property__c prop2 = new Property__c( property_id__c='gmf.canada.url', property_value__c='gmfdealersource.ca' );
       Insert prop2 ;
       
       LiveChatVisitor lcv = new LiveChatVisitor(); 
       insert lcv;
       Id visitorId = lcv.Id;
       LiveChatTranscript lctUS = new LiveChatTranscript(location = 'TestBatch1', LiveChatVisitorId = visitorId, ReferrerUri='http://www.gmfdealersource.ca/');
       insert lctUS;
       LiveChatTranscript lctCA = new LiveChatTranscript(location = 'TestBatch2', LiveChatVisitorId = visitorId, ReferrerUri='http://www.gmfdealersource.com/');
       insert lctCA;   

       Test.startTest();
       BatchCleanupGMFLiveChat c = new BatchCleanupGMFLiveChat();
       //Database.executeBatch(c);
       String sch = '0 0 23 * * ?'; system.schedule('Test BatchCleanupGMFLiveChat', sch, c);
       Test.stopTest();

    }
}