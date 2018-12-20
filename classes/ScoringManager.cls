/**
* Copyright 2013-2014 Forseva, LLC. All rights reserved.
*/
public with sharing class ScoringManager {

    //-------------------------
    // scoring constants
    //-------------------------
    
    public static final String LTE_75K = 'LTE $75K';
    public static final String GT_75K = 'GT $75K';    
    public static final String VALUE = 'Value';
    public static final String RANGE = 'Range';
    
    public static final String NEGATIVE = 'Negative';
    public static final String POSITIVE = 'Positive';

    public static final String BUSINESS_TYPE = 'Business Type';
    public static final String GUARANTOR_CREDIT_SCORE = 'Guarantor Credit Score';
    public static final String HIGH_CREDIT_AMOUNT = 'High Credit Amount';
    public static final String LATE_PAYMENTS = 'Late Payments';
    public static final String LOT_OWNERSHIP = 'Lot Ownership';
    public static final String NUMBER_OF_AUCTION_REFERENCES = 'Number of Auction References';
    public static final String NUMBER_OF_EXISTING_UCC_FILINGS = 'Number of Existing UCC Filings';
    public static final String NUMBER_OF_UNITS_CURRENTLY_ON_LOT = 'Number of Units Currently on Lot';
    public static final String PREVIOUS_ACCOUNT_GUARANTOR_SEARCH = 'Previous Account/Guarantor Search';
    public static final String YEARS_IN_BUREAU = 'Years in Bureau';
    public static final String YEARS_OF_EXPERIENCE_IN_AUTO_BUSINESS = 'Years of Experience in Auto Business';    
    public Set<String> ListFLSUpdate;
    public Set<String> ListFLSCreate;
    //-------------------------
    // public methods
    //-------------------------

    public ScoringManager(ApplicationScoring__c score) {
		
		if(ListFLSUpdate == null)
		{
			ListFLSUpdate = new Set<String>();
		}
		if(ListFLSCreate == null)
		{
			ListFLSCreate = new Set<String>();
		}
		Boolean blnFLSOverride = Utils.GetFLS();
        m_score = score;
        m_application = (Application__c)DBUtility.getObjectWithAllFields(m_score.Application__c, Application__c.SObjectType);
        m_quest = (Dealer_Questionnaire__c)DBUtility.getRelatedDealerQuestionnaire(m_score.Application__c);
        m_account = DBUtility.getOwningAccount(m_application);
        
        m_efxReports = DBUtility.getEfxReports(m_score.Id);
        m_expReports = DBUtility.getExpReports(m_score.Id);
        m_tuReports = DBUtility.getTuReports(m_score.Id);
        m_lnReports = DBUtility.getLnReports(m_score.Id);
		
		if(ListFLSUpdate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_UPDATE','CLASS:ScoringManager', ListFLSUpdate);
		}
		if(ListFLSUpdate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_CREATE','CLASS:ScoringManager', ListFLSCreate);
		}
    }

    public void score() {
		
		if(ListFLSUpdate == null)
		{
			ListFLSUpdate = new Set<String>();
		}
		if(ListFLSCreate == null)
		{
			ListFLSCreate = new Set<String>();
		}
		Boolean blnFLSOverride = Utils.GetFLS();
		if(m_score.Id !=null)
		{
			if (Schema.sObjectType.ApplicationScoring__c.fields.Scoring_Calculation_Status__c.isUpdateable() || blnFLSOverride)
			{
				m_score.Scoring_Calculation_Status__c = '';
			}
			else
			{						
				ListFLSUpdate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Scoring_Calculation_Status__c.getName());
			}
		}
		else
		{
			if (Schema.sObjectType.ApplicationScoring__c.fields.Scoring_Calculation_Status__c.isCreateable() || blnFLSOverride)
			{
				m_score.Scoring_Calculation_Status__c = '';
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Scoring_Calculation_Status__c.getName());
			}
		}
        addStatusMessage('Scoring Calculation as of ' + Datetime.now().format());

        if(m_application.Opportunity__c == null) {
            addStatusMessage('This application cannot be scored as it is not opportunity-based');
			if(m_score.Id !=null)
			{
				if (Schema.sObjectType.ApplicationScoring__c.fields.Total_Score__c.isUpdateable() || blnFLSOverride)
				{
					m_score.Total_Score__c = null;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Total_Score__c.getName());
				}
			}
			else
			{
				if (Schema.sObjectType.ApplicationScoring__c.fields.Total_Score__c.isCreateable() || blnFLSOverride)
				{
					m_score.Total_Score__c = null;
				}
				else
				{						
					ListFLSCreate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Total_Score__c.getName());
				}
			}
        }        
        else if(m_quest == null) {
            addStatusMessage('This application cannot be scored as it is missing its Dealer Questionnaire');
			if(m_score.Id !=null)
			{
				if (Schema.sObjectType.ApplicationScoring__c.fields.Total_Score__c.isUpdateable() || blnFLSOverride)
				{
					m_score.Total_Score__c = null;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Total_Score__c.getName());
				}
			}
			else
			{
				if (Schema.sObjectType.ApplicationScoring__c.fields.Total_Score__c.isCreateable() || blnFLSOverride)
				{
					m_score.Total_Score__c = null;
				}
				else
				{						
					ListFLSCreate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Total_Score__c.getName());
				}				
			}
        }
        else if(m_account == null) {
            addStatusMessage('This application cannot be scored as it is not related to an Account');
			if(m_score.Id !=null)
			{
				if (Schema.sObjectType.ApplicationScoring__c.fields.Total_Score__c.isUpdateable() || blnFLSOverride)
				{
					m_score.Total_Score__c = null;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Total_Score__c.getName());
				}
			}
			else
			{
				if (Schema.sObjectType.ApplicationScoring__c.fields.Total_Score__c.isCreateable() || blnFLSOverride)
				{
					m_score.Total_Score__c = null;
				}
				else
				{						
					ListFLSCreate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Total_Score__c.getName());
				}

			}
        }        
        else {        
            assignScorecard();        
            stageScoringInputs();
            Decimal totalScore = calculateTotalScore();
            if(totalScore != null) {
				if(m_score.Id !=null)
				{
					if (Schema.sObjectType.ApplicationScoring__c.fields.Total_Score__c.isUpdateable() || blnFLSOverride)
					{
						m_score.Total_Score__c = totalScore;					
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Total_Score__c.getName());
					}
				}
				else
				{
					if (Schema.sObjectType.ApplicationScoring__c.fields.Total_Score__c.isCreateable() || blnFLSOverride)
					{
						m_score.Total_Score__c = totalScore;					
					}
					else
					{						
						ListFLSCreate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Total_Score__c.getName());
					}
				}
                addStatusMessage('Total Score = ' + m_score.Total_Score__c);        
                addStatusMessage('Scoring Calculation complete');
            }
        }
		
		if(ListFLSUpdate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_UPDATE','CLASS:ScoringManager', ListFLSUpdate);
		}
		else if(ListFLSCreate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_CREATE','CLASS:ScoringManager', ListFLSCreate);
		}
		else
		{	
			upsert m_score;
			
			if(m_score.Primary__c == true) {
				setOtherPrimaryFlagsToFalse();
				createAdverseActionLetters();            
			}		
		}
		
    }

    //---------------------------------------
    // private attributes
    //---------------------------------------
    
    private ApplicationScoring__c m_score;
    private Application__c m_application;
    private Dealer_Questionnaire__c m_quest;
    private Account m_account;
    
    private List<forseva1__EquifaxConsumer__c> m_efxReports;
    private List<forseva1__ExperianConsumer__c> m_expReports;
    private List<forseva1__TransunionConsumer__c> m_tuReports;
    private List<forseva1__LexisNexisReport__c> m_lnReports;
        
    private Integer m_counter = 1;

    //---------------------------------------
    // private methods
    //---------------------------------------

    @TestVisible private void addStatusMessage(String msg) {
		Boolean blnFLSOverride = Utils.GetFLS();
		if(m_score.Id !=null)
		{
			if (Schema.sObjectType.ApplicationScoring__c.fields.Scoring_Calculation_Status__c.isUpdateable() || blnFLSOverride)
			{
				m_score.Scoring_Calculation_Status__c += '(' + m_counter++ + ') ' + msg + '.\n';							
			}
			else
			{						
				ListFLSUpdate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Scoring_Calculation_Status__c.getName());
			}
		}
		else
		{
			if (Schema.sObjectType.ApplicationScoring__c.fields.Scoring_Calculation_Status__c.isCreateable() || blnFLSOverride)
			{
				m_score.Scoring_Calculation_Status__c += '(' + m_counter++ + ') ' + msg + '.\n';							
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Scoring_Calculation_Status__c.getName());
			}			
		}
    }

    @TestVisible private void assignScorecard() {
		Boolean blnFLSOverride = Utils.GetFLS();
		if(m_score.Id !=null)
		{
			if (Schema.sObjectType.ApplicationScoring__c.fields.Scorecard__c.isUpdateable() || blnFLSOverride)
			{
				m_score.Scorecard__c = (m_score.Credit_Limit_Requested__c != null && m_score.Credit_Limit_Requested__c > 75000 ? GT_75K : LTE_75K);   									
			}
			else
			{						
				ListFLSUpdate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Scorecard__c.getName());
			}
		}
		else
		{
			if (Schema.sObjectType.ApplicationScoring__c.fields.Scorecard__c.isCreateable() || blnFLSOverride)
			{
				m_score.Scorecard__c = (m_score.Credit_Limit_Requested__c != null && m_score.Credit_Limit_Requested__c > 75000 ? GT_75K : LTE_75K);   									
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Scorecard__c.getName());
			}
		}
    }        
    
    @TestVisible private void stageScoringInputs() {

        // credit score average
        // high credit max
        // years in bureau        
        // late payment count
        Decimal cumScore = 0;
        Decimal cumYearsOnFile = 0;
        Decimal highestCredit = 0;        
        Integer scoreCounter = 0; 
        Integer yearsCounter = 0; 
        Integer latePayments = 0;
        Integer activeUCCFilings = 0;
        Boolean blnFLSOverride = Utils.GetFLS();
        for(forseva1__EquifaxConsumer__c r : m_efxReports) {
        	
        	if(r.forseva1__eqScrBeacon__c != null && r.Exclude__c == false) {
                cumScore += r.forseva1__eqScrBeacon__c;
                scoreCounter++;
        	}
        	if(r.Maximum_High_Credit__c != null && r.Exclude__c == false) {
        	    highestCredit = Math.max(highestCredit, r.Maximum_High_Credit__c);
        	}
        	if(r.Years_on_File__c != null && r.Exclude__c == false) {
        	    cumYearsOnFile += r.Years_on_File__c;
        	    yearsCounter++;
        	}
        	if(r.Late_Payment_Count__c != null && r.Exclude__c == false) {
        	    latePayments += r.Late_Payment_Count__c.intValue();
        	}
        }    

        for(forseva1__ExperianConsumer__c r : m_expReports) {

            if(r.FICO_Score__c != null && r.Exclude__c == false) {
                cumScore += r.FICO_Score__c;
                scoreCounter++;
            }
            if(r.Maximum_High_Credit__c != null && r.Exclude__c == false) {
                highestCredit = Math.max(highestCredit, r.Maximum_High_Credit__c);
            }
            if(r.Years_on_File__c != null && r.Exclude__c == false) {
                cumYearsOnFile += r.Years_on_File__c;
                yearsCounter++;
            }
            if(r.Late_Payment_Count__c != null && r.Exclude__c == false) {
                latePayments += r.Late_Payment_Count__c.intValue();
            }

        }    

        for(forseva1__TransunionConsumer__c r : m_tuReports) {
            
            if(r.FICO_Score__c != null && r.Exclude__c == false) {
                cumScore += r.FICO_Score__c;
                scoreCounter++;
            }
            if(r.Maximum_High_Credit__c != null && r.Exclude__c == false) {
                highestCredit = Math.max(highestCredit, r.Maximum_High_Credit__c);
            }
            if(r.Years_on_File__c != null && r.Exclude__c == false) {
                cumYearsOnFile += r.Years_on_File__c;
                yearsCounter++;
            }
            if(r.Late_Payment_Count__c != null && r.Exclude__c == false) {
                latePayments += r.Late_Payment_Count__c.intValue();
            }
        }    
        
		// UCC filings
        for(forseva1__LexisNexisReport__c r : m_lnReports) {
        	if(r.Number_of_Existing_UCC_Filings__c != null && r.Exclude__c == false) {
        	    activeUCCFilings += r.Number_of_Existing_UCC_Filings__c.intValue();
        	} 
        }
		
		if(m_score.Id !=null )
		{
			if (Schema.sObjectType.ApplicationScoring__c.fields.Guarantor_Credit_Score__c.isUpdateable() || blnFLSOverride)
			{
				m_score.Guarantor_Credit_Score__c = cumScore/Math.max(1, scoreCounter);												
			}
			else
			{						
				ListFLSUpdate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Guarantor_Credit_Score__c.getName());
			}
			if (Schema.sObjectType.ApplicationScoring__c.fields.High_Credit_Amount__c.isUpdateable() || blnFLSOverride)
			{
				m_score.High_Credit_Amount__c = highestCredit;													
			}
			else
			{						
				ListFLSUpdate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.High_Credit_Amount__c.getName());
			}
			if (Schema.sObjectType.ApplicationScoring__c.fields.Years_in_Bureau__c.isUpdateable() || blnFLSOverride)
			{
				m_score.Years_in_Bureau__c = cumYearsOnFile/Math.max(1, yearsCounter);
			}
			else
			{						
				ListFLSUpdate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Years_in_Bureau__c.getName());
			}
			if (Schema.sObjectType.ApplicationScoring__c.fields.Late_Payments__c.isUpdateable() || blnFLSOverride)
			{
				m_score.Late_Payments__c = latePayments;			
			}
			else
			{						
				ListFLSUpdate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Late_Payments__c.getName());
			}
			
			// lot ownership        
			if (Schema.sObjectType.ApplicationScoring__c.fields.Lot_Ownership__c.isUpdateable() || blnFLSOverride)
			{			
				m_score.Lot_Ownership__c = m_application.Lot_Ownership__c;
			}
			else
			{						
				ListFLSUpdate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Lot_Ownership__c.getName());
			}
			
			// auction references        
			
			if (Schema.sObjectType.ApplicationScoring__c.fields.Number_of_Auction_References__c.isUpdateable() || blnFLSOverride)
			{			
				m_score.Number_of_Auction_References__c = 
				(m_quest.Auction_1__c != null ? 1 : 0) +
				(m_quest.Auction_2__c != null ? 1 : 0) +
				(m_quest.Auction_3__c != null ? 1 : 0);
			}
			else
			{						
				ListFLSUpdate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Number_of_Auction_References__c.getName());
			}
				
			// previous account/guaranter search        
			if (Schema.sObjectType.ApplicationScoring__c.fields.Previous_Account_Guarantor_Search__c.isUpdateable() || blnFLSOverride)
			{	
				m_score.Previous_Account_Guarantor_Search__c = m_account != null ? m_account.Previous__c : null;
			}
			else
			{						
				ListFLSUpdate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Previous_Account_Guarantor_Search__c.getName());
			}
			
			// years in autos
			if (Schema.sObjectType.ApplicationScoring__c.fields.Years_of_Experience_in_Auto_Business__c.isUpdateable() || blnFLSOverride)
			{	
				m_score.Years_of_Experience_in_Auto_Business__c = m_quest.Experience_in_Automotive_Industry__c;
			}
			else
			{						
				ListFLSUpdate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Years_of_Experience_in_Auto_Business__c.getName());
			}
			
			// business type
			if (Schema.sObjectType.ApplicationScoring__c.fields.Business_Type__c.isUpdateable() || blnFLSOverride)
			{	
				m_score.Business_Type__c = DBUtility.getBusinessType(m_score.Application__c);
			}
			else
			{						
				ListFLSUpdate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Business_Type__c.getName());
			}
			
			if (Schema.sObjectType.ApplicationScoring__c.fields.Number_of_Existing_UCC_Filings__c.isUpdateable() || blnFLSOverride)
			{
				m_score.Number_of_Existing_UCC_Filings__c = activeUCCFilings;
			}
			else
			{						
				ListFLSUpdate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Number_of_Existing_UCC_Filings__c.getName());
			}
			
			// number of units on lot
			if (Schema.sObjectType.ApplicationScoring__c.fields.Number_of_Units_Currently_on_Lot__c.isUpdateable() || blnFLSOverride)
			{
				m_score.Number_of_Units_Currently_on_Lot__c = m_quest.How_Many_Units_are_on_the_Lot_Currently__c;  
			}
			else
			{						
				ListFLSUpdate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Number_of_Units_Currently_on_Lot__c.getName());
			}
		}
		else
		{
			if (Schema.sObjectType.ApplicationScoring__c.fields.Guarantor_Credit_Score__c.isCreateable() || blnFLSOverride)
			{
				m_score.Guarantor_Credit_Score__c = cumScore/Math.max(1, scoreCounter);												
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Guarantor_Credit_Score__c.getName());
			}
			if (Schema.sObjectType.ApplicationScoring__c.fields.High_Credit_Amount__c.isCreateable() || blnFLSOverride)
			{
				m_score.High_Credit_Amount__c = highestCredit;													
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.High_Credit_Amount__c.getName());
			}
			if (Schema.sObjectType.ApplicationScoring__c.fields.Years_in_Bureau__c.isCreateable() || blnFLSOverride)
			{
				m_score.Years_in_Bureau__c = cumYearsOnFile/Math.max(1, yearsCounter);
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Years_in_Bureau__c.getName());
			}
			if (Schema.sObjectType.ApplicationScoring__c.fields.Late_Payments__c.isCreateable() || blnFLSOverride)
			{
				m_score.Late_Payments__c = latePayments;			
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Late_Payments__c.getName());
			}
			
			// lot ownership        
			if (Schema.sObjectType.ApplicationScoring__c.fields.Lot_Ownership__c.isCreateable() || blnFLSOverride)
			{			
				m_score.Lot_Ownership__c = m_application.Lot_Ownership__c;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Lot_Ownership__c.getName());
			}
			
			// auction references        
			
			if (Schema.sObjectType.ApplicationScoring__c.fields.Number_of_Auction_References__c.isCreateable() || blnFLSOverride)
			{			
				m_score.Number_of_Auction_References__c = 
				(m_quest.Auction_1__c != null ? 1 : 0) +
				(m_quest.Auction_2__c != null ? 1 : 0) +
				(m_quest.Auction_3__c != null ? 1 : 0);
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Number_of_Auction_References__c.getName());
			}
				
			// previous account/guaranter search        
			if (Schema.sObjectType.ApplicationScoring__c.fields.Previous_Account_Guarantor_Search__c.isCreateable() || blnFLSOverride)
			{	
				m_score.Previous_Account_Guarantor_Search__c = m_account != null ? m_account.Previous__c : null;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Previous_Account_Guarantor_Search__c.getName());
			}
			
			// years in autos
			if (Schema.sObjectType.ApplicationScoring__c.fields.Years_of_Experience_in_Auto_Business__c.isCreateable() || blnFLSOverride)
			{	
				m_score.Years_of_Experience_in_Auto_Business__c = m_quest.Experience_in_Automotive_Industry__c;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Years_of_Experience_in_Auto_Business__c.getName());
			}
			
			// business type
			if (Schema.sObjectType.ApplicationScoring__c.fields.Business_Type__c.isCreateable() || blnFLSOverride)
			{	
				m_score.Business_Type__c = DBUtility.getBusinessType(m_score.Application__c);
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Business_Type__c.getName());
			}
			
			if (Schema.sObjectType.ApplicationScoring__c.fields.Number_of_Existing_UCC_Filings__c.isCreateable() || blnFLSOverride)
			{
				m_score.Number_of_Existing_UCC_Filings__c = activeUCCFilings;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Number_of_Existing_UCC_Filings__c.getName());
			}
			
			// number of units on lot
			if (Schema.sObjectType.ApplicationScoring__c.fields.Number_of_Units_Currently_on_Lot__c.isCreateable() || blnFLSOverride)
			{
				m_score.Number_of_Units_Currently_on_Lot__c = m_quest.How_Many_Units_are_on_the_Lot_Currently__c;  
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoring__c.getName()+'.'+Schema.sObjectType.ApplicationScoring__c.fields.Number_of_Units_Currently_on_Lot__c.getName());
			}

		}
		
    }
    
    @TestVisible private Decimal calculateTotalScore() {

        Decimal totalScore = 0;        
        Map<String,List<ApplicationScoringFactor__c>> factorMap = DBUtility.getScoringFactors(m_score.Scorecard__c);
        List<String> factorList = new List<String>();
        factorList.addAll(factorMap.keySet());
        factorList.sort();
        for(String factor : factorList) {
        	Decimal factorScore = calculateFactorScore(factor, factorMap.get(factor));
        	if(factorScore == null) {
        	    addStatusMessage('Cannot score application - no factor score calculation possible for ' + factor);
        	    return null;
        	}
            totalScore += factorScore;                    	
        }
        return totalScore;
    }

    @TestVisible private Decimal calculateFactorScore(String factor, List<ApplicationScoringFactor__c> asfList) {

        String factorGroup = null;    
        Decimal factorScore = null;
        String defaultGroup = null;        
        Decimal defaultScore = null;
        
        String inputFieldName = DBUtility.getNameForLabel(ApplicationScoring__c.SObjectType, factor);
        if(inputFieldName == null) {
            addStatusMessage('Cannot score application - no Account Scoring input field for ' + factor);
            return null;        
        }        
        Object obj = m_score.get(inputFieldName);
        
        for(ApplicationScoringFactor__c asf : asfList) {
        	        	
        	// VALUE
            if(asf.Type__c == VALUE) {
                if(asf.Value__c == null) {
                    defaultGroup = asf.Group__c;
                    defaultScore = asf.Scorecard_Points__c;
                }
                else if(obj != null) {
                	String objStr = String.valueOf(obj);
                    if(asf.Value__c == objStr) {
                        factorGroup = asf.Group__c;
                        factorScore = asf.Scorecard_Points__c;
                        break;
                    }
                }
            }
            // RANGE
            else if(asf.Type__c == RANGE) {
                if(asf.Lower_Range__c == null || asf.Upper_Range__c == null) {
                    defaultGroup = asf.Group__c;
                    defaultScore = asf.Scorecard_Points__c;
                }
                else if(obj != null) {
                    Decimal objDec = Decimal.valueOf(String.valueOf(obj));
                    Decimal lower = asf.Lower_Range__c;
                    Decimal upper = asf.Upper_Range__c;
                    if(objDec >= lower && objDec <= upper) {
                        factorGroup = asf.Group__c;
                        factorScore = asf.Scorecard_Points__c;
                        break;                    	
                    }
                }    
            }
        }
        
        if(factorGroup == null) {
            factorGroup = defaultGroup;
        }
        if(factorScore == null) {
            factorScore = defaultScore;
        }
        
        addStatusMessage('Factor: ' + factor + ', Group: ' + factorGroup + ', Score: ' + factorScore);
        return factorScore;
    }

    @TestVisible private void createAdverseActionLetters() {
        
        List<ApplicationScoringAdverseAction__c> aList = [select Id from ApplicationScoringAdverseAction__c where Application__c = :m_application.Id];
        delete aList;
        aList = new List<ApplicationScoringAdverseAction__c>();
        ApplicationScoringAdverseAction__c letter;       
 
		 //Story B-44003 : FLS CREATE ACCESS CHECK
		Set<String> ListFLSCreate = new Set<String>();
		Boolean blnFLSOverride = Utils.GetFLS();
		
        for(forseva1__EquifaxConsumer__c r : m_efxReports) {
            letter = new ApplicationScoringAdverseAction__c();            
            
			if (Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Application__c.isCreateable() || blnFLSOverride)
			{
				letter.Application__c = m_application.Id;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoringAdverseAction__c.getName()+'.'+Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Application__c.getName());
			}
			if (Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Application_Scoring__c.isCreateable() || blnFLSOverride)
			{
				letter.Application_Scoring__c = m_score.Id;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoringAdverseAction__c.getName()+'.'+Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Application_Scoring__c.getName());
			}
			if (Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.is_Equifax__c.isCreateable() || blnFLSOverride)
			{
				letter.is_Equifax__c = true;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoringAdverseAction__c.getName()+'.'+Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.is_Equifax__c.getName());
			}
			if (Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Contact__c.isCreateable() || blnFLSOverride)
			{
				letter.Contact__c = r.forseva1__Contact__c;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoringAdverseAction__c.getName()+'.'+Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Contact__c.getName());
			}
			if (Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Credit_Score__c.isCreateable() || blnFLSOverride)
			{
				letter.Credit_Score__c = r.forseva1__eqScrBeacon__c;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoringAdverseAction__c.getName()+'.'+Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Credit_Score__c.getName());
			}
			if (Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Credit_Score_Date__c.isCreateable() || blnFLSOverride)
			{
				letter.Credit_Score_Date__c = Date.newInstance(r.CreatedDate.year(), r.CreatedDate.month(), r.CreatedDate.day());
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoringAdverseAction__c.getName()+'.'+Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Credit_Score_Date__c.getName());
			}
			if (Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Scoring_Factors__c.isCreateable() || blnFLSOverride)
			{
				letter.Scoring_Factors__c = r.Scoring_Messages__c;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoringAdverseAction__c.getName()+'.'+Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Scoring_Factors__c.getName());
			}
            aList.add(letter);
        }
    
        for(forseva1__ExperianConsumer__c r : m_expReports) {
            letter = new ApplicationScoringAdverseAction__c();
            if (Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Application__c.isCreateable() || blnFLSOverride)
			{
				letter.Application__c = m_application.Id;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoringAdverseAction__c.getName()+'.'+Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Application__c.getName());
			}
			if (Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Application_Scoring__c.isCreateable() || blnFLSOverride)
			{
				letter.Application_Scoring__c = m_score.Id;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoringAdverseAction__c.getName()+'.'+Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Application_Scoring__c.getName());
			}
			if (Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.is_Experian__c.isCreateable() || blnFLSOverride)
			{
				letter.is_Experian__c = true;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoringAdverseAction__c.getName()+'.'+Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.is_Experian__c.getName());
			}
			if (Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Contact__c.isCreateable() || blnFLSOverride)
			{
				letter.Contact__c = r.forseva1__Contact__c;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoringAdverseAction__c.getName()+'.'+Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Contact__c.getName());
			}
			if (Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Credit_Score__c.isCreateable() || blnFLSOverride)
			{
				letter.Credit_Score__c = r.FICO_Score__c;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoringAdverseAction__c.getName()+'.'+Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Credit_Score__c.getName());
			}
			if (Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Credit_Score_Date__c.isCreateable() || blnFLSOverride)
			{
				letter.Credit_Score_Date__c = Date.newInstance(r.CreatedDate.year(), r.CreatedDate.month(), r.CreatedDate.day());
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoringAdverseAction__c.getName()+'.'+Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Credit_Score_Date__c.getName());
			}
			if (Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Scoring_Factors__c.isCreateable() || blnFLSOverride)
			{
				letter.Scoring_Factors__c = r.Scoring_Messages__c;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoringAdverseAction__c.getName()+'.'+Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Scoring_Factors__c.getName());
			}

            aList.add(letter);
        }
    
        for(forseva1__TransunionConsumer__c r : m_tuReports) {
            letter = new ApplicationScoringAdverseAction__c();
            if (Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Application__c.isCreateable() || blnFLSOverride)
			{
				letter.Application__c = m_application.Id;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoringAdverseAction__c.getName()+'.'+Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Application__c.getName());
			}
			if (Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Application_Scoring__c.isCreateable() || blnFLSOverride)
			{
				letter.Application_Scoring__c = m_score.Id;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoringAdverseAction__c.getName()+'.'+Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Application_Scoring__c.getName());
			}
			if (Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.is_TransUnion__c.isCreateable() || blnFLSOverride)
			{
				letter.is_TransUnion__c = true;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoringAdverseAction__c.getName()+'.'+Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.is_TransUnion__c.getName());
			}
			if (Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Contact__c.isCreateable() || blnFLSOverride)
			{
				letter.Contact__c = r.forseva1__Contact__c;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoringAdverseAction__c.getName()+'.'+Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Contact__c.getName());
			}
			if (Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Credit_Score__c.isCreateable() || blnFLSOverride)
			{
				letter.Credit_Score__c = r.FICO_Score__c;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoringAdverseAction__c.getName()+'.'+Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Credit_Score__c.getName());
			}
			if (Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Credit_Score_Date__c.isCreateable() || blnFLSOverride)
			{
				letter.Credit_Score_Date__c = Date.newInstance(r.CreatedDate.year(), r.CreatedDate.month(), r.CreatedDate.day());
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoringAdverseAction__c.getName()+'.'+Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Credit_Score_Date__c.getName());
			}
			if (Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Scoring_Factors__c.isCreateable() || blnFLSOverride)
			{
				letter.Scoring_Factors__c = r.Scoring_Messages__c;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.ApplicationScoringAdverseAction__c.getName()+'.'+Schema.sObjectType.ApplicationScoringAdverseAction__c.fields.Scoring_Factors__c.getName());
			}
            aList.add(letter);
        }
        if(ListFLSCreate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_CREATE','CLASS:ScoringManager', ListFLSCreate);
		}
		else
		{
			insert aList;
		}
    }

    private void setOtherPrimaryFlagsToFalse() {
    
        List<ApplicationScoring__c> asList = [select  Id from ApplicationScoring__c 
                                              where   Application__c = :m_score.Application__c
                                              and     Id != :m_score.Id];
        for(ApplicationScoring__c appscr : asList) {
            appscr.Primary__c = false;
        }
        update asList;
    }

    //----------------------------------------------------------------
    //----------------------------------------------------------------
    // factor db load method
    //----------------------------------------------------------------
    //----------------------------------------------------------------

    public static void resetScoringFactors() {
        
		//if(ListFLSUpdate == null)
		//{
		//	ListFLSUpdate = new Set<String>();
		//}
		
        List<ApplicationScoringFactor__c> asfList = [select Id from ApplicationScoringFactor__c];
        delete asfList;
        
        asfList = new List<ApplicationScoringFactor__c>();

        // LTE $75K SCORECARD
     
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = GUARANTOR_CREDIT_SCORE, Type__c = RANGE, 
            Lower_Range__c = 0, Upper_Range__c = 625, Value__c = null, Group__c = '1.00', Scorecard_Points__c = -11));             
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = GUARANTOR_CREDIT_SCORE, Type__c = RANGE, 
            Lower_Range__c = 626, Upper_Range__c = 640, Value__c = null, Group__c = '2.00', Scorecard_Points__c = -6));             
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = GUARANTOR_CREDIT_SCORE, Type__c = RANGE, 
            Lower_Range__c = 641, Upper_Range__c = 1000, Value__c = null, Group__c = '3.00', Scorecard_Points__c = 22));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = GUARANTOR_CREDIT_SCORE, Type__c = RANGE, 
            Lower_Range__c = null, Upper_Range__c = null, Value__c = null, Group__c = '3.00', Scorecard_Points__c = 22));

        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = HIGH_CREDIT_AMOUNT, Type__c = RANGE, 
            Lower_Range__c = 0, Upper_Range__c = 5999, Value__c = null, Group__c = '1.00', Scorecard_Points__c = -1));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = HIGH_CREDIT_AMOUNT, Type__c = RANGE, 
            Lower_Range__c = 6000, Upper_Range__c = 16999, Value__c = null, Group__c = '2.00', Scorecard_Points__c = 0));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = HIGH_CREDIT_AMOUNT, Type__c = RANGE, 
            Lower_Range__c = 17000, Upper_Range__c = 53999, Value__c = null, Group__c = '3.00', Scorecard_Points__c = 8));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = HIGH_CREDIT_AMOUNT, Type__c = RANGE, 
            Lower_Range__c = 54000, Upper_Range__c = 100000000, Value__c = null, Group__c = '4.00', Scorecard_Points__c = 10));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = HIGH_CREDIT_AMOUNT, Type__c = RANGE, 
            Lower_Range__c = null, Upper_Range__c = null, Value__c = null, Group__c = '5.00', Scorecard_Points__c = -4));
            
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = LOT_OWNERSHIP, Type__c = VALUE, 
            Lower_Range__c = null, Upper_Range__c = null, Value__c = 'Own', Group__c = '1.00', Scorecard_Points__c = 32));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = LOT_OWNERSHIP, Type__c = VALUE, 
            Lower_Range__c = null, Upper_Range__c = null, Value__c = 'Rent', Group__c = '2.00', Scorecard_Points__c = 2));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = LOT_OWNERSHIP, Type__c = VALUE, 
            Lower_Range__c = null, Upper_Range__c = null, Value__c = 'Lease', Group__c = '3.00', Scorecard_Points__c = 0));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = LOT_OWNERSHIP, Type__c = VALUE, 
            Lower_Range__c = null, Upper_Range__c = null, Value__c = null, Group__c = '2.00', Scorecard_Points__c = 2));

        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = NUMBER_OF_AUCTION_REFERENCES, Type__c = RANGE, 
            Lower_Range__c = 0, Upper_Range__c = 0, Value__c = null, Group__c = '3.00', Scorecard_Points__c = 4));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = NUMBER_OF_AUCTION_REFERENCES, Type__c = RANGE, 
            Lower_Range__c = 1, Upper_Range__c = 1, Value__c = null, Group__c = '4.00', Scorecard_Points__c = 8));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = NUMBER_OF_AUCTION_REFERENCES, Type__c = RANGE, 
            Lower_Range__c = 2, Upper_Range__c = 2, Value__c = null, Group__c = '5.00', Scorecard_Points__c = 72));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = NUMBER_OF_AUCTION_REFERENCES, Type__c = RANGE, 
            Lower_Range__c = 3, Upper_Range__c = 3, Value__c = null, Group__c = '1.00', Scorecard_Points__c = -17));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = NUMBER_OF_AUCTION_REFERENCES, Type__c = RANGE, 
            Lower_Range__c = 4, Upper_Range__c = 4, Value__c = null, Group__c = '2.00', Scorecard_Points__c = -9));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = NUMBER_OF_AUCTION_REFERENCES, Type__c = RANGE, 
            Lower_Range__c = 5, Upper_Range__c = 7, Value__c = null, Group__c = '3.00', Scorecard_Points__c = 4));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = NUMBER_OF_AUCTION_REFERENCES, Type__c = RANGE, 
            Lower_Range__c = null, Upper_Range__c = null, Value__c = null, Group__c = '3.00', Scorecard_Points__c = 4));
            
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = PREVIOUS_ACCOUNT_GUARANTOR_SEARCH, Type__c = VALUE, 
            Lower_Range__c = 0, Upper_Range__c = 0, Value__c = 'Positive', Group__c = '1.00', Scorecard_Points__c = 60));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = PREVIOUS_ACCOUNT_GUARANTOR_SEARCH, Type__c = VALUE, 
            Lower_Range__c = 0, Upper_Range__c = 0, Value__c = null, Group__c = '2.00', Scorecard_Points__c = 7));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = PREVIOUS_ACCOUNT_GUARANTOR_SEARCH, Type__c = VALUE, 
            Lower_Range__c = 0, Upper_Range__c = 0, Value__c = 'Not Found', Group__c = '2.00', Scorecard_Points__c = 7));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = PREVIOUS_ACCOUNT_GUARANTOR_SEARCH, Type__c = VALUE, 
            Lower_Range__c = 0, Upper_Range__c = 0, Value__c = 'Negative', Group__c = '3.00', Scorecard_Points__c = -18));

        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = YEARS_IN_BUREAU, Type__c = RANGE, 
            Lower_Range__c = 0, Upper_Range__c = 6, Value__c = null, Group__c = '1.00', Scorecard_Points__c = -3));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = YEARS_IN_BUREAU, Type__c = RANGE, 
            Lower_Range__c = 7, Upper_Range__c = 11, Value__c = null, Group__c = '2.00', Scorecard_Points__c = 5));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = YEARS_IN_BUREAU, Type__c = RANGE, 
            Lower_Range__c = 12, Upper_Range__c = 999, Value__c = null, Group__c = '3.00', Scorecard_Points__c = 12));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = YEARS_IN_BUREAU, Type__c = RANGE, 
            Lower_Range__c = null, Upper_Range__c = null, Value__c = null, Group__c = '3.00', Scorecard_Points__c = 12));
            
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = YEARS_OF_EXPERIENCE_IN_AUTO_BUSINESS, Type__c = RANGE, 
            Lower_Range__c = 0, Upper_Range__c = 0, Value__c = null, Group__c = '1.00', Scorecard_Points__c = -2));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = YEARS_OF_EXPERIENCE_IN_AUTO_BUSINESS, Type__c = RANGE, 
            Lower_Range__c = 1, Upper_Range__c = 1, Value__c = null, Group__c = '2.00', Scorecard_Points__c = 0));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = YEARS_OF_EXPERIENCE_IN_AUTO_BUSINESS, Type__c = RANGE, 
            Lower_Range__c = 2, Upper_Range__c = 999, Value__c = null, Group__c = '3.00', Scorecard_Points__c = 11));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = LTE_75K, Factor__c = YEARS_OF_EXPERIENCE_IN_AUTO_BUSINESS, Type__c = RANGE, 
            Lower_Range__c = null, Upper_Range__c = null, Value__c = null, Group__c = '3.00', Scorecard_Points__c = 11));

        // GT $75K SCORECARD
     
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = BUSINESS_TYPE, Type__c = VALUE, 
            Lower_Range__c = null, Upper_Range__c = null, Value__c = 'LLP', Group__c = '1.00', Scorecard_Points__c = -15));             
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = BUSINESS_TYPE, Type__c = VALUE, 
            Lower_Range__c = null, Upper_Range__c = null, Value__c = 'LIMITED PARTNERSHIP', Group__c = '1.00', Scorecard_Points__c = -15));             
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = BUSINESS_TYPE, Type__c = VALUE, 
            Lower_Range__c = null, Upper_Range__c = null, Value__c = 'PARTNERSHIP', Group__c = '1.00', Scorecard_Points__c = -15));             
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = BUSINESS_TYPE, Type__c = VALUE, 
            Lower_Range__c = null, Upper_Range__c = null, Value__c = 'SOLE PROPRIETORSHIP', Group__c = '2.00', Scorecard_Points__c = -6));             
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = BUSINESS_TYPE, Type__c = VALUE, 
            Lower_Range__c = null, Upper_Range__c = null, Value__c = 'LLC', Group__c = '3.00', Scorecard_Points__c = 5));             
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = BUSINESS_TYPE, Type__c = VALUE, 
            Lower_Range__c = null, Upper_Range__c = null, Value__c = 'CORPORATION', Group__c = '4.00', Scorecard_Points__c = 16));             
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = BUSINESS_TYPE, Type__c = VALUE, 
            Lower_Range__c = null, Upper_Range__c = null, Value__c = null, Group__c = '5.00', Scorecard_Points__c = 50));             


        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = GUARANTOR_CREDIT_SCORE, Type__c = RANGE, 
            Lower_Range__c = 0, Upper_Range__c = 625, Value__c = null, Group__c = '1.00', Scorecard_Points__c = -8));             
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = GUARANTOR_CREDIT_SCORE, Type__c = RANGE, 
            Lower_Range__c = 626, Upper_Range__c = 658, Value__c = null, Group__c = '2.00', Scorecard_Points__c = -4));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = GUARANTOR_CREDIT_SCORE, Type__c = RANGE, 
            Lower_Range__c = 659, Upper_Range__c = 668, Value__c = null, Group__c = '3.00', Scorecard_Points__c = 1));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = GUARANTOR_CREDIT_SCORE, Type__c = RANGE, 
            Lower_Range__c = 669, Upper_Range__c = 1000, Value__c = null, Group__c = '4.00', Scorecard_Points__c = 19));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = GUARANTOR_CREDIT_SCORE, Type__c = RANGE, 
            Lower_Range__c = null, Upper_Range__c = null, Value__c = null, Group__c = '5.00', Scorecard_Points__c = 33));             
                         
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = HIGH_CREDIT_AMOUNT, Type__c = RANGE, 
            Lower_Range__c = 0, Upper_Range__c = 39999, Value__c = null, Group__c = '1.00', Scorecard_Points__c = -4));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = HIGH_CREDIT_AMOUNT, Type__c = RANGE, 
            Lower_Range__c = 40000, Upper_Range__c = 59999, Value__c = null, Group__c = '2.00', Scorecard_Points__c = -2));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = HIGH_CREDIT_AMOUNT, Type__c = RANGE, 
            Lower_Range__c = 60000, Upper_Range__c = 109999, Value__c = null, Group__c = '3.00', Scorecard_Points__c = 5));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = HIGH_CREDIT_AMOUNT, Type__c = RANGE, 
            Lower_Range__c = 110000, Upper_Range__c = 100000000, Value__c = null, Group__c = '4.00', Scorecard_Points__c = 13));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = HIGH_CREDIT_AMOUNT, Type__c = RANGE, 
            Lower_Range__c = null, Upper_Range__c = null, Value__c = null, Group__c = '5.00', Scorecard_Points__c = 42));
                         
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = LATE_PAYMENTS, Type__c = RANGE, 
            Lower_Range__c = 0, Upper_Range__c = 0, Value__c = null, Group__c = '1.00', Scorecard_Points__c = 22));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = LATE_PAYMENTS, Type__c = RANGE, 
            Lower_Range__c = 1, Upper_Range__c = 2, Value__c = null, Group__c = '2.00', Scorecard_Points__c = 2));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = LATE_PAYMENTS, Type__c = RANGE, 
            Lower_Range__c = 3, Upper_Range__c = 10000, Value__c = null, Group__c = '3.00', Scorecard_Points__c = -14));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = LATE_PAYMENTS, Type__c = RANGE, 
            Lower_Range__c = null, Upper_Range__c = null, Value__c = null, Group__c = '4.00', Scorecard_Points__c = 43));
            
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = NUMBER_OF_EXISTING_UCC_FILINGS, Type__c = RANGE, 
            Lower_Range__c = 0, Upper_Range__c = 0, Value__c = null, Group__c = '2.00', Scorecard_Points__c = 6));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = NUMBER_OF_EXISTING_UCC_FILINGS, Type__c = RANGE, 
            Lower_Range__c = 1, Upper_Range__c = 1, Value__c = null, Group__c = '3.00', Scorecard_Points__c = 4));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = NUMBER_OF_EXISTING_UCC_FILINGS, Type__c = RANGE, 
            Lower_Range__c = 2, Upper_Range__c = 2, Value__c = null, Group__c = '1.00', Scorecard_Points__c = 41));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = NUMBER_OF_EXISTING_UCC_FILINGS, Type__c = RANGE, 
            Lower_Range__c = 3, Upper_Range__c = 3, Value__c = null, Group__c = '4.00', Scorecard_Points__c = -33));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = NUMBER_OF_EXISTING_UCC_FILINGS, Type__c = RANGE, 
            Lower_Range__c = 4, Upper_Range__c = 4, Value__c = null, Group__c = '1.00', Scorecard_Points__c = 41));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = NUMBER_OF_EXISTING_UCC_FILINGS, Type__c = RANGE, 
            Lower_Range__c = 5, Upper_Range__c = 10000, Value__c = null, Group__c = '5.00', Scorecard_Points__c = 46));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = NUMBER_OF_EXISTING_UCC_FILINGS, Type__c = RANGE, 
            Lower_Range__c = null, Upper_Range__c = null, Value__c = null, Group__c = '5.00', Scorecard_Points__c = 46));
            
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = NUMBER_OF_UNITS_CURRENTLY_ON_LOT, Type__c = RANGE, 
            Lower_Range__c = 0, Upper_Range__c = 7, Value__c = null, Group__c = '1.00', Scorecard_Points__c = -5));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = NUMBER_OF_UNITS_CURRENTLY_ON_LOT, Type__c = RANGE, 
            Lower_Range__c = 7, Upper_Range__c = 100000, Value__c = null, Group__c = '2.00', Scorecard_Points__c = 14));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = NUMBER_OF_UNITS_CURRENTLY_ON_LOT, Type__c = RANGE, 
            Lower_Range__c = null, Upper_Range__c = null, Value__c = null, Group__c = '3.00', Scorecard_Points__c = 40));
            
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = YEARS_OF_EXPERIENCE_IN_AUTO_BUSINESS, Type__c = RANGE, 
            Lower_Range__c = 0, Upper_Range__c = 0, Value__c = null, Group__c = '1.00', Scorecard_Points__c = -12));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = YEARS_OF_EXPERIENCE_IN_AUTO_BUSINESS, Type__c = RANGE, 
            Lower_Range__c = 1, Upper_Range__c = 1, Value__c = null, Group__c = '2.00', Scorecard_Points__c = -4));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = YEARS_OF_EXPERIENCE_IN_AUTO_BUSINESS, Type__c = RANGE, 
            Lower_Range__c = 2, Upper_Range__c = 3, Value__c = null, Group__c = '3.00', Scorecard_Points__c = 3));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = YEARS_OF_EXPERIENCE_IN_AUTO_BUSINESS, Type__c = RANGE, 
            Lower_Range__c = 4, Upper_Range__c = 999, Value__c = null, Group__c = '4.00', Scorecard_Points__c = 13));
        asfList.add(new ApplicationScoringFactor__c(Scorecard__c = GT_75K, Factor__c = YEARS_OF_EXPERIENCE_IN_AUTO_BUSINESS, Type__c = RANGE, 
            Lower_Range__c = null, Upper_Range__c = null, Value__c = null, Group__c = '5.00', Scorecard_Points__c = 44));
                                 
        insert asfList;
		
		//if(ListFLSUpdate.size()>0)
		//{
		//	Utils.SendEmailforFLS('FLS_UPDATE','CLASS:ScoringManager', ListFLSUpdate);
		//}
    }
    
}

// EOF