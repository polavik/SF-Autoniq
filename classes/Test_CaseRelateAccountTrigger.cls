//---------------------------------------------------------------------------------------------
//US Story: 160435:Relate Case to Account
//Purpose: This Test class contains unit tests for validating the behavior of CaseRelateAccountTrigger
//Created by: John Britto (jbritto)
//---------------------------------------------------------------------------------------------

@isTest
Private class Test_CaseRelateAccountTrigger
{
	Public static testMethod void CaseRelateAccountTriggerMethod()
	{
		RecordType caseRecType = [select name, sobjectType
	                              from RecordType
	                              where sobjectType = 'case' 
	                              AND name = 'IAA Buyer Services'
	                              limit 1];
		//Insert Account
		// S-444999 T-567386
		Account accnt = new Account (name='TestAccount', Buyer_ID__c = '12345', BillingPostalCode ='90630');
		insert accnt;

		//Insert Case - Type=Contact us     S-444999 T-567386
		case cas = new case (Type='Contact Us',Status='New',Origin='Web', RecordTypeId = caseRecType.Id, First_Name__c='Test Buyerid',Last_Name__c='End Test',Buyer_ID_Contactus__c='1234590');

		//Insert Case - Type is other than Contact Us     S-444999 T-567386
		case cas1 = new case (Type='Not Contact Us',Status='New',Origin='Web', RecordTypeId = caseRecType.Id, First_Name__c='Not Contactus',Last_Name__c='End Not contact us',Buyer_ID_Contactus__c='1234590');

		//Insert Case with buyer id=0    S-444999 T-567386
		case cas2 = new case (Type='Contact Us',Status='New',Origin='Web', RecordTypeId = caseRecType.Id, First_Name__c='Contactus',Last_Name__c='End contact us',Buyer_ID_Contactus__c='0');

		try
		{
			//Test Date Execution
			test.starttest();
			insert cas;
			Insert cas1;
			insert cas2;
			test.stoptest();
		}
		catch(Exception e){
			system.debug ('Error Relating case to account records');
	   	}
	}
}