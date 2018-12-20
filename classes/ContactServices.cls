public with sharing class ContactServices
{
    public static void updateContactsPartyIds(Application_Contact_Role__c[] acrs, CosmosWebServices.PartyIDType[] partyIDs)
    {
    	if(acrs == null || acrs.isEmpty() || partyIDs == null || partyIDs.isEmpty())
    	{
    		throw new CustomExceptions.ApplicationException('Neither the Contact list nor the Source ID list can be blank when trying to update Contacts\' Party ID fields!');
    	}
    	Map<Id, String> contactIdToPartyIdMap = new Map<Id, String>();
    	for(CosmosWebServices.PartyIDType partyId : partyIDs)
    	{
    		contactIdToPartyIdMap.put(partyId.SalesforceContactID, partyId.CosmosPartyID);
    	}
    	Contact[] contactsToUpdate = new Contact[]{};
		Set<String> ListFLSUpdate = new Set<String>();
		Boolean blnFLSOverride = Utils.GetFLS();
    	for(Id contactID : contactIdToPartyIdMap.keySet())
    	{
    		Contact c = new Contact(Id = contactID);
			
			 //Story B-44003 : FLS UPDATE ACCESS CHECK
			 if (Schema.sObjectType.Contact.fields.Party_Id__c.isUpdateable() || blnFLSOverride)
			 {						 
				c.Party_Id__c = contactIdToPartyIdMap.get(contactID);
			 }
			 else
			 {						
				ListFLSUpdate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.Party_Id__c.getName());
			 }
    		contactsToUpdate.add(c);
    	}
    	update contactsToUpdate;
		if(ListFLSUpdate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_UPDATE','CLASS:ContactServices', ListFLSUpdate);
		}
    }
    public static void updateConvertedContactsFromLeads(Map<Id, Lead> leadToContactMap)
    {
    	Contact[] contactsTobeUpdated = [select Id from Contact where Id in :leadToContactMap.keySet()];
    	for(Contact c : contactsTobeUpdated)
    	{
            c.Middle_Name__c = leadToContactMap.get(c.Id).Contact1_Middle_Initial__c;
            c.Phone = leadToContactMap.get(c.Id).Contact1_Phone__c;
            c.MobilePhone = leadToContactMap.get(c.Id).MobilePhone;
            c.Fax = leadToContactMap.get(c.Id).Contact1_Fax__c;
            c.AFC_Primary_Street__c = leadToContactMap.get(c.Id).Contact1_Address1__c;
            c.AFC_Primary_Street2__c = leadToContactMap.get(c.Id).Contact1_Address2__c;
            c.AFC_Primary_City__c = leadToContactMap.get(c.Id).Contact1_City__c;
            c.AFC_Primary_State__c = leadToContactMap.get(c.Id).Contact1_State_or_Province__c;
            c.AFC_Primary_Postalcode__c = leadToContactMap.get(c.Id).Contact1_Postal_Code__c;
            c.AFC_Primary_County__c = leadToContactMap.get(c.Id).Contact1_County__c;
            c.AFC_Primary_Country__c = leadToContactMap.get(c.Id).Contact1_Country__c;
            c.Birthdate = leadToContactMap.get(c.Id).Contact1_Date_of_Birth__c;
            c.Driver_s_License__c = leadToContactMap.get(c.Id).Contact1_Driver_s_License_Number__c;
            c.Driver_s_Lic_State_Province__c = leadToContactMap.get(c.Id).Contact1_Driver_s_License_State__c;
            c.Driver_s_License_Expiration_Date__c = leadToContactMap.get(c.Id).Contact1_Drivers_License_Expiration__c;
            c.Type_of_Home_Ownership__c = leadToContactMap.get(c.Id).Contact1_Own_or_Rent__c;
            c.Years_There__c = leadToContactMap.get(c.Id).Contact1_Years_at_Location__c;
            c.Citizen__c = leadToContactMap.get(c.Id).Contact1_Citizen__c == 'Y' ? false : true;
            c.SSN__c = leadToContactMap.get(c.Id).Contact1_Federal_ID__c;
    	}
    	update contactsTobeUpdated;
    }

    public static void checkForCosmosSync(Map<Id, Contact> triggerOldMap, List<Contact> triggerNew){
        for(Contact newCtc : triggerNew){
            if(newCtc.Party_Id__c !=null){
                for(String field : cosmosSyncFieldSet){
                    Contact oldCtc = triggerOldMap.get(newCtc.Id);
                    if(oldCtc.get(field) != newCtc.get(field)){
                        newCtc.Cosmos_Sync_Pending__c = true;
                        break;
                    }
                }
            }
        }
    }

    @testVisible static List<String> cosmosSyncFieldSet{
        get{
            if(cosmosSyncFieldSet == null){
                cosmosSyncFieldSet = new List<String>();
                for(Schema.FieldSetMember field : SObjectType.Contact.FieldSets.CosmosSyncFields.getFields()){
                    cosmosSyncFieldSet.add(field.getFieldPath());
                }
            }
            return cosmosSyncFieldSet;
        }
        set;
    }
}