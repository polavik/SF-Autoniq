/**
* Copyright 2013-2014 Forseva, LLC. All rights reserved.
*/
global class CreditPersonsWS {

    // used by blended reports
    WebService static List<PersonWS> getCreditSubject(ID accountId) {

        List<Contact> contacts;
        UserContext__c uc = DBUtility.getUserContext();
        if(uc.Current_Application_Id__c != null) {
            contacts = DBUtility.getRelatedContacts(uc.Current_Application_Id__c);
        }
        else {
            contacts = DBUtility.getRelatedAccountContacts(accountId);
        }
        
        List<PersonWS> persons = new List<PersonWS>();                
        for(Contact ct : contacts) {             
            PersonWS p = new PersonWS();
            p.FirstName = ct.FirstName;
            p.LastName = ct.LastName;
            p.UnparsedAddress = ct.AFC_Primary_Street__c != null ? ct.AFC_Primary_Street__c : ct.MailingStreet;
            p.City = ct.AFC_Primary_City__c != null ? ct.AFC_Primary_City__c : ct.MailingCity;
            p.State = ct.AFC_Primary_State__c != null ? ct.AFC_Primary_State__c : ct.MailingState;
            p.PostalCode = ct.AFC_Primary_Postalcode__c != null ? ct.AFC_Primary_Postalcode__c : ct.MailingPostalCode;
            p.personId = ct.id;
            if(ct.Birthdate != null) {
                p.age = ct.Birthdate.monthsBetween(Date.today())/12;
            }
            if(ct.SSN__c != null) {
                p.SSN = ct.SSN__c;
            }
            persons.add(p);
        } 

        return persons;        
    }
    
    WebService static List<PersonWS> getCreditSubjectUsingParameterString(String parameterString) {
        
        ID accountId = null;
        ID contactId = null;
        list<String> nvpList = parameterString.split(',');
        for (String nvp: nvpList) {
            String nm = getNameFromNvp(nvp);
            String val = getValueFromNvp(nvp);
            if(nm == 'accountId') {
                accountId = Id.valueOf(val);
            }
            else if(nm == 'contactId') {
                contactId = Id.valueOf(val);
            }
        }
        
        List<Contact> contacts = new List<Contact>();
        UserContext__c uc = DBUtility.getUserContext();
        if(uc.Current_Application_Id__c != null) {
            contacts = DBUtility.getRelatedContacts(uc.Current_Application_Id__c);
        }
        else if(accountId != null) {
            contacts = DBUtility.getRelatedAccountContacts(accountId);
        }
        
        List<PersonWS> persons = new List<PersonWS>();
        for(Contact ct : contacts) {
            PersonWS p = new PersonWS();
            p.FirstName = ct.FirstName;
            p.LastName = ct.LastName;
            p.UnparsedAddress = ct.AFC_Primary_Street__c != null ? ct.AFC_Primary_Street__c : ct.MailingStreet;
            p.City = ct.AFC_Primary_City__c != null ? ct.AFC_Primary_City__c : ct.MailingCity;
            p.State = ct.AFC_Primary_State__c != null ? ct.AFC_Primary_State__c : ct.MailingState;
            p.PostalCode = ct.AFC_Primary_Postalcode__c != null ? ct.AFC_Primary_Postalcode__c : ct.MailingPostalCode;
            p.personId = ct.id;
            if(ct.Birthdate != null) {
                p.age = ct.Birthdate.monthsBetween(Date.today())/12;
            }
            if(ct.SSN__c != null) {
                p.SSN = ct.SSN__c;
            }
            persons.add(p);
        } 

        return persons;
    }
        
    WebService static List<String> getCreditBureauRequestParameters(String parameterString) {

        String parm;
        String theBureau;
        List<String> parmlist = new List<String>();

        string accountId = null;        
        list<String> nvpList = parameterString.split(',');
        for (String nvp: nvpList) {
            String nm = getNameFromNvp(nvp);
            String val = getValueFromNvp(nvp);
            if(nm == 'accountId') {
                accountId = id.valueOf(val);
                parm = 'accountId!' + accountId;
                parmList.add(parm);
            }        
            else if(nm == 'bureau') {
                theBureau = val;
            }        
        }

        if(DBUtility.EQUIFAX == theBureau) {
            // equifax parms
            parm = 'Flags!BeaconFlag';
            parmlist.add(parm);
            parm = 'Flags!OnLineDirectoryFlag';
            parmlist.add(parm);
            parm = 'Flags!ConsumerReferralLocationFlag';
            parmlist.add(parm);
            parm = 'Flags!AlertContactFlag';
            parmlist.add(parm);
            parm = 'Customer Options!RawFileAppendIndicator:N';        
            parmlist.add(parm);
            parm = 'Customer Options!PrintImageCDATAInclude:Y';        
            parmlist.add(parm);
            parm = 'Customer Options!OutputFormat:67';  // Acrofile Advanced 6.0
            parmlist.add(parm);
        }
        else if(DBUtility.EXPERIAN == theBureau) {            
            // experian parms 
            parm = 'Risk Models!Bankruptcy';
            parmList.add(parm);
            parm = 'Risk Models!FICO2';
            parmList.add(parm);
            parm = 'Output Options!TTY';
            parmList.add(parm);
        }        
        
        return parmList;
    }
    
    WebService static String parseAndScore(String dataProviderName, ID accountId, ID personId, String parameterString, String xml) {
 
        if(dataProviderName == 'Equifax Consumer') {
            return parseAndScoreEquifax(dataProviderName, accountId, personId, parameterString, xml);
        }
        else if(dataProviderName == 'Experian Consumer') {
            return parseAndScoreExperian(dataProviderName, accountId, personId, parameterString, xml);
        }
        else {
            return parseAndScoreTransUnion(dataProviderName, accountId, personId, parameterString, xml);
        }
    }

    //--------------------------
    // private
    //--------------------------

    private static Map<String,String> m_expReasons = new Map<String,String> {
        '01'=>'AMOUNT OWED ON ACCOUNTS IS TOO HIGH',
        '02'=>'LEVEL OF DELINQUENCY ON ACCOUNTS',
        '03'=>'TOO FEW BANK/NATIONAL REVOLVING ACCOUNTS',
        '04'=>'TOO MANY BANK/NATIONAL REVOLVING ACCOUNTS',
        '05'=>'TOO MANY ACCOUNTS WITH BALANCES',
        '06'=>'TOO MANY CONSUMER FINANCE COMPANY ACCOUNTS',
        '07'=>'ACCOUNT PAYMENT HISTORY IS TOO NEW TO RATE',
        '08'=>'TOO MANY INQUIRIES LAST 12 MONTHS',
        '09'=>'TOO MANY ACCOUNTS RECENTLY OPENED',
        '10'=>'RATIO OF BALANCE TO LIMIT ON BANK REVOLVING OR OTHER REV ACCTS TOO HIGH',
        '11'=>'AMOUNT OWED ON REVOLVING ACCOUNTS IS TOO HIGH',
        '12'=>'LENGTH OF TIME REVOLVING ACCOUNTS HAVE BEEN ESTABLISHED',
        '13'=>'TIME SINCE DELINQUENCY IS TOO RECENT OR UNKNOWN',
        '14'=>'LENGTH OF TIME ACCOUNTS HAVE BEEN ESTABLISHED',
        '15'=>'LACK OF RECENT BANK/NATIONAL REVOLVING INFORMATION',
        '16'=>'LACK OF RECENT REVOLVING ACCOUNT INFORMATION',
        '17'=>'NO RECENT NON-MORTGAGE BALANCE INFORMATION',
        '18'=>'NUMBER OF ACCOUNTS WITH DELINQUENCY',
        '19'=>'TOO FEW ACCOUNTS CURRENTLY PAID AS AGREED',
        '20'=>'TIME SINCE DEROGATORY PUBLIC RECORD OR COLLECTION IS TOO SHORT',
        '21'=>'AMOUNT PAST DUE TO ACCOUNTS',
        '22'=>'SERIOUS DELINQUENCY, DEROGATORY PUBLIC RECORD OR COLLECTION FILED',
        '24'=>'NO RECENT REVOLVING BALANCES',
        '25'=>'LENGTH OF TIME INSTALLMENT LOANS HAVE BEEN ESTABLISHED',
        '26'=>'NUMBER OF REVOLVING ACCOUNTS',
        '28'=>'NUMBER OF ESTABLISHED ACCOUNTS',
        '30'=>'TIME SINCE MOST RECENT ACCOUNT OPENING IS TOO SHORT',
        '31'=>'TOO FEW ACCOUNTS WITH RECENT PAYMENT INFORMATION',
        '32'=>'LACK OF RECENT INSTALLMENT LOAN INFORMATION',
        '33'=>'PROPORTION OF LOAN BALANCES TO LOAN AMOUNTS IS TOO HIGH',
        '34'=>'AMOUNT OWED ON DELINQUENT ACCOUNTS',
        '36'=>'LENGTH OF TIME OPEN INSTALLMENT LOANS HAVE BEEN ESTABLISHED',
        '37'=>'NUMBER OF FINANCE COMPANY ACCOUNTS ESTABLISHED RELATIVE TO LENGTH OF FINANCE HISTORY',
        '38'=>'SERIOUS DELINQUENCY AND PUBLIC RECORD OR COLLECTION FILED',
        '39'=>'SERIOUS DELINQUENCY',
        '40'=>'DEROGATORY PUBLIC RECORD OR COLLECTION FILED',
        '98'=>'LACK OF RECENT AUTO LOAN INFORMATION',
        '99'=>'LACK OF RECENT CONSUMER FINANCE COMPANY ACCOUNT INFORMATION'
    };

    private static String parseAndScoreEquifax(String dataProviderName, ID accountId, ID personId, String parameterString, String xml) {
    
        String serstr = null;
                            
        forseva1.ConsumerReportService crs = new forseva1.ConsumerReportService(xml, dataProviderName);
        forseva1__DataProviderProduct__c dpp = [select id from forseva1__DataProviderProduct__c where name = 'Equifax Consumer Credit'];
        forseva1__EquifaxConsumer__c ec = new forseva1__EquifaxConsumer__c();
        ec.forseva1__Data_Provider_Product__c = dpp.Id;
        ec.forseva1__Account__c = accountId;
        if(personId != null) {
            ec.forseva1__Contact__c = personId;
        }            
        
        try {

            Decimal  maxHighCredit = 0;
            Decimal  totalBalance = 0;
            Decimal  totalRealEstateBalance = 0;
            Decimal  totalRevolvingBalance = 0;            
            Integer  yearsOnFile = 0;            
            Integer  latePaymentCounter = 0;
            Integer  totalTradeCounter = 0;
            Integer  currentTradeCounter = 0;
            Integer  inquiryCounter = 0;
            Integer  recentInquiryCounter = 0;
            Integer  publicRecordCounter = 0;
            Integer  lienCounter = 0;
            Integer  collectionsCounter = 0;
            Integer  judgmentCounter = 0;
            Date     currentDate = Date.today();
            String   scoringMessages = '';
            String   reportMessages = '';
            Integer  reportMessageCounter = 1;

            Set<String> uniqueAccountNumbers = new Set<String>();
                            
            DOM.Document doc = new DOM.Document();
            doc.load(xml);
            Dom.XmlNode EfxTransmit = doc.getRootElement();
            Dom.XmlNode EfxReport = EfxTransmit.getChildElement('EfxReport', null);
            Dom.XmlNode USConsumerCreditReports = EfxReport.getChildElement('USConsumerCreditReports', null);
            Dom.XmlNode USConsumerCreditReport = USConsumerCreditReports.getChildElement('USConsumerCreditReport', null);

            for(Dom.XmlNode child : USConsumerCreditReport.getChildElements()) {
                
                // person info
                if(child.getName() == 'USHeader') {                 
                    Dom.XmlNode USCreditFile = child.getChildElement('USCreditFile', null);
                    Dom.XmlNode USConsumerSubject = child.getChildElement('USConsumerSubject', null);
                    if(USCreditFile != null) {
                        Dom.XmlNode FileSinceDate = USCreditFile.getChildElement('FileSinceDate', null);
                        Dom.XmlNode Safescans = USCreditFile.getChildElement('Safescans', null);
                        if(FileSinceDate != null) {
                            Date fsd = DBUtility.efxToDate(FileSinceDate.getText());
                            yearsOnFile = (Date.today().year() - fsd.year());
                        }
                        if(Safescans != null) {
                            for(Dom.XmlNode Safescan : Safescans.getChildElements()) {
                                String scanDesc = Safescan.getAttributeValue('description', null);
                                if(scanDesc != null) {
                                    reportMessages += '(' + reportMessageCounter++ + ') SAFESCAN: ' + scanDesc + '\n';
                                }    
                            }
                        }
                    }
                    if(USConsumerSubject != null) {
                        Dom.XmlNode SocialSecurityNumber = USConsumerSubject.getChildElement('SocialSecurityNumber', null);
                        if(SocialSecurityNumber != null) {
                            ec.SSN__c = SocialSecurityNumber.getText();
                        }    
                    }   
                }                                  
                                                  
                // accounts
                else if(child.getName() == 'USTrades') {
                    for(Dom.XmlNode USTrade : child.getChildElements()) {                    	                                                                        
                        
                        Dom.XmlNode AccountNumber = USTrade.getChildElement('AccountNumber', null);
                        Dom.XmlNode HighCreditAmount = USTrade.getChildElement('HighCreditAmount', null);
                        Dom.XmlNode DateClosed = USTrade.getChildElement('DateClosed', null);
                        Dom.XmlNode PortfolioType = USTrade.getChildElement('PortfolioType', null);
                        Dom.XmlNode BalanceAmount = USTrade.getChildElement('BalanceAmount', null);
                        Dom.XmlNode PaymentHistory = USTrade.getChildElement('PaymentHistory', null);                        

                        // ignore dupe records
                        if(AccountNumber != null && AccountNumber.getText() != null) {
                            if(uniqueAccountNumbers.contains(AccountNumber.getText())) {
                                continue;
                            }
                            else {
                                uniqueAccountNumbers.add(AccountNumber.getText());
                            }	
                        }

                        totalTradeCounter++;
                        
                        if(DateClosed == null) {
                            currentTradeCounter++;
                        }
                        
                        if(PortfolioType != null && BalanceAmount != null && BalanceAmount.getText() != null) {
                            String code = PortfolioType.getAttributeValue('code', null);
                            Integer bal = Integer.valueOf(BalanceAmount.getText());
                            totalBalance += bal;
                            if('M' == code) {
                                totalRealEstateBalance += bal;
                            }
                            else if('R' == code) {
                            	totalRevolvingBalance += bal;
                            } 
                        }
                        
                        if(HighCreditAmount != null) {
                            String hcaStr = HighCreditAmount.getText();
                            if(hcaStr != null) {
                                Integer hca = Integer.valueOf(hcaStr);
                                maxHighCredit = Math.max(maxHighCredit,hca);
                            }
                        }
                        
                        if(PaymentHistory != null) {
                            String phStr = PaymentHistory.getText();
                            // remove all good payment history indicators and count what is left
                            phStr = phStr.replace('*','').replace('E','').replace('1','').replace('/','');
                            latePaymentCounter += phStr.length();
                        }                        
                    }                
                }
                
                // inquiries
                else if(child.getName() == 'USInquiries') {
                    for(Dom.XmlNode USInquiry : child.getChildElements()) {
                        inquiryCounter++;
                        Dom.XmlNode DateOfInquiry = USInquiry.getChildElement('DateOfInquiry', null);
                        if(DateOfInquiry != null) {
                            Date inquiryDate = DBUtility.efxToDate(DateOfInquiry.getText());
                            if(inquiryDate.daysBetween(currentDate) <= 182) {
                                recentInquiryCounter++;
                            }
                        }
                    }
                }                
                
                // beacon score
                else if(child.getName() == 'USBeacon') {                    
                    
                    Dom.XmlNode BeaconScore = child.getChildElement('BeaconScore', null);
                    if(BeaconScore != null) {
                        String beacon = BeaconScore.getText();
                        if(beacon != null) {
                            ec.forseva1__F_Credit_Quality_Rating__c = Decimal.valueOf(beacon);
                            ec.forseva1__eqScrBeacon__c = Decimal.valueOf(beacon);
                        }
                    }
                    
                    Dom.XmlNode ScoreReasons = child.getChildElement('ScoreReasons', null);
                    if(ScoreReasons != null) {
                        for(Dom.XmlNode ScoreReason : ScoreReasons.getChildElements()) {
                            String reason = ScoreReason.getAttributeValue('description', null);
                            if(reason != null) {
                                reportMessages += '(' + reportMessageCounter++ + ') ' + Label.ScoreReason + ': ' + reason + '\n';
                                scoringMessages += reason + '\n';
                            }
                        }
                    }
                }
                
                // legal items
                else if(child.getName() == 'USLegalItems') {
                    for(Dom.XmlNode USLegalItem : child.getChildElements()) {
                        publicRecordCounter++;
                        judgmentCounter++;
                    }
                }

                // collections
                else if(child.getName() == 'USCollections') {
                    for(Dom.XmlNode USCollection : child.getChildElements()) {
                        collectionsCounter++;
                    }
                }

                // tax liens
                else if(child.getName() == 'USTaxLiens') {
                    for(Dom.XmlNode USTaxLien : child.getChildElements()) {
                        publicRecordCounter++;
                        lienCounter++;
                    }
                }

                // bankruptcies
                else if(child.getName() == 'USBankruptcies') {
                    for(Dom.XmlNode USBankruptcy : child.getChildElements()) {
                        publicRecordCounter++;
                    }                               
                }                                                                

                // ofac message
                else if(child.getName() == 'USOFACAlerts') {
                	Dom.XmlNode USOFACAlert = child.getChildElement('USOFACAlert', null);
                	if(USOFACAlert != null) {
                	    Dom.XmlNode LegalVerbiage = USOFACAlert.getChildElement('LegalVerbiage', null);
                	    if(LegalVerbiage != null) {
                	        String ofac = LegalVerbiage.getText();
                	        if(ofac != null) {
                	            reportMessages += '(' + reportMessageCounter++ + ') OFAC: ' + ofac + '\n';
                	        }
                	    }
                	}
                }                                                                
            }          

            //----------------------------------------
            // populate scoring inputs on report
            //----------------------------------------

            ec.Years_on_File__c = yearsOnFile;
            ec.Maximum_High_Credit__c = maxHighCredit;
            ec.Late_Payment_Count__c = latePaymentCounter;
            ec.Total_Trades__c = totalTradeCounter;
            ec.Current_Trades__c = currentTradeCounter;
            ec.Inquiries__c = inquiryCounter;
            ec.Inquiries_Last_6_Months__c = recentInquiryCounter;
            ec.Public_Records__c = publicRecordCounter;
            ec.Liens__c = lienCounter;
            ec.Collections__c = collectionsCounter;
            ec.Judgments__c = judgmentCounter;
            ec.Report_Messages__c = reportMessages;
            ec.Scoring_Messages__c = scoringMessages;
            ec.Total_Balance__c = totalBalance;
            ec.Total_Real_Estate_Balance__c = totalRealEstateBalance;
            ec.Total_Revolving_Balance__c = totalRevolvingBalance;                                                          
        }
        catch(Exception e) {
            ec.forseva1__F_Credit_Review_Comments__c = 'Error Reading Equifax Report: ' + e.getTypeName() + ' - ' + e.getMessage() + ' - ' + e.getStackTraceString();
        }

        serstr =  crs.serializeSObject(ec);               
        return serstr;                    
    }

    private static String parseAndScoreExperian(String dataProviderName, ID accountId, ID personId, String parameterString, String xml) {

        String serstr = null;
                            
        forseva1.ConsumerReportService crs = new forseva1.ConsumerReportService(xml, dataProviderName);
        forseva1__DataProviderProduct__c dpp = [select id from forseva1__DataProviderProduct__c where name = 'Experian Consumer Credit'];
        forseva1__ExperianConsumer__c ec = new forseva1__ExperianConsumer__c();
        ec.forseva1__Data_Provider_Product__c = dpp.id;
        ec.forseva1__Account__c = accountId;
        if(personId != null) {
            ec.forseva1__Contact__c = personId;
        }            
        
        try {

            Decimal  maxHighCredit = 0;
            Decimal  totalBalance = 0;
            Decimal  totalRealEstateBalance = 0;
            Decimal  totalRevolvingBalance = 0;
            Integer  yearsOnFile = 0;            
            Integer  latePaymentCounter = 0;
            Integer  totalTradeCounter = 0;
            Integer  currentTradeCounter = 0;
            Integer  inquiryCounter = 0;
            Integer  recentInquiryCounter = 0;
            Integer  publicRecordCounter = 0;
            String   namespace = 'http://www.experian.com/ARFResponse';
            Date     currentDate = Date.today();
            String   scoringMessages = '';
            String   reportMessages = '';
            Integer  reportMessageCounter = 1;
            
            DOM.Document doc = new DOM.Document();
            doc.load(xml);
            Dom.XmlNode NetConnectResponse = doc.getRootElement();
            Dom.XmlNode Products = NetConnectResponse.getChildElement('Products', namespace);
            Dom.XmlNode CreditProfile = Products.getChildElement('CreditProfile', namespace);
            
            for(Dom.XmlNode child : CreditProfile.getChildElements()) {
            
                // fico score and reasons
                if(child.getName() == 'RiskModel') {
                	
                    Dom.XmlNode ModelIndicator = child.getChildElement('ModelIndicator', namespace);
                    Dom.XmlNode Score = child.getChildElement('Score', namespace);
                    Dom.XmlNode ScoreFactorCodeOne = child.getChildElement('ScoreFactorCodeOne', namespace);
                    Dom.XmlNode ScoreFactorCodeTwo = child.getChildElement('ScoreFactorCodeTwo', namespace);
                    Dom.XmlNode ScoreFactorCodeThree = child.getChildElement('ScoreFactorCodeThree', namespace);
                    Dom.XmlNode ScoreFactorCodeFour = child.getChildElement('ScoreFactorCodeFour', namespace);
                    
                    if(ModelIndicator != null && Score != null) {                    	
                    	String code = ModelIndicator.getAttributeValue('code', null);
                        String fico = Score.getText();
                        if('F' == code && fico != null) {
                            ec.forseva1__F_Credit_Quality_Rating__c = Decimal.valueOf(fico);
                            ec.FICO_Score__c = Decimal.valueOf(fico);
                        }
                        if('F' == code) {                            
                            if(ScoreFactorCodeOne != null && ScoreFactorCodeOne.getText() != null) {
                                scoringMessages += m_expReasons.get(ScoreFactorCodeOne.getText()) + '\n';
                            }                                            
                            if(ScoreFactorCodeTwo != null && ScoreFactorCodeTwo.getText() != null) {
                                scoringMessages += m_expReasons.get(ScoreFactorCodeTwo.getText()) + '\n';
                            }                                            
                            if(ScoreFactorCodeThree != null && ScoreFactorCodeThree.getText() != null) {
                                scoringMessages += m_expReasons.get(ScoreFactorCodeThree.getText()) + '\n';
                            }                                            
                            if(ScoreFactorCodeFour != null && ScoreFactorCodeFour.getText() != null) {
                                scoringMessages += m_expReasons.get(ScoreFactorCodeFour.getText()) + '\n';
                            }                                                                        
                        }
                    }
                }

                // ssn 
                else if(child.getName() == 'SSN') {
                    Dom.XmlNode theNumber = child.getChildElement('Number', namespace);
                    if(theNumber != null) {
                        ec.SSN__c = theNumber.getText();
                    }
                }

                // accounts
                else if(child.getName() == 'TradeLine') {

                    totalTradeCounter++;
                    Dom.XmlNode OpenOrClosed = child.getChildElement('OpenOrClosed', namespace);
                    String code = OpenOrClosed.getAttributeValue('code', null);
                    if('O' == code) {
                        currentTradeCounter++;
                    }

                    for(Dom.XmlNode child2 : child.getChildElements()) {
                        if(child2.getName() == 'Amount') {
                            Dom.XmlNode Qualifier  = child2.getChildElement('Qualifier', namespace);
                            Dom.XmlNode Value = child2.getChildElement('Value', namespace);
                            if(Qualifier != null && Value != null) {
                                code = Qualifier.getAttributeValue('code', null);
                                if('H' == code) {
                                    String highBalance = Value.getText();
                                    if(highBalance != null) {
                                        Integer hca = Integer.valueOf(highBalance);
                                        maxHighCredit = Math.max(maxHighCredit,hca);                                        
                                    }
                                }
                            }
                        }
                        else if(child2.getName() == 'BalanceAmount' && child2.getText() != null) {
                        	try {
                        	    Integer bal = Integer.valueOf(child2.getText());
                                totalBalance += bal;
                                maxHighCredit = Math.max(maxHighCredit,bal);
                        	}
                        	catch(Exception e){}  // ignore bad data
                        }
                    }

                    Dom.XmlNode PaymentProfile = child.getChildElement('PaymentProfile', namespace);
                    if(PaymentProfile != null) {
                        String phStr = PaymentProfile.getText();
                        // remove all good payment history indicators and count what is left
                        phStr = phStr.replace('C','').replace('N','').replace('0','').replace('-','').replace('B','');
                        latePaymentCounter += phStr.length();
                    }                                            
                }            
            
                // inquiries
                else if(child.getName() == 'Inquiry') {
                    inquiryCounter++;
                    Dom.XmlNode theDate = child.getChildElement('Date', namespace);
                    Date dt = DBUtility.expToDate(theDate.getText());
                    if(dt != null && dt.daysBetween(currentDate) <= 182) {
                        recentInquiryCounter++;
                    }                    
                }            
            
                // public records
                else if(child.getName() == 'PublicRecord') {
                	publicRecordCounter++;
                }            

                // summary items
                else if(child.getName() == 'ProfileSummary') {                                 
                    Dom.XmlNode RealEstateBalance = child.getChildElement('RealEstateBalance', namespace);
                    Dom.XmlNode RevolvingBalance = child.getChildElement('RevolvingBalance', namespace);                    
                    if(RealEstateBalance != null && RealEstateBalance.getText() != null) {
                        totalRealEstateBalance = Integer.valueOf(RealEstateBalance.getText());
                    }
                    if(RevolvingBalance != null && RevolvingBalance.getText() != null) {
                        totalRevolvingBalance = Integer.valueOf(RevolvingBalance.getText());
                    }
                }
                
                // years on file
                else if(child.getName() == 'AddressInformation' || child.getName() == 'EmploymentInformation') {
                    Dom.XmlNode FirstReportedDate = child.getChildElement('FirstReportedDate', namespace);                
                    if(FirstReportedDate != null && FirstReportedDate.getText() != null && FirstReportedDate.getText().replace(' ','').length() > 0) {
                        Date frd = DBUtility.expToDate(FirstReportedDate.getText());
                        yearsOnFile = Math.max(yearsOnFile, (Date.today().year() - frd.year()));
                    }
                }                                
                
                // statements from consumer
                else if(child.getName() == 'Statement') {                
                    Dom.XmlNode StatementText = child.getChildElement('StatementText', namespace);
                    if(StatementText != null) {
                        Dom.XmlNode MessageText = StatementText.getChildElement('MessageText', namespace);
                        if(MessageText != null && MessageText.getText() != null) {
                            reportMessages += '(' + reportMessageCounter++ + ') ' + Label.Statement + ': ' + MessageText.getText() + '\n';
                        }
                    }
                }

                // fraud messages                
                else if(child.getName() == 'FraudServices') {                
                    Dom.XmlNode Text = child.getChildElement('Text', namespace);
                    if(Text != null && Text.getText() != null) {
                        reportMessages += '(' + reportMessageCounter++ + ') ' + Label.FraudServices + ': ' + Text.getText() + '\n';
                    }
                }                
            }            

            //----------------------------------------
            // populate scoring inputs on report
            //----------------------------------------

            ec.Years_on_File__c = yearsOnFile;
            ec.Maximum_High_Credit__c = maxHighCredit;
            ec.Late_Payment_Count__c = latePaymentCounter;
            ec.Total_Trades__c = totalTradeCounter;
            ec.Current_Trades__c = currentTradeCounter;
            ec.Inquiries__c = inquiryCounter;
            ec.Inquiries_Last_6_Months__c = recentInquiryCounter;
            ec.Public_Records__c = publicRecordCounter;
            ec.Report_Messages__c = reportMessages;
            ec.Scoring_Messages__c = scoringMessages;
            ec.Total_Balance__c = totalBalance;
            ec.Total_Real_Estate_Balance__c = totalRealEstateBalance;
            ec.Total_Revolving_Balance__c = totalRevolvingBalance;                        
        }
        catch(Exception e) {
            ec.forseva1__F_Credit_Review_Comments__c = 'Error Reading Experian Report: ' + e.getTypeName() + ' - ' + e.getMessage() + ' - ' + e.getStackTraceString();
        }

        serstr =  crs.serializeSObject(ec);               
        return serstr;                    
    }

    private static String parseAndScoreTransUnion(String dataProviderName, ID accountId, ID personId, String parameterString, String xml) {

        String serstr = null;
                            
        forseva1.ConsumerReportService crs = new forseva1.ConsumerReportService(xml, dataProviderName);
        forseva1__DataProviderProduct__c dpp = [select id from forseva1__DataProviderProduct__c where name = 'Transunion Consumer Credit'];
        forseva1__TransunionConsumer__c tc = new forseva1__TransunionConsumer__c();
        tc.forseva1__Data_Provider_Product__c = dpp.id;
        tc.forseva1__Account__c = accountId;
        if(personId != null) {
            tc.forseva1__Contact__c = personId;
        }            
        
        try {

            Date currentDate = Date.today();                
            DOM.Document doc = new DOM.Document();
            doc.load(xml);
                        
        }
        catch(Exception e) {
            tc.forseva1__F_Credit_Review_Comments__c = 'Error Reading TransUnion Report: ' + e.getTypeName() + ' - ' + e.getMessage() + ' - ' + e.getStackTraceString();
        }

        serstr =  crs.serializeSObject(tc);               
        return serstr;                    
    }
        
    private static String getNameFromNvp(String nvp) {
        list<String> lst = nvp.split(':');
        return lst[0];
    }

    private static String getValueFromNvp(String nvp) {
        list<String> lst = nvp.split(':');
        return lst[1];
    }
        
}

// EOF