/*
Author: Pike Pullen
Date: 10/30/2013
Description: Unit Test Coverage for assorted Classes
*/

@isTest
private class TestCosmosWebServices 
{
    static testMethod void runCosmosWebServices() 
    {
		CosmosWebServices test 												= new CosmosWebServices();
		CosmosWebServices.Branch t1 										= new CosmosWebServices.Branch();
		CosmosWebServices.ContractType t2									= new CosmosWebServices.ContractType();
		CosmosWebServices.Communication t3									= new CosmosWebServices.Communication();
		CosmosWebServices.IdentificationNumbersType t4						= new CosmosWebServices.IdentificationNumbersType();
		CosmosWebServices.DealerAndContractType t5							= new CosmosWebServices.DealerAndContractType();
		CosmosWebServices.AddressesType t6 									= new CosmosWebServices.AddressesType();
		CosmosWebServices.ServiceError t7                                   = new CosmosWebServices.ServiceError();
		CosmosWebServices.DealerAndContractReadResponseType t8				= new CosmosWebServices.DealerAndContractReadResponseType();
		CosmosWebServices.PartyIDType t9									= new CosmosWebServices.PartyIDType();
		CosmosWebServices.Vehicle t10										= new CosmosWebServices.Vehicle();
		CosmosWebServices.ServiceResponse t11								= new CosmosWebServices.ServiceResponse();
		CosmosWebServices.DealerRelatedPartiesType t12 						= new CosmosWebServices.DealerRelatedPartiesType();
		CosmosWebServices.Contact t13										= new CosmosWebServices.Contact();
		CosmosWebServices.CommunicationsType t14	 						= new CosmosWebServices.CommunicationsType();
		CosmosWebServices.DealerRelatedPartiesIDType t15 					= new CosmosWebServices.DealerRelatedPartiesIDType();
		CosmosWebServices.Geocode t18										= new CosmosWebServices.Geocode();
		CosmosWebServices.MSP_UPA_SF_CSMOS_DEALERCONTRACTSOAP_HTTP_Port t19 = new CosmosWebServices.MSP_UPA_SF_CSMOS_DEALERCONTRACTSOAP_HTTP_Port();
		CosmosWebServices.Address t20										= new CosmosWebServices.Address();
		CosmosWebServices.Dealership t21									= new CosmosWebServices.Dealership();
		CosmosWebServices.IdentificationNumber t22							= new CosmosWebServices.IdentificationNumber();
		CosmosWebServices.People t23										= new CosmosWebServices.People();
		CosmosWebServices.DealerAndContractSubmitRequestType t24			= new CosmosWebServices.DealerAndContractSubmitRequestType();
		CosmosWebServices.Person t25										= new CosmosWebServices.Person();
    }
}