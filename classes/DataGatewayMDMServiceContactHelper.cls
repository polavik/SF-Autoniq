public with sharing class DataGatewayMDMServiceContactHelper {
	public static Set<String> ListFLSUpdate ;
    public DataGatewayMDMServiceContactHelper() {
		
    }
    public class MDMServiceContactParsingException extends Exception{}
	
    // SOAP message parts for Contacts
    private static String correlationIdString = String.valueOfGmt(System.now());    
    private static final String personMatchRequestTemplate = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ihub="http://inthub.adesa.com/ihservices/common/IHubManifest" xmlns:cus="http://inthub.adesa.com/ihservices/common/CustomerMaster"> <soapenv:Header> <ihub:IHubManifest> <ihub:IHubConversation CorrelationId="'+correlationIdString+'" MessageId=""/> <ihub:RequestMeta> <ihub:SourceSystem Name="KAR Salesforce" /> <ihub:SourceRequest Name="ContactVerification" Version="1.0"/> <ihub:Division>Salesforce</ihub:Division> <ihub:SubDivision>IHUB</ihub:SubDivision> <ihub:Additionals> <ihub:code>0002</ihub:code> <ihub:description>mdmcustrt_sf_user_t</ihub:description> </ihub:Additionals> </ihub:RequestMeta> </ihub:IHubManifest> </soapenv:Header> <soapenv:Body> <cus:getPersonMatchRequest> <cus:PersonMatchRequestXML><![CDATA[<dat:PersonMatch_Input xmlns:dat="http://siebel.com/DataQuality" xmlns:swi="http://www.siebel.com/xml/SwiPersonMatchInputIO"> <swi:SwiPersonMatchInputIO Threshold="80" MessageId="" Locale="English - United States" Language="ENU" EnterpriseServerName="SBA_82">{ContactListString}</swi:SwiPersonMatchInputIO></dat:PersonMatch_Input>]]></cus:PersonMatchRequestXML> </cus:getPersonMatchRequest> </soapenv:Body> </soapenv:Envelope>';

    // Calls the MDM Service method getPersonMatch
    // It returns a Map of elements, consisting of an Contact Id and a(nother) Map of Field Names and Values.
    // This represents the collection of fields whose values are different than in the supplied Contact
    public static void getPersonMatch(List<Id> contactIdList){
		
        if(System.isFuture() || System.isBatch()){
            getPersonMatchSync(contactIdList);
        } else {
            if(Limits.getFutureCalls() < Limits.getLimitFutureCalls()){
                getPersonMatchAsync(contactIdList);
            } else {
                System.debug('***** Future Call Limits exceeded for getPersonMatch');
            }
        }
    }

    @future(callout=true)
    public static void getPersonMatchAsync(List<Id> contactIdList){
        getPersonMatchSync(contactIdList);
    }

    public static void getPersonMatchSync(List<Id> contactIdList){
        List<Contact> contacts = [select id, FirstName, Middle_Name__c, LastName, Email, Phone, Birthdate, Integration_ID__c,Rep_Auction_Access_Number__c,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry 
                                from Contact where Id in :contactIdList];

        String contactListString = '';
        for(Contact contact :contacts){
            contactListString += getContactString(contact);
        }
        if(contactListString == ''){
            contactListString = '<swi:Contact/>';
        }

        String serviceRequestString = '';
        serviceRequestString = personMatchRequestTemplate.replace('{ContactListString}', contactListString);
        System.debug('*****Request:'+serviceRequestString);
        String responseString = makeMDMServiceRequest(serviceRequestString,'http://inthub.adesa.com/ihservices/common/CustomerMaster/getPersonMatch');
        System.debug('*****Response:'+responseString);

        Map<String,Contact> keyStringContactsMap = new Map<String,Contact>();
        String keyString = '';
        for(Contact c : contacts){
            keyString = '';
            keyString += (c.FirstName == null)?'':c.FirstName;
            keyString += (c.LastName == null)?'':c.LastName;
            keyString += (c.Rep_Auction_Access_Number__c == null)?'':c.Rep_Auction_Access_Number__c;
            keyString += (c.Integration_ID__c == null)?'':c.Integration_ID__c;
            keyString += (c.Email == null)?'':c.Email;
            keyString += (c.MailingStreet == null)?'':c.MailingStreet;
            keyString += (c.MailingPostalCode == null)?'':c.MailingPostalCode;          
            keyStringContactsMap.put(keyString,c);
        }

        List<ContactComparator> resultList = new List<ContactComparator>();
        String keyMatchString = '';
        for(String driver : getDrivers(responseString)){
            if(driver.indexOf('<ListOfCandidate>') == -1){}
            String requestString = driver.substring(0, driver.indexOf((driver.indexOf('<ListOfCandidate>') == -1)?'<ListOfCandidate/>':'<ListOfCandidate>'));
            keyMatchString = '';
            keyMatchString += String.join(processTag(requestString,'FirstName'),'');
            keyMatchString += String.join(processTag(requestString,'LastName'),'');
            keyMatchString += String.join(processTag(requestString,'CompanyIdentifier'),'');
            keyMatchString += String.join(processTag(requestString,'IntegrationId'),'');
            keyMatchString += String.join(processTag(requestString,'EmailAddress'),'');
            keyMatchString += String.join(processTag(requestString,'StreetAddress'),'');
            keyMatchString += String.join(processTag(requestString,'PostalCode'),'');

            Contact matchContact = keyStringContactsMap.get(keyMatchString);
            if(matchContact == null){
          //      throw new MDMServiceContactParsingException('Could not find a result/Contact match: ('+keyString+'/'+keyMatchString+')');
            } else {
                resultList.add(getResponseContacts(matchContact,driver));
            }
        }

        Set<String> contactUpdateFields = new Set<String>();
        for(Data_Gateway_MDM_Auto_Update__c field : Data_Gateway_MDM_Auto_Update__c.getAll().values()){
            if(field.Object_Name__c == 'Contact' && field.MDM_Service_Response__c == true){
                contactUpdateFields.add(field.Field_Name__c);
            }
        }

        List<Contact> finalContacts = new List<Contact>();
		
		ListFLSUpdate = new Set<String>(); 
		Boolean blnFLSOverride = Utils.GetFLS();
		
        for(ContactComparator ac : resultList){
            ac.updateContact(contactUpdateFields);   
            finalContacts.add(ac.salesforceContact);
        }
        update finalContacts;
		
		if(ListFLSUpdate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_UPDATE','CLASS:DataGatewayMDMServiceContactHelper', ListFLSUpdate);
		}
    }

    private static String getContactString(Contact contact){
        String result = '';
        
        if(contact != null){
            result = '<swi:Contact>';

            if(contact.Rep_Auction_Access_Number__c != null && contact.Rep_Auction_Access_Number__c != ''){
                result += '<swi:CompanyIdentifier>'+contact.Rep_Auction_Access_Number__c+'</swi:CompanyIdentifier>';
            }
            if(contact.Integration_ID__c != null && contact.Integration_ID__c != ''){
                result += '<swi:IntegrationId>'+contact.Integration_ID__c+'</swi:IntegrationId>';
            }
            if(contact.FirstName != null && contact.FirstName != ''){
                result += '<swi:FirstName>'+contact.FirstName+'</swi:FirstName>';
            }
            if(contact.Middle_Name__c != null && contact.Middle_Name__c != ''){
                result += '<swi:MiddleName>'+contact.Middle_Name__c+'</swi:MiddleName>';
            }
            if(contact.LastName != null && contact.LastName != ''){
                result += '<swi:LastName>'+contact.LastName+'</swi:LastName>';
            }
            if(contact.Email != null && contact.Email != ''){
                result += '<swi:EmailAddress>'+contact.Email+'</swi:EmailAddress>';
            }
            if(contact.Phone != null && contact.Phone != ''){
                result += '<swi:WorkPhone>'+contact.Phone+'</swi:WorkPhone>';
            }

            String personAddressString = '';
            if(contact.mailingStreet != null && contact.mailingStreet != ''){
                personAddressString += '<swi:StreetAddress>'+contact.mailingStreet+'</swi:StreetAddress>';
            }            
            if(contact.mailingCity != null && contact.mailingCity != ''){
                personAddressString += '<swi:City>'+contact.mailingCity+'</swi:City>';
            } 
            if(contact.mailingState != null && contact.mailingState != ''){
                personAddressString += '<swi:State>'+contact.mailingState+'</swi:State>';
            } 
            if(contact.mailingPostalCode != null && contact.mailingPostalCode != ''){
                personAddressString += '<swi:PostalCode>'+contact.mailingPostalCode+'</swi:PostalCode>';
            }
            if(personAddressString != ''){
                result += '<swi:ListOfPersonalAddress><swi:PersonalAddress>'+personAddressString+'</swi:PersonalAddress></swi:ListOfPersonalAddress>';
            }

            if(result == '<swi:Contact>'){
                result = '<swi:Contact/>';
            } else {
                result += '</swi:Contact>';
            }
        }
        return result;
    }

    // Shared method for making the actual callout
    private static String makeMDMServiceRequest(String requestString, String soapAction){
        if(Test.isRunningTest()){
            if(TestDataGatewayAccount.currentTest == '' || TestDataGatewayAccount.currentTest == null){
                Test.setMock(HttpCalloutMock.class,new TestDataGatewayMDMServiceMock('Person'));                
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
        String xmlString = response.replace(' xmlns="http://www.siebel.com/xml/SwiPersonMatchOutputIO"', '');
        xmlString = xmlString.trim();
        List<ResponseContact> result = new List<ResponseContact>();

        // Because there may have been multiple contacts in the request,
        // break up the response string into sections by requested Contact
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

    public static ContactComparator getResponseContacts(Contact requestContact, String driverString){
        ContactComparator result = new ContactComparator();
        result.salesforceContact = requestContact;

        List<String> responseContactList = processTag(driverString,'Candidate');
        for(String contactString : responseContactList){
            ResponseContact ra = new ResponseContact();
            ra.matchScore = (contactString.indexOf('MatchScore') == -1)?null:Integer.valueOf(processTag(contactString,'MatchScore')[0]);
            ra.firstName = (contactString.indexOf('FirstName') == -1)?null:processTag(contactString,'FirstName')[0];
            ra.middleName = (contactString.indexOf('MiddleName') == -1)?null:processTag(contactString,'MiddleName')[0];
            ra.lastName = (contactString.indexOf('LastName') == -1)?null:processTag(contactString,'LastName')[0];
            ra.integrationId = (contactString.indexOf('IntegrationId') == -1)?null:processTag(contactString,'IntegrationId')[0];
            ra.email = (contactString.indexOf('EmailAddress') == -1)?null:processTag(contactString,'EmailAddress')[0];
            ra.phone = (contactString.indexOf('WorkPhone') == -1)?null:processTag(contactString,'WorkPhone')[0];
            ra.birthdate = (contactString.indexOf('BirthDate') == -1)?null:processTag(contactString,'BirthDate')[0];
            ra.repAuctionAccessNumber = (contactString.indexOf('CompanyIdentifier') == -1)?null:processTag(contactString,'CompanyIdentifier')[0];
            ra.socialSecurityNumber = (contactString.indexOf('SocialSecurityNumber') == -1)?null:processTag(contactString,'SocialSecurityNumber')[0];
            ra.mailStop = (contactString.indexOf('MailStop') == -1)?null:processTag(contactString,'MailStop')[0];
            ra.doNotCall = (contactString.indexOf('SuppressAllCalls') == -1)?null:processTag(contactString,'SuppressAllCalls')[0];

            if(contactString.indexOf('<PersonalAddress IsPrimary="YES">') == -1){
                ra.streetAddress = (contactString.indexOf('StreetAddress') == -1)?null:processTag(contactString,'StreetAddress')[0];
                ra.city = (contactString.indexOf('City') == -1)?null:processTag(contactString,'City')[0];
                ra.state = (contactString.indexOf('State') == -1)?null:processTag(contactString,'State')[0];
                ra.postalCode = (contactString.indexOf('PostalCode') == -1)?null:processTag(contactString,'PostalCode')[0];
                ra.country = (contactString.indexOf('Country') == -1)?null:processTag(contactString,'Country')[0];
            }  else {
                String primaryAddressString = contactString.substringBetween('<PersonalAddress IsPrimary="YES">','</PersonalAddress>');
                ra.streetAddress = (primaryAddressString.indexOf('StreetAddress') == -1)?null:processTag(primaryAddressString,'StreetAddress')[0];
                ra.city = (primaryAddressString.indexOf('City') == -1)?null:processTag(primaryAddressString,'City')[0];
                ra.state = (primaryAddressString.indexOf('State') == -1)?null:processTag(primaryAddressString,'State')[0];
                ra.postalCode = (primaryAddressString.indexOf('PostalCode') == -1)?null:processTag(primaryAddressString,'PostalCode')[0];
                ra.country = (primaryAddressString.indexOf('Country') == -1)?null:processTag(primaryAddressString,'Country')[0];
            }
            result.mdmContactList.add(ra);
        }
        return result;
    }


    public class ContactComparator{
        public Contact salesforceContact{get;set;}
        public List<ResponseContact> mdmContactList{get;set;}
        public ContactComparator(){
            mdmContactList = new List<ResponseContact>();
        }
        public ContactComparator(Contact sfContact, ResponseContact mdmContact){
            this.salesforceContact = sfContact;
            mdmContactList = new List<ResponseContact>();
            mdmContactList.add(mdmContact);
        }
        public void updateContact(Set<String> fieldNames){
			Boolean blnFLSOverride = Utils.GetFLS();
            if(mdmContactList != null && mdmContactList.size() > 0){
                if(fieldNames.contains('FirstName')){                    
					//Story B-44003 : FLS UPDATE ACCESS CHECK
					if (Schema.sObjectType.Contact.fields.FirstName.isUpdateable() || blnFLSOverride)
					{						 
						salesforceContact.FirstName = mdmContactList[0].FirstName;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.FirstName.getName());
					}
                }           
                if(fieldNames.contains('Middle_Name__c')){
					if (Schema.sObjectType.Contact.fields.Middle_Name__c.isUpdateable() || blnFLSOverride)
					{						
						salesforceContact.Middle_Name__c = mdmContactList[0].MiddleName;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.Middle_Name__c.getName());
					}
                }   
                if(fieldNames.contains('LastName')){
					if (Schema.sObjectType.Contact.fields.LastName.isUpdateable() || blnFLSOverride)
					{						 
						salesforceContact.LastName = mdmContactList[0].LastName;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.LastName.getName());
					}
                }
                if(fieldNames.contains('Rep_Auction_Access_Number__c')){
					if (Schema.sObjectType.Contact.fields.Rep_Auction_Access_Number__c.isUpdateable() || blnFLSOverride)
					{						 
						salesforceContact.Rep_Auction_Access_Number__c = mdmContactList[0].repAuctionAccessNumber;						
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.Rep_Auction_Access_Number__c.getName());
					}
                }           
                if(fieldNames.contains('Integration_ID__c')){
					if (Schema.sObjectType.Contact.fields.Integration_ID__c.isUpdateable() || blnFLSOverride)
					{						 
						salesforceContact.Integration_ID__c = mdmContactList[0].integrationId;						
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.Integration_ID__c.getName());
					}
                }                   
                if(fieldNames.contains('Phone')){
					if (Schema.sObjectType.Contact.fields.phone.isUpdateable() || blnFLSOverride)
					{						 
						salesforceContact.phone = mdmContactList[0].phone;						
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.phone.getName());
					}
                }                   
                if(fieldNames.contains('Email')){
					if (Schema.sObjectType.Contact.fields.email.isUpdateable() || blnFLSOverride)
					{						 
						salesforceContact.email = mdmContactList[0].email;						
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.email.getName());
					}
                }                   
                if(fieldNames.contains('Birthdate') && mdmContactList[0].birthdate != null){
                    List<String> dateComponents = mdmContactList[0].birthdate.split('-');
                    if(dateComponents.size() == 3){
						if (Schema.sObjectType.Contact.fields.birthdate.isUpdateable() || blnFLSOverride)
						{						 
							salesforceContact.birthdate = Date.newInstance(Integer.valueOf(dateComponents[0]),Integer.valueOf(dateComponents[1]),Integer.valueOf(dateComponents[2]));							
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.birthdate.getName());
						}
                    }
                }                   
                if(fieldNames.contains('MailingStreet')){
					if (Schema.sObjectType.Contact.fields.MailingStreet.isUpdateable() || blnFLSOverride)
					{						 
						salesforceContact.MailingStreet = mdmContactList[0].streetAddress;						
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.MailingStreet.getName());
					}
                }           
                if(fieldNames.contains('MailingCity')){
					if (Schema.sObjectType.Contact.fields.MailingCity.isUpdateable() || blnFLSOverride)
					{						 
						salesforceContact.MailingCity = mdmContactList[0].city;						
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.MailingCity.getName());
					}
                }           
                if(fieldNames.contains('MailingState')){
                    
					if (Schema.sObjectType.Contact.fields.MailingState.isUpdateable() || blnFLSOverride)
					{						 
						salesforceContact.MailingState = mdmContactList[0].state;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.MailingState.getName());
					}
                }           
                if(fieldNames.contains('MailingPostalCode')){
                    
					if (Schema.sObjectType.Contact.fields.MailingPostalCode.isUpdateable() || blnFLSOverride)
					{						 
						salesforceContact.MailingPostalCode = mdmContactList[0].postalCode;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.MailingPostalCode.getName());
					}
                }           
                if(fieldNames.contains('MailingCountry')){
                    
					if (Schema.sObjectType.Contact.fields.MailingCountry.isUpdateable() || blnFLSOverride)
					{						 
						salesforceContact.MailingCountry = mdmContactList[0].country;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.MailingCountry.getName());
					}
                }       
            }   
        }
    }

    public class ResponseContact{
        public Integer matchScore{get;set;}
        public String firstName{get;set;}
        public String middleName{get;set;}
        public String lastName{get;set;}
        public String integrationId{get;set;}
        public String repAuctionAccessNumber{get;set;}
        public String phone{get;set;}
        public String email{get;set;}
        public String birthDate{get;set;}
        public String socialSecurityNumber{get;set;}
        public String mailStop{get;set;}
        public String doNotCall{get;set;}
        public String streetAddress{get;set;}
        public String city{get;set;}
        public String state{get;set;}
        public String postalCode{get;set;}
        public String country{get;set;}
    }
}