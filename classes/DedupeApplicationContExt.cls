/*
Original Author: ?
Editor: Pike Pullen
Date: 10/30/2013
Description: There is currently no way to write a test method that directly tests the addfields method for standardController, added workaround (L.36)
*/
public with sharing class DedupeApplicationContExt
{
    public DedupeApplicationContExt(ApexPages.StandardController stdCont)
    { 
    	//Add child record fields to be queried by standard controller
    	String [] childRecordFields = new String[]{};
    	//Account fields
        childRecordFields.add('Application_Account_Roles__r.Account__r.Name');
        childRecordFields.add('Application_Account_Roles__r.Account__r.Dba__c');
        childRecordFields.add('Application_Account_Roles__r.Account__r.Legal_Name__c');
    	childRecordFields.add('Application_Account_Roles__r.Account__r.Primary_City__c');
    	childRecordFields.add('Application_Account_Roles__r.Account__r.Primary_Postalcode__c');
    	childRecordFields.add('Application_Account_Roles__r.Account__r.Primary_State__c');
    	childRecordFields.add('Application_Account_Roles__r.Account__r.Primary_Street1__c');
    	childRecordFields.add('Application_Account_Roles__r.Account__r.Primary_Street2__c');
    	childRecordFields.add('Application_Account_Roles__r.Account__r.Corrected_P_City__c');
    	childRecordFields.add('Application_Account_Roles__r.Account__r.Corrected_P_Postalcode__c');
    	childRecordFields.add('Application_Account_Roles__r.Account__r.Corrected_P_State__c');
    	childRecordFields.add('Application_Account_Roles__r.Account__r.Corrected_P_Street__c');
    	childRecordFields.add('Application_Account_Roles__r.Account__r.Tax_Identification_Number__c');
        childRecordFields.add('Application_Account_Roles__r.Account__r.Dealer_License_Number__c');
        childRecordFields.add('Application_Account_Roles__r.TIN__c');
        childRecordFields.add('Application_Account_Roles__r.Dealer_License_Number__c');
    	//Contact fields
    	childRecordFields.add('Application_Contact_Roles__r.Contact__r.Name');
    	childRecordFields.add('Application_Contact_Roles__r.Contact__r.FirstName');
    	childRecordFields.add('Application_Contact_Roles__r.Contact__r.LastName');
    	childRecordFields.add('Application_Contact_Roles__r.Contact__r.SSN__c');
    	childRecordFields.add('Application_Contact_Roles__r.Contact__r.AFC_Primary_City__c');
    	childRecordFields.add('Application_Contact_Roles__r.Contact__r.AFC_Primary_Postalcode__c');
    	childRecordFields.add('Application_Contact_Roles__r.Contact__r.AFC_Primary_State__c');
    	childRecordFields.add('Application_Contact_Roles__r.Contact__r.AFC_Primary_Street__c');
    	childRecordFields.add('Application_Contact_Roles__r.Contact__r.AFC_Primary_Street2__c');
    	if (!Test.isRunningTest()) 
		{ 
			stdCont.addFields(childRecordFields);
		}
    	//stdCont.addFields(childRecordFields);
    	ApplicationModel app = new ApplicationModel((Application__c)stdCont.getRecord());
    	matchingAccountsMap = CosmosDedupeDataServices.findDupeCosmosAccountData(app);
    	matchingContactsMap = CosmosDedupeDataServices.findDupeCosmosContactData(app);
    	accountsToDisplayMap = new Map<Account, Boolean>();
    	contactsToDisplayMap = new Map<Contact, Boolean>();
    	checkEmptyResultsAndSetDisplay();
    }
    public Map<Account, Cosmos_Dedupe_Data__c[]> matchingAccountsMap {get; private set;}
    public Map<Contact, Cosmos_Dedupe_Data__c[]> matchingContactsMap {get; private set;}
    public Map<Account, Boolean> accountsToDisplayMap {get; private set;}
    public Map<Contact, Boolean> contactsToDisplayMap {get; private set;}
    public void checkEmptyResultsAndSetDisplay()
    {
    	for(Account a : matchingAccountsMap.keySet())
    	{ 
    		if(matchingAccountsMap.get(a).size() == 0) 
    		{
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, system.label.No_Account_Found + ': ' + a.Name));
    			accountsToDisplayMap.put(a, false);
    		}
    		else
    		{
    			accountsToDisplayMap.put(a, true);
    		}
    	}
    	for(Contact c : matchingContactsMap.keySet())
    	{
    		if(matchingContactsMap.get(c).size() == 0)
    		{
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, system.label.No_Contact_Found + ': ' + c.Name));
    			contactsToDisplayMap.put(c, false);
    		}
    		else
    		{
    			contactsToDisplayMap.put(c, true);
    		}
    	}
    }
}