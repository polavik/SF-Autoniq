//
// (c) 2014 Appirio, Inc.
//
// Handler Class for trigger IntranetContent_ShareWithPublicGroups
//
// November 3rd, 2014   Sidhant Agarwal     Original T-330482
// November 12th 2014   Sidhant Agarwal     Modified T-333321
// Description: Changed whole code
//
public class EF_ShareWithPublicGroupTriggerHandler {
    public static void createICSharing(Map<Id,Intranet_Content__c> newInstanceMap, Map<Id,Intranet_Content__c> oldInstanceMap){
        if(oldInstanceMap != null){
            List<Intranet_Content__Share> oldShares = [SELECT Id
                                                       FROM Intranet_Content__Share
                                                       WHERE ParentId IN :oldInstanceMap.keySet()
                                                       AND RowCause = 'Manual'];
            delete oldShares;
        }

        Map<Id,Set<Id>> mapOfICtoICBID = new Map<Id,Set<Id>>();
        for(Intranet_Content__c intraCont : newInstanceMap.values()){
            if(intraCont.Content_Bucket__c != null){
                if(mapOfICtoICBID.containsKey(intraCont.Content_Bucket__c)){
                    mapOfICtoICBID.get(intraCont.Content_Bucket__c).add(intraCont.Id);
                }else{
                    mapOfICtoICBID.put(intraCont.Content_Bucket__c,new Set<Id>{intraCont.Id});
                }
            }
        }

        Map<Id,Set<String>> viewerMap = new Map<Id,Set<String>>();
        Map<Id,Set<String>> adminMap = new Map<Id,Set<String>>();
        Set<String> groupSet = new Set<String>();
        List<Intranet_Content_Buckets__c> lstICB_Share = new List<Intranet_Content_Buckets__c>();
        for(Intranet_Content_Buckets__c icb : [SELECT Viewers__c, Permission_Groups__c
                                               FROM Intranet_Content_Buckets__c 
                                               WHERE Id IN :mapOfICtoICBID.keySet()]){
            viewerMap.put(icb.Id,splitAndTrim(icb.Viewers__c));
            adminMap.put(icb.Id,splitAndTrim(icb.Permission_Groups__c));
            groupSet.addAll(viewerMap.get(icb.Id));
            groupSet.addAll(adminMap.get(icb.Id));
        }

        Map<String,Id> groupMap = new Map<String,Id>();
        for(Group g : [SELECT Id, Name, DeveloperName FROM Group WHERE Name IN :groupSet OR DeveloperName IN :groupSet]){
            if(g.DeveloperName == 'AllInternalUsers'){
                groupMap.put(g.DeveloperName,g.Id);
            }else{
                groupMap.put(g.Name,g.Id);
            }
        }

        List<Intranet_Content__Share> IC_Shares = new List<Intranet_Content__Share>();
        //For each Intranet Content record being inserted/updated, 
        //create a sharing record to the group for that Intranet Content
        if(!mapOfICtoICBID.isEmpty()){
            for(Id icbId : mapOfICtoICBID.keySet()){
                for(Id icId : mapOfICtoICBID.get(icbId)){
                    for(String viewerGroup : viewerMap.get(icbId)){
                        Intranet_Content__Share ics = new Intranet_Content__Share(
                            ParentId = icId,
                            AccessLevel = 'Read',
                            UserOrGroupId = groupMap.get(viewerGroup)
                        );
                        IC_Shares.add(ics);
                    }
                    for(String adminGroup : adminMap.get(icbId)){
                        Intranet_Content__Share ics = new Intranet_Content__Share(
                            ParentId = icId,
                            AccessLevel = 'Edit',
                            UserOrGroupId = groupMap.get(adminGroup)
                        );
                        IC_Shares.add(ics);
                    }
                }
            }
        }
        //Insert all shares to the Database.
        try{
            insert IC_Shares;
        }catch (Exception e){
            System.Debug(e);
        }
    }

    private static Set<String> splitAndTrim(String groupString) {
        Set<String> setGroups = new Set<String>();
        if(!String.isEmpty(groupString)){
            for(String grpName : groupString.split(';')){
                if(grpName.trim() == 'All Internal Users - Default'){
                    setGroups.add('AllInternalUsers');
                } else {
                    setGroups.add(grpName.trim());
                }
            }
        }
        return setGroups;
    }
   
    /* This method is called by the Intranet Content trigger and verifies that the current 
       user is allowed to insert or update the record theya re attempting to save.
    */ 
    public static void verifyBucketMatch(Map<Id,Intranet_Content__c> newInstanceMap){   
        //Get the current user's ID.
        Id cUser = UserInfo.getUserId();

        // If the user is a sysadmin or 'Deployer', we'll let them update.
        id id1 = userinfo.getProfileId();
    // Modified by J. Steadman to include additional profile to satisfy new AFC Deployment role
        List<Profile> pn = [select Name from profile where id = :id1 limit 1];
        if(pn[0].Name == 'System Administrator' || pn[0].Name == 'Deployment' || pn[0].Name == 'AFC Production Administration') return;
    // End J. Steadman modifications    
        // Check to see if the user is a Site admin. If they are, let them edit.
        PermissionSet ps = [SELECT Id, Name from PermissionSet where Name = 'Intranet_Site_Manager' LIMIT 1];
        List<PermissionSetAssignment> psa = [SELECT Id, PermissionSetId, AssigneeId FROM PermissionSetAssignment where AssigneeId = :cUser and PermissionSetId = :ps.Id];
        if(psa != null && psa.size() > 0) return;
                                          
        // Get the groups that the current user belongs to.
        List<String> groups = new List<String>();
        for(GroupMember g : [SELECT Id, group.id, group.name, group.type 
                     FROM GroupMember 
                     where UserOrGroupId = :cUser AND group.type='Regular']) {
            groups.add(g.group.name);           
        }
        // If the user isn't in any groups, he can't edit anything. Raise an error on ALL items and return.
        if(groups.size() < 1) {
           for(Id z : newInstanceMap.keySet()) 
              newInstanceMap.get(z).addError('You are not a member of any groups.');        
           return;
        }
                    
        //Get the buckets that include those groups. These are the buckets that the current user can access.
        String qryString = 'Select ID, Permission_Groups__c from Intranet_Content_Buckets__c where Permission_Groups__c includes (';
        for(String g : groups) qryString += '\'' + g + '\',';
        qryString=qryString.substring(0, qryString.length()-1);
        qryString += ')';
        System.debug('$$$$$ qryString=' + qryString);
        List<Intranet_Content_Buckets__c> buckets = Database.query(qryString);
        
        // Check to see that all the insertions and updates are legit.
        boolean matchFound = false;
        Intranet_Content__c currentObject;
        System.debug('%%% newInstanceMap.keySet=' + newInstanceMap.keySet());
        for(Id w : newInstanceMap.keySet()) {
            currentObject = newInstanceMap.get(w);
            matchFound = false;
            for( Intranet_Content_Buckets__c d : buckets) {
                System.debug('!!!!! w=' + w + ' and d.Id=' + d.Id);
                if(currentObject.Content_Bucket__c == d.Id) matchFound = true;
            }
            if(!matchFound) {
                newInstanceMap.get(w).addError('You do not have the correct permissions to update (or insert) this record.');
            }
        }
    }
}