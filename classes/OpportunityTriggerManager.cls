/*
*Appirio Inc. 2016
*Name  : OpportunityTriggerManager
*Author: Amit SanWariya (Appirio)
*Date  : 12 Oct, 2016
*Description: Filters Opportunites to restrict open Opportunity count to 100 for an owner
*Modified By: Sumit Tanwar (Appirio) Ref T-549774 - added two methods setAccountInlaneStatusFields, recalculateFieldsOnBypass
*Modified By: Amit Sanwariya (Appirio) Ref T-550099 - changed the limit from fixed 100 to being editable from Custom Metadata Type, added profile exclusion too.
*Moidifed By: Arvind Thakur (Appirio) Ref I-277935 - Adding Metadata Setting so that the code works only on Added Profiles
*/
public class OpportunityTriggerManager {
    
    //Method to limit opportunity creation or owner change 
    public static void LimitOpportunityCreation(List<Opportunity> newOppList, Map<Id, Integer> ownerIdToCountMap) {
        //Get Opportunity Limits
        Opportunity_Setting__mdt oppLimits = [SELECT Id, DeveloperName, Opportunity_Limit__c, Profiles_With_Opportunity_Limit__c
                                              FROM Opportunity_Setting__mdt 
                                              Where DeveloperName = 'Opportunity_Records_Limits' 
                                              LIMIT 1];
        
        Set<String> allowedProfilesSet = new Set<String>();
        for(String profileNames : oppLimits.Profiles_With_Opportunity_Limit__c.split(',')) {
            allowedProfilesSet.add(profileNames.trim());
        }
        
        Profile currentUserProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String profileName = currentUserProfile.Name;
        
        //Get owner and count of opportunity per owner
        for (AggregateResult result: [SELECT count(Id), OwnerId
                                      FROM Opportunity
                                      WHERE IsClosed = false
                                      AND OwnerId in :ownerIdToCountMap.keySet()
                                      GROUP BY OwnerId]) {
            ownerIdToCountMap.put((Id)result.get('OwnerId'), (Integer)result.get('expr0'));
        }
        
        //Add error when limits exceed
        for(Opportunity opp: newOppList) {
            ownerIdToCountMap.put(opp.OwnerId, ownerIdToCountMap.get(opp.OwnerId) + 1);
            if(ownerIdToCountMap.get(opp.OwnerId) > oppLimits.Opportunity_Limit__c && allowedProfilesSet.contains(profileName)) {
                opp.addError(Label.Opportunity_Limit_Error);
            }
        }
    }
    
    public static void setAccountInlaneStatusFields(List<Opportunity> newOppList){
        Map<Id, List<Opportunity>> accOppMap = new Map<Id, List<Opportunity>>();
        Map<Id, User> mapuser = new Map<Id, User>();
        Set<Id> userIds = new Set<Id>();
        
        for(Opportunity o: newOppList){
            if(o.AccountId != null){
                userIds.add(o.OwnerId);
                if(!accOppMap.containsKey(o.AccountId)){
                    accOppMap.put(o.AccountId, new List<Opportunity>());
                }
                accOppMap.get(o.AccountId).add(o);
            }
        }
        
        for(user u: [Select Id, ADESAAUCTION__c from user where Id IN: userIds]){
            mapuser.put(u.Id, u);
        }
        
        for(Auction_Detail__c ad: [Select Id, Account__c, Auction__c, Auction__r.Name, Inlane_Seller_Status__c, Buyer_Category__c from Auction_Detail__c Where Account__c IN: accOppMap.keySet()]){
            if(accOppMap.containsKey(ad.Account__c)){
                for(Opportunity o: accOppMap.get(ad.Account__c)){
                    if(mapuser.containsKey(o.OwnerId) && ad.Auction__c !=null && ad.Auction__r.Name.equals(mapuser.get(o.OwnerId).ADESAAUCTION__c)){
                        o.Account_Inlane_Seller_Status__c = ad.Inlane_Seller_Status__c;
                        o.Account_Buyer_Category_Status__c = ad.Buyer_Category__c;
                    }
                }
            }
        }
    }
    
    public static void setOpportunityStartFields(List<Opportunity> newOppList){
        Map<Id, List<Opportunity>> accOppMap = new Map<Id, List<Opportunity>>();

        for(Opportunity o: newOppList){
            if(o.AccountId != null){
                //userIds.add(o.OwnerId);
                if(!accOppMap.containsKey(o.AccountId)){
                    accOppMap.put(o.AccountId, new List<Opportunity>());
                }
                accOppMap.get(o.AccountId).add(o);
            }
        }
        
        for(Auction_Detail__c ad: [Select Id, Account__c, Auction__c, Auction__r.Name, Inlane_Seller_Status__c, Buyer_Category__c from Auction_Detail__c Where Account__c IN: accOppMap.keySet()]){
            if(accOppMap.containsKey(ad.Account__c)){
                for(Opportunity o: accOppMap.get(ad.Account__c)){
                    o.Account_Inlane_Seller_Status_at_Opportun__c = ad.Inlane_Seller_Status__c;
                    o.Account_Buyer_Category_Status_Op_Start__c = ad.Buyer_Category__c;
                }
            }
        }
    }
    
    public static void recalculateFieldsOnBypass(List<Opportunity> newOppList){
        Map<Id, List<Opportunity>> accOppMap = new Map<Id, List<Opportunity>>();
        Map<Id, User> mapuser = new Map<Id, User>();
        Set<Id> userIds = new Set<Id>();
        
        for(Opportunity o: newOppList){
            if(o.Bypass_Inlane_Seller_Status__c && o.AccountId != null){
                userIds.add(o.OwnerId);
                if(!accOppMap.containsKey(o.AccountId)){
                    accOppMap.put(o.AccountId, new List<Opportunity>());
                }
                accOppMap.get(o.AccountId).add(o);
            }
        }       
        
        for(user u: [Select Id, ADESAAUCTION__c from user where Id IN: userIds]){
            mapuser.put(u.Id, u);
        }
        
        for(Auction_Detail__c ad: [Select Id, Account__c, Auction__c, Auction__r.Name, Inlane_Seller_Status__c, Buyer_Category__c from Auction_Detail__c Where Account__c IN: accOppMap.keySet()]){
            if(accOppMap.containsKey(ad.Account__c)){
                for(Opportunity o: accOppMap.get(ad.Account__c)){
                    if(mapuser.containsKey(o.OwnerId) && ad.Auction__c !=null && ad.Auction__r.Name.equals(mapuser.get(o.OwnerId).ADESAAUCTION__c)){
                        o.Account_Inlane_Seller_Status_at_Opportun__c = ad.Inlane_Seller_Status__c;
                        o.Account_Buyer_Category_Status_Op_Start__c = ad.Buyer_Category__c;
                        o.Bypass_Inlane_Seller_Status__c = false;
                    }
                }
            }
        }
    }
}