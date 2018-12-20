/**
* Copyright 2013 Forseva, LLC. All rights reserved.
*/
public with sharing class LexisNexisController extends ControllerBase {

    public LexisNexisController() {
    	
    	String scoreId = ApexPages.currentPage().getParameters().get('Id');
        m_score = (ApplicationScoring__c)DBUtility.getObjectWithAllFields(Id.valueOf(scoreId), ApplicationScoring__c.SObjectType);
        m_svc = new forseva1.LexisNexisReportService();
    }

    //-----------------------
    // public getters/setters
    //-----------------------

    public ApplicationScoring__c getScore() {
        return m_score;
    }

    public List<ContactSelection> getRelatedContacts() {

        if(m_contacts != null) {
            return m_contacts;
        }
        else {
            m_contacts = new List<ContactSelection>();
        }        

        for(Contact c : DBUtility.getRelatedContacts(m_score.Application__c)) {
            m_contacts.add(new ContactSelection(c,true));
        }
        
        return m_contacts;    
    }

    public List<AccountSelection> getRelatedAccounts() {
    
        if(m_accounts != null) {
            return m_accounts;
        }
        else {
            m_accounts = new List<AccountSelection>();
        }        

        Application__c app = (Application__c)DBUtility.getObjectWithAllFields(m_score.Application__c, Application__c.SObjectType);
        Account acct = DBUtility.getOwningAccount(app);
        m_accounts.add(new AccountSelection(acct,true));

        for(Account a : DBUtility.getRelatedAccounts(m_score.Application__c)) {
        	if(a.Id != acct.Id) {
                m_accounts.add(new AccountSelection(a,true));
        	}                
        }
                
        return m_accounts;
    } 

    public List<SelectOption> getReportTypeChoices() {
    
        List<SelectOption> choices = new List<SelectOption>();
        choices.add(new SelectOption(DBUtility.COMPREHENSIVE_PERSON_REPORT,DBUtility.COMPREHENSIVE_PERSON_REPORT));
        choices.add(new SelectOption(DBUtility.ENHANCED_BUSINESS_REPORT,DBUtility.ENHANCED_BUSINESS_REPORT));
        choices.add(new SelectOption(DBUtility.UCC_FILING_SEARCH,DBUtility.UCC_FILING_SEARCH));
        choices.add(new SelectOption(DBUtility.CORPORATE_FILING_SEARCH,DBUtility.CORPORATE_FILING_SEARCH));
        return choices;
    }

    public String getCurrentReportType() {
        return m_currentReportType;
    }

    public void setCurrentReportType(String reportType) {
        m_currentReportType = reportType;
    }

    public Boolean getIsContactPanelActive() {
        return (m_currentReportType == DBUtility.COMPREHENSIVE_PERSON_REPORT);
    }

    public Boolean getIsDone() {
        return m_isDone;
    }

    //-----------------------
    // action methods 
    //-----------------------

    public void reportTypeChosen() {
    	
        m_pullCounter = 0;
        m_isDone = false;
        for(ContactSelection cSel : m_contacts) {
            cSel.setSelected(true);
            cSel.setHitStatus('');
        }
        for(AccountSelection aSel : m_accounts) {
            aSel.setSelected(true);
            aSel.setHitStatus('');
        }
    }

    public void getNextReport() {
    
        forseva1__LexisNexisReport__c report;
    
        try {
            if(m_isDone) {
                return;
            }

            if(m_currentReportType == DBUtility.COMPREHENSIVE_PERSON_REPORT) {

                ContactSelection cSel = m_contacts[m_pullCounter];
                if(cSel.getSelected()) {
                    Contact c = cSel.getContact();
                    stageProperAddressFields(c);
                    Account a = (Account)DBUtility.getObjectWithAllFields(c.AccountId, Account.SObjectType);         
                    stageProperAddressFields(a);       
            
                    forseva1.Person p = new forseva1.Person();
                    p.FirstName = c.FirstName;
                    p.LastName = c.LastName;
                    p.UnparsedAddress = c.MailingStreet;
                    p.City = c.MailingCity;
                    p.State = c.MailingState;
                    p.PostalCode = c.MailingPostalCode;
                    p.Phone = c.Phone;
                    p.DateOfBirth = c.Birthdate;
                    p.PersonId = c.Id;   

                    report = (forseva1__LexisNexisReport__c)m_svc.getReport(DBUtility.COMPREHENSIVE_PERSON_REPORT, 
                              new Map<String,String>{'BusinessId'=>toString(a.LexisNexis_Id__c), 'GLBPurpose'=>'1', 'DLPurpose'=>'3'}, a, p);                        
                    cSel.setHitStatus(Label.Done);                        
                }
                m_pullCounter++;
                if(m_pullCounter == m_contacts.size()) {
                    m_isDone = true;
                }
            }
            else {

                AccountSelection aSel = m_accounts[m_pullCounter];
                if(aSel.getSelected()) {                
                    Account a = (Account)DBUtility.getObjectWithAllFields(aSel.getAccount().Id, Account.SObjectType);
                    stageProperAddressFields(a);

                    if(m_currentReportType == DBUtility.ENHANCED_BUSINESS_REPORT) {
                        report = (forseva1__LexisNexisReport__c)m_svc.getReport(DBUtility.ENHANCED_BUSINESS_REPORT, 
                                  new Map<String,String>{'BusinessId'=>toString(a.LexisNexis_Id__c)}, a, null);
                    }
                    else if(m_currentReportType == DBUtility.UCC_FILING_SEARCH) {
                        report = (forseva1__LexisNexisReport__c)m_svc.getSearchResults(DBUtility.UCC_FILING_SEARCH, 
                                  new Map<String,String>{'BusinessId'=>toString(a.LexisNexis_Id__c)}, a, null, null, null, 200, 1);	
                    }
                    else if(m_currentReportType == DBUtility.CORPORATE_FILING_SEARCH) {
                        report = (forseva1__LexisNexisReport__c)m_svc.getSearchResults(DBUtility.CORPORATE_FILING_SEARCH, 
                                  new Map<String,String>{'BusinessId'=>toString(a.LexisNexis_Id__c)}, a, null, null, null, 200, 1);                
                    }
                    aSel.setHitStatus(Label.Done);
                }
                m_pullCounter++;
                if(m_pullCounter == m_accounts.size()) {
                    m_isDone = true;
                }
            }
            
            if(report != null) {
                DBUtility.parseLexisNexisReportFields(report.Id);    // parse out active UCC count
            }
        }
        catch(Exception e) {
            handleException(e);
        }                
    }

    public ApexPages.PageReference doCancel() {
        ApexPages.PageReference p = new ApexPages.PageReference('/' + m_score.Id);
        return p; 
    }

    //-----------------------
    // inner classes 
    //-----------------------

    public class ContactSelection {
        
        public ContactSelection(Contact c, Boolean s) {
            m_contact = c;
            m_selected = s;
        }
        
        public Contact getContact() {return m_contact;}
        public String getHitStatus() {return m_hitStatus;}
        public void setHitStatus(String s) {m_hitStatus = s;}
        public Boolean getSelected() {return m_selected;}
        public void setSelected(Boolean s) {m_selected = s;}
        
        private Contact m_contact;
        private String m_hitStatus = '';
        private Boolean m_selected;
    }

    public class AccountSelection {
        
        public AccountSelection(Account a, Boolean s) {
            m_account = a;
            m_selected = s;
        }
        
        public Account getAccount() {return m_account;}
        public String getHitStatus() {return m_hitStatus;}
        public void setHitStatus(String s) {m_hitStatus = s;}
        public Boolean getSelected() {return m_selected;}
        public void setSelected(Boolean s) {m_selected = s;}
        
        private Account m_account;
        private String m_hitStatus = '';
        private Boolean m_selected;
    }

    //----------------------
    // private
    //----------------------
    
    private forseva1.LexisNexisReportService m_svc;    
    private ApplicationScoring__c m_score;
    private List<ContactSelection> m_contacts;
    private List<AccountSelection> m_accounts;    
    
    private String m_currentReportType = DBUtility.COMPREHENSIVE_PERSON_REPORT;
    private Integer m_pullCounter = 0;
    private Boolean m_isDone = false;

    private void stageProperAddressFields(Account a) {
    
        if(a.Corrected_P_Street__c != null) {
            a.BillingStreet = a.Corrected_P_Street__c;
            a.BillingCity = a.Corrected_P_City__c;
            a.BillingState = a.Corrected_P_State__c;
            a.BillingPostalCode = a.Corrected_P_Postalcode__c;
        }
        else if(a.Primary_Street1__c != null) {
            a.BillingStreet = a.Primary_Street1__c;
            a.BillingCity = a.Primary_City__c;
            a.BillingState = a.Primary_State__c;
            a.BillingPostalCode = a.Primary_Postalcode__c;        
        }
    }

    private void stageProperAddressFields(Contact c) {
    
        if(c.AFC_Primary_Street__c != null) {
            c.MailingStreet = c.AFC_Primary_Street__c;
            c.MailingCity = c.AFC_Primary_City__c;
            c.MailingState = c.AFC_Primary_State__c;
            c.MailingPostalCode = c.AFC_Primary_Postalcode__c;
        }
    }

    private String toString(String s) {
        return s != null ? s : '';
    }                
    
}

// EOF