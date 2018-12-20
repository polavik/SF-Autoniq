/**
* Copyright 2013 Forseva, LLC. All rights reserved.
*/
trigger LexisNexisUpsert on forseva1__LexisNexisReport__c (before insert) {

    UserContext__c uc = DBUtility.getUserContext();
    for(forseva1__LexisNexisReport__c r : Trigger.new) {
        if(uc != null && uc.Current_Application_Scoring_Id__c != null) {
            r.Application_Scoring__c = uc.Current_Application_Scoring_Id__c;
        }    
    }

}

// EOF