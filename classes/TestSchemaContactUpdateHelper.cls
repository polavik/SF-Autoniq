@isTest
private class TestSchemaContactUpdateHelper {
	static testMethod void setContactParams(){
    	Contact ctc = new Contact(
    		Party_Id__c='123456789',
    		FirstName='Test',
    		Middle_Name__c='TestM',
    		LastName = 'LastT',
    		Suffix__c='JR.',
    		Bankruptcy_Indicator__c=FALSE,
    		Citizen__c=TRUE,
    		BirthDate=Date.today(),
    		AFC_Primary_Street__c='Test Street',
    		AFC_Primary_City__c='NYC',
    		AFC_Primary_State__c='NY',
    		AFC_Primary_Postalcode__c='12345',
    		AFC_Primary_Country__c='US',
    		Type_of_Home_Ownership__c='Own',
    		Years_There__c=10,
    		SSN__c='123456789',
    		Phone='123-456-7890');

    	Test.startTest();
    		SchemaContactUpdate.ContactUpdateType contactHelper = SchemaContactUpdateHelper.setContactParams(ctc);
    	Test.stopTest();

    	System.assertEquals(ctc.Party_Id__c, contactHelper.CosmosPartyID, 'The fields should be set correctly');
    	System.assertEquals(ctc.FirstName, contactHelper.FirstName, 'The fields should be set correctly');
    	System.assertEquals(ctc.Middle_Name__c, contactHelper.MiddleInitial, 'The fields should be set correctly');
    	System.assertEquals(ctc.LastName, contactHelper.LastName, 'The fields should be set correctly');
    	System.assertEquals(ctc.Suffix__c, contactHelper.SuffixCode, 'The fields should be set correctly');
    	System.assertEquals(SchemaContactUpdateHelper.FALSE_STRING, contactHelper.BankruptcyIndicator, 'The fields should be set correctly');
    	System.assertEquals(SchemaContactUpdateHelper.FALSE_STRING, contactHelper.IsCitizen, 'The fields should be set correctly');
    	System.assertEquals(ctc.BirthDate, contactHelper.DateOfBirth, 'The fields should be set correctly');
    	System.assertEquals(ctc.AFC_Primary_Street__c, contactHelper.Addresses.Address1, 'The fields should be set correctly');
    	System.assertEquals(ctc.AFC_Primary_City__c, contactHelper.Addresses.City, 'The fields should be set correctly');
    	System.assertEquals(ctc.AFC_Primary_Postalcode__c, contactHelper.Addresses.PostalCode, 'The fields should be set correctly');
    	System.assertEquals(ctc.AFC_Primary_Country__c, contactHelper.Addresses.Country, 'The fields should be set correctly');
    	System.assertEquals(ctc.AFC_Primary_State__c, contactHelper.Addresses.StateOrProvince, 'The fields should be set correctly');
    	System.assertEquals(ctc.Type_of_Home_Ownership__c, contactHelper.Addresses.OwnOrRent, 'The fields should be set correctly');
    	System.assertEquals(String.valueOf(ctc.Years_There__c), contactHelper.Addresses.YearsAtCurrentLocation, 'The fields should be set correctly');
    	System.assertEquals(ctc.SSN__c, contactHelper.IdentificationNumbers.IdentificationNumber[0].Value, 'The fields should be set correctly');
    	System.assertEquals(SchemaContactUpdateHelper.SSN_TOKEN, contactHelper.IdentificationNumbers.IdentificationNumber[0].IdentificationTypeID, 'The fields should be set correctly');
    	System.assertEquals(ctc.Phone.replaceAll('[^0-9]',''), contactHelper.Communications.Communication[0].Value, 'The fields should be set correctly');
    }
}