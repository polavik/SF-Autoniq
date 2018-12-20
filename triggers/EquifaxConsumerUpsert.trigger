/**
* Copyright 2013 Forseva, LLC. All rights reserved.
*/
trigger EquifaxConsumerUpsert on forseva1__EquifaxConsumer__c (before insert) {

    UserContext__c uc = DBUtility.getUserContext();
    for(forseva1__EquifaxConsumer__c r : Trigger.new) {
        if(uc != null && uc.Current_Application_Scoring_Id__c != null) {
            r.Application_Scoring__c = uc.Current_Application_Scoring_Id__c;
        }    
    }

}

// EOF