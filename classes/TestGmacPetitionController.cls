@isTest
private class TestGmacPetitionController 
{
	static testMethod void myUnitTest() 
	{
		GmacPetitionController con = new GmacPetitionController();
		con.submit();
		con.petition.Contact_Person_Phone_or_Email__c = 'a';
		con.petition.Contact_Person_Title__c = 'a';
		con.petition.Dealership_Address__c = 'a';
		con.petition.Dealership_Name__c = 'a';
		con.petition.Would_Purchase_More__c = 'YES'; 
		con.submit();
			
	}
}