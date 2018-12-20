global class MobilePushNotificationHelper {


   global static void postNewFeedItem(Id feedId, List<Id> mentionedUserIds, String feedItemInputText) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        feedItemInput.body = messageBodyInput;
        addMessageSegments(messageBodyInput, mentionedUserIds, feedItemInputText);
        ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, feedId, feedItemInput, null);
    }

    global static void addMessageSegments(ConnectApi.MessageBodyInput messageInput, List<Id> mentionedUserIds, String text) {
        List<ConnectApi.MessageSegmentInput> postSegments = new List<ConnectAPI.MessageSegmentInput>();//messageInput.messageSegments;

        // Add text (body) of message
        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = text;
        postSegments.add(textSegment);
        
        // Add mentions of supplied users
        for(User u : [select id from user where id in :mentionedUserIds]){
            ConnectApi.MentionSegmentInput mention = new ConnectApi.MentionSegmentInput();
            mention.id = u.id;
            postSegments.add(mention);
        }
        messageInput.messageSegments = postSegments;
    }
}