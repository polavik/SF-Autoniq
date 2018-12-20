trigger ApplicationPushNotification on Application__c (before update) {
    Set<String> notificationStatuses = new Set<String>{'APPROVED','DECLINED'};
    // Get all the necessary set of AFC Branch Ids
    Set<String> afcBranchIds = new Set<String>();
    for(Application__c a : Trigger.New){
        if(a.AFC_Branch__c != null){
            afcBranchIds.add(a.AFC_Branch__c);
        }
    }

    Map<String,AFC_Branch__c> afcBranchMap = new Map<String,AFC_Branch__c>();
    for(AFC_Branch__c afcBranch : [select id, Name,Area_Sales_Manager__r.id,Area_Sales_Manager__r.Name,Branch_Manager_1__r.id,Branch_Manager_1__r.Name,
                                        Assistant_Branch_Manager__r.id,Assistant_Branch_Manager__r.Name 
                                        from AFC_Branch__c where Name in :afcBranchIds]){
        afcBranchMap.put(afcBranch.Name,afcBranch);
    }

    for(Application__c app : Trigger.new){
        Application__c oldApp = Trigger.oldMap.get(app.id);
        AFC_Branch__c afcBranch = afcBranchMap.get(app.AFC_Branch__c);
        if(oldApp.AFC_Credit_Status__c != app.AFC_Credit_Status__c && notificationStatuses.contains(app.AFC_Credit_Status__c) && afcBranch != null){
            List<Id> mentionedUserIds = new List<Id>();
            List<String> mentionedUserNames = new List<String>();
            String postString = 'Application Update: '+app.Name+' has changed to '+app.AFC_Credit_Status__c+' ';
            if(afcBranch.Area_Sales_Manager__c != null && afcBranch.Area_Sales_Manager__c == app.Ownerid){
                mentionedUserIds.add(afcBranch.Area_Sales_Manager__c);
                mentionedUserNames.add(afcBranch.Area_Sales_Manager__r.Name);
            }
            if(afcBranch.Branch_Manager_1__c != null && afcBranch.Branch_Manager_1__r.Name != afcBranch.Area_Sales_Manager__r.Name){
                mentionedUserIds.add(afcBranch.Branch_Manager_1__c);
                mentionedUserNames.add(afcBranch.Branch_Manager_1__r.Name);
            }
            if(afcBranch.Assistant_Branch_Manager__c != null && afcBranch.Assistant_Branch_Manager__c != afcBranch.Branch_Manager_1__c && afcBranch.Assistant_Branch_Manager__c != afcBranch.Area_Sales_Manager__c){
                mentionedUserIds.add(afcBranch.Assistant_Branch_Manager__c);
                mentionedUserNames.add(afcBranch.Assistant_Branch_Manager__r.Name);
            }            
            
            ConnectApi.FeedElementPage fep = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(null,ConnectApi.FeedType.Record,String.valueOf(app.id));
            // If there have been no posts, go ahead and create one.
            if(fep.elements == null || fep.elements.size() == 0){
                MobilePushNotificationHelper.postNewFeedItem(app.id, mentionedUserIds, postString);
            } else {
                // Determine if the number and names of mentions (in this post and in the last post) match
                Set<String> userNames = new Set<String>(mentionedUserNames);
                Integer mentionedUsers = 0;
                for(ConnectApi.MessageSegment ms : fep.elements[0].body.messageSegments){
                    if(ms instanceof ConnectApi.MentionSegment){
                        mentionedUsers++;
                        userNames.contains(((ConnectApi.MentionSegment)ms).name);
                    }
                }

                String lastPost = (fep.elements[0].body == null)?null : fep.elements[0].body.text;
                // If there was no body to the last post or if the two post strings are different or if the mentioned users are different,
                // post a new message.
                if(lastPost == null || !lastPost.contains(postString) || mentionedUsers != mentionedUserNames.size()){
                    MobilePushNotificationHelper.postNewFeedItem(app.id, mentionedUserIds, postString);
                }
            } 
        }
    }
}