/**
* Copyright 2013 Forseva, LLC. All rights reserved.
*/
public with sharing class NewScoreController extends ControllerBase {

	public NewScoreController(ApexPages.StandardController sc) {
        m_application = (Application__c)DBUtility.getObjectWithAllFields(sc.getId(), Application__c.SObjectType);                
    }

    public ApexPages.PageReference navigateToNewApplicationScoring() {

        try {
            ApplicationScoring__c score = new ApplicationScoring__c(Application__c = m_application.Id);
            insert score;
            ApexPages.PageReference p = new ApexPages.PageReference('/' + score.Id);
            return p;
        }
        catch(Exception e) {
            handleException(e);
            return null;
        }
    }

    //----------------------
    // private
    //----------------------

    private Application__c m_application;
    
}

// EOF