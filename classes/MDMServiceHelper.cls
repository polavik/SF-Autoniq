public with sharing class MDMServiceHelper {
    public static final String ACCOUNT_QUERY = 'Account Query';
    public static final String ACCOUNT_MATCH = 'Account Match';
    public static final String SOAP_ACTION_ORG_MATCH = 'http://inthub.adesa.com/ihservices/common/CustomerMaster/getOrganizationMatch';
    public static final String SOAP_ACTION_ORG_QUERY = 'http://inthub.adesa.com/ihservices/common/CustomerMaster/OrganizationQueryService';
    private static final String MATCH_REQUEST_TEMPLATE = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ihub="http://inthub.adesa.com/ihservices/common/IHubManifest" xmlns:cus="http://inthub.adesa.com/ihservices/common/CustomerMaster"> <soapenv:Header> <ihub:IHubManifest> <ihub:IHubConversation CorrelationId="{correlationId}" MessageId=""/> <ihub:RequestMeta> <ihub:SourceSystem Name="Salesforce" /> <ihub:SourceRequest Name="SF" Version="1.0"/> <ihub:Division>KAR</ihub:Division> <ihub:SubDivision>SF Gateway</ihub:SubDivision> <ihub:Additionals> <ihub:code>0002</ihub:code> <ihub:description>Eric.Whipple</ihub:description> </ihub:Additionals> </ihub:RequestMeta> </ihub:IHubManifest> <wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"><wsse:UsernameToken xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><wsse:Username>{wsseusername}</wsse:Username><wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">{wssepassword}</wsse:Password></wsse:UsernameToken></wsse:Security> </soapenv:Header> <soapenv:Body> <cus:getOrganizationMatchRequest> <cus:OrganizationMatchRequestXML><![CDATA[<dat:OrganizationMatch_Input xmlns:dat="http://siebel.com/DataQuality" xmlns:swi="http://www.siebel.com/xml/SwiOrganizationMatchInputIO"> <swi:SwiOrganizationMatchInputIO Threshold="80" MessageId="" Locale="English - United States" Language="ENU" EnterpriseServerName="SBA_82">{AccountListString}</swi:SwiOrganizationMatchInputIO></dat:OrganizationMatch_Input>]]></cus:OrganizationMatchRequestXML> </cus:getOrganizationMatchRequest> </soapenv:Body> </soapenv:Envelope>';
    private static final String QUERY_REQUEST_TEMPLATE = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ihub="http://inthub.adesa.com/ihservices/common/IHubManifest" xmlns:cus="http://inthub.adesa.com/ihservices/common/CustomerMaster"> <soapenv:Header> <ihub:IHubManifest> <ihub:IHubConversation CorrelationId="{correlationId}"/> <ihub:RequestMeta> <ihub:SourceSystem Name="Salesforce" /><ihub:SourceRequest Name="SF" Version="1.0"/> <ihub:Division>KAR</ihub:Division> <ihub:SubDivision>SF Gateway</ihub:SubDivision> <ihub:Additionals> <ihub:code>0002</ihub:code> <ihub:description>Eric.Whipple</ihub:description> </ihub:Additionals> </ihub:RequestMeta> </ihub:IHubManifest> <wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"> <wsse:UsernameToken xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"> <wsse:Username>{wsseusername}</wsse:Username> <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">{wssepassword}</wsse:Password> </wsse:UsernameToken> </wsse:Security> </soapenv:Header> <soapenv:Body> <cus:OrganizationQueryServiceRequest> <cus:OrganizationQueryServiceRequestXML><![CDATA[<cus:getOrganization_Input xmlns:cus="http://xmlns.oracle.com/apps/mdm/customer" xmlns:swi="http://www.siebel.com/xml/SwiOrganizationIO"> <cus:Process_spcInstance_spcId></cus:Process_spcInstance_spcId> <swi:ListOfSwiOrganizationIO ExternalSystemId="{sourceSystem}">{AccountListString} </swi:ListOfSwiOrganizationIO> <cus:Object_spcId>?</cus:Object_spcId> <cus:RealtimePubSub>?</cus:RealtimePubSub> <cus:Siebel_spcOperation_spcObject_spcId>?</cus:Siebel_spcOperation_spcObject_spcId> <cus:_sblesc_lstValue_grt>?</cus:_sblesc_lstValue_grt> <cus:Error_spcCode>?</cus:Error_spcCode> <cus:Error_spcMessage>?</cus:Error_spcMessage> </cus:getOrganization_Input>]]></cus:OrganizationQueryServiceRequestXML> </cus:OrganizationQueryServiceRequest> </soapenv:Body></soapenv:Envelope>';

    public MDMServiceHelper() {
    }

    public static String refreshSalesforceAccount(List<Id> accountIdList){
        Map<Id,Account> accountMap = new Map<Id,Account>([select id, Name, Integration_Id__c, Auction_Access_Number__c, Tax_Identification_Number__c, Dba__c,Legal_Name__c, AFC_Dealer_Id__c, ATC_Organization_ID__c, Openlane_Org_Id__c, 
                                    BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, phone, fax from Account where id in :accountIdList]);

        Map<Id,MDMServiceRequest> accountRequestMap = new Map<Id,MDMServiceRequest>();
        for(Id id : accountMap.keySet()){
			MDMServiceRequest mdmsr1 = new MDMServiceRequest(getRequestString(accountMap.get(id)));
        	mdmsr1.makeRequest();        	
        	accountRequestMap.put(id,mdmsr1);
        }

        for(Id id : accountMap.keySet()){
        	MDMServiceRequest mdmsr = accountRequestMap.get(id);
        	Account account = accountMap.get(id);
	        if(mdmsr.bestMatch != null){
	            account = updateAccountValues(account,mdmsr.bestMatch);

	            Set<String> matchingAccountIdSet = new Set<String>{account.Id};
	            List<Account> acctList = [select id, In_Stewardship__c from Account where Integration_Id__c = :mdmsr.bestMatch.integrationId];
	            for(Account acct : acctList){
	            	matchingAccountIdSet.add(acct.Id);
	            }
	            if(matchingAccountIdSet.size() > 1){
	            	List<String> matchingAccountIdList = new List<String>();
	            	matchingAccountIdList.addAll(matchingAccountIdSet);

	            	StewardshipHelper.createDuplicateIntegrationIdCase(mdmsr.bestMatch.integrationId, matchingAccountIdList);
	            	account.In_Stewardship__c = true; // For the current Account
	            	// Update the other Accounts that have this Integration Id
	            	for(Account acct : acctList){
	            		acct.In_Stewardship__c = true;
	            	}
	            	update acctList;
	            }
	            update account;
	        }
	    }

		///* Check for (and automatically close) "Local Account Integration" cases for Accounts that have an integration id (which may have been filled in by a nightly batch) */
		//List<Case> caseList = [select id, status, accountId, Account.Integration_Id__c from Case where RecordTypeId = :StewardshipHelper.stewardshipRtId and status = 'Open' and accountId in :accountIdList and Account.Integration_Id__c != null limit 10000];
		//for(Case c : caseList){
		//	c.status = 'Closed';
		//}
		//update caseList;
		
	    if(accountIdList.size() == 1){
	    	MDMServiceRequest singleResponseMdmsr = accountRequestMap.get(accountIdList[0]);
	    	if(singleResponseMdmsr.mdmResultList.size() == 0){
				return 'MDM returned '+singleResponseMdmsr.mdmResultList.size()+' zero matching results.  The Account was not updated.';
	        } else {
	            return 'MDM returned '+singleResponseMdmsr.mdmResultList.size()+' Accounts but could not conclusively determine a matching record.  The Account was not updated.';
	        }
	    } else { // If this is a multi-record update
	    	return accountIdList.size() + ' records have been processed by the refreshSalesforceAccount method.';
	    }
    }

    // This method  calls the refreshSalesforceAccount method within an asynchronous context
    @future(callout=true)
    public static void refreshSalesforceAccountAsync(List<Id> accountIdList){
    	System.debug('*****Refreshing with List Size: '+accountIdList.size());
    	refreshSalesforceAccount(accountIdList);
    }


    public static String getRequestString(Account account){
        String requestString = QUERY_REQUEST_TEMPLATE;
        if(account.Openlane_Org_Id__c != null){
            requestString = requestString.replace('{sourceSystem}','OPENLANE');
            requestString = requestString.replace('{AccountListString}','<swi:Account operation="Query"><swi:Id>'+account.Openlane_Org_Id__c+'</swi:Id></swi:Account>');
        } else if(account.Auction_Access_Number__c != null){
            requestString = requestString.replace('{sourceSystem}','AMS');
            requestString = requestString.replace('{AccountListString}','<swi:Account operation="Query" ><swi:CSN>'+account.Auction_Access_Number__c+'</swi:CSN></swi:Account>');
        } else if(account.AFC_Dealer_Id__c != null){
            requestString = requestString.replace('{sourceSystem}','COSMOS');
            requestString = requestString.replace('{AccountListString}','<swi:Account operation="Query"><swi:Id>'+account.AFC_Dealer_Id__c+'</swi:Id></swi:Account>');
        } else if(account.Integration_Id__c != null){
            requestString = requestString.replace('{sourceSystem}','AMS');
            requestString = requestString.replace('{AccountListString}','<swi:Account operation="Query" ><swi:IntegrationId>'+account.Integration_Id__c+'</swi:IntegrationId></swi:Account>');
        } else {
            // If none of the key attributes match, then use SearchMatch (instead of QueryMatch)
            requestString = MATCH_REQUEST_TEMPLATE;
            String accountString = '';
            accountString += createTag('swi:Name',(account.Dba__c == null) ? account.Name : account.Dba__c);
            accountString += createTag('swi:Alias',account.Legal_Name__c);
            accountString += createTag('swi:TaxIDNumber',account.Tax_Identification_Number__c);
            accountString += createTag('swi:CSN',account.Auction_Access_Number__c);

            String businessAddressString = '';
            businessAddressString += createTag('swi:StreetAddress',account.billingStreet);
            businessAddressString += createTag('swi:City',account.billingCity);
            businessAddressString += createTag('swi:State',account.billingState);
            businessAddressString += createTag('swi:PostalCode',account.billingPostalCode);
            if(businessAddressString != ''){
                accountString += '<swi:ListOfBusinessAddress><swi:BusinessAddress>'+businessAddressString+'</swi:BusinessAddress></swi:ListOfBusinessAddress>';
            }
            accountString = (accountString == '')?'<swi:Account/>':'<swi:Account>'+accountString+'</swi:Account>';
            requestString = requestString.replace('{AccountListString}',accountString);
        }

        // Load WS-Security credentials from the custom "Property__c" object
        Map<String,String> wsseCredentialMap = new Map<String,String>();
        for(Property__c p : [select property_id__c,property_value__c from Property__c where property_id__c in ('wsse.username','wsse.password')]){
            wsseCredentialMap.put(p.property_id__c,p.property_value__c);
        }
        requestString = requestString.replace('{wsseusername}',wsseCredentialMap.get('wsse.username'));
        requestString = requestString.replace('{wssepassword}',wsseCredentialMap.get('wsse.password'));
        requestString = requestString.replace('{correlationId}', String.valueOfGmt(System.now()));

        return requestString;
    }

    public static String makeMDMServiceRequest(String requestString, String soapAction){

        MDM_Settings__c endpoint = MDM_Settings__c.getInstance();
        String endpointString = '';
        if(endpoint != null){ 
            if(endpoint.MDM_Current_Environment__c == 'test'){
                endpointString = endpoint.MDM_Test_Env_Endpoint__c;
            } else if(endpoint.MDM_Current_Environment__c == 'stage'){
                endpointString = endpoint.MDM_Stage_Env_Endpoint__c;
            } else if(endpoint.MDM_Current_Environment__c == 'prod'){
                endpointString = endpoint.MDM_Prod_Env_Endpoint__c;
            }
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

    public static Account updateAccountValues(Account account, MDMAccount mdmAccount){
        boolean integrationIdUpdated = false;

        account.Name = (account.Name == null && mdmAccount.dbaName != null)? mdmAccount.dbaName : account.Name; // If this method is populating a brand new Account
        account.AFC_Dealer_Id__c = (account.AFC_Dealer_Id__c == null && mdmAccount.afcDealerId != null)? mdmAccount.afcDealerId : account.AFC_Dealer_Id__c;
        account.Openlane_Org_Id__c = (account.Openlane_Org_Id__c == null && mdmAccount.openlaneOrgId != null)? mdmAccount.openlaneOrgId : account.Openlane_Org_Id__c;
        account.dba__c = (account.dba__c == null && mdmAccount.dbaName != null)? mdmAccount.dbaName : account.dba__c;
        account.Legal_Name__c = (account.Legal_Name__c == null && mdmAccount.legalName != null)? mdmAccount.legalName : account.Legal_Name__c;
        account.Auction_Access_Number__c = (account.Auction_Access_Number__c == null && mdmAccount.auctionAccessNumber != null)? mdmAccount.auctionAccessNumber : account.Auction_Access_Number__c;
        account.Phone = (account.phone == null && mdmAccount.phone != null)? mdmAccount.phone : account.phone;
        account.Fax = (account.fax == null && mdmAccount.fax != null)? mdmAccount.fax : account.fax;
        account.Tax_Identification_Number__c = (account.Tax_Identification_Number__c == null && mdmAccount.taxIdNumber != null)? mdmAccount.taxIdNumber : account.Tax_Identification_Number__c;

        if(account.Integration_Id__c == null && mdmAccount.integrationId != null){
            account.Integration_Id__c = mdmAccount.integrationId;
            integrationIdUpdated = true;
        }

        for(MDMAccountAddress address : mdmAccount.addressList){
            if(address.isPrimary){
                account.billingStreet = (account.billingStreet == null && address.streetAddress != null)? address.streetAddress : account.billingStreet;
                account.billingCity = (account.billingCity == null && address.city != null)? address.city : account.billingCity;
                account.billingState = (account.billingState == null && address.state != null)? address.state : account.billingState;
                account.billingPostalCode = (account.billingPostalCode == null && address.postalCode != null)? address.postalCode : account.billingPostalCode;
                account.BillingCountry = (account.billingCountry == null && address.country != null)? address.country : account.billingCountry;     
            }
        }
        account.Mdm_Refresh_Date__c = System.now();
        account.Mdm_Compliant__c = isAccountCompliant(account,mdmAccount);
        // If you have updated the integrationid, check whether this has created a duplicate and raise a case
        if(integrationIdUpdated){
            List<Account> aList = [select id from Account where Integration_Id__c = :account.Integration_Id__c];
            if(aList.size() > 1){
                List<Id> idList = new List<Id>();
                for(Account a : aList){
                    idList.add(a.Id);
                }
                StewardshipHelper.createDuplicateIntegrationIdCase(account.Integration_Id__c, idList); // Could be false if there is no update
            }
        }
        return account;
    }

    public static boolean isAccountCompliant(Account account, MDMAccount mdmAccount){

        if(mdmAccount.dbaName != account.Dba__c){
            return false;
        }
        if(mdmAccount.legalName != account.Legal_Name__c){
            return false;
        }
        if(mdmAccount.auctionAccessNumber != account.Auction_Access_Number__c){
            return false;
        }
        // Ignores any phone masking characters applied by Salesforce       
        String mdmPhone = (mdmAccount.phone == null)?mdmAccount.phone : mdmAccount.phone.replaceAll('[^0-9]', '');
        String accountPhone = (account.phone == null)?account.phone : account.phone.replaceAll('[^0-9]', '');
        if(mdmPhone != accountPhone){
            return false;
        }
        // Ignores any phone masking characters applied by Salesforce
        String mdmFax = (mdmAccount.fax == null)?mdmAccount.fax : mdmAccount.fax.replaceAll('[^0-9]', '');
        String accountFax = (account.fax == null)?account.fax : account.fax.replaceAll('[^0-9]', '');
        if(mdmFax != accountFax){
            return false;
        }
        if(mdmAccount.taxIdNumber != account.Tax_Identification_Number__c){
            return false;
        }
        if(mdmAccount.integrationId != account.Integration_Id__c){
            return false;
        }
        if(mdmAccount.afcDealerId != account.AFC_Dealer_Id__c){
            return false;
        }
        if(mdmAccount.openlaneOrgId != account.Openlane_Org_Id__c){
            return false;
        }        
        for(MDMAccountAddress address : mdmAccount.addressList){
            if(address.isPrimary){
                if(account.billingStreet != address.streetAddress){
                    return false;
                }
                if(account.billingCity != address.city){
                    return false;
                }
                if(account.billingState != address.state){
                    return false;
                }
                if(account.billingPostalCode != address.PostalCode){
                    return false;
                }                       
                if(account.billingCountry != address.Country){
                    return false;
                }       
            }
        }

        return true;
    }

    //SUPPORTING METHODS

    @TestVisible
    private static String createTag(String tagName,String tagValue){
        /* Creates an XML tag, based on the supplied tag name and tag value.
           If the tagValue is null or '', it will return "the empty tag"*/
        if(tagName == null || tagName == ''){
            return '';
        } else if(tagValue == null || tagValue == ''){
            return '<'+tagName+'/>';
        } else {
            return '<'+tagName+'>'+tagValue+'</'+tagName+'>';
        }
    }

    public static List<String> findTags(String sourceString, String tagName, boolean contentOnly){
    /* Finds all tags of a specified name within a supplied string and returns them as a collection of Strings.  
        The results may or may not include the tags themselves, based on the value of the contentOnly paramter.  
        This method will ignore all tag attributes (as if they are not there) */

        List<String> result = new List<String>();
        Integer currentIndex = 0;

        List<Integer> indicies = new List<Integer>();
        while(currentIndex != -1){
            currentIndex = sourceString.indexOf('<'+tagName, currentIndex);
            if(currentIndex != -1){
                String squeezeString = sourceString.substring(currentIndex);
                // If it starts with tagName + a space, it is either dead whitespace or the space before an attribute
                // If the character after tagName is something else (like alphanumeric), this is a different tag that happens
                // to start with the tagName value (e.g. 'Account' and 'AccountId') and is not the tag we're looking for.
                if(squeezeString.startswith('<'+tagName+'>') || squeezeString.startswith('<'+tagName+' ') || squeezeString.startswith('<'+tagName+'/>')){
                    indicies.add(currentIndex);
                }
                currentIndex++;
            }
        }

        List<String> goodOnes = new List<String>();
        for(Integer i : indicies){
            String tempString = sourceString.substring(i);

            if(tempString.deleteWhitespace().startswith('<'+tagName+'/>')){
                if(!contentOnly){
                    goodOnes.add(tempString.substringBefore('/>')+'/>');
                }
            } else {
                if(!contentOnly){
                    goodOnes.add(tempString.substringBefore('</'+tagName+'>')+'</'+tagName+'>');
                } else {
                    if(!(tempString.substringBetween('>','</'+tagName+'>') == '')){
                        goodOnes.add(tempString.substringBetween('>','</'+tagName+'>'));
                    }
                }
            }
        }
        result = goodOnes;
        return result;
    }

    //SUPPORTING CLASSES

    public class MDMAccount{
    /* This class represents the a single account, returned from the results of an MDM service call, 
       including all Addresses.  It includes a constructor that will take a 
       a string (intented to be the contents of a single account) and self-populate */
        public Integer matchScore{get;set;}
        public String integrationId{get;set;} // used by the MDMRealTimeServiceHandler
        public String openlaneOrgId{get;set;} // used by the MDMRealTimeServiceHandler
        public String afcDealerId{get;set;}
        public String dbaName{get;set;}
        public String legalName{get;set;}
        public String phone{get;set;}
        public String fax{get;set;}
        public String accountType{get;set;}
        public String taxIdNumber{get;set;}
        public String auctionAccessNumber{get;set;}
        public List<MDMAccountAddress> addressList{get;set;}

        public MDMAccount(){
            addressList = new List<MDMAccountAddress>();
        }

        public MDMAccount(String accountString){
            this();
            for(String s : findTags(accountString,'Name',true)){
                dbaName = s;
            }
            for(String s : findTags(accountString,'Alias',true)){
                legalName = s;
            }
            for(String s : findTags(accountString,'MatchScore',true)){
                matchScore = Integer.valueOf(s);
            }
            for(String s : findTags(accountString,'IntegrationId',true)){
                integrationId = s;
            }
            for(String s : findTags(accountString,'CSN',true)){
                auctionAccessNumber = s;
            }
            for(String s : findTags(accountString,'MainFaxNumber',true)){
                fax = s;
            }  
            for(String s : findTags(accountString,'MainPhoneNumber',true)){
                phone = s;
            }
            for(String s : findTags(accountString,'TaxIDNumber',true)){
                taxIdNumber = s;
            }                       
            // accountType = findTags(accountString,'MainFaxNumber',true)[0];

            // Only one of these for loops will have any values to iterate, based on whether 
            // this object is populated from the MDM Query service or the MDM Match service
            if(accountString.contains('ListOfBusinessAddress')){
                for(String address : findTags(accountString,'BusinessAddress',false)){
                    addressList.add(new MDMAccountAddress(address.substringAfter('>').substringBefore('</BusinessAddress>'),address.contains('IsPrimary="YES"')));
                }
            } else if(accountString.contains('ListOfAccount_BusinessAddress')){
                for(String address : findTags(accountString,'Account_BusinessAddress',false)){
                    addressList.add(new MDMAccountAddress(address.substringAfter('>').substringBefore('</Account_BusinessAddress>'),address.contains('IsPrimaryMVG="Y"')));
                }
            }
        }
    }

    public class MDMAccountAddress{
    /* This class represents a single Address returned from an MDM service.  It includes a constructor that will take a string 
       (intented to be the contents of a single <BusinessAddressEndDate> tag) and self-populate */
        public boolean isPrimary{get;set;}
        public String streetAddress{get;set;}
        public String city{get;set;}
        public String state{get;set;}
        public String postalCode{get;set;}
        public String country{get;set;}

        public MDMAccountAddress(){
        }

        public MDMAccountAddress(String addressString, boolean isPrimary){
            /* This constructor includes an isPrimary tag, that can be determined from the IsPrimary attribute
               of the <BusinessAddress> tag */
            this();
            this.isPrimary = isPrimary;
            for(String s : findTags(addressString,'StreetAddress',true)){
                streetAddress = s;
            }            
            for(String s : findTags(addressString,'City',true)){
                city = s;
            }            
            for(String s : findTags(addressString,'State',true)){
                state = s;
            }            
            for(String s : findTags(addressString,'PostalCode',true)){
                postalCode = s;
            }            
            for(String s : findTags(addressString,'Country',true)){
                country = s;
            }            
        }
    }

    public class MDMServiceRequest{
        public String requestType{get;set;}
        public String requestString{get;set;}
        public String responseString{get;set;}
        public String responseMessage{get;set;}
        public Account account{get;set;}
        public MDMAccount bestMatch{get;set;}
        public List<MDMAccount> mdmResultList{get;set;}

        public MDMServiceRequest(){
            responseMessage = '';
            bestMatch = null;
            mdmResultList = new List<MDMAccount>();
        }

        public MDMServiceRequest (String requestString){
            this();
            this.requestString = requestString;
        }

        public void makeRequest(){
            requestType = (requestString.contains('OrganizationQueryServiceRequestXML'))?SOAP_ACTION_ORG_QUERY : SOAP_ACTION_ORG_MATCH;
            System.debug('*****req:'+requestString);
            String responseString = MDMServiceHelper.makeMDMServiceRequest(requestString,requestType);
            System.debug('*****resp:'+responseString);
            for(String accountString : findTags(responseString,(requestType == SOAP_ACTION_ORG_MATCH)?'Candidate':'Account',true)){
                // we remove the "ListOfContact" tag because it also contains an "Account" tag,
                // which will create confusion for the parser.  This will have to be updated
                // to incorporate Contacts from MDM into the system.
                String tempString = accountString.substringBefore('<ListOfContact');
                tempString = tempString + accountString.substringAfter('</ListOfContact>');
                mdmResultList.add(new MDMAccount(tempString));
            }
            getBestResult();
        }

        private void getBestResult(){
            Map<Integer,List<MDMAccount>> matchScoreMap = new Map<Integer,List<MDMAccount>>();
            for(MDMAccount mdma : mdmResultList){
                // Set all matchScore nulls to 0
                if(mdma.matchScore == null ){
                    mdma.matchScore = 0;
                }
                if(matchScoreMap.get(mdma.matchScore) == null){
                    matchScoreMap.put(mdma.matchScore,new List<MDMAccount>{mdma});
                } else {
                    List<MDMAccount> tempList = matchScoreMap.get(mdma.matchScore);
                    tempList.add(mdma);
                    matchScoreMap.put(mdma.matchScore,tempList);
                }
            }
            Integer topMatchScore = 0;
            for(Integer ms : matchScoreMap.keySet()){
                if(ms > topMatchScore){
                    topMatchScore = ms;
                }
            }
            // If the highest Match Score meets the minimum threshhold and there is only one result at that score, update the Account
            Integer minimumMatchScore = (MDM_Settings__c.getInstance().Minimum_Match_Score__c == null)?80:Integer.valueOf(MDM_Settings__c.getInstance().Minimum_Match_Score__c);
            if(matchScoreMap.get(topMatchScore) != null && (matchScoreMap.get(topMatchScore).size() == 1 || topMatchScore >= minimumMatchScore)){ // default matchScore value is 80
                bestMatch = matchScoreMap.get(topMatchScore)[0];
            }
        }
    }   
}