//
// (c) 2013 Appirio, Inc.
//
// A Utility Class for Intranet
//
// 31 Oct 2013     Sudhir Kr. Jagetiya       Original
//

public without sharing class IntranetUtility {


  public static Map<Id, LikesCommentFollwerInfo> getSocialInfo(Set<Id> recordIds) {
    Map<Id, LikesCommentFollwerInfo> socialInfoMap = new Map<Id, LikesCommentFollwerInfo>();
    if(recordIds.size() > 0) {
      Map<Id, Id> feedAndRecordIds = new Map<Id, Id>();
      for(FeedItem feedItem : [SELECT Id, ParentId, LikeCount, CommentCount
                                 FROM FeedItem
                                WHERE ParentId IN :recordIds]) {
        feedAndRecordIds.put(feedItem.Id, feedItem.ParentId);
        if(!socialInfoMap.containsKey(feedItem.ParentId)) {
          socialInfoMap.put(feedItem.ParentId, new LikesCommentFollwerInfo());
        }
        socialInfoMap.get(feedItem.ParentId).noOfLikes += Integer.ValueOf(feedItem.LikeCount);
        socialInfoMap.get(feedItem.ParentId).noOfComments += 1;
        socialInfoMap.get(feedItem.ParentId).noOfComments += Integer.ValueOf(feedItem.CommentCount);
      }

      for(EntitySubscription entitySubscription : [SELECT ParentId, Id FROM EntitySubscription
                                                    WHERE ParentId IN :recordIds]) {
        if(!socialInfoMap.containsKey(entitySubscription.ParentId)) {
          socialInfoMap.put(entitySubscription.ParentId, new LikesCommentFollwerInfo());
        }
        socialInfoMap.get(entitySubscription.ParentId).noOfFollowers += 1;
      }

      for(Id recordId : recordIds) {
        if(!socialInfoMap.containsKey(recordId)) {
          socialInfoMap.put(recordId, new LikesCommentFollwerInfo());
        }
      }
    }
    return socialInfoMap;
  }

  public class LikesCommentFollwerInfo {
    public Integer noOfLikes {get; private set;}
    public Integer noOfComments {get; private set;}
    public Integer noOfFollowers {get; private set;}

    public LikesCommentFollwerInfo() {
      noOfLikes = 0;
      noOfComments = 0;
      noOfFollowers = 0;
    }
  }

  public static String getAllFields(String sobjectname){
    if(!Schema.getGlobalDescribe().containsKey(sobjectname)) return 'Invalid object name';
    Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get(sobjectname).getDescribe().SObjectType.getDescribe().fields.getMap();

    List<String> accessiblefields = new List<String>();

    for(Schema.SObjectField field : fields.values()){
        if(field.getDescribe().isAccessible())
          accessiblefields.add(field.getDescribe().getName());
    }

    String allfields='';

    for(String fieldname : accessiblefields)
        allfields += fieldname+',';

    allfields = allfields.subString(0,allfields.length()-1);
  
    return allfields;
  }
}