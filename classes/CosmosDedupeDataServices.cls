/*
Original Author: ?
Editor: Pike Pullen
Date: 10/30/2013
Description: Added null check on line 35 for unit testing protection
*/
public with sharing class CosmosDedupeDataServices
{
	public static Map<Account, Cosmos_Dedupe_Data__c[]> findDupeCosmosAccountData(ApplicationModel app)
	{
		if(app == null)
		{
			return new Map<Account, Cosmos_Dedupe_Data__c[]>();
		}
		else
		{
			Map<Account, Cosmos_Dedupe_Data__c[]> matchingResultsMap = new Map<Account, Cosmos_Dedupe_Data__c[]>();
			if(app.accounts != null && !app.accounts.isEmpty())
			{
				for(Application_Account_Role__c aar : app.accounts)
				{
                    String accountName = '%' + aar.Account__r.Name + '%';
                    String dbaName = '%' + aar.Account__r.Dba__c + '%';
                    String legalName = '%' + aar.Account__r.Legal_Name__c + '%';
					String dealerFedId1 = aar.Account__r.Tax_Identification_Number__c;
					String dealerFedId2 = aar.TIN__c;
					String dealerLicenseNum = aar.Account__r.Dealer_License_Number__c;
					String street1 = aar.Account__r.Primary_Street1__c;
					String street2 = aar.Account__r.Primary_Street2__c;
					String city = aar.Account__r.Primary_City__c;
					String state = aar.Account__r.Primary_State__c;
					String postalCode = aar.Account__r.Primary_Postalcode__c;
					String corStreet1 = aar.Account__r.Corrected_P_Street__c;
					String corCity = aar.Account__r.Corrected_P_City__c;
					String corState = aar.Account__r.Corrected_P_State__c;
					String corPostalCode = aar.Account__r.Corrected_P_Postalcode__c;
					Cosmos_Dedupe_Data__c[] matchingResults = new Cosmos_Dedupe_Data__c[]{};
					if(aar.Account__r != null)
					{
						for(Cosmos_Dedupe_Data__c cdd : Database.query(getAccountQuery(aar)))
						{
							matchingResults.add(cdd);
						}
					}
					matchingResultsMap.put(aar.Account__r, matchingResults);
				}
			}
			return matchingResultsMap;
		}
	}
	private static String getAccountQuery(Application_Account_Role__c aar)
	{
		string soqlQuery = 'select Street_1__c, ';
		soqlQuery += 'State__c, ';
		soqlQuery += 'SSN_SIN__c, ';
		soqlQuery += 'Postal_Code__c, ';
		soqlQuery += 'Guarantor_Last_Name__c, ';
		soqlQuery += 'Guarantor_First_Name__c, ';
		soqlQuery += 'Dealership_Federal_ID__c, ';
        soqlQuery += 'Dealer_License_Number__c, ';
        soqlQuery += 'Dealership_DBA_Name__c, ';
        soqlQuery += 'Dealership_Entity_Name__c, ';
        soqlQuery += 'Dealer_Id__c, ';
        soqlQuery += 'Contract_Id__c, ';
        soqlQuery += 'Application_Id__c, ';
		soqlQuery += 'City__c ';
		soqlQuery += 'from Cosmos_Dedupe_Data__c ';
		soqlQuery += 'where Dealership_Entity_Name__c like :accountName ';

        if(String.isNotBlank(aar.Account__r.Dba__c))
            soqlQuery += 'or Dealership_DBA_Name__c like :dbaName ';
        if(String.isNotBlank(aar.Account__r.Legal_Name__c))
            soqlQuery += 'or Dealership_Entity_Name__c like :legalName ';
        if(String.isNotBlank(aar.Account__r.Tax_Identification_Number__c))
            soqlQuery += 'or Dealership_Federal_ID__c = :dealerFedId1 ';
		if(aar.TIN__c != null)
			soqlQuery += 'or Dealership_Federal_ID__c = :dealerFedId2 ';
		if(String.isNotBlank(aar.Account__r.Dealer_License_Number__c))
			soqlQuery += 'or Dealer_License_Number__c = :dealerLicenseNum ';
		if(String.isNotBlank(aar.Account__r.Primary_Street1__c)
				|| String.isNotBlank(aar.Account__r.Primary_Street2__c)
				|| String.isNotBlank(aar.Account__r.Primary_City__c)
				|| String.isNotBlank(aar.Account__r.Primary_State__c)
				|| String.isNotBlank(aar.Account__r.Primary_Postalcode__c))
		{
			soqlQuery += 'or (Street_1__c = :street1 ';
			soqlQuery += 'and City__c = :city ';
			soqlQuery += 'and State__c = :state ';
			soqlQuery += 'and Postal_Code__c = :postalCode) ';
		}
		if(String.isNotBlank(aar.Account__r.Corrected_P_Street__c)
				|| String.isNotBlank(aar.Account__r.Corrected_P_City__c)
				|| String.isNotBlank(aar.Account__r.Corrected_P_State__c)
				|| String.isNotBlank(aar.Account__r.Corrected_P_Postalcode__c))
		{
			soqlQuery += 'or (Street_1__c = :corStreet1 ';
			soqlQuery += 'and City__c = :corCity ';
			soqlQuery += 'and State__c = :corState ';
			soqlQuery += 'and Postal_Code__c = :corPostalCode)';
		}

		return soqlQuery;
	}
	public static Map<Contact, Cosmos_Dedupe_Data__c[]> findDupeCosmosContactData(ApplicationModel app)
	{
		if(app == null)
		{
			return new Map<Contact, Cosmos_Dedupe_Data__c[]>();
		}
		else
		{
			Map<Contact, Cosmos_Dedupe_Data__c[]> matchingResultsMap = new Map<Contact, Cosmos_Dedupe_Data__c[]>();
			if(app.contacts != null && !app.contacts.isEmpty())
			{
				for(Application_Contact_Role__c acr : app.contacts)
				{
					String lastName = acr.Contact__r.LastName;
					String firstName = acr.Contact__r.FirstName;
					String ssn = acr.Contact__r.SSN__c;
					String street1 = acr.Contact__r.AFC_Primary_Street__c;
					String street2 = acr.Contact__r.AFC_Primary_Street2__c;
					String city = acr.Contact__r.AFC_Primary_City__c;
					String state = acr.Contact__r.AFC_Primary_State__c;
					String postalCode = acr.Contact__r.AFC_Primary_Postalcode__c;
					Cosmos_Dedupe_Data__c[] matchingResults = new Cosmos_Dedupe_Data__c[]{};
					if(acr.Contact__r != null)
					{
						for(Cosmos_Dedupe_Data__c cdd : Database.query(getContactQuery(acr.Contact__r)))
						{
							matchingResults.add(cdd);
						}
					}
					matchingResultsMap.put(acr.Contact__r, matchingResults);
				}
			}
			return matchingResultsMap;
		}
	}
	private static String getContactQuery(Contact c)
	{
		string soqlQuery = 'select Person_Street__c, ';
		soqlQuery += 'Person_State__c, ';
		soqlQuery += 'SSN_SIN__c, ';
		soqlQuery += 'Person_Postal_Code__c, ';
		soqlQuery += 'Guarantor_Last_Name__c, ';
		soqlQuery += 'Guarantor_First_Name__c, ';
		soqlQuery += 'Person_Party_Id__c, ';
		soqlQuery += 'Person_City__c ';
		soqlQuery += 'from Cosmos_Dedupe_Data__c ';
		if(String.isEmpty(c.FirstName))
			soqlQuery += 'where Guarantor_Last_Name__c = :lastName ';
		else
			soqlQuery += 'where (Guarantor_Last_Name__c = :lastName and Guarantor_First_Name__c = :firstName) ';
		if(String.isNotBlank(c.SSN__c))
			soqlQuery += 'or SSN_SIN__c = :ssn ';
		if(c.AFC_Primary_Street__c != null
				|| c.AFC_Primary_Street2__c != null
				|| c.AFC_Primary_City__c != null
				|| c.AFC_Primary_State__c != null
				|| c.AFC_Primary_Postalcode__c != null)
		{
			soqlQuery += 'or (Person_Street__c = :street1 ';
			soqlQuery += 'and Person_City__c = :city ';
			soqlQuery += 'and Person_State__c = :state ';
			soqlQuery += 'and Person_Postal_Code__c = :postalCode) ';
		}
		return soqlQuery;
	}
}