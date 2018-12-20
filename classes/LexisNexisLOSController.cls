/**
* Copyright 2014 Forseva, LLC. All rights reserved.
*/
public with sharing class LexisNexisLOSController extends ControllerBase {

    public LexisNexisLOSController() {

        try {        
            String scoreId = ApexPages.currentPage().getParameters().get('Id');
            m_score = (ApplicationScoring__c)DBUtility.getObjectWithAllFields(Id.valueOf(scoreId), ApplicationScoring__c.SObjectType);        
        
            Account a = DBUtility.getOwningAccount(m_score);
            a = (Account)DBUtility.getObjectWithAllFields(a.Id, Account.SObjectType);
            if(a.LexisNexis_Id__c == null) {
        	    m_accounts.add(a);
            }
        
            for(Account b : DBUtility.getRelatedAccounts(m_score.Application__c)) {
        	    Account c = (Account)DBUtility.getObjectWithAllFields(b.Id, Account.SObjectType);
                if(a.Id != c.Id) {
                    if(c.LexisNexis_Id__c == null) {
                	    m_accounts.add(c);
                    }            	
                }                
            }
                
            m_svc = new forseva1.LexisNexisReportService();
        }
        catch(Exception e) {
            handleException(e);
        }
    }

    //-----------------------
    // getters/setters
    //-----------------------

    public ApplicationScoring__c getScore() {
        return m_score;
    }

    public Account getCurrentAccount() {
        return m_accounts.size() != 0 ? m_accounts[0] : null;
    }

    public List<forseva1.CompanyLookupResultGlobal> getListOfSimilars() {

        try {    
            if(m_accounts.size() == 0) {
        	    return new List<forseva1.CompanyLookupResultGlobal>();
            }
            else {
        	    Account a = m_accounts.get(0);
                return m_svc.getListOfSimilars(a.Name, 
            	                               a.Corrected_P_Street__c != null ? a.Corrected_P_Street__c : a.Primary_Street1__c,
            	                               a.Corrected_P_City__c != null ? a.Corrected_P_City__c : a.Primary_City__c,
            	                               a.Corrected_P_State__c != null ? a.Corrected_P_State__c : a.Primary_State__c,
            	                               a.Corrected_P_Postalcode__c != null ? a.Corrected_P_Postalcode__c : a.Primary_Postalcode__c,
            	                               a.Primary_Country__c != null ? a.Primary_Country__c : '',
            	                               a.Phone != null ? a.Phone : '',
            	                               50, 
            	                               null);        
            }
        }
        catch(Exception e) {
            //handleException(e);
            addWarningMessage('Address incomplete or invalid. No candidate records can be matched.');
            return new List<forseva1.CompanyLookupResultGlobal>();
        }
    }

    //-----------------------
    // action methods
    //-----------------------

    public ApexPages.PageReference conditionalBypass() {
        
        if(m_accounts.size() > 0) {
            return null;
        } 
        else {
            ApexPages.PageReference p = Page.LexisNexis;
            p.getParameters().put('Id', m_score.Id);
            return p;        
        }
    } 

    public ApexPages.PageReference processSelection() {
    	
    	try {
            String lexisNexisId = ApexPages.currentPage().getParameters().get('companyId');
			 //Story B-44003 : FLS UPDATE ACCESS CHECK
			 Set<String> ListFLSUpdate = new Set<String>();
			 Boolean blnFLSOverride = Utils.GetFLS();
			 if (Schema.sObjectType.Account.fields.LexisNexis_Id__c.isUpdateable() || blnFLSOverride)
			 {						 
				m_accounts[0].LexisNexis_Id__c = lexisNexisId;
			 }
			 else
			 {						
				ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.LexisNexis_Id__c.getName());
			 }
			 if(ListFLSUpdate.size()>0)
			 {
			 	Utils.SendEmailforFLS('FLS_UPDATE','CLASS:LexisNexisLOSController', ListFLSUpdate);
			 }
 
            m_updateList.add(m_accounts.remove(0));
            if(m_accounts.size() == 0) {
            	update m_updateList;
                ApexPages.PageReference p = Page.LexisNexis;
                p.getParameters().put('Id', m_score.Id);
                return p;                    	
            }   
            else { 		
            	ApexPages.currentPage().getParameters().put('companyId',null);
    		    return ApexPages.currentPage();
            }
    	}
    	catch(Exception e) {
    		handleException(e);
    		return ApexPages.currentPage();
    	}
    }

    public ApexPages.PageReference doSkip() {

        try {
            m_accounts.remove(0);
            if(m_accounts.size() == 0) {
                update m_updateList;
                ApexPages.PageReference p = Page.LexisNexis;
                p.getParameters().put('Id', m_score.Id);
                return p;                       
            }   
            else {      
                ApexPages.currentPage().getParameters().put('companyId',null);            	
                return ApexPages.currentPage();
            }
        }
        catch(Exception e) {
            handleException(e);
            return ApexPages.currentPage();
        }
    }

    public ApexPages.PageReference doCancel() {
        ApexPages.PageReference p = new ApexPages.PageReference('/' + m_score.Id);
        return p; 
    }

    //----------------------
    // private
    //----------------------
        
    private ApplicationScoring__c             m_score;
    private List<Account>                     m_accounts = new List<Account>();
    private List<Account>                     m_updateList = new List<Account>();
    private forseva1.LexisNexisReportService  m_svc;    

}

// EOF