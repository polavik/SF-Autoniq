public with sharing class MarketingAttributeServices {
	@testVisible static final String PRIMARY_EXISTS_ERROR_MSG = Label.Primary_Already_Exists_Error_Msg;

	public static Map<Id, List<Marketing_Attribute__c>> groupByApplication(List<Marketing_Attribute__c> maList){
		Map<Id, List<Marketing_Attribute__c>> applicationToAttributes = new Map<Id, List<Marketing_Attribute__c>>();
		for(Marketing_Attribute__c ma : maList){
			if(applicationToAttributes.get(ma.Application__c) != null){
				applicationToAttributes.get(ma.Application__c).add(ma);
			} else {
				applicationToAttributes.put(ma.Application__c, new List<Marketing_Attribute__c>{ma});
			}
		}		
		return applicationToAttributes;
	}

	public static Boolean filterMarketingAttributes(List<Marketing_Attribute__c> maList){
		for(Marketing_Attribute__c ma : maList) {
			if(ma.Primary__c) return false;
		}
		return true;
	}

	public static List<Application__c> processMarketingAttributes(Map<Id, List<Marketing_Attribute__c>> triggerMap){
		List<Application__c> appsToUpdate = new List<Application__c>();
		for(Application__c app : [SELECT Id, (SELECT Id, Primary__c FROM Marketing_Attributes__r) FROM Application__c WHERE Id IN :triggerMap.keySet()]){
			Integer numOfPrimaries = countPrimaryAttributes(app.Marketing_Attributes__r);
			if(numOfPrimaries > 1){
				for(Marketing_Attribute__c ma : triggerMap.get(app.Id)){
					ma.addError(PRIMARY_EXISTS_ERROR_MSG);
				}
			} else {
				appsToUpdate.add(new Application__c(id=app.id, Ready_For_Submission__c=(numOfPrimaries == 1)));
			}
		}
		return appsToUpdate;
	}

	public static void updateApplications(List<Application__c> apps, Map<Id, List<Marketing_Attribute__c>> triggerMap){
		try {
			update apps;
		} 
		catch (DmlException e) {
			for (Integer i=0; i < e.getNumDml(); i++) {
				for (Marketing_Attribute__c maWithErr : triggerMap.get(apps[e.getDmlIndex(i)].Id) ) 
					maWithErr.addError(e.getDmlMessage(i));
			}
		}
	}

	@testVisible static Integer countPrimaryAttributes(List<Marketing_Attribute__c> maList){

		Integer numOfPrimaries = 0;
		for(Marketing_Attribute__c ma : maList){
			if(ma.Primary__c == true) numOfPrimaries++;
		}

		return numOfPrimaries;
	}

}