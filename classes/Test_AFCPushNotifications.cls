@isTest
private class Test_AFCPushNotifications {
    public Test_AFCPushNotifications() {
    }
            
    public static testMethod void testAddMessageSegments() {

        Profile sysAdminProfile = [SELECT id FROM Profile WHERE Name = 'System Administrator'];
        User user1 = new User(Username='first@automotivefinance.com', LastName='Wilson', FirstName='Ted', Email='AccountManager@st.com', Alias='AMAlias', TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', ProfileId=sysAdminProfile.Id, LanguageLocaleKey='en_US' );
        insert user1;

        User user2 = new User(Username='second@automotivefinance.com', LastName='Parker', FirstName='Sherri', Email='AccountManager@st.com', Alias='AMAlias', TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', ProfileId=sysAdminProfile.Id, LanguageLocaleKey='en_US' );
        insert user2;

        List<Id> userIds = new List<Id>{user1.id,user2.id};
        Set<String> userIdStrings = new Set<String>{user1.id,user2.id};
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        feedItemInput.body = messageBodyInput;
        Test.startTest();
            MobilePushNotificationHelper.addMessageSegments(messageBodyInput, userIds,'This is a test post');
            System.assertEquals(3,messageBodyInput.messageSegments.size()); // The post, plus two mentions
            for(ConnectApi.MessageSegmentInput ms :messageBodyInput.messageSegments){
                if(ms instanceof ConnectApi.MentionSegmentInput){
                    System.assert(userIdStrings.contains(((ConnectApi.MentionSegmentInput)ms).id));
                }
            }
        Test.stopTest();
    }
}