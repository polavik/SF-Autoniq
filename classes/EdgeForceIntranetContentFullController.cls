/*
Created By : Vipul Jain
Created Date : July 15,2015
Description  : Controller for EF_Content_Full page.
*/
public with sharing class EdgeForceIntranetContentFullController {
		//String to hold team name selected by current user
		public String groupName{get; set;}
		public String tabName{get; set;}
		//Respective group id of selected team
		public Id groupId {get;set;}
		public String pageName {get;set;}
		public boolean showCRMContent{get;set;} {showCRMContent = true;}
		public EdgeForceIntranetContentFullController() {
			groupName = ApexPages.currentPage().getParameters().get('name');
			system.debug('####################'+ groupName);
			tabName =  ApexPages.currentPage().getParameters().get('tabName');
			//fetch groupId of selected team show chatter feed on IntranetTeam page.
			for(CollaborationGroup groupObj : [Select c.Name, c.Id From CollaborationGroup c where c.Name =: groupName limit 1] ) {
			        groupId = groupObj.Id;
			        system.debug('$$$$$$$$$$$$$$$$$'+ groupId);
			}
			if(ApexPages.currentPage().getParameters().get('name') != null) {
			        pageName = ApexPages.currentPage().getParameters().get('name');
			}
			for(Intranet_Content__C teamContent : [select Content_Type__C from Intranet_Content__C where name =: pageName]){
			    if(teamContent.content_type__c == 'Custom Content'){
			        showCRMContent = false;
			    }
			}
    }
}