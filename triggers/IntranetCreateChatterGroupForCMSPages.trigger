/*******************************************************************
* Author        :  Ashish Sharma(Appirio offshore)
* Name          :  IntranetCreateChatterGroupForCMSPages
* Date          :  September 09,2013
* Description   :  Create chatter group(if not exits) on CMSPage Insert
                   where(Create_Chatter_Group__c == true).
                   and create a Tags__c record with same name as 
                   team page name
                   10.5.2015 - Nick Marson - Commented out Tag creation logic as this is handled
                   in another trigger on the Intranet_Content__c
*******************************************************************/
trigger IntranetCreateChatterGroupForCMSPages on Intranet_Content__c (after insert) {
  map<String, Intranet_Content__c> nameCMSPageMap = new map<String, Intranet_Content__c>();
  map<String, CollaborationGroup> namechatterGroupMap = new map<String,CollaborationGroup>();
  list<CollaborationGroup> newChateGroupList = new list<CollaborationGroup>(); 
  list<Intranet_Content__c> cmsPageList = new list<Intranet_Content__c>();
  //list<Tags__c> toInsertTags = new list<Tags__c>();
  String cmsPageContentId = 
     Schema.SObjectType.Intranet_Content__c.getRecordTypeInfosByName().get('Intranet CMS Pages').getRecordTypeId();
  //Tags__c newTag;
  //Create list of all CMSPages where Create_Chatter_Group__c = true
  for(Intranet_Content__c cmsPage : trigger.new){
    if(cmsPage.Create_Chatter_Group__c == true && cmsPage.RecordTypeId == cmsPageContentId) {
      nameCMSPageMap.put(cmsPage.Name,cmsPage);
      cmsPageList.add(cmsPage);
    }
    
    //if(cmsPage.Template__c == 'Team' && cmsPage.RecordTypeId == cmsPageContentId){
        //newTag = new Tags__c();
        //newTag.Tag__c = cmsPage.Name;
        //toInsertTags.add(newTag);
    //}
  }
  
  
  //If Intranet Contents are not CMS Pages then return
  if(cmsPageList.size() == 0){
    return;
  }
  
  //If toInsertTags size is not zero insert
  //if(toInsertTags.size() != 0){
  
    //insert toInsertTags;
  //}
  
  //Populate map of already exits chatter groups present in nameCMSPageMap
  for(CollaborationGroup chatterGroup : [Select Id,Name from CollaborationGroup where Name in:nameCMSPageMap.KeySet()]){
    namechatterGroupMap.put(chatterGroup.Name,chatterGroup);  
  }
  
  //Create list of new chatter groups if previously not exits
  for(String CMSPageName : nameCMSPageMap.KeySet()){
    if(!namechatterGroupMap.containsKey(CMSPageName)) {
      newChateGroupList.add(new CollaborationGroup(Name = CMSPageName,CollaborationType = 'public',description = 'All news and information related to '+CMSPageName));
    }
  }
  
  //insert list of chatter groups
  if(!newChateGroupList.isEmpty()){
    try{
    insert newChateGroupList;  
    }catch(Exception e){
        
    }
  }
}