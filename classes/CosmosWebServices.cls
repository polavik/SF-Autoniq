//Generated by wsdl2apex

public class CosmosWebServices {
    public class ServiceResponse {
        public String ResponseStatus;
        public CosmosWebServices.ServiceError Error;
        private String[] ResponseStatus_type_info = new String[]{'ResponseStatus','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] Error_type_info = new String[]{'Error','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.adesa.com/cosmos','true','false'};
        private String[] field_order_type_info = new String[]{'ResponseStatus','Error'};
    }
    public class Branch {
        public String BranchId;
        public String Name;
        public String Phone;
        public String Fax;
        public String EmailAddress;
        public Double Longitude;
        public Double Latitude;
        public String RegionId;
        public String RegionName;
        public String DivisionId;
        public String DivisionName;
        private String[] BranchId_type_info = new String[]{'BranchId','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] Name_type_info = new String[]{'Name','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] Phone_type_info = new String[]{'Phone','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] Fax_type_info = new String[]{'Fax','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] EmailAddress_type_info = new String[]{'EmailAddress','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] Longitude_type_info = new String[]{'Longitude','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] Latitude_type_info = new String[]{'Latitude','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] RegionId_type_info = new String[]{'RegionId','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] RegionName_type_info = new String[]{'RegionName','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] DivisionId_type_info = new String[]{'DivisionId','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] DivisionName_type_info = new String[]{'DivisionName','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.adesa.com/cosmos','true','false'};
        private String[] field_order_type_info = new String[]{'BranchId','Name','Phone','Fax','EmailAddress','Longitude','Latitude','RegionId','RegionName','DivisionId','DivisionName'};
    }
    public class ContractType {
        public String SalesforceContractID;
        public String IsContractRevision;
        public String MasterContractID;
        public String ProductTypeID;
        public String ContractTypeID;
        public String LicenseTypeID;
        public String AffiliationTypeID;
        public String ApprovedCreditLimit;
        public Date ContractRcvFromDlrDate;
        public Date ContractRcvByContractDate;
        public Date SalvageMasterContractEndDate;
        private String[] SalesforceContractID_type_info = new String[]{'SalesforceContractID','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] IsContractRevision_type_info = new String[]{'IsContractRevision','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] MasterContractID_type_info = new String[]{'MasterContractID','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] ProductTypeID_type_info = new String[]{'ProductTypeID','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] ContractTypeID_type_info = new String[]{'ContractTypeID','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] LicenseTypeID_type_info = new String[]{'LicenseTypeID','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] AffiliationTypeID_type_info = new String[]{'AffiliationTypeID','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] ApprovedCreditLimit_type_info = new String[]{'ApprovedCreditLimit','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] ContractRcvFromDlrDate_type_info = new String[]{'ContractRcvFromDlrDate','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] ContractRcvByContractDate_type_info = new String[]{'ContractRcvByContractDate','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] SalvageMasterContractEndDate_type_info = new String[]{'SalvageMasterContractEndDate','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.adesa.com/cosmos','true','false'};
        private String[] field_order_type_info = new String[]{'SalesforceContractID','IsContractRevision','MasterContractID','ProductTypeID','ContractTypeID','LicenseTypeID','AffiliationTypeID','ApprovedCreditLimit','ContractRcvFromDlrDate','ContractRcvByContractDate','SalvageMasterContractEndDate'};
    }
    public class DealerRelatedPartiesType {
        public CosmosWebServices.People[] Person;
        private String[] Person_type_info = new String[]{'Person','http://schemas.adesa.com/cosmos',null,'1','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.adesa.com/cosmos','true','false'};
        private String[] field_order_type_info = new String[]{'Person'};
    }
    public class Contact {
        public String FirstName;
        public String LastName;
        public String Email;
        public String Phone;
        private String[] FirstName_type_info = new String[]{'FirstName','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] LastName_type_info = new String[]{'LastName','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] Email_type_info = new String[]{'Email','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] Phone_type_info = new String[]{'Phone','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.adesa.com/cosmos','true','false'};
        private String[] field_order_type_info = new String[]{'FirstName','LastName','Email','Phone'};
    }
    public class Communication {
        public String CommunicationTypeID;
        public String CommunicationMethodTypeID;
        public String Value;
        public String Extension;
        public String IsPrimary;
        private String[] CommunicationTypeID_type_info = new String[]{'CommunicationTypeID','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] CommunicationMethodTypeID_type_info = new String[]{'CommunicationMethodTypeID','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] Value_type_info = new String[]{'Value','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] Extension_type_info = new String[]{'Extension','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] IsPrimary_type_info = new String[]{'IsPrimary','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.adesa.com/cosmos','true','false'};
        private String[] field_order_type_info = new String[]{'CommunicationTypeID','CommunicationMethodTypeID','Value','Extension','IsPrimary'};
    }
    public class CommunicationsType {
        public CosmosWebServices.Communication[] Communication;
        private String[] Communication_type_info = new String[]{'Communication','http://schemas.adesa.com/cosmos',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.adesa.com/cosmos','true','false'};
        private String[] field_order_type_info = new String[]{'Communication'};
    }
    public class IdentificationNumbersType {
        public CosmosWebServices.IdentificationNumber[] IdentificationNumber;
        private String[] IdentificationNumber_type_info = new String[]{'IdentificationNumber','http://schemas.adesa.com/cosmos',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.adesa.com/cosmos','true','false'};
        private String[] field_order_type_info = new String[]{'IdentificationNumber'};
    }
    public class ServiceError {
        public String ErrorCode;
        public String ErrorMessage;
        private String[] ErrorCode_type_info = new String[]{'ErrorCode','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] ErrorMessage_type_info = new String[]{'ErrorMessage','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.adesa.com/cosmos','true','false'};
        private String[] field_order_type_info = new String[]{'ErrorCode','ErrorMessage'};
    }
    public class DealerRelatedPartiesIDType {
        public CosmosWebServices.PartyIDType[] PartyID;
        private String[] PartyID_type_info = new String[]{'PartyID','http://schemas.adesa.com/cosmos',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.adesa.com/cosmos','true','false'};
        private String[] field_order_type_info = new String[]{'PartyID'};
    }
    public class MarketingAttributesType {
        public CosmosWebServices.MarketingAttributeType[] MarketingAttribute;
        private String[] MarketingAttribute_type_info = new String[]{'MarketingAttribute','http://schemas.adesa.com/cosmos',null,'1','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.adesa.com/cosmos','true','false'};
        private String[] field_order_type_info = new String[]{'MarketingAttribute'};
    }
    public class Geocode {
        public Double Latitude;
        public Double Longitude;
        private String[] Latitude_type_info = new String[]{'Latitude','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] Longitude_type_info = new String[]{'Longitude','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.adesa.com/cosmos','true','false'};
        private String[] field_order_type_info = new String[]{'Latitude','Longitude'};
    }
    public class DealerAndContractType {
        public String EventType;
        public CosmosWebServices.Dealership DealershipProfile;
        public CosmosWebServices.DealerRelatedPartiesType DealerRelatedParties;
        public CosmosWebServices.ContractType Contract;
        public CosmosWebServices.MarketingAttributesType MarketingAttributes;
        private String[] EventType_type_info = new String[]{'EventType','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] DealershipProfile_type_info = new String[]{'DealershipProfile','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] DealerRelatedParties_type_info = new String[]{'DealerRelatedParties','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] Contract_type_info = new String[]{'Contract','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] MarketingAttributes_type_info = new String[]{'MarketingAttributes','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.adesa.com/cosmos','true','false'};
        private String[] field_order_type_info = new String[]{'EventType','DealershipProfile','DealerRelatedParties','Contract','MarketingAttributes'};
    }
    public class AddressesType {
        public CosmosWebServices.Address[] Address;
        private String[] Address_type_info = new String[]{'Address','http://schemas.adesa.com/cosmos',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.adesa.com/cosmos','true','false'};
        private String[] field_order_type_info = new String[]{'Address'};
    }
    public class DealerAndContractReadResponseType {
        public String ResponseStatus;
        public String SalesforceAccountID;
        public String DealerID;
        public CosmosWebServices.DealerRelatedPartiesIDType DealerRelatedPartiesID;
        public String SalesforceContractID;
        public String MasterContractID;
        public String OriginalMasterContractID;
        private String[] ResponseStatus_type_info = new String[]{'ResponseStatus','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] SalesforceAccountID_type_info = new String[]{'SalesforceAccountID','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] DealerID_type_info = new String[]{'DealerID','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] DealerRelatedPartiesID_type_info = new String[]{'DealerRelatedPartiesID','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] SalesforceContractID_type_info = new String[]{'SalesforceContractID','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] MasterContractID_type_info = new String[]{'MasterContractID','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] OriginalMasterContractID_type_info = new String[]{'OriginalMasterContractID','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.adesa.com/cosmos','true','false'};
        private String[] field_order_type_info = new String[]{'ResponseStatus','SalesforceAccountID','DealerID','DealerRelatedPartiesID','SalesforceContractID','MasterContractID','OriginalMasterContractID'};
    }
    public class Address {
        public String Address1;
        public String Address2;
        public String City;
        public String StateOrProvince;
        public String County;
        public String PostalCode;
        public String Country;
        public String StreetNumber;
        public String Address3;
        public String LocationTypeID;
        public String PrimaryAddress;
        public String OwnOrRent;
        public String YearsAtCurrentLocation;
        private String[] Address1_type_info = new String[]{'Address1','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] Address2_type_info = new String[]{'Address2','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] City_type_info = new String[]{'City','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] StateOrProvince_type_info = new String[]{'StateOrProvince','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] County_type_info = new String[]{'County','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] PostalCode_type_info = new String[]{'PostalCode','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] Country_type_info = new String[]{'Country','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] StreetNumber_type_info = new String[]{'StreetNumber','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] Address3_type_info = new String[]{'Address3','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] LocationTypeID_type_info = new String[]{'LocationTypeID','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] PrimaryAddress_type_info = new String[]{'PrimaryAddress','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] OwnOrRent_type_info = new String[]{'OwnOrRent','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] YearsAtCurrentLocation_type_info = new String[]{'YearsAtCurrentLocation','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.adesa.com/cosmos','true','false'};
        private String[] field_order_type_info = new String[]{'Address1','Address2','City','StateOrProvince','County','PostalCode','Country','StreetNumber','Address3','LocationTypeID','PrimaryAddress','OwnOrRent','YearsAtCurrentLocation'};
    }
    public class PartyIDType {
        public String SalesforceContactID;
        public String CosmosPartyID;
        private String[] SalesforceContactID_type_info = new String[]{'SalesforceContactID','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] CosmosPartyID_type_info = new String[]{'CosmosPartyID','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.adesa.com/cosmos','true','false'};
        private String[] field_order_type_info = new String[]{'SalesforceContactID','CosmosPartyID'};
    }
    public class Dealership {
        public String CosmosDealerID;
        public String SalesforceAccountID;
        public String SalesforceMasterIndex;
        public String CompanyName;
        public String DBAName;
        public String DealerLegalEntityType;
        public String HomeBranchID;
        public String YearsInBusiness;
        public String Website;
        public String AdditionalLocations;
        public String DistanceFromBranch;
        public String HearAbout;
        public CosmosWebServices.AddressesType Addresses;
        public CosmosWebServices.CommunicationsType Communications;
        public CosmosWebServices.IdentificationNumbersType IdentificationNumbers;
        private String[] CosmosDealerID_type_info = new String[]{'CosmosDealerID','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] SalesforceAccountID_type_info = new String[]{'SalesforceAccountID','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] SalesforceMasterIndex_type_info = new String[]{'SalesforceMasterIndex','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] CompanyName_type_info = new String[]{'CompanyName','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] DBAName_type_info = new String[]{'DBAName','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] DealerLegalEntityType_type_info = new String[]{'DealerLegalEntityType','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] HomeBranchID_type_info = new String[]{'HomeBranchID','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] YearsInBusiness_type_info = new String[]{'YearsInBusiness','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] Website_type_info = new String[]{'Website','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] AdditionalLocations_type_info = new String[]{'AdditionalLocations','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] DistanceFromBranch_type_info = new String[]{'DistanceFromBranch','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] HearAbout_type_info = new String[]{'HearAbout','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] Addresses_type_info = new String[]{'Addresses','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] Communications_type_info = new String[]{'Communications','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] IdentificationNumbers_type_info = new String[]{'IdentificationNumbers','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.adesa.com/cosmos','true','false'};
        private String[] field_order_type_info = new String[]{'CosmosDealerID','SalesforceAccountID','SalesforceMasterIndex','CompanyName','DBAName','DealerLegalEntityType','HomeBranchID','YearsInBusiness','Website','AdditionalLocations','DistanceFromBranch','HearAbout','Addresses','Communications','IdentificationNumbers'};
    }
    public class IdentificationNumber {
        public String IdentificationTypeID;
        public String Value;
        private String[] IdentificationTypeID_type_info = new String[]{'IdentificationTypeID','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] Value_type_info = new String[]{'Value','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.adesa.com/cosmos','true','false'};
        private String[] field_order_type_info = new String[]{'IdentificationTypeID','Value'};
    }
    public class People {
        public String SalesforceContactID;
        public String CosmosPartyID;
        public String FirstName;
        public String MiddleInitial;
        public String LastName;
        public String Title;
        public String SuffixCode;
        public String RelationShipTypeID;
        public String RelationShipSubTypeID;
        public String IsCitizen;
        public Date DateOfBirth;
        public Date EndDate;
        public CosmosWebServices.AddressesType Addresses;
        public CosmosWebServices.CommunicationsType Communications;
        public CosmosWebServices.IdentificationNumbersType IdentificationNumbers;
        private String[] SalesforceContactID_type_info = new String[]{'SalesforceContactID','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] CosmosPartyID_type_info = new String[]{'CosmosPartyID','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] FirstName_type_info = new String[]{'FirstName','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] MiddleInitial_type_info = new String[]{'MiddleInitial','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] LastName_type_info = new String[]{'LastName','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] Title_type_info = new String[]{'Title','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] SuffixCode_type_info = new String[]{'SuffixCode','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] RelationShipTypeID_type_info = new String[]{'RelationShipTypeID','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] RelationShipSubTypeID_type_info = new String[]{'RelationShipSubTypeID','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] IsCitizen_type_info = new String[]{'IsCitizen','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] DateOfBirth_type_info = new String[]{'DateOfBirth','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] EndDate_type_info = new String[]{'EndDate','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] Addresses_type_info = new String[]{'Addresses','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] Communications_type_info = new String[]{'Communications','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] IdentificationNumbers_type_info = new String[]{'IdentificationNumbers','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.adesa.com/cosmos','true','false'};
        private String[] field_order_type_info = new String[]{'SalesforceContactID','CosmosPartyID','FirstName','MiddleInitial','LastName','Title','SuffixCode','RelationShipTypeID','RelationShipSubTypeID','IsCitizen','DateOfBirth','EndDate','Addresses','Communications','IdentificationNumbers'};
    }
    public class DealerAndContractSubmitRequestType {
        public CosmosWebServices.DealerAndContractType DealerAndContract;
        private String[] DealerAndContract_type_info = new String[]{'DealerAndContract','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.adesa.com/cosmos','true','false'};
        private String[] field_order_type_info = new String[]{'DealerAndContract'};
    }
    public class Person {
        public String FirstName;
        public String MiddleInitial;
        public String LastName;
        public String Title;
        public CosmosWebServices.Address Address;
        public String Phone;
        public String MobilePhone;
        public String Fax;
        public String EmailAddress;
        public String SuffixCD;
        private String[] FirstName_type_info = new String[]{'FirstName','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] MiddleInitial_type_info = new String[]{'MiddleInitial','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] LastName_type_info = new String[]{'LastName','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] Title_type_info = new String[]{'Title','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] Address_type_info = new String[]{'Address','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] Phone_type_info = new String[]{'Phone','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] MobilePhone_type_info = new String[]{'MobilePhone','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] Fax_type_info = new String[]{'Fax','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] EmailAddress_type_info = new String[]{'EmailAddress','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] SuffixCD_type_info = new String[]{'SuffixCD','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.adesa.com/cosmos','true','false'};
        private String[] field_order_type_info = new String[]{'FirstName','MiddleInitial','LastName','Title','Address','Phone','MobilePhone','Fax','EmailAddress','SuffixCD'};
    }
    public class MarketingAttributeType {
        public String High;
        public String Medium;
        public String Low;
        public String Primary;
        private String[] High_type_info = new String[]{'High','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] Medium_type_info = new String[]{'Medium','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] Low_type_info = new String[]{'Low','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] Primary_type_info = new String[]{'Primary','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.adesa.com/cosmos','true','false'};
        private String[] field_order_type_info = new String[]{'High','Medium','Low','Primary'};
    }
    public class Vehicle {
        public String VIN;
        public String Year;
        public String Make;
        public String Model;
        public String Color;
        public String StockNumber;
        public String TitleStatus;
        public String PurchaseLocation;
        private String[] VIN_type_info = new String[]{'VIN','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] Year_type_info = new String[]{'Year','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] Make_type_info = new String[]{'Make','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] Model_type_info = new String[]{'Model','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] Color_type_info = new String[]{'Color','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] StockNumber_type_info = new String[]{'StockNumber','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] TitleStatus_type_info = new String[]{'TitleStatus','http://schemas.adesa.com/cosmos',null,'1','1','false'};
        private String[] PurchaseLocation_type_info = new String[]{'PurchaseLocation','http://schemas.adesa.com/cosmos',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.adesa.com/cosmos','true','false'};
        private String[] field_order_type_info = new String[]{'VIN','Year','Make','Model','Color','StockNumber','TitleStatus','PurchaseLocation'};
    }
    public class MSP_UPA_SF_CSMOS_DEALERCONTRACTSOAP_HTTP_Port {
        public String endpoint_x = 'http://localhost:7800/MSP_UPA_SF_CSMOS_DEALERCONTRACTSOAP_HTTP_Service';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://schemas.adesa.com/cosmos', 'CosmosWebServices', 'http://ihub.adesa.com/dealercontract', 'CosmosWebServices'};
        public CosmosWebServices.DealerAndContractReadResponseType DealerAndContractSubmitRequest(CosmosWebServices.DealerAndContractType DealerAndContract) {
            CosmosWebServices.DealerAndContractSubmitRequestType request_x = new CosmosWebServices.DealerAndContractSubmitRequestType();
            request_x.DealerAndContract = DealerAndContract;
            CosmosWebServices.DealerAndContractReadResponseType response_x;
            Map<String, CosmosWebServices.DealerAndContractReadResponseType> response_map_x = new Map<String, CosmosWebServices.DealerAndContractReadResponseType>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://schemas.adesa.com/cosmos',
              'DealerAndContractSubmitRequest',
              'http://schemas.adesa.com/cosmos',
              'DealerAndContractReadResponse',
              'CosmosWebServices.DealerAndContractReadResponseType'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
}