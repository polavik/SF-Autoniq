public class EF_ContentDocumentSharingTriggerHandler {
	public static void checkContentShare(List<ContentVersion> newList){
		List<ContentVersion> cvList = new List<ContentVersion>();
		for(ContentVersion cv : newList){
			if(!String.isEmpty(cv.Team__c)){
				cvList.add(cv);
			}
		}
		if(!cvList.isEmpty()){
			Set<String> grpNameSet = new Set<String>(); 
	    for(GroupMember grpMem : [SELECT UserOrGroupId, GroupId, Group.Name FROM GroupMember 
	                              WHERE UserOrGroupId = :UserInfo.getUserId() LIMIT 1000]){           
	        grpNameSet.add(grpMem.Group.Name);
	    }
	    Set<String> lstContBucket = new Set<String>();
	    for(Intranet_Content_Buckets__c intraBucket : [SELECT Id,(SELECT Id, Name
	    																													FROM Intranet_Content1__r
	    																													WHERE RecordType.Name = 'Intranet CMS Pages'),
	                                                   Permission_Groups__c  
	                                                   FROM Intranet_Content_Buckets__c]){
	        if(intraBucket.Permission_Groups__c != null){
	            for(String grp : intraBucket.Permission_Groups__c.split(';')){
	                if(grpNameSet.contains(grp)){
	                    for(Intranet_Content__c ic : intraBucket.Intranet_Content1__r){
	                        lstContBucket.add(ic.Name);
	                    }
	                }
	            }
	        }
	    }
			for(ContentVersion cv : cvList){
				for(String team : cv.Team__c.split(';')){
					if(!lstContBucket.contains(team)){
						cv.addError('You must be an admin of the page to share the document to the '+team+' page.');
					}
				}
			}
		}
	}

}