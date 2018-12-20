global without sharing class ArticleTaggingController {
    public static final String CMS_RECORD_TYPE = 'Intranet CMS Pages';
    public ArticleTaggingController(ApexPages.StandardController controller) {
        articleID = controller.getId();
    }


    public String articleID {get; set;}
    
    /* constructor */
    public ArticleTaggingController(){
        //articleID = ApexPages.currentPage().getParameters().get('id');
    }
    
    public static Map<String, Id> mapOfTagNameAndId {
        get{
            if(mapOfTagNameAndId == null){
                mapOfTagNameAndId = new Map<String, Id>();
                for(Tags__c tg : [SELECT Id, Tag__c FROM Tags__c]){
                    mapOfTagNameAndId.put(tg.Tag__c, tg.Id);
                }
            }
            return mapOfTagNameAndId;
        }
        private set;
    }
    
    /**
    @author Manish
    @purpose get the list of all the tags from in Tags__c object
    */
    @RemoteAction
    global static WrapperClass fetchListOfTags(){
        String profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
        List<Tags__c> listOfTags =  new List<Tags__c>();
        Set<String> nonAdminPages = new Set<String>();
//        if(profileName == 'System Administrator'){
        	// If the user is a sys admin, they can tag anything.
            listOfTags = [SELECT Id, Tag__c FROM Tags__c WHERE Tag__c != null];
/*        } else {
        	// If they are not, we must determine whether or not they are allowed to add tags.
        	// First we get the list of groups they belong to.
            Set<String> grpNameSet = new Set<String>(); 
            for(GroupMember grpMem : [Select UserOrGroupId, GroupId, Group.Name From GroupMember 
                                        where UserOrGroupId =: UserInfo.getUserId() LIMIT 1000]){           
                grpNameSet.add(grpMem.Group.Name);
            }
            system.debug('grpNameSet********'+grpNameSet);
            
            // Next, we go to the Content Buckets and create a set containing the names of all the content that belongs to the group.
            Set<String> lstContBucket = new Set<String>();
            for(Intranet_Content_Buckets__c intraBucket : [SELECT Id,(SELECT Id, Name FROM Intranet_Content1__r),
                                                           Permission_Groups__c  
                                                           FROM Intranet_Content_Buckets__c]) {
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
            system.debug('lstContBucket********'+lstContBucket);
            Set<String> intraContNameSet = new Set<String>();
            nonAdminPages = new Set<String>();

            String dbQuery = 'SELECT Id, Tag__c FROM Tags__c';
            for(Intranet_Content__c contentData : [SELECT Id, Name, Content_Bucket__c 
                                                   FROM Intranet_Content__c 
                                                   WHERE RecordType.Name = :CMS_RECORD_TYPE 
                                                   LIMIT 1000]){
                if(lstContBucket.contains(contentData.Name)){
                    intraContNameSet.add(contentData.Name);
                } else {
                    nonAdminPages.add(contentData.Name);
                }
            }
            system.debug('intraContNameSet********'+intraContNameSet);
            dbQuery += ' where Tag__c IN :intraContNameSet';
            listOfTags =  new List<Tags__c>();
            for(Tags__c tg : Database.query(dbQuery)){
                if(String.isNotBlank(tg.Tag__c)){
                    listOfTags.add(tg);
                 }
            }
        }
*/
        WrapperClass wrap = new WrapperClass(listOfTags, nonAdminPages);
        return wrap;
    }
    
    @RemoteAction
    global static Boolean addTags(String tagString, String artID){
        List<Intranet_Content_Tags__c> listOfArticleTags = new List<Intranet_Content_Tags__c>();
        
        for(Intranet_Content_Tags__c artTags :  [SELECT Id FROM Intranet_Content_Tags__c WHERE Intranet_Content__c = :artID]){
            listOfArticleTags.add(artTags);
        }
        
        Database.delete(listOfArticleTags);
        
        List<Tags__c> listOfNewTags = new List<Tags__c>();
        
        listOfArticleTags = new List<Intranet_Content_Tags__c>();
        for(String s : tagString.split(',')){
            if(String.isNotBlank(s)){
                if(mapOfTagNameAndId.containsKey(s)){
                    listOfArticleTags.add(new Intranet_Content_Tags__c(Tags__c = mapOfTagNameAndId.get(s), Intranet_Content__c = artID));
                }else{
                    Tags__c newTag = new Tags__c(Tag__c = s);
                    listOfNewTags.add(newTag);
                }
            }
        }
        
        Database.insert(listOfNewTags);
        
        for(Tags__c tg : listOfNewTags){
            listOfArticleTags.add(new Intranet_Content_Tags__c(Tags__c = tg.Id, Intranet_Content__c = artID));
        }
        
        Database.insert(listOfArticleTags);
        
        return true;
    }
    
    /**
    @author Manish
    @purpose get the list of all the tags associated with this Article from in Intranet_Content_Tags__c object
    */
    public List<Intranet_Content_Tags__c> getListOfArticleTags(){
        List<Intranet_Content_Tags__c> listOfArticelTags =  new List<Intranet_Content_Tags__c>();
        if(String.isNotBlank(articleID)){
            for(Intranet_Content_Tags__c tg : [SELECT Id, Name, Tags__r.Tag__c, Tags__r.Id 
                                               FROM Intranet_Content_Tags__c 
                                               WHERE Intranet_Content__c = :articleID]){
                listOfArticelTags.add(tg);
            }
        }
        return listOfArticelTags;
    }
    
    global class WrapperClass {
        public List<Tags__c> listOfTags = new List<Tags__c>();
        public Set<String> adminPages =  new Set<String>();

        public wrapperClass(List<Tags__c> tags, Set<String> pages) {
            listOfTags = tags;
            adminPages = pages;
        }
    }
}