/* EF_SearchUtilities.cls
Description: Supports EdgeForce Searches - currently implements methods to remove unauthorized  
              results from Edgeforce searches. Implementing "with sharing" not an option as 
              EdgeForce has private OWD on Intranet_Content__c - which is necessary for searches.   
              FUture projects should investigate whether how to add appropriate sharing rule 
              or update the APEX Managed sharing to include sharing for RT --> "Config - Search"  
              Due to critical natue of the issue, we do not have time now to fully investigate the sharing change.
Author: Joe Castro, Appirio
Date: 27-MAR-2017
*/
public class EF_SearchUtilities {
    static Integer USER_RECORD_ACCESS_QUERY_LIMIT = 200;
    public static void RemoveUnauthorizedFromList(List<sObject> objList){
        List<List<sObject>> listOfLists = new List<List<sObject>>();
        listOfLists.add(objList);
        RemoveUnauthorizedFromLists(listOfLists);
    }

    public static void RemoveUnauthorizedFromLists(List<List<sObject>> objListList){
        // Get list of record Ids to get access control list 
        Map<Id, sObject> objMap = new Map<Id, sObject>();
        for(List<SObject> objList : objListList){
            objMap.putAll(objList);
        }
        Set<Id> idSet = objMap.keySet();
        List<Id> idList = new List<Id>(idSet);
        // FUTURE ENHANCEMENTS - you can operate on Sets below instead fo lists - the Set.Remove method may be simpler - no need to burn through in reverse order
		//System.debug('objListList.size(): ' + objListList.size());
        Map<Id, Boolean> objAccessMap = GetRecordAccessMap(idList);
        for(List<SObject> objList : objListList){
            //System.debug('Next objList size: ' + objList.size());
            if(objList != null && objList.size() > 0){
                // burn through the list in reverse order so you can remove restricted list items as you go
                for(Integer idx = objList.size()-1; idx>=0; idx--){
                    // NOTE: Feed, sObject and ContentVersion records will always have a sharing record.  No need to test for existentce - will be in objAccessList
                    sObject obj = objList[idx];
                    Boolean isAuthorized = true;
                    if(objAccessMap.get(obj.Id) == false){
                        isAuthorized = false;
                        objList.remove(idx);    
                    }
                    //System.debug(String.valueOf(obj.getsObjectType()) + ' (' + obj.Id + ') is Authorized? ' + isAuthorized);

                }
                //System.debug('Final (Authorized) objList size: ' + objList.size());             
            }
        }
    }

    private static Map<Id,Boolean> GetRecordAccessMap(List<Id> idList){
        Id userId = UserInfo.getUserId();
        Map<Id, Boolean> resultMap = new Map<Id, Boolean>();
        List<List<Id>> idListList = new List<List<Id>>();

        Integer idListSize = idList.size();
        if(idListSize <= USER_RECORD_ACCESS_QUERY_LIMIT){
            idListList.add(idList);
        }else{

            // create the right number of lists we are going to need for the idList size
            Integer listsNeeded = idListSize / USER_RECORD_ACCESS_QUERY_LIMIT;
            if(Math.mod(idListSize,USER_RECORD_ACCESS_QUERY_LIMIT) != 0){
                listsNeeded++;
            }
            for (Integer curList = 1; curList <= listsNeeded; curList++){
                idListList.add(new List<Id>());
            }

            // burn through idList putting 200 Ids in each list appropriately
            Integer currentListIdx = 0;
            Integer currentIdIdx = -1;
            for(Id currentId : idList){
                currentIdIdx++;
                // if currentList is full (index > 199 ), move on to next list and reset id index
                if(currentIdIdx >= USER_RECORD_ACCESS_QUERY_LIMIT){
                    currentListIdx++;
                    currentIdIdx = 0;
                }
                //System.debug('List[' + currentListIdx + '][' + currentIdIdx + ']');
                idListList[currentListIdx].add(currentId);        
            }
        }
        // NOTE: SOQL within a loop is necessary.  UserRecordAccess has SOQL limit of 200.  Use of this 
        // is max of 300 items, so expect to have only 2 iterations of SOQL queries - but if you are getting 
        // governor limit errors, the Search Controller needs to be refactored to use with sharing appropriately.        
        for(List<Id> curList : idListList){
            // SOQL Limitations - Can filter on only UserId = [single ID], either RecordId = [single ID] or RecordId IN [list of IDs], and Has*Access = true 
            // also, this SOQL query does not natively return into a Map<Id, sObject> - need to burn through it to create
            List<UserRecordAccess> objAccessList = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId = :userId AND RecordId IN :curList LIMIT 200]; 
            //System.debug('Retrieved ' + objAccessList.size() + ' access list records');
            for (UserRecordAccess ura : objAccessList){
              resultMap.put(ura.RecordId, ura.HasReadAccess);
              //System.debug(ura.RecordId + ' HasReadAccess: ' + ura.HasReadAccess);
            }     
        }
        return resultMap;
    }
}