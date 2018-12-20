public with sharing class DataGatewayMDMServiceAccountHelper {
    public DataGatewayMDMServiceAccountHelper() {
    }
    public class MDMServiceParsingException extends Exception{}

    // SOAP message parts for Accounts
    private static String correlationIdString = String.valueOfGmt(System.now());
    private static final String organizationMatchRequestTemplate = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ihub="http://inthub.adesa.com/ihservices/common/IHubManifest" xmlns:cus="http://inthub.adesa.com/ihservices/common/CustomerMaster"> <soapenv:Header> <ihub:IHubManifest> <ihub:IHubConversation CorrelationId="'+correlationIdString+'" MessageId=""/> <ihub:RequestMeta> <ihub:SourceSystem Name="KAR Salesforce" /> <ihub:SourceRequest Name="AccountVerification" Version="1.0"/> <ihub:Division>Salesforce</ihub:Division> <ihub:SubDivision>IHUB</ihub:SubDivision> <ihub:Additionals> <ihub:code>0002</ihub:code> <ihub:description>mdmcustrt_sf_user_t</ihub:description> </ihub:Additionals> </ihub:RequestMeta> </ihub:IHubManifest> </soapenv:Header> <soapenv:Body> <cus:getOrganizationMatchRequest> <cus:OrganizationMatchRequestXML><![CDATA[<dat:OrganizationMatch_Input xmlns:dat="http://siebel.com/DataQuality" xmlns:swi="http://www.siebel.com/xml/SwiOrganizationMatchInputIO"> <swi:SwiOrganizationMatchInputIO Threshold="80" MessageId="" Locale="English - United States" Language="ENU" EnterpriseServerName="SBA_82">{AccountListString}</swi:SwiOrganizationMatchInputIO></dat:OrganizationMatch_Input>]]></cus:OrganizationMatchRequestXML> </cus:getOrganizationMatchRequest> </soapenv:Body> </soapenv:Envelope>';

    // Calls the MDM Service method getOrganizationMatch
    // It returns a Map of elements, consisting of an Account Id and a(nother) Map of Field Names and Values.
    // This represents the collection of fields whose values are different than in the supplied Account
    public static void getOrganizationMatch(List<Id> accountIdList){
        if(System.isFuture() || System.isBatch()){
            getOrganizationMatchSync(accountIdList);
        } else {
            if(Limits.getFutureCalls() < Limits.getLimitFutureCalls()){
                getOrganizationMatchAsync(accountIdList);
            } else {
                System.debug('*** Future Call Limits exceeded for getOrganizationMatch');
            }
        }
    }

    @future(callout=true)
    public static void getOrganizationMatchAsync(List<Id> accountIdList){
        getOrganizationMatchSync(accountIdList);
    }

    public static void getOrganizationMatchSync(List<Id> accountIdList){
        List<Account> accounts = [select id, Name, Auction_Access_Number__c, Tax_Identification_Number__c, Integration_ID__c,Type,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry 
                                from Account where Id in :accountIdList];

        String accountListString = '';
        for(Account account :accounts){
            accountListString += getAccountString(account);
        }
        if(accountListString == ''){
            accountListString = '<swi:Account/>';
        }

        String serviceRequestString = '';
        serviceRequestString = organizationMatchRequestTemplate.replace('{AccountListString}', accountListString);
        System.debug('*****Request:'+serviceRequestString);
        String responseString = makeMDMServiceRequest(serviceRequestString,'http://inthub.adesa.com/ihservices/common/CustomerMaster/getOrganizationMatch');
        System.debug('*****Response:'+responseString);

        Map<String,Account> keyStringAccountsMap = new Map<String,Account>();
        String keyString = '';
        for(Account a : accounts){
            keyString = '';
            keyString += (a.Name == null)?'':a.Name;
            keyString += (a.Auction_Access_Number__c == null)?'':a.Auction_Access_Number__c;
            keyString += (a.Tax_Identification_Number__c == null)?'':a.Tax_Identification_Number__c;
            keyString += (a.Integration_ID__c == null)?'':a.Integration_ID__c;
            keyString += (a.BillingStreet == null)?'':a.BillingStreet;
            keyString += (a.BillingPostalCode == null)?'':a.BillingPostalCode;
            keyStringAccountsMap.put(keyString,a);
        }

        List<AccountComparator> resultList = new List<AccountComparator>();
        String keyMatchString = '';
        for(String driver : getDrivers(responseString)){
            if(driver.indexOf('<ListOfCandidate>') == -1){}
            String requestString = driver.substring(0, driver.indexOf((driver.indexOf('<ListOfCandidate>') == -1)?'<ListOfCandidate/>':'<ListOfCandidate>'));
            keyMatchString = '';
            keyMatchString += String.join(processTag(requestString,'Name'),'');
            keyMatchString += String.join(processTag(requestString,'CSN'),'');
            keyMatchString += String.join(processTag(requestString,'TaxIdNumber'),'');
            keyMatchString += String.join(processTag(requestString,'IntegrationId'),'');
            keyMatchString += String.join(processTag(requestString,'StreetAddress'),'');
            keyMatchString += String.join(processTag(requestString,'PostalCode'),'');

            Account matchAccount = keyStringAccountsMap.get(keyMatchString);
            if(matchAccount == null){
              //  throw new MDMServiceParsingException('Could not find a result/Account match: ('+keyString+'/'+keyMatchString+')');
            } else {
                resultList.add(getResponseAccounts(matchAccount,driver));
            }
        }


        Set<String> accountUpdateFields = new Set<String>();
        for(Data_Gateway_MDM_Auto_Update__c field : Data_Gateway_MDM_Auto_Update__c.getAll().values()){
            if(field.Object_Name__c == 'Account' && field.MDM_Service_Response__c == true){
                accountUpdateFields.add(field.Field_Name__c);
            }
        }

        List<Account> finalAccounts = new List<Account>();
        for(AccountComparator ac : resultList){
            ac.updateAccount(accountUpdateFields);   
            finalAccounts.add(ac.salesforceAccount);
        }
        update finalAccounts;
    }

    private static String getAccountString(Account account){
        String result = '';
        
        if(account != null){
            result = '<swi:Account>';
            if(account.Tax_Identification_Number__c != null && account.Tax_Identification_Number__c != ''){
                result += '<swi:TaxIDNumber>'+account.Tax_Identification_Number__c+'</swi:TaxIDNumber>';
            }
            if(account.Auction_Access_Number__c != null && account.Auction_Access_Number__c != ''){
                result += '<swi:CSN>'+account.Auction_Access_Number__c+'</swi:CSN>';
            }
            if(account.Integration_ID__c != null && account.Integration_ID__c != ''){
                result += '<swi:IntegrationId>'+account.Integration_ID__c+'</swi:IntegrationId>';
            }
            if(account.Name != null && account.Name != ''){
                result += '<swi:Name>'+account.Name+'</swi:Name>';
            }
            String businessAddressString = '';
            if(account.billingStreet != null && account.billingStreet != ''){
                businessAddressString += '<swi:StreetAddress>'+account.billingStreet+'</swi:StreetAddress>';
            }            
            if(account.billingCity != null && account.billingCity != ''){
                businessAddressString += '<swi:City>'+account.billingCity+'</swi:City>';
            } 
            if(account.billingState != null && account.billingState != ''){
                businessAddressString += '<swi:State>'+account.billingState+'</swi:State>';
            } 
            if(account.billingPostalCode != null && account.billingPostalCode != ''){
                businessAddressString += '<swi:PostalCode>'+account.billingPostalCode+'</swi:PostalCode>';
            }
            if(businessAddressString != ''){
                result += '<swi:ListOfBusinessAddress><swi:BusinessAddress>'+businessAddressString+'</swi:BusinessAddress></swi:ListOfBusinessAddress>';
            }

            if(result == '<swi:Account>'){
                result = '<swi:Account/>';
            } else {
                result += '</swi:Account>';
            }
        }
        return result;
    }

    // Shared method for making the actual callout
    private static String makeMDMServiceRequest(String requestString, String soapAction){
        if(Test.isRunningTest()){
            if(TestDataGatewayAccount.currentTest == '' || TestDataGatewayAccount.currentTest == null){
                Test.setMock(HttpCalloutMock.class,new TestDataGatewayMDMServiceMock('Organization'));                
            }
        }        

        Data_Gateway_MDMService_Endpoint__c endpoint = Data_Gateway_MDMService_Endpoint__c.getInstance('MDMServiceEndpoint');
        String endpointString = '';
        if(endpoint == null){
            endpointString = 'http://inthub.auctionintegrationhub.com/karcustomermdm/KARCMDMService';
        } else {
            endpointString = endpoint.Environment_Url__c;
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpointString);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        req.setHeader('Content-Length',String.valueOf(requestString.length()));
        req.setHeader('SOAPAction',soapAction);
        req.setBody(requestString);

        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res.getBody().unescapeHtml4();
    }       

    private static List<String> getDrivers(String response){
        String xmlString = response.replace(' xmlns="http://www.siebel.com/xml/SwiOrganizationMatchOutputIO"', '');
        xmlString = xmlString.trim();
        List<ResponseAccount> result = new List<ResponseAccount>();

        // Because there may have been multiple accounts in the request,
        // break up the response string into sections by requested Account
        return processTag(xmlString,'Driver');
    }


    public static List<String> processTag(String sourceString, String tagName){
        String tagNameBegin = '<'+tagName+'>';
        String tagNameEnd = '</'+tagName+'>';
        List<String> result = new List<String>();

        integer foundStart = 0; 
        integer foundEnd = 0; 
        integer currentSpot = 0; 
        string itemAdd = ''; 
        do {    
            foundStart = sourceString.indexOf(tagNameBegin, currentSpot); 
            if(foundStart >= 0){ 
                foundEnd = sourceString.indexOf(tagNameEnd, foundStart + tagNameBegin.length()); 
                itemAdd = sourceString.substring(foundStart + tagNameBegin.length(), foundEnd); 
                result.add(itemAdd); 
            }   currentSpot = foundEnd + 1; 
        } while (foundStart != -1);     
        return result;  
    }

    public static AccountComparator getResponseAccounts(Account requestAccount, String driverString){
        AccountComparator result = new AccountComparator();
        result.salesforceAccount = requestAccount;

        List<String> responseAccountList = processTag(driverString,'Candidate');
        for(String accountString : responseAccountList){
            ResponseAccount ra = new ResponseAccount();
            ra.matchScore = (accountString.indexOf('MatchScore') == -1)?null:Integer.valueOf(processTag(accountString,'MatchScore')[0]);
            ra.name = (accountString.indexOf('Name') == -1)?null:processTag(accountString,'Name')[0];
            ra.integrationId = (accountString.indexOf('IntegrationId') == -1)?null:processTag(accountString,'IntegrationId')[0];
            ra.auctionAccessNumber = (accountString.indexOf('CSN') == -1)?null:processTag(accountString,'CSN')[0];
            ra.taxIdNumber = (accountString.indexOf('TaxIDNumber') == -1)?null:processTag(accountString,'TaxIDNumber')[0];
            ra.doNotCall = (accountString.indexOf('DontCall') == -1)?null:processTag(accountString,'DontCall')[0];
            ra.lastCallDate = (accountString.indexOf('LastCallDate') == -1)?null:processTag(accountString,'LastCallDate')[0];  

            if(accountString.indexOf('<BusinessAddress IsPrimary="YES">') == -1){
                ra.streetAddress = (accountString.indexOf('StreetAddress') == -1)?null:processTag(accountString,'StreetAddress')[0];
                ra.city = (accountString.indexOf('City') == -1)?null:processTag(accountString,'City')[0];
                ra.state = (accountString.indexOf('State') == -1)?null:processTag(accountString,'State')[0];
                ra.postalCode = (accountString.indexOf('PostalCode') == -1)?null:processTag(accountString,'PostalCode')[0];
                ra.country = (accountString.indexOf('Country') == -1)?null:processTag(accountString,'Country')[0];
            }  else {
                String primaryAddressString = accountString.substringBetween('<BusinessAddress IsPrimary="YES">','</BusinessAddress>');
                ra.streetAddress = (primaryAddressString.indexOf('StreetAddress') == -1)?null:processTag(primaryAddressString,'StreetAddress')[0];
                ra.city = (primaryAddressString.indexOf('City') == -1)?null:processTag(primaryAddressString,'City')[0];
                ra.state = (primaryAddressString.indexOf('State') == -1)?null:processTag(primaryAddressString,'State')[0];
                ra.postalCode = (primaryAddressString.indexOf('PostalCode') == -1)?null:processTag(primaryAddressString,'PostalCode')[0];
                ra.country = (primaryAddressString.indexOf('Country') == -1)?null:processTag(primaryAddressString,'Country')[0];
            }
            result.mdmAccountList.add(ra);
        }
        return result;
    }


    public class AccountComparator{
        public Account salesforceAccount{get;set;}
        public List<ResponseAccount> mdmAccountList{get;set;}
        public AccountComparator(){
            mdmAccountList = new List<ResponseAccount>();
        }
        public AccountComparator(Account sfAccount, ResponseAccount mdmAccount){
            this.salesforceAccount = sfAccount;
            mdmAccountList = new List<ResponseAccount>();
            mdmAccountList.add(mdmAccount);
        }
		Set<String> ListFLSUpdate = new Set<String>();
		Boolean blnFLSOverride = Utils.GetFLS();
        public void updateAccount(Set<String> fieldNames){
            if(mdmAccountList != null && mdmAccountList.size() > 0){
                if(fieldNames.contains('Name')){
					 //Story B-44003 : FLS UPDATE ACCESS CHECK
					 if (Schema.sObjectType.Account.fields.Name.isUpdateable() || blnFLSOverride)
					 {						 
						salesforceAccount.Name = mdmAccountList[0].Name;						
					 }
					 else
					 {						
						ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.Name.getName());
					 }
                }           
                if(fieldNames.contains('Auction_Access_Number__c')){
                    
					if (Schema.sObjectType.Account.fields.Auction_Access_Number__c.isUpdateable() || blnFLSOverride)
					 {						 
						salesforceAccount.Auction_Access_Number__c = mdmAccountList[0].auctionAccessNumber;
					 }
					 else
					 {						
						ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.Auction_Access_Number__c.getName());
					 }
                }           
                if(fieldNames.contains('Integration_ID__c')){
                    
					if (Schema.sObjectType.Account.fields.Integration_ID__c.isUpdateable() || blnFLSOverride)
					 {						 
						salesforceAccount.Integration_ID__c = mdmAccountList[0].integrationId;
					 }
					 else
					 {						
						ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.Integration_ID__c.getName());
					 }
                }           
                if(fieldNames.contains('Tax_Identification_Number__c')){
                    
					if (Schema.sObjectType.Account.fields.Tax_Identification_Number__c.isUpdateable() || blnFLSOverride)
					 {						 
						salesforceAccount.Tax_Identification_Number__c = mdmAccountList[0].taxIdNumber;
					 }
					 else
					 {						
						ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.Tax_Identification_Number__c.getName());
					 }
                }
                if(fieldNames.contains('Type')){
                    
					if (Schema.sObjectType.Account.fields.Type.isUpdateable() || blnFLSOverride)
					 {						 
						salesforceAccount.Type = mdmAccountList[0].accountType;
					 }
					 else
					 {						
						ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.Type.getName());
					 }
                }           
                if(fieldNames.contains('BillingStreet')){
                    
					if (Schema.sObjectType.Account.fields.BillingStreet.isUpdateable() || blnFLSOverride)
					 {						 
						salesforceAccount.BillingStreet = mdmAccountList[0].streetAddress;
					 }
					 else
					 {						
						ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.BillingStreet.getName());
					 }
                }           
                if(fieldNames.contains('BillingCity')){
                    
					if (Schema.sObjectType.Account.fields.BillingCity.isUpdateable() || blnFLSOverride)
					 {						 
						salesforceAccount.BillingCity = mdmAccountList[0].city;
					 }
					 else
					 {						
						ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.BillingCity.getName());
					 }
                }           
                if(fieldNames.contains('BillingState')){
                    
					if (Schema.sObjectType.Account.fields.BillingState.isUpdateable() || blnFLSOverride)
					 {						 
						salesforceAccount.BillingState = mdmAccountList[0].state;
					 }
					 else
					 {						
						ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.BillingState.getName());
					 }
                }           
                if(fieldNames.contains('BillingPostalCode')){
                    
					if (Schema.sObjectType.Account.fields.BillingPostalCode.isUpdateable() || blnFLSOverride)
					 {						 
						salesforceAccount.BillingPostalCode = mdmAccountList[0].postalCode;
					 }
					 else
					 {						
						ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.BillingPostalCode.getName());
					 }
                }           
                if(fieldNames.contains('BillingCountry')){
                    
					if (Schema.sObjectType.Account.fields.BillingCountry.isUpdateable() || blnFLSOverride)
					 {						 
						salesforceAccount.BillingCountry = mdmAccountList[0].country;
					 }
					 else
					 {						
						ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.BillingCountry.getName());
					 }
                }       
            }   
			
			if(ListFLSUpdate.size()>0)
			{
				Utils.SendEmailforFLS('FLS_UPDATE','CLASS:DataGatewayMDMServiceAccountHelper', ListFLSUpdate);
			}
        }
    }

    public class ResponseAccount{
        public Integer matchScore{get;set;}
        public String dunsNumber{get;set;}
        public String name{get;set;}
        public String accountType{get;set;}
        public String integrationId{get;set;}
        public String taxIdNumber{get;set;}
        public String auctionAccessNumber{get;set;}
        public String doNotCall{get;set;}
        public String lastCallDate{get;set;}
        public String isPrimaryAddress{get;set;}
        public String streetAddress{get;set;}
        public String city{get;set;}
        public String state{get;set;}
        public String postalCode{get;set;}
        public String country{get;set;}
    }
}