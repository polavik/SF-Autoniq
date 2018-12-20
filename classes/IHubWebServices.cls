global class IHubWebServices
{
    private static final String CANADA_COUNTRY_TOKEN = 'Canada';
    @testVisible static final String ACTIVE_STATUS = 'ACTIVE';
    @testVisible static final String SENDLINEMOD_ERROR_GENERAL = 'Unexpected error in sendLineMod: ';
    @testVisible static final String SENDLINEMOD_OPP_STAGE = 'L- Confirm Customer\'s Needs';
    @testVisible static final String SENDLINEMOD_RECORDTYPE = 'AFC_Increase_Utilization';
    @testVisible static final String SENDLINEMOD_GOLDLINE = 'Line Modification Gold';
    @testVisible static final String SENDLINEMOD_PLATINUMLINE = 'Line Modification Platinum';
    @testVisible static final String SENDLINEMOD_OPP_METHOD = 'Web';
    @testVisible static final String SENDLINEMOD_OPP_SOURCE = 'AFCDealer.com Line Mod';
    @testVisible static final String AFC_AGREE = 'Y';

    webservice static list<ID> sendTerms(AFC_Contract_Terms__c[] contractTerm)
    {
        if(contractTerm != null && !contractTerm.isEmpty())
        {
            Savepoint sp = Database.setSavepoint();
            //Set the Term ID to the concatenation of parent Contract ID + incoming Term ID
            for(AFC_Contract_Terms__c term : contractTerm)
            {
                term.Term_ID__c = term.AFC_Contract_Shell__c + term.Term_ID__c;
            }
            //Wipe out current terms then insert new ones
            try
            {
                delete [select Id from AFC_Contract_Terms__c where AFC_Contract_Shell__c = :contractTerm[0].AFC_Contract_Shell__c];
                insert contractTerm;
            }
            catch(DMLException dmle)
            {
                Database.rollback(sp);
                throw dmle;
            }
            //Collect returned IDs for return to caller
            List<ID> ctIds = new List<ID>();
            for(AFC_Contract_Terms__c ct : contractTerm)
            {
               ctIds.add(ct.Id);
            }

            return ctIds;
        }
        else
        {
            throw new CustomExceptions.WebServiceException(system.Label.SendTermsException);
        }
    }

    webservice static Id sendApplication(Lead application)
    {
        if(application != null)
        {
        	application.AFC_Branch__c = BranchNumberServices.getBranchNameFromBranchNumber(application.Branch_ID__c);
            insert application;
            return application.id;
        }
        else
        {
            //change this message
            throw new CustomExceptions.WebServiceException(System.Label.SendApplicationException);
        }
    }

    webservice static Boolean updateMasterContract(Integer masterContractID,
            Integer originalMasterContractID,
            String salesForceContractID,
            Integer cosmosDealerID,
            Date contractReceivedFromDealerDate,
            String contractStatus)
    {
        Savepoint sp = Database.setSavepoint();
        try{
            //if the contractReceivedFromDealerDate or contractStatus are not provided, throw an excpetion
            if(contractReceivedFromDealerDate == null || String.isEmpty(contractStatus)){
                throw new CustomExceptions.WebServiceException(System.Label.required_web_service_field_is_null);
            }
            //this logic only applies if the contract status is active
            if(contractStatus.equalsIgnoreCase('Active')){
                //query for contract shell that has the master contract Id
                AFC_Contract_Shell__c theContractShell = ContractServices.getContractShell(masterContractID);
                //update shells contract received from date and contract status
                theContractShell = ContractServices.updateContractShellFields(theContractShell, contractReceivedFromDealerDate, contractStatus);

                //if there is already a contract that shares a contract id with the contract shell
                AFC_Contracts__c matchingContract = ContractServices.matchingActiveContracts(theContractShell);
                if(matchingContract != null){
                    //clone the contract to a contract version and update the status to amended.
                    ContractServices.cloneContractToContractVersionAndUpdateContract(matchingContract, theContractShell);
                }else{
                    //create a new contract record and clone the contract shell into it
                    ContractServices.createContractFromContractShell(theContractShell);
                }
            }else{
                throw new CustomExceptions.WebServiceException(System.Label.contractStatus_not_Valid);
            }
        }catch(Exception e){
            Database.rollback(sp);
            throw e;
        }

    	return true;
    }

    webservice static Id sendLineMod( Double amount, String dealerId, String agreeToTerms, String agreeToElectronicConsent )
    {
        Opportunity newOpportunity = new Opportunity();
        try{
            AFC_Contracts__c contract = [SELECT AFC_Dealer_ID__c, AFC_Branch_Number__c, Credit_Limit__c, Account__c, Product_Type__c, 
                                                Account__r.Name, Account__r.AFC_Branch__c, Account__r.Contract_Credit_Summary__c
                                         FROM AFC_Contracts__c 
                                         WHERE AFC_Dealer_ID__c = :dealerId AND Contract_Status__c = :ACTIVE_STATUS
                                         LIMIT 1];
            RecordType oppRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = :SENDLINEMOD_RECORDTYPE LIMIT 1];
            newOpportunity.OwnerId = [SELECT Branch_Manager_1__c FROM AFC_Branch__c WHERE Branchnumber__c = :contract.AFC_Branch_Number__c].Branch_Manager_1__c;
            newOpportunity.RecordTypeId = oppRecType.Id;
            newOpportunity.Opportunity_Product_Type__c = ContractTypeToOpportunityType__c.getValues(contract.Product_Type__c).Opportunity_Product_Type__c;
            newOpportunity.AccountId = contract.Account__c;
            newOpportunity.AFC_Contracts__c = contract.Id;
            newOpportunity.StageName = SENDLINEMOD_OPP_STAGE;
            newOpportunity.Opportunity_Method__c = SENDLINEMOD_OPP_METHOD;
            newOpportunity.Opportunity_Source__c = SENDLINEMOD_OPP_SOURCE;
            newOpportunity.AFC_Web_App__c = true;
            newOpportunity.CloseDate = Date.today().addDays(14);
            newOpportunity.Name = contract.Account__r.Name;
            newOpportunity.AFC_Branch__c = contract.Account__r.AFC_Branch__c;
            newOpportunity.Agree_to_Electronic_Consent__c = agreeToElectronicConsent == AFC_AGREE? true : false;
            newOpportunity.Agree_to_Terms__c = agreeToTerms == AFC_AGREE? true : false;
            newOpportunity.Credit_Limit_Requested__c = amount;
            if((contract.Account__r.Contract_Credit_Summary__c - contract.Credit_Limit__c) + amount >= 500000 ){
                newOpportunity.type = SENDLINEMOD_PLATINUMLINE;
                newOpportunity.Accept_Platinum_Opportunity__c = true;
            } else {
                newOpportunity.type = SENDLINEMOD_GOLDLINE;
            }

            insert newOpportunity;
        }catch(Exception e){
            throw new CustomExceptions.SendLineModException(SENDLINEMOD_ERROR_GENERAL + e.getMessage());
        }
        return newOpportunity.Id;
    }

    public static void cosmosInvoke(AFC_Contract_Shell__c afcContract, Application_Account_Role__c primaryAccount)
    {
        validateRequest(afcContract, primaryAccount);
        CosmosWebServices.DealerAndContractReadResponseType response;
        try
        {
            CosmosWebServices.MSP_UPA_SF_CSMOS_DEALERCONTRACTSOAP_HTTP_Port stub = new CosmosWebServices.MSP_UPA_SF_CSMOS_DEALERCONTRACTSOAP_HTTP_Port();
            stub.endpoint_x     = BWAppsConfigModel.endpointURL;
            stub.timeout_x      = BWAppsConfigModel.timeout;
            stub.inputHttpHeaders_x = new Map<String, String>();
            for(String propName : PropertyServices.propertiesMap.keySet())
            {
	            stub.inputHttpHeaders_x.put(propName, PropertyServices.propertiesMap.get(propName));
            }

            CosmosWebServices.DealerAndContractType dealerAndContract = new CosmosWebServices.DealerAndContractType();
            dealerAndContract.EventType = getEventType(afcContract);
            if(BWAppsConfigModel.enableStackTrace)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'dealerAndContract.EventType = ' + dealerAndContract.EventType));
            }

            mapDealerFields(dealerAndContract, afcContract, primaryAccount);
            mapDealerAddresses(dealerAndContract, afcContract, primaryAccount);
            mapDealerPhone(dealerAndContract, afcContract);
            mapDealerIdNumbers(dealerAndContract, afcContract, primaryAccount);
            mapContractMarketingAttributes(dealerAndContract, afcContract);
            //Contact Information
            dealerAndContract.DealerRelatedParties = new CosmosWebServices.DealerRelatedPartiesType();
            dealerAndContract.DealerRelatedParties.Person = new List<CosmosWebServices.People>();
            for(Application_Contact_Role__c acr : afcContract.Application_Contacts__r)
            {
                validatePeopleRequest(afcContract, acr);
                mapPeopleFields(dealerAndContract, acr);
            }

            mapContractFields(dealerAndContract, afcContract);

            if(BWAppsConfigModel.enableStackTrace)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Endpoint URL = ' + stub.endpoint_x));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Timeout = ' + stub.timeout_x));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Request = ' + dealerAndContract));
            }
            if(Test.isRunningTest())
            {
                response = TestServices.getMockCosmosResponse(afcContract.Application_Contacts__r);
            }
            else
            {
                response = stub.DealerAndContractSubmitRequest(dealerAndContract);
            }
            /*
                Post callout processing
            */
            //Update contact Party ID
            ContactServices.updateContactsPartyIds(afcContract.Application_Contacts__r, response.DealerRelatedPartiesID.PartyID);
            //Set updated Contract fields
            afcContract.Master_Contract_ID__c = Integer.valueOf(response.MasterContractID);
            afcContract.AFC_Dealer_ID__c = response.DealerID;
            afcContract.Contract_Start_Date__c = Datetime.now();
            afcContract.Contract_ID__c = response.OriginalMasterContractID;

            if(BWAppsConfigModel.enableStackTrace)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Response = ' + response));
            }
        }
        catch(DmlException dmle)
        {
            throw dmle;
        }
        catch(Exception e)
        {
            throw new CustomExceptions.WebServiceException(e.getMessage());
        }
    }
    private static void validateRequest(AFC_Contract_Shell__c afcContract, Application_Account_Role__c primaryAccount)
    {
        //Validation rules
        if(afcContract == null || afcContract.Id == null)
        {
            throw new CustomExceptions.ApplicationException(System.Label.CosmosInvokeAccess);
        }
        if(afcContract.Application__r.RecordType.DeveloperName != 'QAPP'){
            if(afcContract != null && (afcContract.Application_Contacts__r == null || afcContract.Application_Contacts__r.isEmpty()))
            {
                throw new CustomExceptions.ApplicationException(System.Label.No_principal_contacts);
            }
            if(afcContract.Contract_Status__c != null && afcContract.Contract_Status__c.equalsIgnoreCase('ACTIVE'))
            {
                throw new CustomExceptions.ApplicationException(System.Label.Active_Contract);
            }
            if(afcContract.Credit_Limit__c == null || !(afcContract.Credit_Limit__c > 0))
            {
                throw new CustomExceptions.ApplicationException(System.Label.Credit_Limit_Null);
            }
            if(String.isBlank(afcContract.Contract_Type__c))
            {
                throw new CustomExceptions.ApplicationException(System.Label.Contract_Type_null);
            }
            if(String.isBlank(afcContract.Product_Type__c))
            {
                throw new CustomExceptions.ApplicationException(System.Label.Product_Type);
            }
        }
        if(afcContract.Application__r.AFC_Branch_Number__c == null)
        {
            throw new CustomExceptions.ApplicationException(System.Label.Branch_Number_null);
        }
        if(String.isBlank(primaryAccount.TIN__c) && String.isBlank(afcContract.Account__r.Tax_Identification_Number__c))
        {
            throw new CustomExceptions.ApplicationException(System.Label.TIN_null);
        }
        if(String.isBlank(primaryAccount.Entity_Type__c))
        {
            throw new CustomExceptions.ApplicationException(System.Label.Dealer_Entity_Type_null);
        }
        if(String.isBlank(afcContract.Account__r.Primary_Street1__c)
                    && String.isBlank(afcContract.Account__r.Primary_City__c)
                    && String.isBlank(afcContract.Account__r.Primary_State__c)
                    && String.isBlank(afcContract.Account__r.Primary_PostalCode__c)
                    && String.isBlank(afcContract.Account__r.Corrected_P_Street__c)
                    && String.isBlank(afcContract.Account__r.Corrected_P_City__c)
                    && String.isBlank(afcContract.Account__r.Corrected_P_State__c)
                    && String.isBlank(afcContract.Account__r.Corrected_P_Postalcode__c))
        {
        	throw new CustomExceptions.ApplicationException(System.Label.Account_Address_fields_null);
        }
        if(String.isBlank(primaryAccount.Lot_Ownership__c))
        {
            throw new CustomExceptions.ApplicationException(System.Label.Lot_Ownership_null);
        }
    }
    private static void validatePeopleRequest(AFC_Contract_Shell__c afcContract, Application_Contact_Role__c acr)
    {
        if(String.isBlank(acr.Contact__r.FirstName))
        {
            throw new CustomExceptions.ApplicationException(System.Label.First_Name_null + ' ' + acr.Contact__r.LastName);
        }
        String contactName = acr.Contact__r.FirstName + ' ' + acr.Contact__r.LastName;
        if(String.isBlank(acr.Contact__r.AFC_Primary_Street__c)
                || String.isBlank(acr.Contact__r.AFC_Primary_City__c)
                || String.isBlank(acr.Contact__r.AFC_Primary_State__c)
                || String.isBlank(acr.Contact__r.AFC_Primary_PostalCode__c))
        {
            throw new CustomExceptions.ApplicationException(System.Label.Contact_Address_fields_null + ' ' + contactName);
        }
        if(String.isBlank(acr.Contact__r.Phone))
        {
            throw new CustomExceptions.ApplicationException(System.Label.Contact_Phone_null + ' ' + contactName);
        }
        if(afcContract.Application__r.RecordType.DeveloperName != 'QAPP'){
            if(acr.Contact__r.Birthdate == null)
            {
                throw new CustomExceptions.ApplicationException(System.Label.Birthdate_null + ' ' + contactName);
            }
            if(String.isBlank(acr.Contact__r.Type_of_Home_Ownership__c))
            {
                throw new CustomExceptions.ApplicationException(System.Label.Ownership_null + ' ' + contactName);
            }
            if(String.isBlank(acr.Contact__r.Driver_s_License__c))
            {
                throw new CustomExceptions.ApplicationException(System.Label.Driver_s_License_null + ' ' + contactName);
            }
        }
    }
    private static String getEventType(AFC_Contract_Shell__c afcContract)
    {
        Set<String> validLineModApplicationRecordTypes = new Set<String>();
        validLineModApplicationRecordTypes.add('Line Mod');
        validLineModApplicationRecordTypes.add('C Line Mod');
        if(afcContract.Application__r.RecordType.Name == 'New Application' && String.isBlank(afcContract.AFC_Dealer_ID__c))
        {
            return 'NEW APP';
        }
        else if(afcContract.Application__r.RecordType.Name == 'New Application' && String.isNotBlank(afcContract.AFC_Dealer_ID__c))
        {
            return 'MODIFIED APP';
        }
        else if(afcContract.Application__r.RecordType.Name == 'QAPP')
        {
            return 'QAPP';
        }
        else if(validLineModApplicationRecordTypes.contains(afcContract.Application__r.RecordType.Name) && afcContract.Last_Synced_Date__c == null)
        {
            return 'LINE MOD';
        }
        else if(validLineModApplicationRecordTypes.contains(afcContract.Application__r.RecordType.Name) && afcContract.Last_Synced_Date__c != null)
        {
            return 'MODIFIED APP';
        }
        else
        {
        	throw new CustomExceptions.ApplicationException(System.Label.Invalid_App_Record_Type);
        }
    }
    private static void mapDealerFields(CosmosWebServices.DealerAndContractType dealerAndContract, AFC_Contract_Shell__c afcContract, Application_Account_Role__c primaryAccount)
    {
        /*
        Dealership General Information
        */
        dealerAndContract.DealershipProfile = new CosmosWebServices.Dealership();
        dealerAndContract.DealershipProfile.CosmosDealerID              = afcContract.AFC_Dealer_ID__c;
        dealerAndContract.DealershipProfile.SalesforceAccountID         = afcContract.Account__c;
        dealerAndContract.DealershipProfile.CompanyName                 = primaryAccount.Company_Name__c;
        dealerAndContract.DealershipProfile.DBAName                     = primaryAccount.DBA_Name__c;
        dealerAndContract.DealershipProfile.DealerLegalEntityType       = primaryAccount.Entity_Type__c;
        dealerAndContract.DealershipProfile.HomeBranchID                = String.valueOf(afcContract.Application__r.AFC_Branch_Number__c);
        dealerAndContract.DealershipProfile.Website                     = afcContract.Account__r.Website;
        dealerAndContract.DealershipProfile.YearsInBusiness             = String.valueOf(primaryAccount.Years_in_Business__c);
        dealerAndContract.DealershipProfile.SalesforceMasterIndex       = afcContract.Account__r.Master_Index__c;
    }
    private static void mapDealerAddresses(CosmosWebServices.DealerAndContractType dealerAndContract, AFC_Contract_Shell__c afcContract, Application_Account_Role__c primaryAccount)
    {
        /*
        Dealership Addresses
        */
        dealerAndContract.DealershipProfile.Addresses               = new CosmosWebServices.AddressesType();
        dealerAndContract.DealershipProfile.Addresses.Address       = new List<CosmosWebServices.Address>();

        CosmosWebServices.Address stdAccAddress = new CosmosWebServices.Address();
        stdAccAddress.LocationTypeID  = 'BUSINESS';
        stdAccAddress.PrimaryAddress  = 'Y';
        stdAccAddress.OwnOrRent       = primaryAccount.Lot_Ownership__c;
        stdAccAddress.Address1        = String.isBlank(afcContract.Account__r.Corrected_P_Street__c) ? afcContract.Account__r.Primary_Street1__c : afcContract.Account__r.Corrected_P_Street__c;
        stdAccAddress.Address2        = afcContract.Account__r.Primary_Street2__c;
        stdAccAddress.City            = String.isBlank(afcContract.Account__r.Corrected_P_City__c) ? afcContract.Account__r.Primary_City__c : afcContract.Account__r.Corrected_P_City__c;
        stdAccAddress.StateOrProvince = String.isBlank(afcContract.Account__r.Corrected_P_State__c) ? afcContract.Account__r.Primary_State__c : afcContract.Account__r.Corrected_P_State__c;
        stdAccAddress.PostalCode      = String.isBlank(afcContract.Account__r.Corrected_P_Postalcode__c) ? afcContract.Account__r.Primary_PostalCode__c : afcContract.Account__r.Corrected_P_Postalcode__c;
        stdAccAddress.County          = afcContract.Account__r.Primary_County__c;
        stdAccAddress.Country         = String.isBlank(afcContract.Account__r.Primary_Country__c) ? 'USA' : afcContract.Account__r.Primary_Country__c;
        //Validation rule
        if(String.isBlank(stdAccAddress.Address1)
        		|| String.isBlank(stdAccAddress.City)
        		|| String.isBlank(stdAccAddress.StateOrProvince)
        		|| String.isBlank(stdAccAddress.PostalCode))
		{
			throw new CustomExceptions.ApplicationException(System.Label.Account_Address_fields_null);
		}

        dealerAndContract.DealershipProfile.Addresses.Address.add(stdAccAddress);
    }
    private static void mapDealerPhone(CosmosWebServices.DealerAndContractType dealerAndContract, AFC_Contract_Shell__c afcContract)
    {
        /*
        Dealership Communication
        */
        dealerAndContract.DealershipProfile.Communications = new CosmosWebServices.CommunicationsType();
        dealerAndContract.DealershipProfile.Communications.Communication = new List<CosmosWebServices.Communication>();

		String phone = String.isBlank(afcContract.Account__r.Corrected_Landline_Phone__c) ? afcContract.Account__r.Phone : afcContract.Account__r.Corrected_Landline_Phone__c;
        if(String.isNotBlank(phone))
        {
            CosmosWebServices.Communication compPhone = new CosmosWebServices.Communication();
            compPhone.CommunicationTypeID = 'BUSINESS';
            compPhone.CommunicationMethodTypeID = 'TELEPHONE';
            compPhone.Value = phone.replaceAll('[^0-9]','');
            //compPhone.Extension =
            compPhone.IsPrimary = 'Y';
            //compPhone.EndDate =
            dealerAndContract.DealershipProfile.Communications.Communication.add(compPhone);
        }
    }
    private static void mapDealerIdNumbers(CosmosWebServices.DealerAndContractType dealerAndContract, AFC_Contract_Shell__c afcContract, Application_Account_Role__c primaryAccount)
    {
        /*
        Dealership Identification Numbers
        */
        dealerAndContract.DealershipProfile.IdentificationNumbers = new CosmosWebServices.IdentificationNumbersType();
        dealerAndContract.DealershipProfile.IdentificationNumbers.IdentificationNumber = new List<CosmosWebServices.IdentificationNumber>();

        if(String.isNotBlank(primaryAccount.Sales_Tax_Number__c))
        {
            CosmosWebServices.IdentificationNumber salesTaxNum = new CosmosWebServices.IdentificationNumber();
            salesTaxNum.IdentificationTypeID = 'SALES TAX ID';
            salesTaxNum.Value = primaryAccount.Sales_Tax_Number__c;
            dealerAndContract.DealershipProfile.IdentificationNumbers.IdentificationNumber.add(salesTaxNum);
        }
        if(String.isNotBlank(primaryAccount.Dealer_License_Number__c))
        {
            CosmosWebServices.IdentificationNumber dealerLicenseNum = new CosmosWebServices.IdentificationNumber();
            dealerLicenseNum.IdentificationTypeID = 'DEALER LICENSE NUMBER';
            dealerLicenseNum.Value = primaryAccount.Dealer_License_Number__c;
            dealerAndContract.DealershipProfile.IdentificationNumbers.IdentificationNumber.add(dealerLicenseNum);
        }
        if(String.isNotBlank(primaryAccount.TIN__c) || String.isNotBlank(afcContract.Account__r.Tax_Identification_Number__c))
        {
            CosmosWebServices.IdentificationNumber taxID = new CosmosWebServices.IdentificationNumber();
            taxID.Value = String.isNotBlank(primaryAccount.TIN__c) ? primaryAccount.TIN__c : afcContract.Account__r.Tax_Identification_Number__c;
            if(String.isNotBlank(afcContract.Account__r.Primary_Country__c) && afcContract.Account__r.Primary_Country__c == 'USA')
            {
                taxID.IdentificationTypeID = 'FEDERAL TAX ID (U.S)';
            }else if(String.isNotBlank(afcContract.Account__r.Primary_Country__c) && afcContract.Account__r.Primary_Country__c == CANADA_COUNTRY_TOKEN)
            {
                taxID.IdentificationTypeID = 'GST NUMBER (CANADA)';
            }
            dealerAndContract.DealershipProfile.IdentificationNumbers.IdentificationNumber.add(taxID);
        }
    }
    private static void mapPeopleFields(CosmosWebServices.DealerAndContractType dealerAndContract, Application_Contact_Role__c acr)
    {
        CosmosWebServices.People stdCon = new CosmosWebServices.People();
        /*
        Contact General Information
        */
        stdCon.SalesforceContactID      = acr.Contact__c;
        stdCon.CosmosPartyID            = acr.Contact__r.Party_Id__c;
        stdCon.FirstName                = acr.Contact__r.FirstName;
        stdCon.MiddleInitial            = acr.Contact__r.Middle_Name__c;
        stdCon.LastName                 = acr.Contact__r.LastName;
        stdCon.SuffixCode               = acr.Contact__r.Suffix__c;
        stdCon.Title                    = acr.Contact__r.Salutation;
        stdCon.RelationShipTypeID       = acr.Relationship__c;
        stdCon.RelationShipSubTypeID    = acr.Relationship_Subtype__c;
        stdCon.IsCitizen                = acr.Contact__r.Citizen__c ? 'N' : 'Y';
        stdCon.DateOfBirth              = acr.Contact__r.Birthdate;
        stdCon.EndDate                  = acr.End_Date__c;

        mapPeopleCommunications(stdCon, acr);
        mapPeopleAddresses(stdCon, acr);
        mapPeopleIdNumbers(stdCon, acr);

        dealerAndContract.DealerRelatedParties.Person.add(stdCon);
    }
    private static void mapPeopleCommunications(CosmosWebServices.People stdCon, Application_Contact_Role__c acr)
    {
        /*
        Contact Communications
        */
        stdCon.Communications = new CosmosWebServices.CommunicationsType();
        stdCon.Communications.Communication = new List<CosmosWebServices.Communication>();
        //Main Phone
        if(String.isNotBlank(acr.Contact__r.Phone))
        {
            CosmosWebServices.Communication phone = new CosmosWebServices.Communication();
            phone.CommunicationTypeID = 'BUSINESS';
            phone.CommunicationMethodTypeID = 'TELEPHONE';
            phone.Value = acr.Contact__r.Phone.replaceAll('[^0-9]','');
            phone.IsPrimary = 'Y';
            stdCon.Communications.Communication.add(phone);
        }
        //Home Phone
        if(String.isNotBlank(acr.Contact__r.HomePhone))
        {
            CosmosWebServices.Communication homePhone = new CosmosWebServices.Communication();
            homePhone.CommunicationTypeID = 'RESIDENTIAL';
            homePhone.CommunicationMethodTypeID = 'TELEPHONE';
            homePhone.Value = acr.Contact__r.HomePhone.replaceAll('[^0-9]','');
            homePhone.IsPrimary = 'N';
            stdCon.Communications.Communication.add(homePhone);
        }
        //Mobile Phone
        if(String.isNotBlank(acr.Contact__r.MobilePhone))
        {
            CosmosWebServices.Communication mobilePhone = new CosmosWebServices.Communication();
            mobilePhone.CommunicationTypeID = 'BUSINESS';
            mobilePhone.CommunicationMethodTypeID = 'CELLULAR';
            mobilePhone.Value = acr.Contact__r.MobilePhone.replaceAll('[^0-9]','');
            mobilePhone.IsPrimary = 'N';
            stdCon.Communications.Communication.add(mobilePhone);
        }
        //Email
        if(String.isNotBlank(acr.Contact__r.Email))
        {
            CosmosWebServices.Communication email = new CosmosWebServices.Communication();
            email.CommunicationTypeID = 'BUSINESS';
            email.CommunicationMethodTypeID = 'EMAIL';
            email.Value = acr.Contact__r.Email;
            email.IsPrimary = 'N';
            stdCon.Communications.Communication.add(email);
        }
    }
    private static void mapPeopleAddresses(CosmosWebServices.People stdCon, Application_Contact_Role__c acr)
    {
        /*
        Contact Addressses
        */
        stdCon.Addresses                            = new CosmosWebServices.AddressesType();
        stdCon.Addresses.Address                    = new List<CosmosWebServices.Address>();

        CosmosWebServices.Address stdConAddress     = new CosmosWebServices.Address();
        stdConAddress.Address1                      = acr.Contact__r.AFC_Primary_Street__c;
        stdConAddress.Address2                      = acr.Contact__r.AFC_Primary_Street2__c;
        stdConAddress.City                          = acr.Contact__r.AFC_Primary_City__c;
        stdConAddress.StateOrProvince               = acr.Contact__r.AFC_Primary_State__c;
        stdConAddress.PostalCode                    = acr.Contact__r.AFC_Primary_Postalcode__c;
        stdConAddress.County                        = acr.Contact__r.AFC_Primary_County__c;
        stdConAddress.Country                       = acr.Contact__r.AFC_Primary_Country__c;
        stdConAddress.LocationTypeID                = 'MAILING';
        stdConAddress.PrimaryAddress                = 'Y';
        stdConAddress.OwnOrRent                     = acr.Contact__r.Type_of_Home_Ownership__c;
        stdCon.Addresses.Address.add(stdConAddress);
    }
    private static void mapPeopleIdNumbers(CosmosWebServices.People stdCon, Application_Contact_Role__c acr)
    {
        /*
        Contact Identification Numbers
        */
        stdCon.IdentificationNumbers                      = new CosmosWebServices.IdentificationNumbersType();
        stdCon.IdentificationNumbers.IdentificationNumber = new List<CosmosWebServices.IdentificationNumber>();
        if(String.isNotBlank(acr.Contact__r.SSN__c))
        {
            CosmosWebServices.IdentificationNumber ssn        = new CosmosWebServices.IdentificationNumber();
            ssn.IdentificationTypeID                          = acr.Contact__r.AFC_Primary_Country__c == CANADA_COUNTRY_TOKEN ? 'SOCIAL INSURANCE NUMBER' : 'SOCIAL SECURITY NUMBER';
            ssn.Value                                         = acr.Contact__r.SSN__c;
            stdCon.IdentificationNumbers.IdentificationNumber.add(ssn);
        }
        if(String.isNotBlank(acr.Contact__r.Driver_s_License__c))
        {
            CosmosWebServices.IdentificationNumber driversLicense = new CosmosWebServices.IdentificationNumber();
            driversLicense.IdentificationTypeID                   = 'DRIVERS LICENCE';
            driversLicense.Value                                  = acr.Contact__r.Driver_s_License__c;
            stdCon.IdentificationNumbers.IdentificationNumber.add(driversLicense);
        }
    }
    private static void mapContractFields(CosmosWebServices.DealerAndContractType dealerAndContract, AFC_Contract_Shell__c afcContract)
    {
        /*
        Contract Information
        */
        dealerAndContract.Contract = new CosmosWebServices.ContractType();
        dealerAndContract.Contract.SalesforceContractID     = afcContract.Id;
        dealerAndContract.Contract.IsContractRevision       = dealerAndContract.EventType == 'LINE MOD' ? 'Y' : 'N';
        dealerAndContract.Contract.MasterContractID         = String.valueOf(afcContract.Master_Contract_ID__c);
        dealerAndContract.Contract.ProductTypeID            = afcContract.Product_Type__c;
        dealerAndContract.Contract.ContractTypeID           = afcContract.Contract_Type__c;
        dealerAndContract.Contract.LicenseTypeID            = afcContract.License_Type__c;
        dealerAndContract.Contract.AffiliationTypeID        = afcContract.Affiliation_Type__c;
        dealerAndContract.Contract.ApprovedCreditLimit      = String.ValueOf(afcContract.Credit_Limit__c);
        dealerAndContract.Contract.ContractRcvFromDlrDate   = afcContract.Received_from_Dealer__c;
        if(afcContract.Contract_Received_At_Contracts_Date__c != null)
        {
            dealerAndContract.Contract.ContractRcvByContractDate = date.newInstance(afcContract.Contract_Received_At_Contracts_Date__c.year(),
                    afcContract.Contract_Received_At_Contracts_Date__c.month(),
                    afcContract.Contract_Received_At_Contracts_Date__c.day());
        }
        dealerAndContract.Contract.SalvageMasterContractEndDate     = afcContract.Salvage_Master_Contract_End_Date__c;
    }
    @TestVisible private static void mapContractMarketingAttributes( CosmosWebServices.DealerAndContractType dealerAndContract, AFC_Contract_Shell__c afcContract )
    {
        dealerAndContract.MarketingAttributes = new CosmosWebServices.MarketingAttributesType();
        dealerAndContract.MarketingAttributes.MarketingAttribute = new List<CosmosWebServices.MarketingAttributeType>();

        List<Marketing_Attribute__c> relatedAttributes = [ SELECT Id, High__c, Medium__c, Low__c, Primary__c FROM Marketing_Attribute__c WHERE Application__c = :afcContract.Application__c ];
        for( Marketing_Attribute__c anAttribute : relatedAttributes )
        {
            CosmosWebServices.MarketingAttributeType newAttribute = new CosmosWebServices.MarketingAttributeType();
            newAttribute.High = anAttribute.High__c;
            newAttribute.Medium = anAttribute.Medium__c;
            newAttribute.Low = anAttribute.Low__c;
            newAttribute.Primary = anAttribute.Primary__c ? 'Y' : 'N';

            dealerAndContract.MarketingAttributes.MarketingAttribute.add( newAttribute );
        }
    }
}