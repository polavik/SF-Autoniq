public class SchemaContactUpdateHelper {
	public class ContactUpdateException extends Exception{}

	private static final String DEFAULT_PROPERTIES_NAME='CONTACTUPDATE';

    @TestVisible static final String TRUE_STRING='Y';
    @TestVisible static final String FALSE_STRING='N';
    public static final String SUCCESS_STRING='SUCCESS';

    private static final String BUSINESS_TOKEN='BUSINESS';
    private static final String PHONE_TOKEN='TELEPHONE';
    private static final String CELLULAR_TOKEN='CELLULAR';
    private static final String EMAIL_TOKEN='EMAIL';

    private static final String MAILING_TOKEN='MAILING';
    private static final String CANADA_COUNTRY_TOKEN = 'Canada';
    @TestVisible static final String SIN_TOKEN='SOCIAL INSURANCE NUMBER';
    @TestVisible static final String SSN_TOKEN='SOCIAL SECURITY NUMBER';

    private static BW_Apps_Config__c config
    {
        get
        {
            if(config == null) config = BW_Apps_Config__c.getInstance();
            return config;
        }
        private set;
    }
    public static String endpointURL
    {
        get
        {
            if(config.Contact_Update_Endpoint_URL__c == null)
                throw new CustomExceptions.ApplicationException(System.Label.Endpoint_URL_is_not_configured);
            else
                return config.Contact_Update_Endpoint_URL__c;
        }
    }
    public static Integer timeout
    {
        get
        {
            if(config.Contact_Update_Timeout__c == null)
                throw new CustomExceptions.ApplicationException(System.Label.Timeout_is_not_configured);
            else
                return config.Contact_Update_Timeout__c.intValue();
        }
    }

    public static Id errorEmailUserId
    {
        get
        {
        	if(errorEmailUserId==null){
        		if(config.Username_Receiving_Error_Messages__c != null){
        			List<User> possibleUsers = [SELECT Id from User where UserName=:config.Username_Receiving_Error_Messages__c LIMIT 1];
                    errorEmailUserId = possibleUsers.isEmpty()? errorEmailUserId : possibleUsers[0].Id;
        		}            	
        	}
        	return errorEmailUserId;
        }
        private set;
    }

    public static String propertiesName
    {
        get
        {
            return config == null || config.Contact_Update_Properties_Name__c == null ? DEFAULT_PROPERTIES_NAME : config.Contact_Update_Properties_Name__c;
        }
    }


    public static SchemaContactUpdate.ContactUpdateType setContactParams(Contact ctc){
        SchemaContactUpdate.ContactUpdateType contact = new SchemaContactUpdate.ContactUpdateType();
        contact.CosmosPartyID = ctc.Party_Id__c;
        contact.FirstName = ctc.FirstName;
        contact.MiddleInitial = ctc.Middle_Name__c;
        contact.LastName = ctc.LastName;
        contact.SuffixCode = ctc.Suffix__c;
        contact.BankruptcyIndicator = ctc.Bankruptcy_Indicator__c ? TRUE_STRING : FALSE_STRING; 
        contact.IsCitizen = ctc.Citizen__c ? FALSE_STRING : TRUE_STRING; // Label of this field is actually non citizen
        contact.DateOfBirth = ctc.BirthDate;

        //Address
        contact.Addresses = setAddressParams(ctc);

        //Communications
        contact.Communications = setCommunicationParams(ctc);

        //Identifications
        contact.IdentificationNumbers = setIdentificationParams(ctc);

        return contact;
    }

    private static SchemaContactUpdate.CommunicationsType setCommunicationParams(Contact ctc){
        SchemaContactUpdate.CommunicationsType commType = new SchemaContactUpdate.CommunicationsType();
        commType.Communication = new List<SchemaContactUpdate.Communication>();

        //Main Phone
        if(String.isNotBlank(ctc.Phone)){
            SchemaContactUpdate.Communication phone = new SchemaContactUpdate.Communication();
            phone.CommunicationTypeID = BUSINESS_TOKEN;
            phone.CommunicationMethodTypeID = PHONE_TOKEN;
            phone.Value = ctc.Phone.replaceAll('[^0-9]','');
            phone.IsPrimary = TRUE_STRING;
            commType.Communication.add(phone);
        }
        //Mobile Phone
        if(String.isNotBlank(ctc.MobilePhone)){
            SchemaContactUpdate.Communication mobilePhone = new SchemaContactUpdate.Communication();
            mobilePhone.CommunicationTypeID = BUSINESS_TOKEN;
            mobilePhone.CommunicationMethodTypeID = CELLULAR_TOKEN;
            mobilePhone.Value = ctc.MobilePhone.replaceAll('[^0-9]','');
            mobilePhone.IsPrimary = FALSE_STRING;
            commType.Communication.add(mobilePhone);
        }
        //Email
        if(String.isNotBlank(ctc.Email)){
            SchemaContactUpdate.Communication email = new SchemaContactUpdate.Communication();
            email.CommunicationTypeID = BUSINESS_TOKEN;
            email.CommunicationMethodTypeID = EMAIL_TOKEN;
            email.Value = ctc.Email;
            email.IsPrimary = FALSE_STRING;
            commType.Communication.add(email);
        }

        return commType;
    }

    private static SchemaContactUpdate.Address setAddressParams(Contact ctc){
        //Address
        SchemaContactUpdate.Address address = new SchemaContactUpdate.Address();
        address.Address1 = ctc.AFC_Primary_Street__c;
        address.Address2 = ctc.AFC_Primary_Street2__c;
        address.City = ctc.AFC_Primary_City__c;
        address.StateOrProvince = ctc.AFC_Primary_State__c;
        address.PostalCode = ctc.AFC_Primary_Postalcode__c;
        address.County = ctc.AFC_Primary_County__c;
        address.Country = ctc.AFC_Primary_Country__c;
        address.OwnOrRent = ctc.Type_of_Home_Ownership__c;
        address.YearsAtCurrentLocation = ctc.Years_There__c !=null ? String.valueOf(ctc.Years_There__c) : null;
        address.LocationTypeID= MAILING_TOKEN;
        address.PrimaryAddress= TRUE_STRING;

        return address;

    }

    private static SchemaContactUpdate.IdentificationNumbersType setIdentificationParams(Contact ctc){
        //SSN
        SchemaContactUpdate.IdentificationNumbersType ident= new SchemaContactUpdate.IdentificationNumbersType();
        ident.IdentificationNumber = new List<SchemaContactUpdate.IdentificationNumber>();
        
        if(String.isNotBlank(ctc.SSN__c))
        {
            SchemaContactUpdate.IdentificationNumber ssn        = new SchemaContactUpdate.IdentificationNumber();
            ssn.IdentificationTypeID                          = ctc.AFC_Primary_Country__c == CANADA_COUNTRY_TOKEN ? SIN_TOKEN : SSN_TOKEN;
            ssn.Value                                         = ctc.SSN__c;
            ident.IdentificationNumber.add(ssn);
        }
        
        return ident;
    }
}