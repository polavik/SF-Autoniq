/* *************************************************
      copyright (c) Appirio Inc 2017
      
      author/date: unknown.
      purpose: Provide data on chatter group 
               membership to edgeforce.

      updated: 1/26/2017 Jim Cook (Appirio)
      change: 1.Added userMapForModal to allow the 
                "show all" modal to show all users.
              2. Increased the number of users 
                 shown in the sidebar from 5 to 15.
                 
**************************************************** */
public class EdgeForceChatterGroupController{
    public CollaborationGroup userGroup {get;set;}
    public List<ContentDocumentLink> groupFiles {get;set;} //all the files of the group
    public Boolean noFiles {get;set;} {noFiles=false;}    //if there is no any file in the group
    public String searchText {get;set;} //userName to be searched 

    public Boolean getIsMember(){
        return userRoleMap.containsKey(UserInfo.getUserId());
    }
    public Boolean getIsAdmin(){
        return getIsMember() ? 'Admin,Owner'.contains(userRoleMap.get(UserInfo.getUserId())) : false;
    }
    public Boolean getIsOwner(){
        return getIsMember() ? 'Owner'.contains(userRoleMap.get(UserInfo.getUserId())) : false;
    }
    
    public Map<Id,String> userRoleMap {get;set;}
    // UserMap is limited to fifteen users and is used in the sidebar.
    // UserMapForModal is unlimited and is used in teh popup window.
    public Map<Id,User> userMap         {get;set;}
    public Map<Id,User> userMapForModal {get;set;}

    public transient String fileData {get;set;}

    public EdgeForceChatterGroupController(){
        userRoleMap     = new Map<Id,String>();
        userMap         = new Map<Id,User>();
        userMapForModal = new Map<Id,User>();
        Id groupId = ApexPages.currentPage().getParameters().get('g');
        userGroup = [SELECT Id, FullPhotoUrl, Description, Name, Owner.Id, Owner.FirstName, 
                     Owner.LastName, Owner.SmallPhotoUrl, Owner.UserType, MemberCount, IsBroadcast
                     FROM CollaborationGroup
                     WHERE Id = :groupId];
        userRoleMap.put(userGroup.Owner.Id,'Owner');
        userMap.put(userGroup.Owner.Id,userGroup.Owner);
        userMapForModal.put(userGroup.Owner.Id,userGroup.Owner);
        for(CollaborationGroupMember member : [SELECT Member.Id, Member.SmallPhotoUrl, Member.FirstName,
                                               Member.LastName, Member.UserType, CollaborationRole
                                               FROM CollaborationGroupMember
                                               WHERE CollaborationGroupId = :userGroup.Id
                                               AND MemberId != :userGroup.Owner.Id]){
            userRoleMap.put(member.Member.Id,member.CollaborationRole);
            // Add the first fifteen members to the userMap. We only want to show fifteen ppl in the side bar.
            if(userMap.size()<15) userMap.put(member.Member.Id,member.Member);
            // Add everyone to the userMapForModal. We want to show everyone there.
            userMapForModal.put(member.Member.Id,member.Member);

        }
        groupFiles = [SELECT ContentDocument.LatestPublishedVersion.Title, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityid = :userGroup.Id];
        if(groupFiles.size() == 0){
            noFiles = true;
        }
    }
    
    public void showAllUsers(){
       for(CollaborationGroupMember member : [SELECT Member.Id, Member.SmallPhotoUrl, Member.FirstName,
                                               Member.LastName, Member.UserType, CollaborationRole
                                               FROM CollaborationGroupMember
                                               WHERE CollaborationGroupId = :userGroup.Id
                                               AND MemberId NOT IN :userMapForModal.keySet()]){
            //userRoleMap.put(member.Member.Id,member.CollaborationRole);
            userMap.put(member.Member.Id,member.Member);
            userMapForModal.put(member.Member.Id,member.Member);
        }
    }

    public PageReference joinGroup(){
        CollaborationGroupMember gm = new CollaborationGroupMember(
            CollaborationGroupId = userGroup.Id,
            CollaborationRole = 'Standard',
            MemberId = UserInfo.getUserId(),
            NotificationFrequency = 'N'
        );
        try{
            insert gm;
        }catch(Exception e){
            System.debug(e);
        }
        return null;
    }

    public PageReference leaveGroup(){
        CollaborationGroupMember gm = [SELECT Id
                                       FROM CollaborationGroupMember
                                       WHERE MemberId = :UserInfo.getUserId()
                                       AND CollaborationGroupId = :userGroup.Id LIMIT 1];
        try{
            delete gm;
        }catch(Exception e){
            System.debug(e);
        }
        return new PageReference('/apex/KAR_ChatterPage');
    }

    public void searchUser(){
        userMap = new Map<Id,User>();
        userRoleMap = new Map<Id,String>();
        if(searchText.length() == 0){
            showAllUsers();
        }else{
            searchText = searchText+'%';
            for(CollaborationGroupMember members : [SELECT MemberId, CollaborationRole, Member.FirstName, 
                                                    Member.LastName, Member.Id, Member.SmallPhotoUrl, Member.UserType
                                                    FROM CollaborationGroupMember
                                                    WHERE Member.FirstName LIKE :searchText
                                                    AND CollaborationGroupId = :userGroup.Id]){
                userRoleMap.put(members.Member.Id,members.CollaborationRole);
                userMap.put(members.Member.Id,members.Member);
                userMapForModal.put(members.Member.Id,members.Member);
            }
        }
    }

    public PageReference uploadPhoto() {
        Blob blobValue = EncodingUtil.base64Decode(fileData);
        ConnectApi.BinaryInput photoFileInput = new ConnectApi.BinaryInput(blobValue, 'image/jpg', 'groupphoto');
        ConnectApi.ChatterGroups.setPhoto(null, userGroup.Id, photoFileInput);

        return null;
    }

}