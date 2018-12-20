//
// (c) 2014 Appirio, Inc.
//
// Handler Class for trigger IntranetContentBucket_ShareWithPublicGroups
//
// November 10th, 2014  Sidhant Agarwal     Original T-333318
// November 12th, 2014  Sidhant Agarwal     Modified T-333321
// Modified Deletion of IC Records
// November 13th, 2014  Sidhant Agarwal     Modified CR-Corrections
// November 26th, 2014  Sidhant Agarwal     Modified T-336281
// August 11th, 2017    Hawkins, Justin     AA: W-000053
//
public with sharing class EF_ShareWithViewersPublicGroups {
    public static void icbShareManager(Map<Id, Intranet_Content_Buckets__c> oldInstanceMap, Map<Id, Intranet_Content_Buckets__c> newInstanceMap) {
        Set<String> allGroupSet = new Set<String>();
        Set<Id> icbSet = new Set<Id>();

        Map<Id,Set<String>> oldViewersMap = new Map<Id,Set<String>>();
        Map<Id,Set<String>> oldAdminsMap = new Map<Id,Set<String>>();

        Map<Id,Set<String>> newViewersMap = new Map<Id,Set<String>>();
        Map<Id,Set<String>> newAdminsMap = new Map<Id,Set<String>>();

        for(Intranet_Content_Buckets__c icb : newInstanceMap.values()){
            Intranet_Content_Buckets__c oldIcb = oldInstanceMap.get(icb.Id);
            if(icb.Viewers__c != oldIcb.Viewers__c){
                oldViewersMap.put(icb.Id,compareGroups(oldIcb.Viewers__c,icb.Viewers__c));
                newViewersMap.put(icb.Id,compareGroups(icb.Viewers__c,oldIcb.Viewers__c));
                allGroupSet.addAll(newViewersMap.get(icb.Id));
                allGroupSet.addAll(oldViewersMap.get(icb.Id));
                icbSet.add(icb.Id);
            }
            if(icb.Permission_Groups__c != oldIcb.Permission_Groups__c){
                oldAdminsMap.put(icb.Id,compareGroups(oldIcb.Permission_Groups__c,icb.Permission_Groups__c));
                newAdminsMap.put(icb.Id,compareGroups(icb.Permission_Groups__c,oldIcb.Permission_Groups__c));
                allGroupSet.addAll(newAdminsMap.get(icb.Id));
                allGroupSet.addAll(oldAdminsMap.get(icb.Id));
                icbSet.add(icb.Id);
            }
        }

        Map<String,Id> groupIdMap = new Map<String,Id>();
        for(Group g : [SELECT Id, Name, DeveloperName FROM Group WHERE Name IN :allGroupSet OR DeveloperName IN :allGroupSet]){
            if(g.DeveloperName == 'AllInternalUsers'){
                groupIdMap.put(g.DeveloperName,g.Id);
            }else{
                groupIdMap.put(g.Name,g.Id);
            }
        }

        // BEGIN: AA: W-000053
        // Get and delete all old shares for Intranet Content and Intranet Content Buckets
        List<Intranet_Content__Share> oldICShares = new List<Intranet_Content__Share>();
        List<Intranet_Content_Buckets__Share> oldICBShares = new List<Intranet_Content_Buckets__Share>();
        List<Id> allOldIcbIds = new List<Id>();
        allOldIcbIds.addAll(oldViewersMap.keySet());
        allOldIcbIds.addAll(oldAdminsMap.keySet());

        // Get Intranet Content Shares for both viewers and admins
        for(Intranet_Content__Share ics : [SELECT Id, UserOrGroup.Name, AccessLevel, Parent.Content_Bucket__c FROM Intranet_Content__Share 
                                                                                                              WHERE Parent.Content_Bucket__c IN :allOldIcbIds])
        {
            // Admin Scenario
            if(oldAdminsMap.containsKey(ics.Parent.Content_Bucket__c)
                && ics.AccessLevel == 'Edit'
                && oldAdminsMap.get(ics.Parent.Content_Bucket__c).contains(ics.UserOrGroup.Name))
            {
                oldICShares.add(ics);
            }
            
            // Viewer Scenario            
            if(oldViewersMap.containsKey(ics.Parent.Content_Bucket__c)
                && ics.AccessLevel == 'Read'
                && oldViewersMap.get(ics.Parent.Content_Bucket__c).contains(ics.UserOrGroup.Name))
            {
                oldICShares.add(ics);
            }
        }

        // Get Intranet Content Buckets Shares for Admins
        for(Intranet_Content_Buckets__Share icbs : [SELECT Id, ParentId, UserOrGroup.Name
                                                    FROM Intranet_Content_Buckets__Share
                                                    WHERE ParentId = :oldAdminsMap.keySet()
                                                    AND AccessLevel = 'Edit'])
        {
            if(oldAdminsMap.containsKey(icbs.ParentId)
                && oldAdminsMap.get(icbs.ParentId).contains(icbs.UserOrGroup.Name))
            {
                oldICBShares.add(icbs);
            }
        }

        /*for(Id icbId : oldViewersMap.keySet()){
            oldICShares.addAll([SELECT Id
                                FROM Intranet_Content__Share
                                WHERE Parent.Content_Bucket__c = :icbId
                                AND UserOrGroup.Name IN :oldViewersMap.get(icbId)
                                AND AccessLevel = 'Read']);
        }
        for(Id icbId : oldAdminsMap.keySet()){
            oldICBShares.addAll([SELECT Id
                                 FROM Intranet_Content_Buckets__Share
                                 WHERE ParentId = :icbId
                                 AND UserOrGroup.Name IN :oldAdminsMap.get(icbId)
                                 AND AccessLevel = 'Edit']);
            oldICShares.addAll([SELECT Id
                                FROM Intranet_Content__Share
                                WHERE Parent.Content_Bucket__c = :icbId
                                AND UserOrGroup.Name IN :oldAdminsMap.get(icbId)
                                AND AccessLevel = 'Edit']);
        }*/
        // END: AA: W-000053
        delete oldICShares;
        delete oldICBShares;

        // If updated create and update new shares
        if(oldInstanceMap != null){
            List<Intranet_Content__Share> newICShares = new List<Intranet_Content__Share>();
            List<Intranet_Content_Buckets__Share> newICBShares = new List<Intranet_Content_Buckets__Share>();
            for(Intranet_Content__c ic : [SELECT Id, Content_Bucket__c
                                          FROM Intranet_Content__c
                                          WHERE Content_Bucket__c IN :icbSet]){
                if(newViewersMap.containsKey(ic.Content_Bucket__c)){
                    for(String viewer : newViewersMap.get(ic.Content_Bucket__c)){
                        if(groupIdMap.containsKey(viewer)){
                            Intranet_Content__Share icShare = new Intranet_Content__Share(
                                ParentId = ic.Id,
                                UserOrGroupId = groupIdMap.get(viewer),
                                AccessLevel = 'Read'
                            );
                            newICShares.add(icShare);
                        }else{
                            newInstanceMap.get(ic.Content_Bucket__c).addError('Group not found: '+viewer);
                        }
                    }
                }
                if(newAdminsMap.containsKey(ic.Content_Bucket__c)){
                    for(String admin : newAdminsMap.get(ic.Content_Bucket__c)){
                        if(groupIdMap.containsKey(admin)){
                            Intranet_Content__Share icShare = new Intranet_Content__Share(
                                ParentId = ic.Id,
                                UserOrGroupId = groupIdMap.get(admin),
                                AccessLevel = 'Edit'
                            );
                            newICShares.add(icShare);
                        }else{
                            newInstanceMap.get(ic.Content_Bucket__c).addError('Group not found: '+admin);
                        }
                    }
                }
            }
            for(Id icb : icbSet){
                if(newAdminsMap.containsKey(icb)){
                    for(String admin : newAdminsMap.get(icb)){
                        if(groupIdMap.containsKey(admin)){
                            Intranet_Content_Buckets__Share icbShare = new Intranet_Content_Buckets__Share(
                                ParentId = icb,
                                UserOrGroupId = groupIdMap.get(admin),
                                AccessLevel = 'Edit'
                            );
                            newICBShares.add(icbShare);
                        }else{
                            newInstanceMap.get(icb).addError('Group not found: '+admin);
                        }
                    }
                }
            }
            insert newICShares;
            insert newICBShares;
        }
    }

    private static Set<String> compareGroups(String icb, String oldIcb){
        Set<String> groupSet = new Set<String>();
        Set<String> oldGroupSet = splitAndTrim(oldIcb);
        for(String newGroup : splitAndTrim(icb)){
            if(!oldGroupSet.contains(newGroup)){
                groupSet.add(newGroup);
            }
        }
        return groupSet;
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
}