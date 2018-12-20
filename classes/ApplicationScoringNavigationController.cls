/**
* Copyright 2013-2014 Forseva, LLC. All rights reserved.
*/
public with sharing class ApplicationScoringNavigationController extends ControllerBase {

    public ApplicationScoringNavigationController(ApexPages.StandardController sc) {    	
        m_score = (ApplicationScoring__c)DBUtility.getObjectWithAllFields(sc.getId(), ApplicationScoring__c.SObjectType);
        m_account = DBUtility.getOwningAccount(m_score);
    }

    public ApexPages.PageReference navigateToNextPage() {
    
        try {
        	
            String dest = ApexPages.currentPage().getParameters().get('dest');
            UserContext__c uc = DBUtility.getUserContext();
			
			uc.Current_Application_Id__c = m_score.Application__c;
			uc.Current_Application_Scoring_Id__c = m_score.Id;
			
			/*
			//Story B-44003 : FLS UPDATE ACCESS CHECK
			Set<String> ListFLSUpdate = new Set<String>();
			Set<String> ListFLSCreate = new Set<String>();
			Boolean blnFLSOverride = Utils.GetFLS();
			if (Schema.sObjectType.UserContext__c.fields.Current_Application_Id__c.isUpdateable() && Schema.sObjectType.UserContext__c.fields.Current_Application_Id__c.isCreateable() || blnFLSOverride)
			{
				uc.Current_Application_Id__c = m_score.Application__c;
			}
			else
			{						
				ListFLSUpdate.add(Schema.sObjectType.UserContext__c.getName()+'.'+Schema.sObjectType.UserContext__c.fields.Current_Application_Id__c.getName());
				ListFLSCreate.add(Schema.sObjectType.UserContext__c.getName()+'.'+Schema.sObjectType.UserContext__c.fields.Current_Application_Id__c.getName());
			}
			if (Schema.sObjectType.UserContext__c.fields.Current_Application_Scoring_Id__c.isUpdateable() && Schema.sObjectType.UserContext__c.fields.Current_Application_Scoring_Id__c.isCreateable() || blnFLSOverride)
			{
				uc.Current_Application_Scoring_Id__c = m_score.Id;
			}
			else
			{						
				ListFLSUpdate.add(Schema.sObjectType.UserContext__c.getName()+'.'+Schema.sObjectType.UserContext__c.fields.Current_Application_Scoring_Id__c.getName());
				ListFLSCreate.add(Schema.sObjectType.UserContext__c.getName()+'.'+Schema.sObjectType.UserContext__c.fields.Current_Application_Scoring_Id__c.getName());
			}
			
			if(ListFLSUpdate.size()>0)
			{
				Utils.SendEmailforFLS('FLS_UPDATE','CLASS:ApplicationScoringNavigationController', ListFLSUpdate);
				return null ; 
			}
			if(ListFLSCreate.size()>0)
			{
				Utils.SendEmailforFLS('FLS_CREATE','CLASS:ApplicationScoringNavigationController', ListFLSCreate);
				return null;
			}
			*/
            upsert uc;

            if(dest != null) {            	
                if(dest == DBUtility.LEXISNEXIS) {
                    ApexPages.PageReference p = Page.LexisNexisLOS;
                    p.getParameters().put('id', m_score.Id);
                    return p;            
                }
                else if(dest == TOTALSCORE) {
                    ScoringManager sm = new ScoringManager(m_score);
                    sm.score();            
                    ApexPages.PageReference p = new ApexPages.PageReference('/' + m_score.Id);
                    return p;
                }
                else if(dest == DBUtility.EQUIFAX) {
                    DBUtility.setCreditPolicy(m_account.Id, DBUtility.EQUIFAX);
                    ApexPages.PageReference p = Page.forseva1__ConsumerCreditReportRequest;
                    p.getParameters().put('fromId', m_score.Id);
                    p.getParameters().put('accountId', m_account.Id);
                    p.getParameters().put('parameterString', 'accountId:' + m_account.Id + ',bureau:' + DBUtility.EQUIFAX);
                    return p;                                                                                        
                }
                else if(dest == DBUtility.EXPERIAN) {                          
                    DBUtility.setCreditPolicy(m_account.Id, DBUtility.EXPERIAN);
                    ApexPages.PageReference p = Page.forseva1__ConsumerCreditReportRequest;
                    p.getParameters().put('fromId', m_score.Id);
                    p.getParameters().put('accountId', m_account.Id);
                    p.getParameters().put('parameterString', 'accountId:' + m_account.Id + ',bureau:' + DBUtility.EXPERIAN);
                    return p;                                                                                        
                }
                else if(dest == DBUtility.TRANSUNION) {
                    //DBUtility.setCreditPolicy(m_account.Id, DBUtility.TRANSUNION);                                                
                    //ApexPages.PageReference p = Page.forseva1__ConsumerCreditReportRequest;
                    //p.getParameters().put('fromId', m_score.Id);
                    //p.getParameters().put('accountId', m_account.Id);
                    //p.getParameters().put('parameterString', 'accountId:' + m_account.Id + ',bureau:' + DBUtility.TRANSUNION);
                    //return p;
                    DBUtility.createEmptyTURecords(m_account.Id, m_score.Application__c, m_score.Id);
                    ApexPages.PageReference p = new ApexPages.PageReference('/' + m_score.Id);
                    return p;                                                                                        
                }
            }

            ApexPages.PageReference p = new ApexPages.PageReference('/' + m_score.Id);
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
    
    private static String TOTALSCORE = 'TotalScore';
    private ApplicationScoring__c m_score;
    private Account m_account;
    
}

// EOF