@RestResource(urlMapping='/autoniq/myaccount/updateGeneral')
global class AutoniqMyAccountGeneralService {
	/*
		Description : Inbound web service for updating 'Autoniq Account' and 'User Applilcation Setting' from the given unique 'contact' in request body 
	*/
	@HttpPost global static string updateGeneral () {
		RestRequest req = RestContext.request;
        string AccountInfoStr = req.requestBody.toString().trim();
        AutoniqMyAccountUpdateGeneralRequest AccountInfo = (AutoniqMyAccountUpdateGeneralRequest) json.deserialize(AccountInfoStr,AutoniqMyAccountUpdateGeneralRequest.class);
        // Quering contact and its related 'Autoniq Account' and 'User Applilcation Setting'
		list<Contact> contactList = [ SELECT Autoniq_Account__c,
								(SELECT Home_region_zip_code__c, Mobile_Device_Type__c, Vehicle_Selector_Style__c, Valuation_region__c,
								Default_Black_Book__c, Default_Kelley_Blue_Book__c, Default_NADA__c FROM Autoniq_User_Applilcation_Settings__r) 
								FROM Contact WHERE id = :AccountInfo.contactId];
		if(!contactList.isEmpty()){
			Contact con = contactList[0];
			// Quering 'Autoniq Account' record and updating with requested information from the callout
			list<Autoniq_Account__c> accList = [SELECT Street__c, City__c, Country__c, 
								PostalCode__c, State__c, Email__c, Phone__c FROM Autoniq_Account__c WHERE id = :con.Autoniq_Account__c];
			if(!accList.isEmpty()){
				Autoniq_Account__c acc = accList[0];
				acc.Street__c = AccountInfo.address;
				acc.City__c = AccountInfo.city;
				//acc.Country__c = AccountInfo.address;
				acc.PostalCode__c = AccountInfo.postalCode;
				acc.State__c = AccountInfo.state;
				acc.Email__c = AccountInfo.email;
				acc.Phone__c = AccountInfo.phone;
				update acc;
			}
			// Fetching 'User Applilcation Setting' record for the contact and updating with requested information from the callout
			if(!con.Autoniq_User_Applilcation_Settings__r.isEmpty()){
				Autoniq_User_Applilcation_Setting__c userAppSetting = con.Autoniq_User_Applilcation_Settings__r[0];
				userAppSetting.Home_region_zip_code__c = AccountInfo.homeRegionZipCode;
				userAppSetting.Mobile_Device_Type__c = AccountInfo.deviceType;
				userAppSetting.Vehicle_Selector_Style__c = AccountInfo.menuStyle;
				userAppSetting.Valuation_region__c = AccountInfo.homeRegionSelected;
				userAppSetting.Default_Kelley_Blue_Book__c = AccountInfo.peKBBTable;
				userAppSetting.Default_Black_Book__c = AccountInfo.peBBTable;
				userAppSetting.Default_NADA__c = AccountInfo.peNADATable;
				update userAppSetting;
			}
		}
		return 'success';
	}
}