public with sharing class LeadServices {
	Private static Set<String> ListFLSCreate = new Set<String>();
    public static void insertAdditionalContacts(list<Lead> newLead)
    {		
        map<Id, Lead> leadMap= new map<Id, Lead>();
		
        for(Lead ld : newLead)
        {           
            if(ld.isConverted)
            {    
                leadMap.put(ld.Id, ld);
            }
        }
    
        if(leadMap.size() > 0)
        {               
            map<Id, Lead> leadToContactMap = new map<Id, Lead>();
            list<Contact> contactsToBeInserted = new list<Contact>();
            for(Lead ld : leadMap.values())
            {
            	if(String.isNotBlank(ld.ConvertedContactId))
            	{
            		leadToContactMap.put(ld.ConvertedContactId, ld);
            	}

                Contact g2 = leadServices.contactBuilder(ld.ConvertedAccountId,
                ld.Contact2_First_Name__c,
                ld.Contact2_Last_Name__c,
                ld.Contact2_Middle_Initial__c,
                ld.Contact2_Title__c,
                ld.Contact2_Email__c,
                ld.Contact2_Phone__c,
                ld.Contact2_Mobile_Phone__c,
                ld.Contact2_Fax__c,
                ld.Contact2_Address1__c,
                ld.Contact2_Address2__c,
                ld.Contact2_City__c,
                ld.Contact2_State_or_Province__c,
                ld.Contact2_Postal_Code__c,
                ld.Contact2_County__c,
                ld.Contact2_Country__c,
                ld.Contact2_Date_of_Birth__c,
                ld.Contact2_Driver_License_Number__c,
                ld.Contact2_Driver_License_State__c,
                ld.Contact2_Driver_License_Expiration__c,
                ld.Contact2_Own_or_Rent__c,
                ld.Contact2_Years_at_Location__c,
                ld.Contact2_Citizen__c,
                ld.Contact2_Federal_ID__c);
                if(g2.LastName != null)
                { 
                    contactsToBeInserted.add(g2);    
                }   
                    
                Contact g3 = leadServices.contactBuilder(ld.ConvertedAccountId,
                ld.Contact3_First_Name__c,
                ld.Contact3_Last_Name__c,
                ld.Contact3_Middle_Initial__c,
                ld.Contact3_Title__c,
                ld.Contact3_Email__c,
                ld.Contact3_Phone__c,
                ld.Contact3_Mobile_Phone__c,
                ld.Contact3_Fax__c,
                ld.Contact3_Address1__c,
                ld.Contact3_Address2__c,
                ld.Contact3_City__c,
                ld.Contact3_State_or_Province__c,
                ld.Contact3_Postal_Code__c,
                ld.Contact3_County__c,
                ld.Contact3_Country__c,
                ld.Contact3_Date_of_Birth__c,
                ld.Contact3_Driver_License_Number__c,
                ld.Contact3_Driver_License_State__c,
                ld.Contact3_Driver_License_Expiration__c,
                ld.Contact3_Own_or_Rent__c,
                ld.Contact3_Years_at_Location__c,
                ld.Contact3_Citizen__c,
                ld.Contact3_Federal_ID__c);
                if(g3.LastName != null)
                {
                    contactsToBeInserted.add(g3);    
                }    
                    
                Contact g4 = leadServices.contactBuilder(ld.ConvertedAccountId,
                ld.Contact4_First_Name__c,
                ld.Contact4_Last_Name__c,
                ld.Contact4_Middle_Initial__c,
                ld.Contact4_Title__c,
                ld.Contact4_Email__c,
                ld.Contact4_Phone__c,
                ld.Contact4_Mobile_Phone__c,
                ld.Contact4_Fax__c,
                ld.Contact4_Address1__c,
                ld.Contact4_Address2__c,
                ld.Contact4_City__c,
                ld.Contact4_State_or_Province__c,
                ld.Contact4_Postal_Code__c,
                ld.Contact4_County__c,
                ld.Contact4_Country__c,
                ld.Contact4_Date_of_Birth__c,
                ld.Contact4_Driver_s_License_Number__c,
                ld.Contact4_Driver_s_License_State__c,
                ld.Contact4_Driver_License_Expiration__c,
                ld.Contact4_Own_or_Rent__c,
                ld.Contact4_Years_at_Location__c,
                ld.Contact4_Citizen__c,
                ld.Contact4_Federal_ID__c);
                if(g4.LastName != null)
                {
                    contactsToBeInserted.add(g4);    
                }    
                    
                Contact g5 = leadServices.contactBuilder(ld.ConvertedAccountId,
                ld.Contact5_First_Name__c,
                ld.Contact5_Last_Name__c,
                ld.Contact5_Middle_Initial__c,
                ld.Contact5_Title__c,
                ld.Contact5_Email__c,
                ld.Contact5_Phone__c,
                ld.Contact5_Mobile_Phone__c,
                ld.Contact5_Fax__c,
                ld.Contact5_Address1__c,
                ld.Contact5_Address2__c,
                ld.Contact5_City__c,
                ld.Contact5_State_or_Province__c,
                ld.Contact5_Postal_Code__c,
                ld.Contact5_County__c,
                ld.Contact5_Country__c,
                ld.Contact5_Date_of_Birth__c,
                ld.Contact5_Driver_s_License_Number__c,
                ld.Contact5_Driver_s_License_State__c,
                ld.Contact5_Driver_s_License_Expiration__c,
                ld.Contact5_Own_or_Rent__c,
                ld.Contact5_Years_at_Location__c,
                ld.Contact5_Citizen__c,
                ld.Contact5_Federal_ID__c);
                if(g5.LastName != null)
                {
                    contactsToBeInserted.add(g5);
                }   

                Contact g6 = leadServices.contactBuilder(ld.ConvertedAccountId,
                ld.Contact6_First_Name__c,
                ld.Contact6_Last_Name__c,
                ld.Contact6_Middle_Initial__c,
                ld.Contact6_Title__c,
                ld.Contact6_Email__c,
                ld.Contact6_Phone__c,
                ld.Contact6_Mobile_Phone__c,
                ld.Contact6_Fax__c,
                ld.Contact6_Address1__c,
                ld.Contact6_Address2__c,
                ld.Contact6_City__c,
                ld.Contact6_State_or_Province__c,
                ld.Contact6_Postal_Code__c,
                ld.Contact6_County__c,
                ld.Contact6_Country__c,
                ld.Contact6_Date_of_Birth__c,
                ld.Contact6_Driver_s_License_Number__c,
                ld.Contact6_Driver_s_License_State__c,
                ld.Contact6_Driver_s_License_Expiration__c,
                ld.Contact6_Own_or_Rent__c,
                ld.Contact6_Years_at_Location__c,
                ld.Contact6_Citizen__c,
                ld.Contact6_Federal_ID__c);
                if(g6.LastName != null)
                { 
                    contactsToBeInserted.add(g6);    
                }   
                    
                Contact g7 = leadServices.contactBuilder(ld.ConvertedAccountId,
                ld.Contact7_First_Name__c,
                ld.Contact7_Last_Name__c,
                ld.Contact7_Middle_Initial__c,
                ld.Contact7_Title__c,
                ld.Contact7_Email__c,
                ld.Contact7_Phone__c,
                ld.Contact7_Mobile_Phone__c,
                ld.Contact7_Fax__c,
                ld.Contact7_Address1__c,
                ld.Contact7_Address2__c,
                ld.Contact7_City__c,
                ld.Contact7_State_or_Province__c,
                ld.Contact7_Postal_Code__c,
                ld.Contact7_County__c,
                ld.Contact7_Country__c,
                ld.Contact7_Date_of_Birth__c,
                ld.Contact7_Driver_s_License_Number__c,
                ld.Contact7_Driver_s_License_State__c,
                ld.Contact7_Driver_s_License_Expiration__c,
                ld.Contact7_Own_or_Rent__c,
                ld.Contact7_Years_at_Location__c,
                ld.Contact7_Citizen__c,
                ld.Contact7_Federal_ID__c);
                if(g7.LastName != null)
                {
                    contactsToBeInserted.add(g7);    
                }   

                Contact g8 = leadServices.contactBuilder(ld.ConvertedAccountId,
                ld.Contact8_First_Name__c,
                ld.Contact8_Last_Name__c,
                ld.Contact8_Middle_Initial__c,
                ld.Contact8_Title__c,
                ld.Contact8_Email__c,
                ld.Contact8_Phone__c,
                ld.Contact8_Mobile_Phone__c,
                ld.Contact8_Fax__c,
                ld.Contact8_Address_1__c,
                ld.Contact8_Address_2__c,
                ld.Contact8_City__c,
                ld.Contact8_State_or_Province__c,
                ld.Contact8_Postal_Code__c,
                ld.Contact8_County__c,
                ld.Contact8_Country__c,
                ld.Contact8_Date_of_Birth__c,
                ld.Contact8_Drivers_License_Number__c,
                ld.Contact8_Drivers_License_State__c,
                ld.Contact8_Drivers_License_Expiration_Date__c,
                ld.Contact8_Own_or_Rent__c,
                ld.Contact8_Years_at_Location__c,
                ld.Contact8_Citizen__c,
                ld.Contact8_Federal_ID__c);
                    
                if(g8.LastName != null)
                {
                    contactsToBeInserted.add(g8);    
                }       
            }
			if(ListFLSCreate.size()>0)
			{
				Utils.SendEmailforFLS('FLS_CREATE','CLASS:LeadServices', ListFLSCreate);
			}
			else
			{
				ContactServices.updateConvertedContactsFromLeads(leadToContactMap);
				insert contactsToBeInserted;
			}
        }
    }
    
    private static Contact contactBuilder(string accId, string fName, string lName, string mName, string title, 
        string email, string phone, string mobilePhone, string fax, 
        string street1, string street2, string city, string state, string postalCode, string county, string country, 
        date dob, string driverLicenseNumber, string driverLicenseState, date driverLicenseExp,
        string ownOrRent, decimal yearsAtLoc, string citizen, string federalId)
    {
		Boolean blnFLSOverride = Utils.GetFLS();
        Contact toReturn = new Contact();
		
		//Story B-44003 : FLS CREATE ACCESS CHECK
		if (Schema.sObjectType.Contact.fields.AccountId.isCreateable() || blnFLSOverride)
		{
			toReturn.AccountId                              = accId;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.AccountId.getName());
		}
		if (Schema.sObjectType.Contact.fields.FirstName.isCreateable() || blnFLSOverride)
		{
			toReturn.FirstName                              = fName;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.FirstName.getName());
		}
		if (Schema.sObjectType.Contact.fields.LastName.isCreateable() || blnFLSOverride)
		{
			toReturn.LastName                               = lName;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.LastName.getName());
		}
		if (Schema.sObjectType.Contact.fields.Middle_Name__c.isCreateable() || blnFLSOverride)
		{
			toReturn.Middle_Name__c                         = mName;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.Middle_Name__c.getName());
		}
		if (Schema.sObjectType.Contact.fields.Title.isCreateable() || blnFLSOverride)
		{
			toReturn.Title                                  = title;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.Title.getName());
		}
		if (Schema.sObjectType.Contact.fields.Email.isCreateable() || blnFLSOverride)
		{
			toReturn.Email                                  = email;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.Email.getName());
		}
		if (Schema.sObjectType.Contact.fields.Phone.isCreateable() || blnFLSOverride)
		{
			toReturn.Phone                                  = phone;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.Phone.getName());
		}
		if (Schema.sObjectType.Contact.fields.MobilePhone.isCreateable() || blnFLSOverride)
		{
			toReturn.MobilePhone                            = mobilePhone;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.MobilePhone.getName());
		}
		if (Schema.sObjectType.Contact.fields.Fax.isCreateable() || blnFLSOverride)
		{
			toReturn.Fax                                    = fax;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.Fax.getName());
		}
		if (Schema.sObjectType.Contact.fields.AFC_Primary_Street__c.isCreateable() || blnFLSOverride)
		{
			toReturn.AFC_Primary_Street__c                  = street1;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.AFC_Primary_Street__c.getName());
		}
		if (Schema.sObjectType.Contact.fields.AFC_Primary_Street2__c.isCreateable() || blnFLSOverride)
		{
			toReturn.AFC_Primary_Street2__c                 = street2;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.AFC_Primary_Street2__c.getName());
		}
		if (Schema.sObjectType.Contact.fields.AFC_Primary_City__c.isCreateable() || blnFLSOverride)
		{
			toReturn.AFC_Primary_City__c                    = city;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.AFC_Primary_City__c.getName());
		}
		if (Schema.sObjectType.Contact.fields.AFC_Primary_State__c.isCreateable() || blnFLSOverride)
		{
			toReturn.AFC_Primary_State__c                   = state;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.AFC_Primary_State__c.getName());
		}
		if (Schema.sObjectType.Contact.fields.AFC_Primary_Postalcode__c.isCreateable() || blnFLSOverride)
		{
			toReturn.AFC_Primary_Postalcode__c              = postalCode;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.AFC_Primary_Postalcode__c.getName());
		}
		if (Schema.sObjectType.Contact.fields.AFC_Primary_County__c.isCreateable() || blnFLSOverride)
		{
			toReturn.AFC_Primary_County__c                  = county;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.AFC_Primary_County__c.getName());
		}
		if (Schema.sObjectType.Contact.fields.AFC_Primary_Country__c.isCreateable() || blnFLSOverride)
		{
			toReturn.AFC_Primary_Country__c                 = country;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.AFC_Primary_Country__c.getName());
		}
		if (Schema.sObjectType.Contact.fields.Birthdate.isCreateable() || blnFLSOverride)
		{
			toReturn.Birthdate                              = dob;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.Birthdate.getName());
		}
		if (Schema.sObjectType.Contact.fields.Driver_s_License__c.isCreateable() || blnFLSOverride)
		{
			toReturn.Driver_s_License__c                    = driverLicenseNumber;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.Driver_s_License__c.getName());
		}
		if (Schema.sObjectType.Contact.fields.Driver_s_Lic_State_Province__c.isCreateable() || blnFLSOverride)
		{
			toReturn.Driver_s_Lic_State_Province__c         = driverLicenseState;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.Driver_s_Lic_State_Province__c.getName());
		}
		if (Schema.sObjectType.Contact.fields.Driver_s_License_Expiration_Date__c.isCreateable() || blnFLSOverride)
		{
			toReturn.Driver_s_License_Expiration_Date__c    = driverLicenseExp;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.Driver_s_License_Expiration_Date__c.getName());
		}
		if (Schema.sObjectType.Contact.fields.Type_of_Home_Ownership__c.isCreateable() || blnFLSOverride)
		{
			toReturn.Type_of_Home_Ownership__c              = ownOrRent;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.Type_of_Home_Ownership__c.getName());
		}
		if (Schema.sObjectType.Contact.fields.Years_There__c.isCreateable() || blnFLSOverride)
		{
			toReturn.Years_There__c                         = yearsAtLoc;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.Years_There__c.getName());
		}
		if (Schema.sObjectType.Contact.fields.SSN__c.isCreateable() || blnFLSOverride)
		{
			toReturn.SSN__c                                 = federalId;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.SSN__c.getName());
		}
        
        if (Schema.sObjectType.Contact.fields.Citizen__c.isCreateable() || blnFLSOverride)
		{
			if(citizen == 'Y')
			{
				toReturn.Citizen__c                             = false;
			}
			else
			{
				toReturn.Citizen__c                             = true;
			}
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.Citizen__c.getName());
		}
        return toReturn;
    }
}