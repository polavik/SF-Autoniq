/**
* Copyright 2013-2014 Forseva, LLC.  All rights reserved.
*/
public with sharing class DBUtility {

    //-----------------------------
    // constants
    //-----------------------------

    public static String EQUIFAX = 'Equifax';
    public static String EXPERIAN = 'Experian';
    public static String TRANSUNION = 'TransUnion';
    public static String LEXISNEXIS = 'LexisNexis';

    public static String COMPREHENSIVE_PERSON_REPORT = 'Comprehensive Person Report';
    public static String ENHANCED_BUSINESS_REPORT = 'Enhanced Business Report';
    public static String UCC_FILING_SEARCH = 'UCC Filing Search';
    public static String CORPORATE_FILING_SEARCH = 'Corporate Filing Search';
    public static Set<String> ListFLSUpdate ;
    //-----------------------------
    // db i/o functions
    //-----------------------------

    public static Account getOwningAccount(Application__c appl) {
        
        try {        
            Account a;
            
            if(appl.Opportunity__c != null) {
                a = [select  Id, LexisNexis_Id__c, Name, Dealer_Type_Dealer_License_Type__c, Previous__c 
                     from    Account 
                     where   Id in (select AccountId from Opportunity where Id = :appl.Opportunity__c)];
            }
            else {
                a = [select  Id, LexisNexis_Id__c, Name, Dealer_Type_Dealer_License_Type__c, Previous__c
                     from    Account
                     where   Id in (select Account__c from Application_Account_Role__c where Application__c = :appl.Id and Primary__c = true)
                     limit   1];
            }

            return a;
        }
        catch(Exception e) {
            return null;
        }
    }

    public static Account getOwningAccount(ApplicationScoring__c appscr) {
        
        try {
            Application__c appl = [select Id, Opportunity__c from Application__c where Id = :appscr.Application__c];
            return getOwningAccount(appl);
        }
        catch(Exception e) {
            return null;
        }
    }

    public static List<Account> getRelatedAccounts(Id applicationId) {
    
        List<Account> accounts = [select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, LexisNexis_Id__c,
                                         Corrected_P_Street__c, Corrected_P_City__c, Corrected_P_State__c, Corrected_P_Postalcode__c,
                                         Primary_Street1__c, Primary_City__c, Primary_State__c, Primary_Postalcode__c 
                                  from   Account
                                  where  Id in (select Account__c from Application_Account_Role__c where Application__c = :applicationId)];
        return accounts;
    }

    public static List<Contact> getRelatedContacts(Id applicationId) {
    
        List<Contact> contacts = [select Id, AccountId, Name, LastName, FirstName, SSN__c, Birthdate, Phone,
                                         MailingStreet, MailingState, MailingPostalCode, MailingCity, Salutation,
                                         AFC_Primary_Street__c, AFC_Primary_City__c, AFC_Primary_State__c, AFC_Primary_Postalcode__c  
                                  from   Contact 
                                  where  Id in (select Contact__c from Application_Contact_Role__c where Application__c = :applicationId)];
        return contacts;
    }    

    public static List<Contact> getRelatedAccountContacts(Id accountId) {
    
        List<Contact> contacts = [select Id, AccountId, Name, LastName, FirstName, SSN__c, Birthdate, Phone,
                                         MailingStreet, MailingState, MailingPostalCode, MailingCity, Salutation, 
                                         AFC_Primary_Street__c, AFC_Primary_City__c, AFC_Primary_State__c, AFC_Primary_Postalcode__c                                         
                                  from   Contact 
                                  where  AccountId = :accountId];
        return contacts;
    }    

    public static Dealer_Questionnaire__c getRelatedDealerQuestionnaire(Id applicationId) {
    
        try {
            Dealer_Questionnaire__c dq = [select    Id, Auction_1__c, Auction_2__c, Auction_3__c, 
                                                    Experience_in_Automotive_Industry__c, How_Many_Units_are_on_the_Lot_Currently__c
                                          from      Dealer_Questionnaire__c 
                                          where     Application__c = :applicationId         
                                          order by  LastModifiedDate desc limit 1];
            return dq;
        }
        catch(Exception e) {
            return null;
        }        
    }

    public static UserContext__c getUserContext() {    
        UserContext__c uc = UserContext__c.getInstance(UserInfo.getUserId());
        return uc;
    }

    public static Map<String,List<ApplicationScoringFactor__c>> getScoringFactors(String scorecard) {
        
        Map<String,List<ApplicationScoringFactor__c>> factorMap = new Map<String,List<ApplicationScoringFactor__c>>();
        
        for(ApplicationScoringFactor__c asf : [select    Id, Scorecard__c, Factor__c, Type__c, Lower_Range__c, Upper_Range__c, Value__c, Group__c, Scorecard_Points__c
                                               from      ApplicationScoringFactor__c
                                               where     Scorecard__c = :scorecard
                                               order by  Factor__c]) {
                                                
            if(factorMap.containsKey(asf.Factor__c)) {
                factorMap.get(asf.Factor__c).add(asf);
            }
            else {
                factorMap.put(asf.Factor__c, new List<ApplicationScoringFactor__c>{asf});
            }                                           
        }
                                                     
        return factorMap;
    }

    public static String getBusinessType(Id applicationId) {
        
        List<Application_Account_Role__c> aarList = [select Entity_Type__c 
                                                     from   Application_Account_Role__c 
                                                     where  Primary__c = true 
                                                     and    Application__c = :applicationId];
                                                     
        return aarList.size() > 0 ? aarList[0].Entity_Type__c : null;
    }

    //---------------------------------------

    public static List<forseva1__EquifaxConsumer__c> getEfxReports(Id applicationScoringId) {
        
        List<forseva1__EquifaxConsumer__c> rList = [select  Id, CreatedDate, forseva1__Contact__c, Exclude__c, forseva1__eqScrBeacon__c, Maximum_High_Credit__c, 
                                                            Years_on_File__c, Late_Payment_Count__c, Report_Messages__c, Scoring_Messages__c 
                                                    from    forseva1__EquifaxConsumer__c
                                                    where   Application_Scoring__c = :applicationScoringId];
        return rList;
    }

    public static List<forseva1__ExperianConsumer__c> getExpReports(Id applicationScoringId) {
        
        List<forseva1__ExperianConsumer__c> rList = [select  Id, CreatedDate, forseva1__Contact__c, Exclude__c, FICO_Score__c, Maximum_High_Credit__c, 
                                                             Years_on_File__c, Late_Payment_Count__c, Report_Messages__c, Scoring_Messages__c  
                                                     from    forseva1__ExperianConsumer__c
                                                     where   Application_Scoring__c = :applicationScoringId];
        return rList;
    }

    public static List<forseva1__TransunionConsumer__c> getTuReports(Id applicationScoringId) {
        
        List<forseva1__TransunionConsumer__c> rList = [select  Id, CreatedDate, forseva1__Contact__c, Exclude__c, FICO_Score__c, Maximum_High_Credit__c, 
                                                               Years_on_File__c, Late_Payment_Count__c, Report_Messages__c, Scoring_Messages__c 
                                                       from    forseva1__TransunionConsumer__c
                                                       where   Application_Scoring__c = :applicationScoringId];
        return rList;
    }

    public static List<forseva1__LexisNexisReport__c> getLnReports(Id applicationScoringId) {
        
        List<forseva1__LexisNexisReport__c> rList = [select  Id, forseva1__Contact__c, Exclude__c, forseva1__Report_Type__c, Number_of_Existing_UCC_Filings__c 
                                                     from    forseva1__LexisNexisReport__c
                                                     where   Application_Scoring__c = :applicationScoringId];
        return rList;
    }

    //---------------------------------------
/*
    public static String getWorstPreviousExperience(Id applicationId) {
    
        String prev = null;
        
        for(Application_Account_Role__c aar : [select Account__r.Previous__c from Application_Account_Role__c where Application__c = :applicationId]) {

            // Negative trumps all
            if(ScoringManager.NEGATIVE == aar.Account__r.Previous__c) {
                return aar.Account__r.Previous__c;
            }
            // Positive trumps all but Negative
            else if(ScoringManager.POSITIVE == aar.Account__r.Previous__c) {
                prev = aar.Account__r.Previous__c;
            }
            else if(ScoringManager.POSITIVE != prev) {
                prev = aar.Account__r.Previous__c;
            }
        }
        
        for(Application_Contact_Role__c acr : [select Contact__r.Previous_Account_Guarantor_Search__c from Application_Contact_Role__c where Application__c = :applicationId]) {

            // Negative trumps all
            if(ScoringManager.NEGATIVE == acr.Contact__r.Previous_Account_Guarantor_Search__c) {
                return acr.Contact__r.Previous_Account_Guarantor_Search__c;
            }
            // Positive trumps all but Negative
            else if(ScoringManager.POSITIVE == acr.Contact__r.Previous_Account_Guarantor_Search__c) {
                prev = acr.Contact__r.Previous_Account_Guarantor_Search__c;
            }
            else if(ScoringManager.POSITIVE != prev) {
                prev = acr.Contact__r.Previous_Account_Guarantor_Search__c;
            }        
        }
        
        return prev;
    }
*/
    public static SObject getObjectWithAllFields(Id soId, Schema.SObjectType sot) {
    
        if(soId == null) {
            return null;
        }
        String tableName = sot.getDescribe().getName();
        String query = 'select ' + getColumnsForObjectType(sot) + ' from ' + tableName + ' where Id = \'' + soId + '\'';
        SObject so = Database.query(query);
        return so;
    }

    public static void setCreditPolicy(Id accountId, String policyName) {
        Id cpId = [select Id from forseva1__CreditPolicy__c where Name = :policyName].Id;
        Account a = new Account(Id = accountId);
        
         //Story B-44003 : FLS UPDATE ACCESS CHECK
         ListFLSUpdate = new Set<String>(); 
		 Boolean blnFLSOverride = Utils.GetFLS();
         if (Schema.sObjectType.Account.fields.forseva1__Credit_Policy__c.isUpdateable() || blnFLSOverride)
         {                       
            a.forseva1__Credit_Policy__c = cpId;
         }
         else
         {                      
            ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.forseva1__Credit_Policy__c.getName());
         }
         
        if(ListFLSUpdate.size()>0)
        {
            Utils.SendEmailforFLS('FLS_UPDATE','CLASS:DBUtility', ListFLSUpdate);
        }
        update a;
    }

    // temporary until we get TU API integration running
    public static void createEmptyTURecords(Id accountId, Id applicationId, Id applicationScoringId) {
    
        Set<Id> existingReportContacts = new Set<Id>();
        for(forseva1__TransunionConsumer__c r : getTuReports(applicationScoringId)) {
            existingReportContacts.add(r.forseva1__Contact__c);
        }
    
        List<forseva1__TransunionConsumer__c> tuList = new List<forseva1__TransunionConsumer__c>();
        Set<String> ListFLSCreate = new Set<String>();
		Boolean blnFLSOverride = Utils.GetFLS();
        for(Contact c : getRelatedContacts(applicationId)) {
            if(!existingReportContacts.contains(c.Id)) {
                forseva1__TransunionConsumer__c tu = new forseva1__TransunionConsumer__c();
                //Story B-44003 : FLS CREATE ACCESS CHECK
                if (Schema.sObjectType.forseva1__TransunionConsumer__c.fields.forseva1__Account__c.isCreateable() || blnFLSOverride)
                {               
                    tu.forseva1__Account__c = accountId;
                }
                else
                {                       
                    ListFLSCreate.add(Schema.sObjectType.forseva1__TransunionConsumer__c.getName()+'.'+Schema.sObjectType.forseva1__TransunionConsumer__c.fields.forseva1__Account__c.getName());
                }
                if (Schema.sObjectType.forseva1__TransunionConsumer__c.fields.Application_Scoring__c.isCreateable() || blnFLSOverride)
                {               
                    tu.Application_Scoring__c = applicationScoringId;
                }
                else
                {                       
                    ListFLSCreate.add(Schema.sObjectType.forseva1__TransunionConsumer__c.getName()+'.'+Schema.sObjectType.forseva1__TransunionConsumer__c.fields.Application_Scoring__c.getName());
                }
                if (Schema.sObjectType.forseva1__TransunionConsumer__c.fields.forseva1__Contact__c.isCreateable() || blnFLSOverride)
                {               
                    tu.forseva1__Contact__c = c.Id;
                }
                else
                {                       
                    ListFLSCreate.add(Schema.sObjectType.forseva1__TransunionConsumer__c.getName()+'.'+Schema.sObjectType.forseva1__TransunionConsumer__c.fields.forseva1__Contact__c.getName());
                }
                if (Schema.sObjectType.forseva1__TransunionConsumer__c.fields.FICO_Score__c.isCreateable() || blnFLSOverride)
                {               
                    tu.FICO_Score__c = 0;
                }
                else
                {                       
                    ListFLSCreate.add(Schema.sObjectType.forseva1__TransunionConsumer__c.getName()+'.'+Schema.sObjectType.forseva1__TransunionConsumer__c.fields.FICO_Score__c.getName());
                }
                if (Schema.sObjectType.forseva1__TransunionConsumer__c.fields.Current_Trades__c.isCreateable() || blnFLSOverride)
                {               
                    tu.Current_Trades__c = null;
                }
                else
                {                       
                    ListFLSCreate.add(Schema.sObjectType.forseva1__TransunionConsumer__c.getName()+'.'+Schema.sObjectType.forseva1__TransunionConsumer__c.fields.Current_Trades__c.getName());
                }
                if (Schema.sObjectType.forseva1__TransunionConsumer__c.fields.Exclude__c.isCreateable() || blnFLSOverride)
                {               
                    tu.Exclude__c = true;
                }
                else
                {                       
                    ListFLSCreate.add(Schema.sObjectType.forseva1__TransunionConsumer__c.getName()+'.'+Schema.sObjectType.forseva1__TransunionConsumer__c.fields.Exclude__c.getName());
                }
                if (Schema.sObjectType.forseva1__TransunionConsumer__c.fields.Inquiries__c.isCreateable() || blnFLSOverride)
                {               
                    tu.Inquiries__c = null;
                }
                else
                {                       
                    ListFLSCreate.add(Schema.sObjectType.forseva1__TransunionConsumer__c.getName()+'.'+Schema.sObjectType.forseva1__TransunionConsumer__c.fields.Inquiries__c.getName());
                }
                if (Schema.sObjectType.forseva1__TransunionConsumer__c.fields.Inquiries_Last_6_Months__c.isCreateable() || blnFLSOverride)
                {               
                    tu.Inquiries_Last_6_Months__c = null;
                }
                else
                {                       
                    ListFLSCreate.add(Schema.sObjectType.forseva1__TransunionConsumer__c.getName()+'.'+Schema.sObjectType.forseva1__TransunionConsumer__c.fields.Inquiries_Last_6_Months__c.getName());
                }
                if (Schema.sObjectType.forseva1__TransunionConsumer__c.fields.Late_Payment_Count__c.isCreateable() || blnFLSOverride)
                {               
                    tu.Late_Payment_Count__c = null;
                }
                else
                {                       
                    ListFLSCreate.add(Schema.sObjectType.forseva1__TransunionConsumer__c.getName()+'.'+Schema.sObjectType.forseva1__TransunionConsumer__c.fields.Late_Payment_Count__c.getName());
                }
                if (Schema.sObjectType.forseva1__TransunionConsumer__c.fields.Maximum_High_Credit__c.isCreateable() || blnFLSOverride)
                {               
                    tu.Maximum_High_Credit__c = null;
                }
                else
                {                       
                    ListFLSCreate.add(Schema.sObjectType.forseva1__TransunionConsumer__c.getName()+'.'+Schema.sObjectType.forseva1__TransunionConsumer__c.fields.Maximum_High_Credit__c.getName());
                }
                if (Schema.sObjectType.forseva1__TransunionConsumer__c.fields.Public_Records__c.isCreateable() || blnFLSOverride)
                {               
                    tu.Public_Records__c = null;
                }
                else
                {                       
                    ListFLSCreate.add(Schema.sObjectType.forseva1__TransunionConsumer__c.getName()+'.'+Schema.sObjectType.forseva1__TransunionConsumer__c.fields.Public_Records__c.getName());
                }
                if (Schema.sObjectType.forseva1__TransunionConsumer__c.fields.Total_Trades__c.isCreateable() || blnFLSOverride)
                {               
                    tu.Total_Trades__c = null;
                }
                else
                {                       
                    ListFLSCreate.add(Schema.sObjectType.forseva1__TransunionConsumer__c.getName()+'.'+Schema.sObjectType.forseva1__TransunionConsumer__c.fields.Total_Trades__c.getName());
                }
                if (Schema.sObjectType.forseva1__TransunionConsumer__c.fields.Total_Balance__c.isCreateable() || blnFLSOverride)
                {               
                    tu.Total_Balance__c = null;
                }
                else
                {                       
                    ListFLSCreate.add(Schema.sObjectType.forseva1__TransunionConsumer__c.getName()+'.'+Schema.sObjectType.forseva1__TransunionConsumer__c.fields.Total_Balance__c.getName());
                }
                if (Schema.sObjectType.forseva1__TransunionConsumer__c.fields.Total_Real_Estate_Balance__c.isCreateable() || blnFLSOverride)
                {               
                    tu.Total_Real_Estate_Balance__c = null;
                }
                else
                {                       
                    ListFLSCreate.add(Schema.sObjectType.forseva1__TransunionConsumer__c.getName()+'.'+Schema.sObjectType.forseva1__TransunionConsumer__c.fields.Total_Real_Estate_Balance__c.getName());
                }
                if (Schema.sObjectType.forseva1__TransunionConsumer__c.fields.Total_Revolving_Balance__c.isCreateable() || blnFLSOverride)
                {               
                    tu.Total_Revolving_Balance__c = null;
                }
                else
                {                       
                    ListFLSCreate.add(Schema.sObjectType.forseva1__TransunionConsumer__c.getName()+'.'+Schema.sObjectType.forseva1__TransunionConsumer__c.fields.Total_Revolving_Balance__c.getName());
                }
                if (Schema.sObjectType.forseva1__TransunionConsumer__c.fields.Years_on_File__c.isCreateable() || blnFLSOverride)
                {               
                    tu.Years_on_File__c = null;
                }
                else
                {                       
                    ListFLSCreate.add(Schema.sObjectType.forseva1__TransunionConsumer__c.getName()+'.'+Schema.sObjectType.forseva1__TransunionConsumer__c.fields.Years_on_File__c.getName());
                }
                
                tuList.add(tu);
            }
        }
        if(ListFLSCreate.size()>0)
        {
            Utils.SendEmailforFLS('FLS_CREATE','CLASS:DBUtility', ListFLSCreate);
        }
        else
        {
            insert tuList;
        }
    }

    //------------------------------------------------------
    // non-db i/o functions
    //------------------------------------------------------

    public static String getColumnsForObjectType(Schema.SObjectType sot) {
    
        String fieldString = '';
        Map<String, Schema.SObjectField> fields = sot.getDescribe().fields.getMap();
        for(Schema.SObjectField sof : fields.values()) {
            Schema.DescribeFieldResult dfr = sof.getDescribe(); 
            //Added condition on 14-Dec-14 by djpatel (ADESA Canada-Salesforce Team)
            if(dfr.getName().equalsIgnoreCase('ShippingAddress') ||dfr.getName().equalsIgnoreCase('BillingAddress') || dfr.getName().equalsIgnoreCase('mailingaddress') || dfr.getName().equalsIgnoreCase('otheraddress'))
            {
                continue;
            }
            if(fieldString != '') {
                fieldString += ',' + dfr.getName();
            }
            else { 
                fieldString += dfr.getName();
            }
        }
        return fieldString;        
    }

    public static String getNameForLabel(Schema.SObjectType sot, String label) {
        
        Map<String, Schema.SObjectField> fields = sot.getDescribe().fields.getMap();
        for(Schema.SObjectField sof : fields.values()) {
            Schema.DescribeFieldResult dfr = sof.getDescribe();
            if(dfr.getLabel() == label) {
                return dfr.getName();
            } 
        }
        return null;        
    }

    public static Date efxToDate(String mm_dd_yyyy) {

        String month = mm_dd_yyyy.substring(0,2);
        String day =   mm_dd_yyyy.substring(3,5);
        String year =  mm_dd_yyyy.substring(6,10);
        if(day == '00') {
            day = '01';
        }
        if(month == '00') {
            month = '01';
        }        
        
        // EFX sometimes sends bad feb dates
        if(month == '02' && (day == '31' || day == '30')) {
            day = '28';
        }
        
        return Date.valueOf(year + '-' + month + '-' + day);
    }                

    public static Date expToDate(String dt) {
        
        if(dt == null || dt == 'null') {
            return null;
        }
        
        String day;
        String month;
        String year;
        
        if(dt.length() == 4) {
            day = '01';
            month = dt.substring(0,2);
            year = Integer.valueOf(dt.substring(2,4)) > 30 ? '19' + dt.substring(2,4) : '20' + dt.substring(2,4); 
        }
        else {
            day = dt.substring(2,4);
            month = dt.substring(0,2);
            year = Integer.valueOf(dt.substring(4,6)) > 30 ? '19' + dt.substring(4,6) : '20' + dt.substring(4,6);           
        }
        
        return Date.valueOf(year + '-' + month + '-' + day);
    }

    //-------------------------------------------------------------------------------------

    @future (callout=false)
    public static void parseLexisNexisReportFields(Id reportId) {

        Date todayDate = Date.today();
        Integer activeUCCCount = 0; 
        Integer liensJudgmentsCount = 0;
        String ns = 'http://webservices.seisint.com/WsAccurint';

        try {

            Attachment att = [select Id, Name, Body from Attachment where ParentId = :reportId and ContentType = 'text/xml'];
            String attachmentName = att.Name;                    
            DOM.Document doc = new DOM.Document();
            doc.load(att.Body.toString());
            Dom.XmlNode Root = doc.getRootElement();
            Dom.XmlNode Body = Root.getChildElements()[0];
            att = null;            

            // start COMPREHENSIVE_PERSON_REPORT
            if(attachmentName.contains(DBUtility.COMPREHENSIVE_PERSON_REPORT)) {

                Dom.XmlNode BpsReportResponseEx = Body.getChildElement('BpsReportResponseEx', ns);
                Dom.XmlNode response = BpsReportResponseEx.getChildElement('response', ns);
                Dom.XmlNode Individual = response.getChildElement('Individual', ns);
                Dom.XmlNode UCCFilings = Individual.getChildElement('UCCFilings', ns);
                Dom.XmlNode LiensJudgments = Individual.getChildElement('LiensJudgments', ns);
    
                if(UCCFilings != null) {    
                    for(Dom.XmlNode UCCFiling : UCCFilings.getChildElements()) {
                        Dom.XmlNode Filings = UCCFiling.getChildElement('Filings', ns);
                        if(Filings == null) {
                            continue;
                        }                       
                        for(Dom.XmlNode Filing : Filings.getChildElements()) {
                            Dom.XmlNode ExpirationDate = Filing.getChildElement('ExpirationDate', ns);
                            if(ExpirationDate == null) {
                                activeUCCCount++;   // when in doubt count it
                                break;
                            }
                            Dom.XmlNode Day = ExpirationDate.getChildElement('Day', ns);
                            Dom.XmlNode Month = ExpirationDate.getChildElement('Month', ns);
                            Dom.XmlNode Year = ExpirationDate.getChildElement('Year', ns);
                            try {                           
                                Date dt = Date.newInstance(Integer.valueOf(Year.getText()), Integer.valueOf(Month.getText()), Integer.valueOf(Day.getText()));
                                if(dt >= todayDate) {
                                    activeUCCCount++;
                                    break;                            
                                }
                            }
                            catch(Exception e) {
                                activeUCCCount++;   // when in doubt count it
                                break;
                            }
                        }
                    } 
                }
                
                if(LiensJudgments != null) {
                    liensJudgmentsCount += LiensJudgments.getChildElements().size();   
                }                
            }            
            // end COMPREHENSIVE_PERSON_REPORT

            // start ENHANCED_BUSINESS_REPORT
            else if(attachmentName.contains(DBUtility.ENHANCED_BUSINESS_REPORT)) {

                Dom.XmlNode EnhancedBusinessReportResponseEx = Body.getChildElement('EnhancedBusinessReportResponseEx', ns);
                Dom.XmlNode response = EnhancedBusinessReportResponseEx.getChildElement('response', ns);
                Dom.XmlNode UCCs = response.getChildElement('UCCs', ns);
                Dom.XmlNode LiensJudgments = response.getChildElement('LiensJudgments', ns);
    
                if(UCCs != null) {    
                    for(Dom.XmlNode UCC : UCCs.getChildElements()) {
                        Dom.XmlNode Filings = UCC.getChildElement('Filings', ns);
                        if(Filings == null) {
                            continue;
                        }                       
                        for(Dom.XmlNode Filing : Filings.getChildElements()) {
                            Dom.XmlNode ExpirationDate = Filing.getChildElement('ExpirationDate', ns);
                            if(ExpirationDate == null) {
                                activeUCCCount++;   // when in doubt count it
                                break;
                            }
                            Dom.XmlNode Day = ExpirationDate.getChildElement('Day', ns);
                            Dom.XmlNode Month = ExpirationDate.getChildElement('Month', ns);
                            Dom.XmlNode Year = ExpirationDate.getChildElement('Year', ns);
                            try {                           
                                Date dt = Date.newInstance(Integer.valueOf(Year.getText()), Integer.valueOf(Month.getText()), Integer.valueOf(Day.getText()));
                                if(dt >= todayDate) {
                                    activeUCCCount++;
                                    break;                            
                                }
                            }
                            catch(Exception e) {
                                activeUCCCount++;   // when in doubt count it
                                break;
                            }
                        }
                    } 
                }
                
                if(LiensJudgments != null) {
                    liensJudgmentsCount += LiensJudgments.getChildElements().size();   
                }                
            }
            // end ENHANCED_BUSINESS_REPORT

            // start UCC_FILING_SEARCH
            else if(attachmentName.contains(DBUtility.UCC_FILING_SEARCH)) {

                Dom.XmlNode UCCSearch2ResponseEx = Body.getChildElement('UCCSearch2ResponseEx', ns);
                Dom.XmlNode response = UCCSearch2ResponseEx.getChildElement('response', ns);
                Dom.XmlNode Records = response.getChildElement('Records', ns);
    
                if(Records != null) {
    
                    for(Dom.XmlNode Record : Records.getChildElements()) {
                        Dom.XmlNode Filings = Record.getChildElement('Filings', ns);
                        if(Filings == null) {
                            continue;
                        }
                        for(Dom.XmlNode Filing : Filings.getChildElements()) {
                            Dom.XmlNode ExpirationDate = Filing.getChildElement('ExpirationDate', ns);
                            if(ExpirationDate == null) {
                                activeUCCCount++;   // when in doubt count it
                                break;
                            }
                            Dom.XmlNode Day = ExpirationDate.getChildElement('Day', ns);
                            Dom.XmlNode Month = ExpirationDate.getChildElement('Month', ns);
                            Dom.XmlNode Year = ExpirationDate.getChildElement('Year', ns);
                            try {                           
                                Date dt = Date.newInstance(Integer.valueOf(Year.getText()), Integer.valueOf(Month.getText()), Integer.valueOf(Day.getText()));
                                if(dt >= todayDate) {
                                    activeUCCCount++;
                                    break;                            
                                }
                            }
                            catch(Exception e) {
                                activeUCCCount++;   // when in doubt count it
                                break;
                            }
                        }
                    } 
                }
            }
            // end UCC_FILING_SEARCH

            forseva1__LexisNexisReport__c rpt = new forseva1__LexisNexisReport__c();
            //Story B-44003 : FLS UPDATE ACCESS CHECK
             ListFLSUpdate = new Set<String>(); 
			 Boolean blnFLSOverride = Utils.GetFLS();
             // test class fail for below condition 
             /*
             if (Schema.sObjectType.forseva1__LexisNexisReport__c.fields.Id.isUpdateable() || blnFLSOverride)
             {                       
                rpt.Id = reportId;
             }
             else
             {                      
                ListFLSUpdate.add(Schema.sObjectType.forseva1__LexisNexisReport__c.getName()+'.'+Schema.sObjectType.forseva1__LexisNexisReport__c.fields.Id.getName());
             }
             */
             rpt.Id = reportId;
             if (Schema.sObjectType.forseva1__LexisNexisReport__c.fields.Number_of_Existing_UCC_Filings__c.isUpdateable() || blnFLSOverride)
             {                       
                 rpt.Number_of_Existing_UCC_Filings__c = activeUCCCount;
             }
             else
             {                      
                ListFLSUpdate.add(Schema.sObjectType.forseva1__LexisNexisReport__c.getName()+'.'+Schema.sObjectType.forseva1__LexisNexisReport__c.fields.Number_of_Existing_UCC_Filings__c.getName());
             }
             if (Schema.sObjectType.forseva1__LexisNexisReport__c.fields.Number_of_Liens_Judgments__c.isUpdateable() || blnFLSOverride)
             {                       
                rpt.Number_of_Liens_Judgments__c = liensJudgmentsCount;
             }
             else
             {                      
                ListFLSUpdate.add(Schema.sObjectType.forseva1__LexisNexisReport__c.getName()+'.'+Schema.sObjectType.forseva1__LexisNexisReport__c.fields.Number_of_Liens_Judgments__c.getName());
             }
             
            if(ListFLSUpdate.size()>0)
            {
                Utils.SendEmailforFLS('FLS_UPDATE','CLASS:DBUtility', ListFLSUpdate);
            }
            
            update rpt;
        }
        catch(Exception e) {
            System.debug('ERROR PARSING LEXISNEXIS REPORT: ' + e.getTypeName() + ' : ' + e.getMessage());
        }        
    }

}

// EOF