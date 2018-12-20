trigger ChecklistItemPushNotification on Checklist_Item__c (after update) {

    // Get old versions of ChecklistItems
    Map<Id,Checklist_Item__c> oldChecklistItems = Trigger.oldMap;

    // Get all the necessary branch numbers and necessary checklists
    Set<String> branchNumbers = new Set<String>();
    Set<String> checklistIds = new Set<String>();

    for(Checklist_Item__c ci : Trigger.New){
        if(ci.Branch_Number__c != null){
            branchNumbers.add(ci.Branch_Number__c);
        }
        if(ci.Checklist__c != null){
            checklistIds.add(ci.Checklist__c);
        }
    }

    // Create a Map of branch numbers -> AFC_Branches
    Map<String,AFC_Branch__c> branchNumberMap = new Map<String,AFC_Branch__c>();
    for(AFC_Branch__c afcBranch : [select id, Area_Sales_Manager__r.id,Area_Sales_Manager__r.Name,Branch_Manager_1__r.id,Branch_Manager_1__r.Name,
                                    Assistant_Branch_Manager__r.id,Assistant_Branch_Manager__r.Name,BranchNumber__c 
                                    from AFC_Branch__c where branchnumber__c in :branchNumbers]){
        branchNumberMap.put(afcBranch.BranchNumber__c,afcBranch);

    }

    // Create a Map of Checklist Ids to Applications
    Map<Id,Application__c> clApplicationsMap = new Map<Id,Application__c>();
    for(Checklist__c cl : [select id, Application__r.Name,Application__r.Ownerid from Checklist__c where id in :checklistIds]){
        clApplicationsMap.put(cl.id,cl.Application__r); // Check for nulls?
    }

    for(Checklist_Item__c ci : Trigger.new){
        boolean itemStatusChanged = oldChecklistItems.get(ci.id).Item_Status__c != ci.Item_Status__c;
        if((ci.Branch_Number__c != null) && (branchNumberMap.get(ci.Branch_Number__c) != null) && 
            (itemStatusChanged) && (ci.Item_Status__c == 'Returned to Branch')){
            List<Id> mentionedUserIds = new List<Id>();
            List<String> mentionedUserNames = new List<String>();
            String postString = 'New Checklist Item Request for '+clApplicationsMap.get(ci.Checklist__c).Name;
            AFC_Branch__c afcBranch = branchNumberMap.get(ci.Branch_Number__c);

            if(afcBranch.Area_Sales_Manager__c != null && afcBranch.Area_Sales_Manager__c == ci.Checklist__r.Application__r.Ownerid){
                mentionedUserIds.add(afcBranch.Area_Sales_Manager__c);
                mentionedUserNames.add(afcBranch.Area_Sales_Manager__r.Name);
            }
            if(afcBranch.Branch_Manager_1__c != null && afcBranch.Branch_Manager_1__c != afcBranch.Area_Sales_Manager__c){
                mentionedUserIds.add(afcBranch.Branch_Manager_1__c);
                mentionedUserNames.add(afcBranch.Branch_Manager_1__r.Name);
            }
            if(afcBranch.Assistant_Branch_Manager__c != null && afcBranch.Assistant_Branch_Manager__c != afcBranch.Area_Sales_Manager__c && 
                afcBranch.Assistant_Branch_Manager__c != afcBranch.Branch_Manager_1__c){
                mentionedUserIds.add(afcBranch.Assistant_Branch_Manager__c);
                mentionedUserNames.add(afcBranch.Assistant_Branch_Manager__r.Name);
            }            


            ConnectApi.FeedElementPage fep = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(null,ConnectApi.FeedType.Record,String.valueOf(ci.id));
            // If there have been no posts, go ahead and create one.
            if(fep.elements == null || fep.elements.size() == 0){
                MobilePushNotificationHelper.postNewFeedItem(ci.id, mentionedUserIds, postString);
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
                    MobilePushNotificationHelper.postNewFeedItem(ci.id, mentionedUserIds, postString);
                }
            } 
        }
    }
}