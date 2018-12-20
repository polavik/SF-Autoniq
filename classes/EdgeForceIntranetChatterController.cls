public class EdgeForceIntranetChatterController{
    public Boolean isfeed {get;set;}
    public Boolean isGroup {get;set;}
    public Boolean isMyFeed {get;set;}
    public Boolean isMyFollowers {get;set;}
    public Boolean isFollowing {get;set;}
    public String groupName {get;set;}
    public String groupDesc {get;set;}
    public Boolean allowCustomer {get;set;} {allowCustomer = false;}
    public String access {get;set;} {access = 'public';}
    public String isAutoArchieve {get;set;} {isAutoArchieve = 'false';}
    public User currentUser {get;set;}
    public List<User> chatterUsers {get;set;}
    public List<User> lstUsersSelected {get;set;}
    public List<CollaborationGroup> userGroups {get;set;}
    public List<CollaborationGroup> activeGroups {get;set;}
    public String groupId {get;set;}

    public transient Component.Chatter.Feed userFeed {get;set;}

    public EdgeForceIntranetChatterController(){
        currentUser = new User();
        resetView();
        isFeed = true;
        currentUser = [SELECT Id, Name, Email, Title, FullPhotoUrl, Department,
                       SmallPhotoUrl, CompanyName, Country, IsActive
                       FROM User WHERE Id = :UserInfo.getUserId()];
    }

    public void showfeed(){
        resetView();
        isFeed = true;
    }

    public void showMyFeed(){
        resetView();
        isMyFeed = true;
        userFeed = new Component.Chatter.Feed();
        userFeed.EntityId = userInfo.getUserId();
    }

    public void showMyFollowers(){
        resetView();
        isMyFollowers = true;
        List<String> lstFollowersIds = new List<String>();
        lstUsersSelected = new List<User>();
        for(EntitySubscription FollowerES : [SELECT SubscriberId FROM EntitySubscription
                                             WHERE ParentId = :currentUser.Id]){
            lstFollowersIds.add(FollowerES.subscriberid);
        }
        if(lstFollowersIds.size() > 0){
            lstUsersSelected = [SELECT Id, Name, Email, UserType, Title, FullPhotoUrl, Department, SmallPhotoUrl,
                                CompanyName, Country, IsActive FROM User 
                                WHERE IsActive = true AND Id IN :lstFollowersIds];
                    
        }
    }

    public void showFollowing(){
        resetView();
        isFollowing = true;
        List<String> lstFollowingsIds = new List<String>();
        lstUsersSelected = new List<User>();
        for(EntitySubscription FollowingES : [SELECT ParentId FROM EntitySubscription
                                              WHERE SubscriberId = :currentUser.Id]){
            lstFollowingsIds.add(FollowingES.parentid);
        }
        if(lstFollowingsIds.size() > 0){
            lstUsersSelected = [SELECT Id, Name, Email, UserType, Title, FullPhotoUrl, Department, SmallPhotoUrl,
                                CompanyName, Country, IsActive FROM User 
                                WHERE IsActive = true AND Id IN :lstFollowingsIds];
                    
        }
    }

    public void showGroup(){
        resetView();
        isGroup = true;
        Map<ID,Integer> feedCountMap = new Map<ID,Integer>();
        List<Integer> countList = new List<Integer>();
        List<String> ids = new List<String>();
        userGroups = new List<CollaborationGroup>();
        activeGroups = new List<CollaborationGroup>();
        List<String> groupIds = new List<String>();
        List<CollaborationGroupMember> gMember = [SELECT CollaborationGroupId FROM CollaborationGroupMember WHERE MemberId = :userInfo.getUserId()];
        for(CollaborationGroupMember cm : gMember)
            groupIds.add(cm.CollaborationGroupId);
        for(CollaborationGroup userGroup :[SELECT Id, Name,SmallPhotoUrl,Description,MemberCount FROM CollaborationGroup WHERE Id IN :groupIds]){
            userGroups.add(userGroup);
        }
        for(CollaborationGroup userGroup :[SELECT Id, Name,SmallPhotoUrl,Description,MemberCount
                                           FROM CollaborationGroup
                                           WHERE Id NOT IN :groupIds
                                           AND CollaborationType = 'Public'
                                           AND IsArchived = false
                                           ORDER BY LastFeedModifiedDate]){
            activeGroups.add(userGroup);
        }
    }

    public PageReference createNewGroup(){
        CollaborationGroup cGroup = new CollaborationGroup(
            name = groupName,
            Description = groupDesc,
            CollaborationType = access,
            CanHaveGuests = allowCustomer
        );
        try{
            insert cGroup;
            return new PageReference('/apex/KAR_ChatterGroup?g='+cGroup.Id);
        }
        catch(Exception e){
            System.debug(e);
            return null;
        }
    }


    public PageReference joinGroup(){
        CollaborationGroupMember gm = new CollaborationGroupMember(
            CollaborationGroupId = groupId,
            CollaborationRole = 'Standard',
            MemberId = UserInfo.getUserId(),
            NotificationFrequency = 'N'
        );
        try{
            insert gm;
            return new PageReference('/apex/KAR_ChatterGroup?g='+groupId);
        }
        catch(Exception e){
            System.debug(e);
            return null;
        }
    }
    
    private void resetView(){
        isFeed = false;
        isGroup = false;
        isMyFeed = false;
        isMyFollowers = false;
        isFollowing = false;
    }
}