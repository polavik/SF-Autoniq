/**
* Copyright 2013-2014 Forseva, LLC. All rights reserved.
*/
trigger ApplicationScoringUpsert on ApplicationScoring__c (before insert, before update) {

    if(Trigger.isInsert) {

        String dtFormatted = Datetime.now().format('yyyy-MM-dd');
        List<Id> appIdList = new List<Id>();
        for(ApplicationScoring__c a : Trigger.new) {
            appIdList.add(a.Application__c);
        }
        Map<Id,Application__c> appMap = new Map<Id,Application__c>([select Id, Name from Application__c where Id in :appIdList]);

        for(ApplicationScoring__c a : Trigger.new) {
    	    Integer maxLength = Math.min(65, appMap.get(a.Application__c).Name.length());
            a.Name = appMap.get(a.Application__c).Name.substring(0,maxLength) + ' ' + dtFormatted;
            a.Primary__c = true;
        }
    }
    
}

// EOF